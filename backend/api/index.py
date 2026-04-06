from fastapi import FastAPI

# The app variable MUST exist at the top level for Vercel to detect it
app = FastAPI()

@app.get("/")
async def home():
    return {"message": "Hello from Python on Vercel"}

@app.get("/api/items/{item_id}")
async def read_item(item_id: int):
    return {"item_id": item_id}

