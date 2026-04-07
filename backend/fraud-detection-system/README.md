# 🚀 AI Cyber Fraud Detection System

A unified fraud detection system built using FastAPI and Machine Learning to detect multiple types of cyber fraud in real-time.

---

## 🎯 Project Overview

This system analyzes different types of inputs and detects potential fraud using rule-based logic and ML models.

### 🔍 Supports Detection For:
- 💳 UPI Fraud Detection
- 📷 QR Code Fraud Detection
- 🔗 Phishing URL Detection
- 📧 Email Phishing Detection
- 💬 Spam Message Detection
- 🎙️ Audio Deepfake Detection
- 🖼️ Image Deepfake Detection
- 🎥 Video Deepfake Detection
- 💰 Transaction Fraud Detection

---

## ⚙️ Tech Stack

- **Backend:** FastAPI  
- **ML Models:** Scikit-learn, TensorFlow/Keras  
- **Libraries:** OpenCV, PyZbar, Joblib  
- **Language:** Python  

---

## 🚀 How to Run

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload