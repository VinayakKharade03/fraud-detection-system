import pandas as pd
import numpy as np
import joblib
import os

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report, roc_auc_score

from imblearn.over_sampling import SMOTE
import lightgbm as lgb

# =========================
# PATHS
# =========================
DATA_PATH = r"D:\fraud-detection-system\data\dataset.csv"
MODEL_PATH = r"D:\fraud-detection-system\app\models\fraud_model.pkl"
ENCODER_PATH = r"D:\fraud-detection-system\app\models\fraud_encoders.pkl"

# =========================
# LOAD DATA
# =========================
df = pd.read_csv(DATA_PATH)
df = df.sample(200000, random_state=42)

# =========================
# TIME FEATURES
# =========================
df['datetime'] = pd.to_datetime(df['unix_time'], unit='s')
df['hour'] = df['datetime'].dt.hour
df['day'] = df['datetime'].dt.day
df['month'] = df['datetime'].dt.month

df['is_night'] = (df['hour'] < 6).astype(int)

# =========================
# DISTANCE
# =========================
df['distance'] = np.sqrt(
    (df['lat'] - df['merch_lat'])**2 +
    (df['long'] - df['merch_long'])**2
)

# =========================
# AMOUNT FEATURES
# =========================
df['amt_log'] = np.log1p(df['amt'])
df['is_high_amt'] = (df['amt'] > 5000).astype(int)

# =========================
# ENCODING
# =========================
cat_cols = ['merchant', 'category', 'gender']
encoders = {}

for col in cat_cols:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col])
    encoders[col] = le

# =========================
# FEATURES
# =========================
features = [
    'merchant',
    'category',
    'amt',
    'amt_log',
    'is_high_amt',
    'day',
    'month',
    'hour',        # ✅ IMPORTANT
    'is_night',
    'gender',
    'distance'
]

X = df[features]
y = df['is_fraud']

# =========================
# SPLIT FIRST
# =========================
X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

# =========================
# SMOTE ONLY ON TRAIN
# =========================
smote = SMOTE(random_state=42)
X_train, y_train = smote.fit_resample(X_train, y_train)

# =========================
# MODEL
# =========================
model = lgb.LGBMClassifier(
    n_estimators=300,
    learning_rate=0.05
)

model.fit(X_train, y_train)

# =========================
# EVALUATION
# =========================
y_pred = model.predict(X_test)

print("\nClassification Report:\n")
print(classification_report(y_test, y_pred))
print("ROC AUC:", roc_auc_score(y_test, y_pred))

# =========================
# SAVE
# =========================
os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)

joblib.dump(model, MODEL_PATH)
joblib.dump(encoders, ENCODER_PATH)

print("\n✅ Model retrained and saved!")