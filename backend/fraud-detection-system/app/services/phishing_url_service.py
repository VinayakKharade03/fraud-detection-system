import joblib
import numpy as np

# Load model once
model = joblib.load("app/models/phishing_model.pkl")

# SAME feature logic used during training
def extract_features(url):
    return [
        len(url),
        url.count("."),
        url.count("-"),
        url.count("@"),
        sum(c.isdigit() for c in url) / max(len(url), 1),
        int("https" in url),
        int(any(word in url for word in ["login", "verify", "secure"])),

        url.count("/"),
        url.count("="),
        int("//" in url[8:]),
        int(len(url.split(".")) > 3),

        url.count("%"),
        int(any(c.isupper() for c in url))
    ]

def predict_phishing(url):
    features = extract_features(url)
    features = np.array(features).reshape(1, -1)

    pred = model.predict(features)[0]

    try:
        prob = model.predict_proba(features)[0][1]
    except:
        prob = None

    return {
        "phishing": bool(pred),
        "confidence": round(float(prob), 3) if prob is not None else None
    }