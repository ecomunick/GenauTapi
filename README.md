# GenauTapi 🐶 - AI German Speech Coach

GenauTapi is a German immersion speech coach app. Speak German, hear German replies, and improve your fluency through natural conversation with AI.

## 🌟 Features (v1.0)
- **German Immersion**: AI always replies in German (like Duolingo's Lili)
- **Real-time Speech Recognition**: German speech-to-text
- **Natural TTS**: German voice (de-DE) at learning-friendly speed
- **Dynamic AI Scoring**: Real feedback on grammar, vocabulary, and fluency
- **Gamification**: XP tracking and daily streaks
- **Free Conversation**: No topics, just speak naturally

## 🚀 Status
- **Backend**: Deployed on Render.com (`https://genautapi.onrender.com/`)
- **iOS App**: v1.0 Ready on Device

---

## 🛠 Usage Guide

### Can I disconnect the cable? 🔌
**YES!** 
Once you press "Run" in Xcode and the app opens on your phone:
1. You can stop the app in Xcode (Click Stop ⏹)
2. You can **unplug the cable**
3. The app is installed! Tap **GenauTapi** icon on your home screen
4. **Note**: Free Apple Developer accounts last **7 days**. After that, just plug in and press "Run" again to renew

---

## 💻 Backend Setup (Python)
The backend handles AI conversation and scoring using OpenAI.

### Deployment (Render)
Already configured for [Render.com](https://render.com):
1. **Service**: Web Service (Python 3)
2. **Build Command**: `pip install -r backend/requirements.txt`
3. **Start Command**: `cd backend && uvicorn main:app --host 0.0.0.0 --port $PORT`
4. **Environment Variables**:
   - `OPENAI_API_KEY`: Your key from `platform.openai.com`

### Local Development
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

---

## 📱 iOS Setup (Xcode)
See [xcode_guide.md](.gemini/antigravity/brain/d8f08c30-bd12-4227-a233-eea5dd4c1352/xcode_guide.md) for detailed instructions.

**Quick Start:**
1. **Open Project**: Double-click `GenauTapi.xcodeproj`
2. **Team / Signing**: Select your Personal Team in Signing & Capabilities
3. **Developer Mode** (iOS 16+): Settings > Privacy & Security > Developer Mode > ON
4. **Run**: Select your iPhone in top bar, press Play ▶️

---

## 📁 Project Structure
- `GenauTapi/` - iOS Source Code (SwiftUI)
- `backend/` - Python API (FastAPI)
- `Instructions.md` - Build instructions for agents
- `README.md` - This guide

---

## 🎯 How It Works
1. **Speak** in German using the microphone button
2. **AI listens** and generates a natural German response
3. **Tapi speaks back** in German (de-DE voice)
4. **Get scored** on grammar, vocabulary, and fluency (0-100)
5. **Earn XP** and maintain your daily streak! 🔥

---

## 🐶 About Tapi
GenauTapi (pronounced "geh-NOW-tah-pee") means "Exactly Tapi" in German. Tapi is your friendly AI dog coach who helps you practice German through natural conversation, just like Duolingo's Lili!

---

## 📝 Version History
- **v1.0** (Dec 2024): German immersion mode, dynamic scoring, simplified UI
- **v0.3**: Conversational mode added
- **v0.2**: Backend deployed to Render
- **v0.1**: Initial MVP with topic selection
