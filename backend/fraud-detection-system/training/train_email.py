import pandas as pd
import joblib
import os

from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression

# =========================
# 1. Load Dataset
# =========================
data_path = r"D:\fraud-detection-system\data\email_phishing.csv"

if not os.path.exists(data_path):
    raise FileNotFoundError("❌ Dataset not found!")

data = pd.read_csv(data_path)

print("✅ Dataset Loaded")
print("Columns:", data.columns)

# =========================
# 2. SAFE TEXT CREATION (FIXED)
# =========================
data["text"] = (
    data["subject"].fillna("").astype(str) + " " +
    data["body"].fillna("").astype(str) + " " +
    data["urls"].fillna("").astype(str)
)

# =========================
# 3. Features & Target
# =========================
X = data["text"]
y = data["label"]

# =========================
# 4. Train-Test Split
# =========================
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

# =========================
# 5. TF-IDF Vectorizer
# =========================
vectorizer = TfidfVectorizer(
    max_features=5000,
    stop_words="english"
)

X_train_vec = vectorizer.fit_transform(X_train)
X_test_vec = vectorizer.transform(X_test)

# =========================
# 6. Model
# =========================
model = LogisticRegression(max_iter=1000)

print("⏳ Training model...")
model.fit(X_train_vec, y_train)

# =========================
# 7. Evaluation
# =========================
y_pred = model.predict(X_test_vec)

print("\n📊 Classification Report:")
print(classification_report(y_test, y_pred))

# =========================
# 8. Save Model
# =========================
os.makedirs("app/models", exist_ok=True)

joblib.dump(model, "app/models/email_model.pkl")
joblib.dump(vectorizer, "app/models/email_vectorizer.pkl")

print("✅ Model saved successfully!")