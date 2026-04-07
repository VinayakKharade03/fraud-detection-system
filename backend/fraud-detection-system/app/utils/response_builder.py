def build_response(status, confidence=0.0, reasons=None, type="unknown"):
    return {
        "status": status,
        "confidence": round(float(confidence), 3),
        "reasons": reasons or [],
        "type": type
    }