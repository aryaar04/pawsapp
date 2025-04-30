from fastapi import FastAPI, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from pymongo import MongoClient
from PIL import Image
import shutil
import os
import uuid

app = FastAPI()

# Allow all origins for dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB setup
client = MongoClient("mongodb://localhost:27017/")
db = client["adoption"]
dogs_collection = db["dogs"]

# Ensure uploads folder exists
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.post("/upload-dog")
async def upload_dog(name: str = Form(...), image: UploadFile = File(...)):
    # Save image with a unique filename
    ext = os.path.splitext(image.filename)[1]
    filename = f"{uuid.uuid4().hex}{ext}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(image.file, buffer)

    # Optional: Resize or validate image (using PIL)
    try:
        img = Image.open(file_path)
        img.verify()
    except Exception:
        os.remove(file_path)
        return {"error": "Invalid image format"}

    # Save to MongoDB
    dog = {
        "name": name,
        "image_path": file_path,
    }
    dogs_collection.insert_one(dog)

    return {"message": "Dog uploaded successfully", "dog": dog}

@app.get("/dogs")
def get_all_dogs():
    dogs = list(dogs_collection.find({}, {"_id": 0}))
    return {"dogs": dogs}
