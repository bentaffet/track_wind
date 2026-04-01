import cv2
import numpy as np

def detect_track(
    image_path,
    lower1=(0, 70, 50),
    upper1=(10, 255, 255),
    lower2=(170, 70, 50),
    upper2=(180, 255, 255),
    min_area=5000,
    debug=True
):
    img = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)

    # Handle PNG alpha
    if img.shape[-1] == 4:
        img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)

    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # Convert thresholds to numpy
    l1 = np.array(lower1)
    u1 = np.array(upper1)
    l2 = np.array(lower2)
    u2 = np.array(upper2)

    mask1 = cv2.inRange(hsv, l1, u1)
    mask2 = cv2.inRange(hsv, l2, u2)
    mask = cv2.bitwise_or(mask1, mask2)

    # Clean mask
    kernel = np.ones((7, 7), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)

    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if not contours:
        print("No regions found")
        return None

    # Filter by size
    contours = [c for c in contours if cv2.contourArea(c) > min_area]
    if not contours:
        print("No large enough regions")
        return None

    largest = max(contours, key=cv2.contourArea)
    x, y, w, h = cv2.boundingRect(largest)

    result = img.copy()
    cv2.rectangle(result, (x, y), (x+w, y+h), (0, 255, 0), 3)

    if debug:
        cv2.imshow("Mask", mask)
        cv2.imshow("Result", result)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    return (x, y, w, h)


# Example usage
detect_track(
    "snapshot3.png",
    lower1=(0, 50, 40),   # ← tweak these
    upper1=(15, 255, 255),
    lower2=(165, 50, 40),
    upper2=(180, 255, 255)
)