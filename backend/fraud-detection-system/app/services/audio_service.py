import numpy as np
import librosa
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.sequence import pad_sequences

# =========================
# LOAD MODEL (ONCE)
# =========================
MODEL_PATH = "app/models/lstm_audio_model.keras"
MAX_LEN_PATH = "app/models/max_length.npy"

model = load_model(MODEL_PATH)
max_length = int(np.load(MAX_LEN_PATH))

# =========================
# PREPROCESS
# =========================
def extract_features(audio_path):
    try:
        audio, sr = librosa.load(audio_path, sr=None, duration=3)

        # normalize
        max_val = np.max(np.abs(audio))
        if max_val > 0:
            audio = audio / max_val

        # slight noise (same as training)
        audio = audio + 0.003 * np.random.randn(len(audio))

        mfccs = librosa.feature.mfcc(y=audio, sr=sr, n_mfcc=13)

        return mfccs.T

    except Exception as e:
        print("Audio processing error:", e)
        return None

# =========================
# PREDICTION
# =========================
def predict_audio(file_path):
    features = extract_features(file_path)

    if features is None:
        return {
            "deepfake": None,
            "confidence": None,
            "error": "Audio processing failed"
        }

    features_padded = pad_sequences(
        [features],
        maxlen=max_length,
        padding='post'
    )

    prediction = model.predict(features_padded)[0]

    class_idx = int(np.argmax(prediction))
    confidence = float(prediction[class_idx])

    return {
        "deepfake": bool(class_idx),  # 1 = FAKE
        "confidence": round(confidence, 3)
    }