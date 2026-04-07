from fastapi import APIRouter
from pydantic import BaseModel
from app.services.transaction_service import predict_transaction

router = APIRouter()

class TransactionInput(BaseModel):
    merchant: str
    category: str
    amt: float
    gender: str
    lat: float
    long: float
    merch_lat: float
    merch_long: float
    day: int
    month: int
    hour: int   # ✅ NEW FIELD


@router.post("/transaction")
def check_transaction(data: TransactionInput):
    result = predict_transaction(data.dict())
    return result