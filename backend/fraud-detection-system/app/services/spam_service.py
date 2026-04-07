import joblib
import os
import re

model = None
vectorizer = None


# =========================
# LOAD MODEL
# =========================
def load_model():
    global model, vectorizer

    if model is None:
        BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

        model_path = os.path.join(BASE_DIR, "models", "spam_model.pkl")
        vectorizer_path = os.path.join(BASE_DIR, "models", "spam_vectorizer.pkl")

        model = joblib.load(model_path)
        vectorizer = joblib.load(vectorizer_path)


# =========================
# UNIVERSAL INPUT NORMALIZER
# =========================
def normalize_input(data) -> str:
    if isinstance(data, list):
        return " ".join(map(str, data))

    if isinstance(data, dict):
        return " ".join(map(str, data.values()))

    return str(data)


# =========================
# TEXT CLEANING
# =========================
def preprocess_text(text: str) -> str:
    text = str(text)

    # lowercase
    text = text.lower()

    # remove line breaks
    text = re.sub(r'[\n\r\t]+', ' ', text)

    # remove extra spaces
    text = re.sub(r'\s+', ' ', text).strip()

    return text


# =========================
# MAIN PREDICTION
# =========================
def predict_spam(message):
    load_model()

    # ✅ handle ANY input type
    message = normalize_input(message)

    # ✅ clean into continuous string
    message = preprocess_text(message)

    vec = vectorizer.transform([message])
    prob = model.predict_proba(vec)[0][1]

    if prob > 0.75:
        status = "FRAUD"
        reasons = ["Spam / scam message detected"]
    elif prob > 0.4:
        status = "SUSPICIOUS"
        reasons = ["Message looks suspicious"]
    else:
        status = "SAFE"
        reasons = []

    return {
        "status": status,
        "confidence": round(float(prob), 3),
        "reasons": reasons
    }