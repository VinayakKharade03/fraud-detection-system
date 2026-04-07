from fastapi import APIRouter
from app.services.ai_service import get_ai_response

router = APIRouter()

@router.post("/ai")
def ai_chat(data: dict):
    message = data.get("message")

    if not message:
        return {"response": "No message provided"}

    result = get_ai_response(message)

    return {"response": result}