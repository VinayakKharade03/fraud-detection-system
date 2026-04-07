import cv2
from pyzbar.pyzbar import decode

from app.services.phishing_url_service import predict_phishing
from app.services.spam_service import predict_spam
from app.services.upi_service import upi_risk_engine


# =========================
# EXTRACT QR DATA
# =========================
def extract_qr_data(image_path):
    img = cv2.imread(image_path)

    if img is None:
        return None

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    decoded = decode(gray)

    if not decoded:
        return None

    return decoded[0].data.decode("utf-8").strip()


# =========================
# DETECT QR TYPE
# =========================
def detect_qr_type(data: str):
    data = data.lower().strip()

    if data.startswith("upi://"):
        return "UPI"

    elif data.startswith("http://") or data.startswith("https://"):
        return "URL"

    elif "@" in data and "upi" in data:
        return "POSSIBLE_UPI"

    elif len(data) < 5:
        return "INVALID"

    else:
        return "TEXT"


# =========================
# BASIC UNIVERSAL CHECKS
# =========================
def basic_qr_checks(data):
    score = 0
    reasons = []

    if len(data) > 500:
        score += 0.3
        reasons.append("Unusually long QR data")

    if any(ord(c) in range(8203, 8290) for c in data):
        score += 0.5
        reasons.append("Hidden characters in QR")

    return score, reasons


# =========================
# UPI QR ANALYSIS (REUSE ENGINE 🔥)
# =========================
def analyze_upi_qr(data):
    from urllib.parse import urlparse, parse_qs

    parsed = urlparse(data)
    params = parse_qs(parsed.query)

    receiver = params.get("pa", [""])[0]
    amount = float(params.get("am", [0])[0] or 0)

    dummy_data = {
        "transaction_id": "QR_TXN",
        "date": "2026-01-01",
        "sender_upi": "unknown@upi",
        "receiver_upi": receiver,
        "amount": amount
    }

    return upi_risk_engine(dummy_data)


# =========================
# MAIN QR ANALYZER
# =========================
def analyze_qr(image_path):
    data = extract_qr_data(image_path)

    if not data:
        return {
            "status": "ERROR",
            "message": "No QR code detected"
        }

    qr_type = detect_qr_type(data)

    base_score, base_reasons = basic_qr_checks(data)

    # =========================
    # UPI QR
    # =========================
    if qr_type == "UPI":
        result = analyze_upi_qr(data)

    # =========================
    # URL QR
    # =========================
    elif qr_type == "URL":
        result = predict_phishing(data)

        if any(x in data for x in ["bit.ly", "tinyurl", "goo.gl"]):
            result["reasons"].append("Shortened URL detected")

    # =========================
    # POSSIBLE HIDDEN UPI
    # =========================
    elif qr_type == "POSSIBLE_UPI":
        result = {
            "status": "SUSPICIOUS",
            "risk_score": 0.6,
            "reasons": ["Possible hidden UPI inside QR"]
        }

    # =========================
    # INVALID QR
    # =========================
    elif qr_type == "INVALID":
        result = {
            "status": "SUSPICIOUS",
            "risk_score": 0.5,
            "reasons": ["Invalid or corrupted QR data"]
        }

    # =========================
    # TEXT QR
    # =========================
    else:
        result = predict_spam(data)

    # =========================
    # MERGE BASE CHECKS
    # =========================
    result["risk_score"] = min(result["risk_score"] + base_score, 1.0)
    result["reasons"].extend(base_reasons)

    # =========================
    # FINAL STATUS FIX
    # =========================
    score = result["risk_score"]

    if score < 0.3:
        status = "SAFE"
    elif score <= 0.6:
        status = "SUSPICIOUS"
    else:
        status = "FRAUD"

    result["status"] = status

    return {
        "type": qr_type,
        "content": data,
        "analysis": result
    }