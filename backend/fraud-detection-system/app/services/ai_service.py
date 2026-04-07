import os
import requests
import time

GROQ_API_KEY = os.getenv("GROQ_API_KEY")

def get_ai_response(message: str) -> str:
    try:
        start_time = time.time()

        # 🔥 DEBUG 1: Check API key exists
        print("\n========== GROQ DEBUG START ==========")
        if not GROQ_API_KEY:
            print("❌ GROQ_API_KEY is NOT loaded from environment")
        else:
            print("✅ GROQ_API_KEY loaded:", GROQ_API_KEY[:6] + "*****")

        url = "https://api.groq.com/openai/v1/chat/completions"

        payload = {
            "model": "llama-3.3-70b-versatile",
            "messages": [
                {
                    "role": "system",
                    "content": "You are a fraud detection assistant."
                },
                {
                    "role": "user",
                    "content": message
                }
            ],
        }

        headers = {
            "Authorization": f"Bearer {GROQ_API_KEY}",
            "Content-Type": "application/json",
        }

        # 🔥 DEBUG 2: Request info
        print("📤 Sending request to:", url)
        print("📦 Payload:", payload)

        response = requests.post(url, headers=headers, json=payload)

        # 🔥 DEBUG 3: Status code
        print("📊 Status Code:", response.status_code)

        # 🔥 DEBUG 4: Raw response text
        print("📥 RAW RESPONSE TEXT:", response.text)

        data = response.json()

        # 🔥 DEBUG 5: Parsed JSON
        print("🧾 PARSED JSON:", data)

        # safety check
        if "choices" not in data:
            print("❌ Missing 'choices' in response")
            return f"API Error: {data}"

        result = data["choices"][0]["message"]["content"]

        # 🔥 DEBUG 6: Time taken
        print("⏱️ Response time:", round(time.time() - start_time, 2), "seconds")
        print("========== GROQ DEBUG END ==========\n")

        return result

    except Exception as e:
        print("❌ EXCEPTION OCCURRED:", str(e))
        return f"Error: {str(e)}"