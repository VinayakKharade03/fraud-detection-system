from fastapi import APIRouter
from pydantic import BaseModel
from app.services.phishing_url_service import predict_phishing
from app.utils.response_builder import build_response

router = APIRouter(prefix="/phishing-url", tags=["URL"])

class URLRequest(BaseModel):
    url: str

@router.post("/")
def check_url(req: URLRequest):
    res = predict_phishing(req.url)

    if res["phishing"]:
        status = "FRAUD"
        reasons = ["Phishing URL detected"]
    else:
        status = "SAFE"
        reasons = []

    return build_response(
        status=status,
        confidence=res["confidence"],
        reasons=reasons,
        type="url"
    )