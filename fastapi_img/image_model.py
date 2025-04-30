import numpy as np
from PIL import Image
import tensorflow as tf
import shutil
import os
from fastapi import UploadFile

# Load the TFLite model
interpreter = tf.lite.Interpreter(model_path="PAWS.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

labels = [
    "Healthy",
    "Skin Disease",
    "Ear Infection",
    "Ringworm",
    "Allergy",
    "Fungal Infection"
]

def save_image(upload_file: UploadFile, destination_folder="images") -> str:
    os.makedirs(destination_folder, exist_ok=True)
    file_location = os.path.join(destination_folder, upload_file.filename)
    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(upload_file.file, buffer)
    return file_location

def predict_image(image_path: str):
    # Load and resize image
    image = Image.open(image_path).convert("RGB").resize((224, 224))
    image = np.asarray(image, dtype=np.float32)

    # Apply same scaling as Colab
    image *= (1.0 / 225.0)
    image = np.expand_dims(image, axis=0)  # Add batch dimension

    interpreter.set_tensor(input_details[0]['index'], image)
    interpreter.invoke()
    output_data = interpreter.get_tensor(output_details[0]['index'])[0]

    # Label list should match training
    labels = ['Dermatitis', 'Fungal_infection', 'Healthy', 'Hypersensitivity', 'demodicosis', 'ringworm']
    prediction_idx = int(np.argmax(output_data))

    if prediction_idx >= len(labels):
        return "Unknown label (index out of range)"

    return labels[prediction_idx]