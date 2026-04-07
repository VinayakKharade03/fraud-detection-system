import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

import numpy as np
from tensorflow.keras.utils import to_categorical
from tensorflow.keras.preprocessing.sequence import pad_sequences
from sklearn.model_selection import train_test_split
from tensorflow.keras.models import save_model

from preprocess import prepare_dataset
from model import create_model

# =========================
# PATHS
# =========================
BASE_PATH = r"D:\fraud-detection-system\data\AUDIO"
REAL_DIR = os.path.join(BASE_PATH, "REAL")
FAKE_DIR = os.path.join(BASE_PATH, "FAKE")

MODEL_PATH = "model/lstm_audio_model.keras"
MAX_LEN_PATH = "model/max_length.npy"

# =========================
# GET FILES (ALL FORMATS)
# =========================
def get_all_files(folder):
    paths = []
    for root, _, files in os.walk(folder):
        for file in files:
            if file.lower().endswith(('.wav', '.mp3', '.m4a')):
                paths.append(os.path.join(root, file))
    return paths

# =========================
# MAIN
# =========================
if __name__ == "__main__":

    print("Loading dataset...\n")

    real_paths = get_all_files(REAL_DIR)
    fake_paths = get_all_files(FAKE_DIR)

    print("Found REAL:", len(real_paths))
    print("Found FAKE:", len(fake_paths))

    X, y = prepare_dataset(real_paths, fake_paths)

    print("\nTotal samples:", len(X))

    # padding
    max_len = max(len(x) for x in X)
    X = pad_sequences(X, maxlen=max_len, padding='post')

    # save max length
    os.makedirs("model", exist_ok=True)
    np.save(MAX_LEN_PATH, max_len)

    # split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, stratify=y, random_state=42
    )

    y_train = to_categorical(y_train)
    y_test = to_categorical(y_test)

    model = create_model((X.shape[1], X.shape[2]))

    print("\nStarting training...\n")

    history = model.fit(
        X_train, y_train,
        epochs=15,
        batch_size=32,
        validation_data=(X_test, y_test),
        class_weight={0: 2.0, 1: 1.0},  # 🔥 FIX BIAS
        verbose=1
    )

    loss, acc = model.evaluate(X_test, y_test, verbose=0)
    print("\nTest Accuracy:", round(acc * 100, 2), "%")

    model.save(MODEL_PATH)
    print("Model saved!")