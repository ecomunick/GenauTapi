from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
import os
import openai
import requests

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    transcript: str
    source_lang: str
    target_lang: str
    topic: str

TOPICS = {
    "Daily Life": "Act as friendly neighbor chatting about weather, family, weekend plans",
    "Shopping": "Act as German supermarket cashier. Keep it simple, correct politely",
    "Job Interview": "Act as HR manager conducting B1 German job interview. Professional but encouraging",
    "Free Conversation": "Act as a friendly conversational partner. Chat naturally. Prioritize keeping the conversation flowing."
}

@app.get("/")
def home():
    return {"message": "GenauTapi Backend is LIVE! 🐶", "status": "Ready to chat"}

def call_openai(prompt: str) -> str:
    if not OPENAI_API_KEY:
        return (
            "REPLY: Simulation: Genau! (OpenAI key missing)\n"
            "CORRECTED:\n"
            "SHOULD_REPEAT: NO\n"
            "PRONUNCIATION_TIP:\n"
            "SCORE: 80"
        )

    client = openai.OpenAI(api_key=OPENAI_API_KEY)
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "system", "content": prompt}],
    )
    return response.choices[0].message.content

def call_gemini(prompt: str) -> str:
    if not GEMINI_API_KEY:
        return (
            "REPLY: Simulation: Genau! (Gemini key missing)\n"
            "CORRECTED:\n"
            "SHOULD_REPEAT: NO\n"
            "PRONUNCIATION_TIP:\n"
            "SCORE: 80"
        )

    url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    params = {"key": GEMINI_API_KEY}
    body = {
        "contents": [
            {"parts": [{"text": prompt}]}
        ]
    }
    resp = requests.post(url, params=params, json=body, timeout=20)
    resp.raise_for_status()
    data = resp.json()
    return data["candidates"][0]["content"]["parts"][0]["text"]

def call_llm(prompt: str) -> str:
    # Prefer Gemini, fallback to OpenAI, then simulation
    try:
        if GEMINI_API_KEY:
            return call_gemini(prompt)
    except Exception:
        pass

    try:
        if OPENAI_API_KEY:
            return call_openai(prompt)
    except Exception:
        pass

    return (
        "REPLY: Simulation: Genau! (no LLM configured)\n"
        "CORRECTED:\n"
        "SHOULD_REPEAT: NO\n"
        "PRONUNCIATION_TIP:\n"
        "SCORE: 75"
    )

@app.post("/chat")
async def chat(request: ChatRequest):
    topic_instruction = TOPICS.get(request.topic or "Free Conversation", TOPICS["Free Conversation"])

    system_instruction = f"""
You are GenauTapi 🐶, a supportive speaking coach.

The user is practicing {request.target_lang} (usually German).
Their comfortable language is {request.source_lang}.

User said: "{request.transcript}"

Goals:
1. Reply PRIMARILY in {request.target_lang}. 
2. You MAY use {request.source_lang} occasionally to explain a mistake if needed, or if the user asks in that language.
3. Evaluate grammar, vocabulary and pronunciation quality of the user's sentence.
4. Decide if their pronunciation is good enough:
   - If it is GOOD: encourage them and do NOT ask to repeat.
   - If it is WEAK or CONFUSING: show a short corrected sentence and politely ask them to repeat it aloud.
5. When you ask for repetition, give a very short example of good pronunciation (describe it in words, not phonetic alphabet).
6. Keep your answer short and friendly (2–3 sentences).

Scoring:
- If the user speaks very well on the first attempt (like a natural sentence with minor issues), give a high score.
- If they consistently speak well for several turns (3–5 in a row), feel free to give 100/100.
- Otherwise, adjust the score proportionally to the quality (grammar, vocabulary, pronunciation).

Output format (VERY IMPORTANT):
You MUST answer in this JSON-like structure in plain text:

REPLY: <your short reply that the app will speak aloud>
CORRECTED: <corrected version of what the user tried to say, in {request.target_lang}, or empty if not needed>
SHOULD_REPEAT: <YES or NO>
PRONUNCIATION_TIP: <one short tip or example if SHOULD_REPEAT is YES, else empty>
SCORE: <number 0-100>
"""

    full_reply = call_llm(system_instruction)

    reply_text = "Simulation: Genau! (no LLM configured)"
    corrected = ""
    should_repeat = False
    pron_tip = ""
    score = 75

    for line in full_reply.splitlines():
        line = line.strip()
        if line.startswith("REPLY:"):
            reply_text = line[len("REPLY:"):].strip()
        elif line.startswith("CORRECTED:"):
            corrected = line[len("CORRECTED:"):].strip()
        elif line.startswith("SHOULD_REPEAT:"):
            val = line[len("SHOULD_REPEAT:"):].strip().upper()
            should_repeat = (val == "YES")
        elif line.startswith("PRONUNCIATION_TIP:"):
            pron_tip = line[len("PRONUNCIATION_TIP:"):].strip()
        elif line.startswith("SCORE:"):
            try:
                score = int(line[len("SCORE:"):].strip())
            except ValueError:
                score = 75

    return {
        "reply": reply_text,
        "correction": corrected,
        "should_repeat": should_repeat,
        "pronunciation_tip": pron_tip,
        "score": score,
        "xp": score // 10,
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
