import pandas as pd
import joblib
import os

from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
from xgboost import XGBClassifier
from imblearn.over_sampling import SMOTE

# =========================
# 1. Load Dataset
# =========================
data_path = "data/phishing.csv"

if not os.path.exists(data_path):
    raise FileNotFoundError("❌ Dataset not found!")

data = pd.read_csv(data_path)

print("✅ Dataset Loaded")

# =========================
# 2. Target Encoding
# =========================
data["status"] = data["status"].map({
    "legitimate": 0,
    "phishing": 1
})

# =========================
# 3. FEATURE ENGINEERING (FINAL)
# =========================
def extract_features(url):
    return [
        len(url),                                  # length
        url.count("."),                            # dots
        url.count("-"),                            # hyphens
        url.count("@"),                            # @ symbol
        sum(c.isdigit() for c in url) / max(len(url), 1),  # digit ratio
        int("https" in url),                       # https
        int(any(word in url for word in ["login", "verify", "secure"])),  # keywords

        url.count("/"),                            # path depth
        url.count("="),                            # query params
        int("//" in url[8:]),                      # redirection trick
        int(len(url.split(".")) > 3),              # many subdomains

        url.count("%"),                            # encoded chars
        int(any(c.isupper() for c in url))         # uppercase presence
    ]

data["features"] = data["url"].apply(extract_features)

X = pd.DataFrame(data["features"].tolist(), columns=[
    "length",
    "dots",
    "hyphens",
    "at",
    "digit_ratio",
    "https",
    "keywords",
    "slashes",
    "equals",
    "double_slash",
    "subdomains",
    "percent",
    "uppercase"
])

y = data["status"]

# =========================
# 4. Train-Test Split
# =========================
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# =========================
# 5. Handle Imbalance (SMOTE)
# =========================
print("⚖️ Applying SMOTE...")
smote = SMOTE(random_state=42)
X_train, y_train = smote.fit_resample(X_train, y_train)

# =========================
# 6. Train Model (TUNED)
# =========================
model = XGBClassifier(
    n_estimators=400,
    max_depth=6,
    learning_rate=0.05,
    subsample=0.9,
    colsample_bytree=0.9,
    random_state=42,
    n_jobs=-1,
    eval_metric="logloss"
)

print("⏳ Training model...")
model.fit(X_train, y_train)

# =========================
# 7. Evaluation
# =========================
y_pred = model.predict(X_test)

print("\n📊 Classification Report:")
print(classification_report(y_test, y_pred))

# =========================
# 8. Save Model
# =========================
os.makedirs("app/models", exist_ok=True)
joblib.dump(model, "app/models/phishing_model.pkl")

print("✅ Model saved successfully!")