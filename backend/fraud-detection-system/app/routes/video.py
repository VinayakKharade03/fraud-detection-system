from fastapi import APIRouter, UploadFile, File
import shutil, os
from app.services.video_service import predict_video
from app.utils.response_builder import build_response

router = APIRouter(prefix="/video", tags=["Video"])

UPLOAD_DIR = "temp_videos"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/")
async def detect_video(file: UploadFile = File(...)):
    path = os.path.join(UPLOAD_DIR, file.filename)

    try:
        with open(path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        result = predict_video(path)

        if result["deepfake"] is None:
            return build_response("ERROR", 0, [result["error"]], "video")

        status = "FRAUD" if result["deepfake"] else "SAFE"

        return build_response(
            status,
            result["confidence"],
            ["Deepfake video detected"] if result["deepfake"] else [],
            "video"
        )

    finally:
        if os.path.exists(path):
            os.remove(path)