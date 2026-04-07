from fastapi import APIRouter, UploadFile, File
import shutil, os, uuid
from app.services.qr_service import analyze_qr
from app.utils.response_builder import build_response

router = APIRouter(prefix="/qr", tags=["QR"])

UPLOAD_DIR = "temp_qr"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/")
async def detect_qr(file: UploadFile = File(...)):
    path = os.path.join(UPLOAD_DIR, f"{uuid.uuid4()}_{file.filename}")

    try:
        with open(path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        result = analyze_qr(path)

        analysis = result["analysis"]

        return build_response(
            analysis["status"],
            analysis["risk_score"],
            analysis["reasons"],
            "qr"
        )

    finally:
        if os.path.exists(path):
            os.remove(path)