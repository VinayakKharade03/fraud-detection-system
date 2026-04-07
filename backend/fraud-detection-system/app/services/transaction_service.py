import joblib
import numpy as np
import os

model = None
encoders = None


def load_model():
    global model, encoders

    if model is None:
        BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

        model_path = os.path.join(BASE_DIR, "models", "fraud_model.pkl")
        encoder_path = os.path.join(BASE_DIR, "models", "fraud_encoders.pkl")

        model = joblib.load(model_path)
        encoders = joblib.load(encoder_path)


def preprocess(data):
    load_model()

    for col in ['merchant', 'category', 'gender']:
        if data[col] in encoders[col].classes_:
            data[col] = encoders[col].transform([data[col]])[0]
        else:
            data[col] = 0

    distance = np.sqrt(
        (data['lat'] - data['merch_lat'])**2 +
        (data['long'] - data['merch_long'])**2
    )

    amt_log = np.log1p(data['amt'])
    is_high_amt = 1 if data['amt'] > 5000 else 0

    hour = data['hour']  # ✅ REQUIRED NOW
    is_night = 1 if hour < 6 else 0

    return [
        data['merchant'],
        data['category'],
        data['amt'],
        amt_log,
        is_high_amt,
        data['day'],
        data['month'],
        hour,
        is_night,
        data['gender'],
        distance
    ]


def predict_transaction(data):
    load_model()

    features = preprocess(data)
    features = np.array(features).reshape(1, -1)

    prob = model.predict_proba(features)[0][1]

    if prob > 0.75:
        risk = "HIGH"
    elif prob > 0.4:
        risk = "MEDIUM"
    else:
        risk = "LOW"

    return {
        "fraud": bool(prob > 0.75),
        "confidence": round(float(prob), 3),
        "risk_level": risk
    }