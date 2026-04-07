from fastapi import APIRouter, Request
from app.services.spam_service import predict_spam
import json

router = APIRouter(
    prefix="/spam",
    tags=["Spam Detection"]
)

@router.post("/")
async def check_spam(request: Request):
    body = await request.body()

    try:
        # ✅ Try parsing JSON
        data = json.loads(body)
        message = data.get("message", "")
    except:
        # ✅ Fallback → raw text (handles broken JSON / plain text)
        message = body.decode("utf-8")

    return predict_spam(message)