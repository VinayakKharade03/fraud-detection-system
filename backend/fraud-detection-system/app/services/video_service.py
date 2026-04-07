import cv2
import numpy as np
from tensorflow.keras.models import load_model

MODEL_PATH = "app/models/image_model.keras"
model = load_model(MODEL_PATH)

def predict_video(video_path):
    try:
        cap = cv2.VideoCapture(video_path)

        predictions = []
        frame_count = 0
        MAX_FRAMES = 30   # 🔥 LIMIT (very important)

        while cap.isOpened():
            ret, frame = cap.read()

            if not ret:
                break

            # 🔥 Skip frames (speed boost)
            if frame_count % 10 != 0:
                frame_count += 1
                continue

            frame = cv2.resize(frame, (224, 224))
            frame = frame / 255.0
            frame = np.reshape(frame, (1, 224, 224, 3))

            pred = model.predict(frame, verbose=0)[0][0]
            predictions.append(pred)

            frame_count += 1

            # 🔥 HARD STOP
            if len(predictions) >= MAX_FRAMES:
                break

        cap.release()

        if len(predictions) == 0:
            return {
                "deepfake": None,
                "confidence": None,
                "error": "No valid frames"
            }

        avg = sum(predictions) / len(predictions)

        is_fake = avg > 0.5

        return {
            "deepfake": bool(is_fake),
            "confidence": round(float(avg), 3),
            "frames_used": len(predictions)  # 🔥 debug info
        }

    except Exception as e:
        return {
            "deepfake": None,
            "confidence": None,
            "error": str(e)
        }