from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from dotenv import load_dotenv
load_dotenv(dotenv_path="D:/fraud-detection-system/.env")

# =========================
# Import Routers
# =========================
from app.routes.predict import router as main_router
from app.routes.phishing_url import router as phishing_url_router
from app.routes.email import router as email_router
from app.routes.upi import router as upi_router
from app.routes.audio import router as audio_router
from app.routes.image import router as image_router
from app.routes.video import router as video_router
from app.routes.transaction import router as transaction_router
from app.routes.spam import router as spam_router
from app.routes.qr import router as qr_router

# ✅ NEW (AI ROUTER)
from app.routes.ai import router as ai_router

# =========================
# Create FastAPI App
# =========================
app = FastAPI(
    title="AI Cyber Fraud Detection System 🚀",
    description=(
        "Unified Fraud Detection API including:\n"
        "- Email Phishing Detection\n"
        "- URL Phishing Detection\n"
        "- UPI Fraud Detection\n"
        "- QR Code Fraud Detection\n"
        "- Spam Message Detection\n"
        "- Audio Deepfake Detection\n"
        "- Image Deepfake Detection\n"
        "- Video Deepfake Detection\n"
        "- Transaction Fraud Detection\n"
        "- AI Fraud Assistant 🤖"   # ✅ added
    ),
    version="4.0.0"
)

# =========================
# CORS Middleware
# =========================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # ⚠️ Change in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# Include Routers
# =========================
app.include_router(main_router)
app.include_router(phishing_url_router)
app.include_router(email_router)
app.include_router(upi_router)
app.include_router(audio_router)
app.include_router(image_router)
app.include_router(video_router)
app.include_router(transaction_router)
app.include_router(spam_router)
app.include_router(qr_router)

# ✅ NEW
app.include_router(ai_router)

# =========================
# Root Endpoint
# =========================
@app.get("/")
def home():
    return {
        "status": "running",
        "message": "AI Cyber Fraud Detection Backend 🚀",
        "version": "4.0.0",
        "features": [
            "Email Phishing Detection",
            "URL Phishing Detection",
            "UPI Fraud Detection",
            "QR Fraud Detection",
            "Spam Message Detection",
            "Audio Deepfake Detection",
            "Image Deepfake Detection",
            "Video Deepfake Detection",
            "Transaction Fraud Detection",
            "AI Fraud Assistant"  # ✅ added
        ]
    }

# =========================
# Health Check
# =========================
@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "fraud-detection-api",
        "version": "4.0.0",
        "modules": [
            "email",
            "url",
            "upi",
            "qr",
            "spam",
            "audio",
            "image",
            "video",
            "transaction",
            "ai"  # ✅ added
        ]
    }