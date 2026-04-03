import cv2
import numpy as np
import math

# --- PARAMETERS ---
input_image = "snapshot0.png"
output_image = "snapshot_home_back_debug.png"

canny_low = 50
canny_high = 150

min_line_length = 50
max_line_gap = 10

angle_tolerance = 8.0   # more forgiving
start_finish_point = (325, 325)

# --- HELPERS ---

def angle_diff(a, b):
    d = abs(a - b) % 360
    return min(d, 360 - d)

def normalize_angle(dx, dy):
    angle = math.degrees(math.atan2(dy, dx))
    return angle % 180  # critical fix

def line_length(x1, y1, x2, y2):
    return math.hypot(x2 - x1, y2 - y1)

def line_tip_distance(line, ref_point):
    x1, y1, x2, y2, _, _ = line
    p1 = np.array([x1, y1])
    p2 = np.array([x2, y2])
    ref = np.array(ref_point)
    return min(np.linalg.norm(p1 - ref), np.linalg.norm(p2 - ref))

def compute_bearing(x1, y1, x2, y2):
    dx = x2 - x1
    dy = y1 - y2   # flip Y axis (image → math coords)

    angle = math.degrees(math.atan2(dx, dy))  # swapped!
    bearing = (angle + 360) % 360

    return bearing

def line_direction_from_sf(line, ref_point):
    x1, y1, x2, y2, _, _ = line

    p1 = np.array([x1, y1])
    p2 = np.array([x2, y2])
    ref = np.array(ref_point)

    # find which endpoint is closer to S/F
    d1 = np.linalg.norm(p1 - ref)
    d2 = np.linalg.norm(p2 - ref)

    if d1 < d2:
        start = p1
        end = p2
    else:
        start = p2
        end = p1

    dx = end[0] - start[0]
    dy = start[1] - end[1]  # flip Y

    angle = math.degrees(math.atan2(dx, dy))
    return (angle + 360) % 360

# --- LOAD ---
img = cv2.imread(input_image)
if img is None:
    raise ValueError("Could not load image")

gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
blur = cv2.GaussianBlur(gray, (5,5), 0)

# --- EDGE DETECTION (stable) ---
edges = cv2.Canny(blur, canny_low, canny_high)

# --- LINE DETECTION ---
lines = cv2.HoughLinesP(
    edges,
    1,
    np.pi / 180,
    threshold=60,
    minLineLength=min_line_length,
    maxLineGap=max_line_gap
)

if lines is None:
    raise ValueError("No lines detected")

# --- BUILD LINE DATA ---
line_info = []

for (x1, y1, x2, y2) in lines[:, 0]:
    dx = x2 - x1
    dy = y2 - y1
    angle = compute_bearing(x1, y1, x2, y2)
    length = line_length(x1, y1, x2, y2)

    line_info.append((x1, y1, x2, y2, angle, length))

# --- DEBUG ---
print("\nDetected angles:")
for l in line_info:
    print(f"{l[4]:.2f}° | length={l[5]:.1f}")

# --- FIND DOMINANT ANGLE (histogram) ---
angles = np.array([l[4] for l in line_info])

hist, bins = np.histogram(angles, bins=36, range=(0, 180))
dominant_bin = np.argmax(hist)

approx_angle = (bins[dominant_bin] + bins[dominant_bin + 1]) / 2
print(f"\nDominant angle (histogram): {approx_angle:.2f}°")

# --- CLUSTER AROUND DOMINANT ANGLE ---
cluster = [
    l for l in line_info
    if angle_diff(l[4], approx_angle) <= angle_tolerance
]

print(f"Cluster size: {len(cluster)}")

if len(cluster) == 0:
    raise ValueError("No lines in dominant cluster")

# --- WEIGHTED AVERAGE ANGLE ---
angles_cluster = np.array([l[4] for l in cluster])
weights = np.array([l[5] for l in cluster])

avg_angle = np.average(angles_cluster, weights=weights)
print(f"Weighted average angle: {avg_angle:.2f}°")

# --- FIND HOME STRAIGHT (closest to S/F) ---
home_line = min(cluster, key=lambda l: line_tip_distance(l, start_finish_point))

home_angle = line_direction_from_sf(home_line, start_finish_point)
back_angle = (home_angle + 180) % 360

print(f"\nHome angle: {home_angle:.2f}°")
print(f"Back angle: {back_angle:.2f}°")

# --- DRAW ---
for (x1, y1, x2, y2, angle, length) in line_info:

    if angle_diff(angle, home_angle) <= angle_tolerance:
        color = (0, 255, 0)  # home
    elif angle_diff(angle, back_angle) <= angle_tolerance:
        color = (0, 0, 255)  # back
    else:
        color = (120, 120, 120)

    cv2.line(img, (x1, y1), (x2, y2), color, 2)

    mid = (int((x1 + x2) / 2), int((y1 + y2) / 2))
    cv2.putText(img, f"{angle:.1f}", mid,
                cv2.FONT_HERSHEY_SIMPLEX, 0.4, color, 1, cv2.LINE_AA)

# --- DRAW S/F POINT ---
cv2.circle(img, start_finish_point, 5, (255, 0, 0), -1)

# --- SAVE ---
cv2.imwrite(output_image, img)
print(f"\nSaved to {output_image}")