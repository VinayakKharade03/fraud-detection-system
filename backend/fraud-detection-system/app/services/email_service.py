import joblib

# =========================
# Load Model + Vectorizer
# =========================
model = joblib.load("app/models/email_model.pkl")
vectorizer = joblib.load("app/models/email_vectorizer.pkl")


# =========================
# Prediction Function
# =========================
def predict_email(text):
    vec = vectorizer.transform([text])

    pred = model.predict(vec)[0]

    try:
        prob = model.predict_proba(vec)[0][1]
    except:
        prob = 0.5

    # =========================
    # STANDARDIZED OUTPUT
    # =========================
    if prob > 0.75:
        status = "FRAUD"
        reasons = ["Phishing email detected"]
    elif prob > 0.4:
        status = "SUSPICIOUS"
        reasons = ["Email looks suspicious"]
    else:
        status = "SAFE"
        reasons = []

    return {
        "status": status,
        "confidence": round(float(prob), 3),
        "reasons": reasons
    }