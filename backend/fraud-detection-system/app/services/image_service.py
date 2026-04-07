import numpy as np
import cv2
from tensorflow.keras.models import load_model

# =========================
# LOAD MODEL ONCE
# =========================
MODEL_PATH = "app/models/image_model.keras"
model = load_model(MODEL_PATH)

# =========================
# PREDICT IMAGE
# =========================
def predict_image(image_path):
    try:
        img = cv2.imread(image_path)

        if img is None:
            return {
                "deepfake": None,
                "confidence": None,
                "error": "Invalid image"
            }

        img = cv2.resize(img, (224, 224))
        img = img / 255.0
        img = np.reshape(img, (1, 224, 224, 3))

        pred = model.predict(img)[0][0]

        is_fake = pred > 0.5
        confidence = float(pred if is_fake else 1 - pred)

        return {
            "deepfake": bool(is_fake),
            "confidence": round(confidence, 3)
        }

    except Exception as e:
        return {
            "deepfake": None,
            "confidence": None,
            "error": str(e)
        }