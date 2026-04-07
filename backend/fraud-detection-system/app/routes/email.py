from fastapi import APIRouter
from pydantic import BaseModel

from app.services.email_service import predict_email
from app.services.spam_service import predict_spam
from app.utils.response_builder import build_response

router = APIRouter(
    prefix="/email",
    tags=["Email Detection"]
)


# =========================
# Request Model
# =========================
class EmailRequest(BaseModel):
    text: str


# =========================
# EMAIL ANALYZER (COMBINED)
# =========================
@router.post("/")
def check_email(request: EmailRequest):

    # 🔹 Run both models
    email_res = predict_email(request.text)   # phishing
    spam_res = predict_spam(request.text)     # spam

    # =========================
    # 🔥 DECISION LOGIC
    # =========================
    if email_res["status"] == "FRAUD":
        status = "FRAUD"
        reasons = email_res["reasons"]

    elif email_res["status"] == "SUSPICIOUS":
        status = "SUSPICIOUS"
        reasons = email_res["reasons"]

    elif spam_res["status"] == "FRAUD":
        status = "SUSPICIOUS"
        reasons = spam_res["reasons"]

    elif spam_res["status"] == "SUSPICIOUS":
        status = "SUSPICIOUS"
        reasons = spam_res["reasons"]

    else:
        status = "SAFE"
        reasons = []

    # =========================
    # 🔹 Confidence (best of both)
    # =========================
    confidence = max(
        email_res.get("confidence", 0),
        spam_res.get("confidence", 0)
    )

    # =========================
    # 🔹 Merge reasons (optional but nice)
    # =========================
    reasons = list(set(reasons))

    # =========================
    # FINAL RESPONSE
    # =========================
    return build_response(
        status=status,
        confidence=confidence,
        reasons=reasons,
        type="email"
    )