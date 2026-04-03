import cv2
import numpy as np
from pathlib import Path

def detect_track_orientation(
    image_path,
    lower1=(0, 50, 40),
    upper1=(15, 255, 255),
    lower2=(165, 50, 40),
    upper2=(180, 255, 255),
    min_area=5000,
    debug=True
):
    # --- Load and preprocess ---
    img = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
    if img is None:
        print("Image not found:", image_path)
        return None

    if img.shape[-1] == 4:
        img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)

    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    mask1 = cv2.inRange(hsv, np.array(lower1), np.array(upper1))
    mask2 = cv2.inRange(hsv, np.array(lower2), np.array(upper2))
    mask = cv2.bitwise_or(mask1, mask2)

    kernel = np.ones((7,7), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)

    # --- Find contours and largest track ---
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    contours = [c for c in contours if cv2.contourArea(c) > min_area]
    if not contours:
        print("No large enough regions:", image_path)
        return None

    largest = max(contours, key=cv2.contourArea)
    epsilon = 0.002 * cv2.arcLength(largest, True)
    approx = cv2.approxPolyDP(largest, epsilon, True)
    points_poly = approx.reshape(-1,2)

    # --- Longest segment ---
    longest_len = 0
    best_segment = None
    for i in range(len(points_poly)):
        p1 = points_poly[i]
        p2 = points_poly[(i+1)%len(points_poly)]
        length = np.linalg.norm(p2 - p1)
        if length > longest_len:
            longest_len = length
            best_segment = (p1, p2)

    if best_segment is None:
        print("No segment found:", image_path)
        return None

    (x1, y1), (x2, y2) = best_segment
    dx = x2 - x1
    dy = y2 - y1

    # --- Compass direction: 0° = north (top of image), clockwise ---
    compass_bearing = (90 - np.degrees(np.arctan2(-dy, dx))) % 360

    # --- Debug visualization ---
    if debug:
        result = img.copy()
        # Draw the largest contour
        cv2.drawContours(result, [approx], -1, (255,0,0), 2)
        # Draw the longest segment
        cv2.line(result, tuple(best_segment[0]), tuple(best_segment[1]), (0,255,0), 4)
        # Show mask and result
        cv2.imshow("Mask", mask)
        cv2.imshow("Result", result)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    print(f"Processing: {Path(image_path).name}")
    print(f"Longest segment: {tuple(map(int, best_segment[0]))} -> {tuple(map(int, best_segment[1]))}")
    print(f"Compass direction (north=0°): {compass_bearing:.2f}\n")

    return compass_bearing, best_segment


# --- Loop through all images ---
image_folder = Path("images")
for image_path in image_folder.glob("*.*"):
    detect_track_orientation(str(image_path))