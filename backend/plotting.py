import json
import matplotlib.pyplot as plt

# Replace this with your JSON
data = {
    "elements": [
        {
            "type": "way",
            "id": 138546154,
            "geometry": [
                {"lat": 40.9614452, "lon": -73.711786},
                {"lat": 40.9600033, "lon": -73.7114872},
                {"lat": 40.960008, "lon": -73.7114032},
                {"lat": 40.9600802, "lon": -73.7114077},
                {"lat": 40.9600862, "lon": -73.7113445},
                {"lat": 40.9600414, "lon": -73.7112438},
                {"lat": 40.9600168, "lon": -73.7110934},
                {"lat": 40.960015, "lon": -73.7109331},
                {"lat": 40.9600607, "lon": -73.7107671},
                {"lat": 40.9601484, "lon": -73.7106878},
                {"lat": 40.960241, "lon": -73.7106371},
                {"lat": 40.9603923, "lon": -73.7106207},
                {"lat": 40.9613649, "lon": -73.7108292},
                {"lat": 40.9615007, "lon": -73.7109363},
                {"lat": 40.9615773, "lon": -73.7110909},
                {"lat": 40.9615964, "lon": -73.7112953},
                {"lat": 40.961581, "lon": -73.7114343},
                {"lat": 40.9615069, "lon": -73.7115938},
                {"lat": 40.9614606, "lon": -73.7116306},
                {"lat": 40.9614452, "lon": -73.711786}
            ],
            "tags": {"leisure": "stadium", "sport": "athletics"}
        },
        {
            "type": "way",
            "id": 138546166,
            "geometry": [
                {"lat": 40.9612821, "lon": -73.7115893},
                {"lat": 40.9613564, "lon": -73.7109912},
                {"lat": 40.960346, "lon": -73.7107924},
                {"lat": 40.9602669, "lon": -73.7113779},
                {"lat": 40.9612821, "lon": -73.7115893}
            ],
            "tags": {"leisure": "pitch", "sport": "american_football"}
        }
    ]
}

# Plot
plt.figure(figsize=(8, 8))
for elem in data["elements"]:
    if elem["type"] == "way" and "geometry" in elem:
        lats = [p["lat"] for p in elem["geometry"]]
        lons = [p["lon"] for p in elem["geometry"]]
        plt.plot(lons, lats, marker='o', label=elem["tags"].get("leisure", "way"))

plt.xlabel("Longitude")
plt.ylabel("Latitude")
plt.title("OSM Shapes")
plt.legend()
plt.axis("equal")  # Keep aspect ratio correct
plt.show()

import math

def haversine(lat1, lon1, lat2, lon2):
    """Distance in meters between two lat/lon points"""
    R = 6371000  # Earth radius in meters
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)

    a = math.sin(dphi/2)**2 + math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)**2
    return 2 * R * math.atan2(math.sqrt(a), math.sqrt(1 - a))

def bearing(lat1, lon1, lat2, lon2):
    """Bearing in degrees (0 = North, 90 = East)"""
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dlambda = math.radians(lon2 - lon1)

    x = math.sin(dlambda) * math.cos(phi2)
    y = math.cos(phi1)*math.sin(phi2) - math.sin(phi1)*math.cos(phi2)*math.cos(dlambda)

    theta = math.atan2(x, y)
    return (math.degrees(theta) + 360) % 360


longest_dist = 0
longest_segment = None
longest_bearing = None

for elem in data["elements"]:
    if elem["type"] == "way" and "geometry" in elem:
        geom = elem["geometry"]
        
        for i in range(len(geom) - 1):
            p1 = geom[i]
            p2 = geom[i + 1]
            
            dist = haversine(p1["lat"], p1["lon"], p2["lat"], p2["lon"])
            
            if dist > longest_dist:
                longest_dist = dist
                longest_segment = (p1, p2)
                longest_bearing = bearing(p1["lat"], p1["lon"], p2["lat"], p2["lon"])

print("Longest segment distance (m):", longest_dist)
print("Bearing (degrees):", longest_bearing)