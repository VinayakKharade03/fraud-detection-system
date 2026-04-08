# 🚀 AI Cyber Fraud Detection System

## 🏆 Achievement

🥈 Secured **2nd Place** in a **State-Level Competition**

---

## 🎯 Overview

A full-stack **AI-powered cyber fraud detection system** that analyzes multiple data sources in real-time to identify potential threats using Machine Learning and rule-based intelligence.

This system is designed to simulate **real-world fraud detection pipelines** used in fintech and cybersecurity applications.

---

## 🔍 Features

* 💳 UPI Fraud Detection
* 📷 QR Code Fraud Detection
* 🔗 Phishing URL Detection
* 📧 Email Phishing Detection
* 💬 Spam Message Detection
* 🎙️ Audio Deepfake Detection
* 🖼️ Image Deepfake Detection
* 🎥 Video Deepfake Detection
* 💰 Transaction Fraud Detection

---

## 🧠 Architecture

```
Flutter App (Frontend)
        ↓
Supabase Auth (JWT)
        ↓
FastAPI Backend (REST APIs)
        ↓
Fraud Detection Engine
(ML Models + Rule Engine)
        ↓
Supabase Database (Store Results)
        ↓
Fraud Detection Result
(Risk Score + Explanation)
```

---

## ⚙️ Tech Stack

**Backend:** FastAPI
**Frontend:** Flutter
**ML Models:** Scikit-learn, TensorFlow/Keras
**Libraries:** OpenCV, PyZbar, Joblib
**Language:** Python

---

## 🚀 Run Locally

### 🔹 Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### 🔹 API Docs

Open in browser:

```
http://127.0.0.1:8000/docs
```

---

## 🌐 Deployment (Render)

* Build Command:

```
pip install -r requirements.txt
```

* Start Command:

```
uvicorn app.main:app --host 0.0.0.0 --port 10000
```

---

## 🧠 Model Design

* Lightweight ML models (<30MB each)
* Combined with rule-based risk engine
* Supports multi-modal fraud detection (text, image, audio, video)

---

## 📸 Screenshots

*Add your app screenshots here*

---

## 🎥 Demo

*Add demo video link here*

---

## 💡 Key Highlights

* 🔥 Multi-domain fraud detection in one system
* ⚡ Real-time API-based architecture
* 🧠 Hybrid ML + rule-based decision engine
* 📱 Full-stack implementation (Flutter + FastAPI)

---

## 📌 Future Improvements

* Real-time streaming detection
* Model optimization with deep learning
* Cloud deployment with scaling
* Integration with banking APIs

---

## 👨‍💻 Author

Developed as part of an AI/ML project focused on real-world cybersecurity challenges.
