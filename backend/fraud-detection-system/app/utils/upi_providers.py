# =========================
# UPI VALID PROVIDERS REGISTRY
# =========================

VALID_UPI_PROVIDERS = {
    "oksbi", "sbi",
    "okhdfcbank", "hdfcbank",
    "okicici", "icici",
    "okaxis", "axisbank", "axl",
    "ybl", "yesbank",
    "ibl",
    "okkotak", "kotak",
    "paytm",
    "okunionbank", "okpnb", "okcanara", "okbob",
    "fbl", "airtel", "upi"
}


# =========================
# HELPERS
# =========================

def extract_upi_handle(upi_id: str):
    if not upi_id or "@" not in upi_id:
        return None
    return upi_id.split("@")[-1].lower().strip()


def extract_username(upi_id: str):
    if not upi_id or "@" not in upi_id:
        return None
    return upi_id.split("@")[0].lower().strip()


def is_valid_upi_provider(handle: str):
    if not handle:
        return False
    return handle in VALID_UPI_PROVIDERS


def normalize_handle(handle: str):
    if not handle:
        return ""
    return ''.join(c for c in handle if c.isalpha())


def has_hidden_chars(text: str):
    if not text:
        return False
    return any(ord(c) in range(8203, 8290) for c in text)