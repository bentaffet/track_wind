import math
import requests
from PIL import Image
from io import BytesIO

# --- PARAMETERS ---
lat = 41.577207977407184
lon = -72.6816897262393
size_pixels = 650   
meters = 650        
api_key = "AIzaSyDZJrtl1rpRYhbfxiw0W9ftl5Dp4KGMyEE"

# --- FUNCTION TO ESTIMATE ZOOM LEVEL ---
def zoom_level_for_meters(lat, map_width_meters, image_width_pixels):
    """
    Estimate zoom level to get a map_width_meters wide image at the given latitude.
    """
    # Earth circumference in meters at equator
    C = 40075016.686
    # Resolution (meters/pixel) at zoom 0
    initial_resolution = C / 256
    # Desired resolution (meters/pixel)
    resolution = map_width_meters / image_width_pixels
    # Compute zoom level
    zoom = math.log2(initial_resolution / (resolution * math.cos(math.radians(lat))))
    return int(round(zoom))

zoom = zoom_level_for_meters(lat, meters, size_pixels)
print(f"Using zoom level: {zoom}")

# --- FETCH STATIC MAP ---
url = (
    f"https://maps.googleapis.com/maps/api/staticmap?"
    f"center={lat},{lon}&zoom={zoom}&size={size_pixels}x{size_pixels}"
    f"&maptype=satellite&key={api_key}"
)

response = requests.get(url)
if response.status_code == 200:
    img = Image.open(BytesIO(response.content))
    img.save("snapshot3.png")
    print("Saved snapshot.png")
else:
    print("Error fetching map:", response.text)



api_key = "AIzaSyDZJrtl1rpRYhbfxiw0W9ftl5Dp4KGMyEE"