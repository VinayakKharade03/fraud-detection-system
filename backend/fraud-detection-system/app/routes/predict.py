from fastapi import APIRouter
from pydantic import BaseModel

# ✅ Correct imports
from app.services.phishing_url_service import predict_phishing
from app.services.upi_service import upi_risk_engine
from app.services.risk_engine import calculate_risk
from app.services.explainability import generate_reasons

router = APIRouter(prefix="/predict", tags=["Fraud Prediction"])

# =========================
# Input Schema
# =========================
class InputData(BaseModel):
    amount: float
    text: str
    sender_upi: str
    receiver_upi: str
    transaction_id: str
    date: str


# =========================
# MAIN FRAUD PREDICTION
# =========================
@router.post("/")
def predict(data: InputData):

    # =========================
    # 1. Transaction (placeholder for now)
    # =========================
    t = 0

    # =========================
    # 2. Phishing Detection
    # =========================
    p = predict_phishing(data.text)

    # =========================
    # 3. UPI Risk Engine
    # =========================
    upi_input = {
        "amount": data.amount,
        "sender_upi": data.sender_upi,
        "receiver_upi": data.receiver_upi,
        "transaction_id": data.transaction_id,
        "date": data.date
    }

    upi_result = upi_risk_engine(upi_input)
    u = int(upi_result["fraud"])

    # =========================
    # 4. Deepfake (placeholder)
    # =========================
    d = 0

    # =========================
    # 5. Risk Score
    # =========================
    risk = calculate_risk(t, p, u, d)

    # =========================
    # 6. Smart Fraud Decision (🔥 IMPORTANT)
    # =========================
    is_fraud = (
        risk >= 0.5 or
        u == 1 or
        (p == 1 and u == 1)
    )

    # =========================
    # 7. Explainability
    # =========================
    reasons = generate_reasons(t, p, u, d, data.dict())

    # =========================
    # Final Response
    # =========================
    return {
        "fraud": is_fraud,
        "risk_score": risk,
        "phishing_detected": bool(p),
        "upi_fraud": bool(u),
        "upi_details": upi_result,
        "reasons": reasons
    }