# GenauTapi - AI German Speech Coach 🐶

## 🚀 AGENT AUTOPILOT MODE
**BUILD COMPLETE MVP WITHOUT USER INPUT.** Data science user, no iOS experience. Handle all SwiftUI, APIs, deployment autonomously.

## FINAL MVP SCOPE (v1.0 - German Immersion)
✅ **German-Only Immersion**: Speak German, hear German replies
✅ **No Topics**: Free conversation mode (like Duolingo's Lili)
✅ **AI Conversation**: Natural German chat with dynamic scoring
✅ **TTS in German**: Always uses German voice (de-DE)
✅ **XP + Streaks**: Gamification with daily tracking
✅ **Backend API**: Live on Render.com
✅ **iPhone-ready**: Xcode project with signing guide
✅ **Dog-themed UI**: Tapi mascot 🐶

---

## FULL AUTONOMOUS TASK LIST

### 1. PROJECT SETUP (5 min)
- Rename project: GenauTapi everywhere
- Add dog emoji 🐶 to app name/title
- Git commit: `feat: rebrand-to-genautapi`

---

### 2. BACKEND (Python - FastAPI)
Create `backend/` folder → COMPLETE FastAPI app:

**main.py:**
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import openai
import re

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

class ChatRequest(BaseModel):
    transcript: str
    source_lang: str
    target_lang: str
    topic: str

@app.get("/")
def home():
    return {"message": "GenauTapi Backend is LIVE! 🐶", "status": "Ready to chat"}

@app.post("/chat")
async def chat(request: ChatRequest):
    # German Immersion Mode
    system_instruction = f"""You are GenauTapi 🐶, a fluent German speaker.
User said: "{request.transcript}"
Task:
1. Act as a friendly conversational partner.
2. Reply ONLY in German.
3. Do not switch to English.
4. Keep replies concise and natural (1-2 sentences max).
5. Do not correct grammar unless the user makes no sense.
6. At the END of your response, add a score on a new line in this exact format: [SCORE: XX]
   where XX is 0-100 based on grammar, vocabulary, and fluency."""

    api_key = os.getenv("OPENAI_API_KEY")
    client = openai.OpenAI(api_key=api_key) if api_key else None
    
    reply = "Simulation: Genau! (OpenAI Key missing)"
    score = 85

    if client:
        try:
            response = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "system", "content": system_instruction}]
            )
            full_reply = response.choices[0].message.content
            
            # Parse score from response
            score_match = re.search(r'\[SCORE:\s*(\d+)\]', full_reply)
            if score_match:
                score = int(score_match.group(1))
                reply = re.sub(r'\s*\[SCORE:\s*\d+\]', '', full_reply).strip()
            else:
                reply = full_reply
                score = 75
        except Exception as e:
             reply = f"Error calling AI: {str(e)}"

    return {
        "reply": reply,
        "correction": "",
        "score": score,
        "xp": score // 10
    }
```

**Deploy:**
- `requirements.txt`: fastapi, uvicorn, openai, pydantic
- `Procfile`: `web: cd backend && uvicorn main:app --host=0.0.0.0 --port=$PORT`
- Push to Render.com (free tier)
- Set `OPENAI_API_KEY` environment variable

---

### 3. FRONTEND (SwiftUI - Complete App)

**MAIN SCREENS:**
1. **Welcome**: "GenauTapi 🐶" + "🇩🇪 Speak German, Learn German!" + Start button
2. **Chat**: Microphone button → AI reply (German TTS) + Score display
3. **Profile**: XP total, streak counter, Tapi dog mascot

**KEY FEATURES (implement ALL):**
- `SFSpeechRecognizer` (de-DE locale for German input)
- `AVSpeechSynthesizer` (de-DE voice, rate 0.5 for learning)
- `URLSession` POST to backend `/chat`
- `UserDefaults`: xp_total, streak_days
- Dynamic score display from AI response
- Back button in Chat header to return to Welcome

**REMOVED FEATURES (Simplified for v1):**
- ❌ Language toggle (German-only now)
- ❌ Topic selection (Free conversation only)
- ❌ Correction text display (Immersion mode)

---

### 4. UI COPY (Exact Text)
- Welcome: "GenauTapi 🐶 Practice speaking like a local!"
- Subtitle: "🇩🇪 Speak German, Learn German!"
- Speak button: "🎤 Sprechen!"
- Chat header: "GenauTapi Chat 🇩🇪"
- After reply: "Score: XX/100 🎉"

---

### 5. GIT + DEPLOYMENT WORKFLOW
**EVERY MAJOR TASK:**
```bash
git add . && git commit -m "feat: [TASK_DESCRIPTION]" && git push origin main
```

**FINAL CHECKLIST:**
- [x] Backend live: https://genautapi.onrender.com/ POST works
- [x] Xcode builds → Simulator/iPhone mic/TTS/backend work
- [x] German TTS voice (de-DE) working
- [x] Dynamic AI scoring implemented
- [x] README.md with setup instructions
- [x] Xcode guide for beginners

---

## 🐕 DOG MASCOT ASSETS
- App Icon: Cartoon Tapi dog + speech bubble "Genau!"
- Profile: Tapi with pawprint icon
- Streak: Tapi counter "X �"

---

## AGENT EXECUTION ORDER
1. "Read this ENTIRE Instructions.md → confirm understanding"
2. "Build COMPLETE backend → deploy Render → return LIVE_API_URL"
3. "Replace ALL SpeechRecognition code → GenauTapi MVP screens"
4. "Connect speech → backend → TTS → XP system"
5. "Polish UI with dog theme + exact copy above"
6. "Test Simulator → generate iPhone instructions"
7. "Create README + Xcode guide → FINAL git push"

---

## SUCCESS CRITERIA (v1.0)
✅ App says "GenauTapi 🐶" on launch
✅ Speak German → AI replies in German (de-DE voice)
✅ Backend responds <2s with dynamic score/XP
✅ XP persists between app restarts
✅ No language toggle (German-only immersion)
✅ Free conversation (no topic selection)
✅ Back button for navigation
✅ GitHub repo ready for portfolio

---

## NO USER INPUT NEEDED
Execute autonomously. Data science user trusts agents completely.