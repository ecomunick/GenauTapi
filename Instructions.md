# GenauTapi - AI Speech Coach (German↔English) 🐶

## 🚀 AGENT AUTOPILOT MODE
**BUILD COMPLETE MVP WITHOUT USER INPUT.** Data science user, no iOS experience. Handle all SwiftUI, APIs, deployment autonomously.

## FINAL MVP SCOPE (All features, no phases)
✅ Language toggle: DE→EN / EN→DE
✅ 3 Topics: "Daily Life", "Shopping", "Job Interview"
✅ Speak → AI corrects → TTS reply + score
✅ XP bar + daily streak
✅ Backend API live on Render.com
✅ iPhone-ready Xcode project
✅ Dog-themed UI (Tapi mascot)

text

## FULL AUTONOMOUS TASK LIST

### 1. PROJECT SETUP (5 min)
Rename project: GenauTapi everywhere

Add dog emoji 🐶 to app name/title

Create app icon: Cute dog with speech bubble + "Genau!"

Git commit: "feat: rebrand-to-genautapi"

text

### 2. BACKEND (Python - Your Comfort Zone)
Create backend/ folder → COMPLETE FastAPI app:

main.py:

python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import openai  # or requests to Perplexity API

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"])

class ChatRequest(BaseModel):
    transcript: str
    source_lang: str
    target_lang: str
    topic: str

TOPICS = {
    "Daily Life": "Act as friendly neighbor chatting about weather, family, weekend plans",
    "Shopping": "Act as German supermarket cashier. Keep it simple, correct politely",
    "Job Interview": "Act as HR manager conducting B1 German job interview. Professional but encouraging"
}

@app.post("/chat")
async def chat(request: ChatRequest):
    prompt = f"""You are GenauTapi 🐶, patient German-English speech coach.
Topic: {TOPICS[request.topic]}
User said (in {request.source_lang}): "{request.transcript}"
Give short reply in {request.target_lang}, correct grammar, score 0-100."""
    
    # Use Perplexity/OpenAI - add your API key later
    response = openai.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "system", "content": prompt}]
    )
    
    reply = response.choices[0].message.content
    score = 85  # Parse from reply or simple heuristic
    
    return {
        "reply": reply,
        "correction": f"Genau! Say: {request.transcript.upper()}",
        "score": score,
        "xp": score // 10
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
Deploy:

requirements.txt: fastapi, uvicorn, openai, pydantic

Procfile: web: uvicorn main:app --host=0.0.0.0 --port=$PORT

Push to Render.com (free tier)

Return LIVE_API_URL for frontend

text

### 3. FRONTEND (SwiftUI - Agents Handle Everything)
ContentView.swift - COMPLETE app:

MAIN SCREENS:

Welcome: "GenauTapi 🐶 Your Speech Coach!" + Language picker

Topics: ["Daily Life", "Shopping", "Job Interview"]

Chat: Speak button → Loading → AI reply (TTS + text) + XP bar

Profile: XP total, streak counter, Tapi dog mascot

KEY FEATURES (implement ALL):

SFSpeechRecognizer (DE/EN locales)

AVSpeechSynthesizer (voice replies)

URLSession POST to LIVE_API_URL/chat

UserDefaults: xp_total, streak_days, selected_lang

ProgressView for XP (0-100 → green dog emoji at 100)

text

### 4. UI COPY (Exact Text)
Welcome: "GenauTapi 🐶 Practice speaking like a local!"
Language: ["🇩🇪 Deutsch → 🇺🇸 English", "🇺🇸 English → 🇩🇪 Deutsch"]
Speak button: "🎤 Sprechen!"
Topics: "🛒 Shopping", "💼 Job Interview", "🏠 Daily Life"
After reply: "Woof! 🐕 Score: 85/100 🎉"

text

### 5. GIT + DEPLOYMENT WORKFLOW
EVERY MAJOR TASK:
git add . && git commit -m "feat: [TASK_DESCRIPTION]" && git push origin main

FINAL CHECKLIST:
[ ] Backend live: https://genautapi-backend.onrender.com/chat POST works
[ ] Xcode builds → Simulator mic/TTS/backend work
[ ] iPhone USB test ready (free Apple ID)
[ ] README.md with screenshots + API docs
[ ] GitHub Pages demo video

text

## 🐕 DOG MASCOT ASSETS
App Icon: Cartoon Tapi dog + speech bubble "Genau!"
Loading: Tapi wagging tail
Perfect score: Tapi with medal 🥇
Streak: Tapi counter "3 Tage! Woof! 🐶"

text

## AGENT EXECUTION ORDER
"Read this ENTIRE Instructions.md → confirm understanding"

"Build COMPLETE backend → deploy Render → return LIVE_API_URL"

"Replace ALL SpeechRecognition code → GenauTapi MVP screens"

"Connect speech → backend → TTS → XP system"

"Polish UI with dog theme + exact copy above"

"Test Simulator → generate iPhone instructions"

"Create README + demo GIF → FINAL git push"


## SUCCESS CRITERIA
✅ App says "GenauTapi 🐶" on launch
✅ Speak German → AI replies English (or reverse)
✅ Backend responds <2s with score/XP
✅ XP persists between app restarts
✅ GitHub repo ready for portfolio

text

## NO USER INPUT NEEDED
Execute autonomously. Data science user trusts agents completely.