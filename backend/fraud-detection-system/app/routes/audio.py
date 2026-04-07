from fastapi import APIRouter, UploadFile, File
import shutil, os
from app.services.audio_service import predict_audio
from app.utils.response_builder import build_response

router = APIRouter(prefix="/audio", tags=["Audio"])

UPLOAD_DIR = "temp_audio"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/")
async def detect_audio(file: UploadFile = File(...)):
    path = os.path.join(UPLOAD_DIR, file.filename)

    try:
        with open(path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        result = predict_audio(path)

        if result["deepfake"] is None:
            return build_response(
                "ERROR",
                0,
                [result.get("error", "Processing failed")],
                "audio"
            )

        status = "FRAUD" if result["deepfake"] else "SAFE"

        return build_response(
            status,
            result["confidence"],
            ["Deepfake detected"] if result["deepfake"] else [],
            "audio"
        )

    finally:
        if os.path.exists(path):
            os.remove(path)