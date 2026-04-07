def generate_reasons(t, p, u, d, data):
    reasons = []

    if t == 1:
        reasons.append("Unusual transaction detected")

    if p == 1:
        reasons.append("Suspicious URL or text detected")

    if u == 1:
        reasons.append("UPI risk detected")

    if d == 1:
        reasons.append("Possible deepfake detected")

    if not reasons:
        reasons.append("No major fraud signals detected")

    return reasons