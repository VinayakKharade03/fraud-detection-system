def calculate_risk(t, p, u, d):
    """
    t = transaction fraud (0/1)
    p = phishing (0/1)
    u = upi fraud (0/1)
    d = deepfake (0/1)
    """

    risk = (t * 0.4) + (p * 0.3) + (u * 0.2) + (d * 0.1)

    return round(risk, 2)