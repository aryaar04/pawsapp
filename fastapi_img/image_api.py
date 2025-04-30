from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from image_model import save_image, predict_image

app = FastAPI()

# Enable CORS for Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"message": "PAWS Image Recognition API"}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    file_path = save_image(file)
    result = predict_image(file_path)
    return {"result": result}
