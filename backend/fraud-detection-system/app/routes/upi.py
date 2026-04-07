from fastapi import APIRouter
from pydantic import BaseModel

from app.services.upi_service import upi_risk_engine

router = APIRouter()


class UPIRequest(BaseModel):
    transaction_id: str
    date: str
    sender_upi: str
    receiver_upi: str
    amount: float


@router.post("/upi-check")
def check_upi(request: UPIRequest):
    return upi_risk_engine(request.dict())