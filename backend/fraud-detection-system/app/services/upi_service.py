from datetime import datetime
import re
from difflib import get_close_matches

from app.utils.upi_providers import (
    extract_upi_handle,
    extract_username,
    is_valid_upi_provider,
    normalize_handle,
    has_hidden_chars,
    VALID_UPI_PROVIDERS
)


# =========================
# VALIDATION HELPERS
# =========================

def is_valid_upi_format(upi_id):
    pattern = r'^[a-zA-Z0-9.\-_]{2,50}@[a-zA-Z]{2,20}$'
    return bool(re.match(pattern, upi_id))


def is_similar_to_valid(handle):
    return get_close_matches(handle, VALID_UPI_PROVIDERS, n=1, cutoff=0.8)


# =========================
# MAIN ENGINE
# =========================

def upi_risk_engine(data):

    score = 0
    reasons = []

    amount = data["amount"]
    sender = data["sender_upi"].lower()
    receiver = data["receiver_upi"].lower()
    txn_id = str(data["transaction_id"])
    date = data["date"]

    # =========================
    # 1. FORMAT VALIDATION
    # =========================
    if not is_valid_upi_format(sender):
        score += 0.3
        reasons.append("Invalid sender UPI format")

    if not is_valid_upi_format(receiver):
        score += 0.3
        reasons.append("Invalid receiver UPI format")

    # =========================
    # 2. AMOUNT BEHAVIOR
    # =========================
    if amount > 80000:
        score += 0.4
        reasons.append("Very high transaction amount")

    elif amount > 30000:
        score += 0.25
        reasons.append("High transaction amount")

    elif amount < 10:
        score += 0.1
        reasons.append("Suspicious micro transaction")

    if amount in [9999, 4999, 1999]:
        score += 0.2
        reasons.append("Common scam amount pattern")

    # =========================
    # 3. HANDLE VALIDATION
    # =========================
    sender_handle = extract_upi_handle(sender)
    receiver_handle = extract_upi_handle(receiver)

    sender_norm = normalize_handle(sender_handle)
    receiver_norm = normalize_handle(receiver_handle)

    if not is_valid_upi_provider(sender_handle):
        if is_similar_to_valid(sender_handle):
            score += 0.5
            reasons.append("Sender provider spoofing attempt")
        else:
            score += 0.35
            reasons.append("Unknown sender UPI provider")

    if not is_valid_upi_provider(receiver_handle):
        if is_similar_to_valid(receiver_handle):
            score += 0.5
            reasons.append("Receiver provider spoofing attempt")
        else:
            score += 0.4
            reasons.append("Unknown receiver UPI provider")

    # =========================
    # 4. USERNAME INTELLIGENCE
    # =========================
    sender_user = extract_username(sender)
    receiver_user = extract_username(receiver)

    risky_words = ["offer", "win", "free", "reward", "cash", "prize",
                   "verify", "secure", "update", "refund", "support"]

    if receiver_user:
        if sum(c.isdigit() for c in receiver_user) > 5:
            score += 0.2
            reasons.append("Numeric-heavy receiver UPI")

        if any(word in receiver_user for word in risky_words):
            score += 0.4
            reasons.append("Fraud keyword in receiver UPI")

        if len(set(receiver_user)) < len(receiver_user) / 2:
            score += 0.2
            reasons.append("Random-looking receiver ID")

    # =========================
    # 5. SENDER-RECEIVER CHECK
    # =========================
    if sender == receiver:
        score += 0.4
        reasons.append("Sender and receiver are same")

    if "new" in receiver or "unknown" in receiver:
        score += 0.2
        reasons.append("Suspicious receiver label")

    # =========================
    # 6. TRANSACTION ID ANALYSIS
    # =========================
    if len(txn_id) < 8 or len(txn_id) > 20:
        score += 0.2
        reasons.append("Unusual transaction ID length")

    if txn_id in ["123456789012", "000000000000"]:
        score += 0.3
        reasons.append("Fake transaction ID pattern")

    if len(set(txn_id)) == 1:
        score += 0.2
        reasons.append("Repetitive transaction ID")

    # =========================
    # 7. DATE VALIDATION
    # =========================
    try:
        txn_date = datetime.strptime(date, "%Y-%m-%d")
        today = datetime.today()

        if txn_date > today:
            score += 0.3
            reasons.append("Future transaction date")

    except:
        score += 0.2
        reasons.append("Invalid date format")

    # =========================
    # 8. HIDDEN CHARACTER CHECK
    # =========================
    if has_hidden_chars(sender) or has_hidden_chars(receiver):
        score += 0.5
        reasons.append("Hidden characters detected")

    # =========================
    # FINAL NORMALIZATION
    # =========================
    score = min(score, 1.0)

    if score < 0.3:
        level = "SAFE"
    elif score < 0.6:
        level = "SUSPICUOUS"
    else:
        level = "FRAUD"

    fraud = level == "FRAUD"

    return {
        "fraud": fraud,
        "risk_score": round(score, 2),
        "reasons": reasons
    }