import pandas as pd
import joblib
import os

from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, roc_auc_score

# =========================
# PATHS
# =========================
DATA_PATH = r"D:\fraud-detection-system\data\spam.csv"
MODEL_PATH = r"D:\fraud-detection-system\app\models\spam_model.pkl"
VECTORIZER_PATH = r"D:\fraud-detection-system\app\models\spam_vectorizer.pkl"

# =========================
# LOAD DATA (ROBUST)
# =========================
print("📥 Loading dataset...")

df = pd.read_csv(DATA_PATH, encoding='latin-1')

# Keep only first 2 columns (safe for all formats)
df = df.iloc[:, :2]
df.columns = ['label', 'message']

# Drop missing
df.dropna(inplace=True)

print("Columns:", df.columns)
print("Sample data:\n", df.head())

# =========================
# LABEL ENCODING
# =========================
df['label'] = df['label'].str.lower().map({'ham': 0, 'spam': 1})

# Remove unknown labels (if any)
df = df[df['label'].isin([0, 1])]

# =========================
# SPLIT
# =========================
X_train, X_test, y_train, y_test = train_test_split(
    df['message'],
    df['label'],
    test_size=0.2,
    random_state=42,
    stratify=df['label']
)

# =========================
# TF-IDF VECTORIZATION
# =========================
print("🔤 Vectorizing text...")

vectorizer = TfidfVectorizer(
    stop_words='english',
    max_features=5000,
    ngram_range=(1, 2)  # 🔥 big improvement
)

X_train_vec = vectorizer.fit_transform(X_train)
X_test_vec = vectorizer.transform(X_test)

# =========================
# MODEL
# =========================
print("🤖 Training model...")

model = LogisticRegression(max_iter=1000)
model.fit(X_train_vec, y_train)

# =========================
# EVALUATION
# =========================
print("\n📊 Evaluation:\n")

y_pred = model.predict(X_test_vec)
y_prob = model.predict_proba(X_test_vec)[:, 1]

print(classification_report(y_test, y_pred))
print("ROC AUC:", roc_auc_score(y_test, y_prob))

# =========================
# SAVE MODEL
# =========================
print("\n💾 Saving model...")

os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)

joblib.dump(model, MODEL_PATH)
joblib.dump(vectorizer, VECTORIZER_PATH)

print("✅ Spam model saved successfully!")