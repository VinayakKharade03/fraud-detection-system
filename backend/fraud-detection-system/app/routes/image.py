from fastapi import APIRouter, UploadFile, File
import shutil, os
from app.services.image_service import predict_image
from app.utils.response_builder import build_response

router = APIRouter(prefix="/image", tags=["Image"])

UPLOAD_DIR = "temp_images"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/")
async def detect_image(file: UploadFile = File(...)):
    path = os.path.join(UPLOAD_DIR, file.filename)

    try:
        with open(path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        result = predict_image(path)

        if result["deepfake"] is None:
            return build_response("ERROR", 0, [result["error"]], "image")

        status = "FRAUD" if result["deepfake"] else "SAFE"

        return build_response(
            status,
            result["confidence"],
            ["Deepfake image detected"] if result["deepfake"] else [],
            "image"
        )

    finally:
        if os.path.exists(path):
            os.remove(path)