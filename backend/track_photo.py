import math
import requests
from PIL import Image
from io import BytesIO
from dotenv import load_dotenv
import os


coords = [
        #   (40.973187,-73.690017),
        #   (41.037443,-73.614033),
        #   (41.155500,-73.327088),
        #   (41.577207977407184,-72.6816897262393),
        #   (41.062861,-73.530169),
        #   (41.020847,-73.733638),
        #   (41.010523,-73.762268),
        #   (41.001760,-73.811327),
        #   (41.013296,-73.871019),
        #   (41.302475,-73.691547),
        #   (41.750178,-72.688993),

        #   (42.103707,-72.556200),
        #   (42.119268,-72.556253),
        #   (42.120885,-72.643326),
        #   (42.198349,-72.620959),
          (42.368514,-72.524181)
          
          
            ]



# --- PARAMETERS ---
for i, coord in enumerate(coords):
    lat, lon = coord
    size_pixels = 625   
    meters = 625     
    load_dotenv()

    api_key = os.getenv("API_KEY")


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
        img.save(f"snapshot{i + 20}.png")
        print("Saved snapshot.png")
    else:
        print("Error fetching map:", response.text)

