# GenauTapi 🐶 - AI Speech Coach

GenauTapi is a personal AI-powered speech coach that helps you practice speaking German. It uses your iPhone's speech recognition to listen to you and a Python AI backend to correct your grammar and reply to you.

## 🌟 Features
- **Real-time Speech Recognition**: Specific to German/English.
- **AI Feedback**: Corrects grammar and rates your sentences.
- **Voice Replies**: The dog (Tapi) speaks back to you!
- **Gamification**: XP tracking and daily streaks.
- **3 Practice Modes**: Daily Life 🏠, Shopping 🛒, Job Interview 💼.

## 🚀 Status
- **Backend**: Deployed on Render.com (`https://genautapi.onrender.com/chat`)
- **iOS App**: MVP Ready on Device.

---

## 🛠 Usage Guide

### Can I disconnect the cable? 🔌
**YES!** 
Once you press "Run" in Xcode and the app opens on your phone:
1. You can stop the app in Xcode (Click Stop ⏹).
2. You can **unplug the cable**.
3. You can verify the app works by tapping the **GenauTapi** icon on your home screen.
4. **Note**: On a free Apple Developer account, the app will work for **7 days**. After that, you just need to plug it in and press "Run" in Xcode again to renew it.

---

## 💻 Backend Setup (Python)
The backend handles the AI logic (OpenAI) and scoring.

### Deployment (Render)
The backend is already configured for [Render.com](https://render.com).
1. **Service**: Web Service (Python 3).
2. **Build Command**: `pip install -r backend/requirements.txt`
3. **Start Command**: `cd backend && uvicorn main:app --host 0.0.0.0 --port $PORT`
4. **Environment Variables**:
   - `OPENAI_API_KEY`: Your key from `platform.openai.com`.

### Local Development
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

---

## 📱 iOS Setup (Xcode)
1. **Open Project**: Double-click `GenauTapi` in this folder.
2. **Team / Signing**:
   - Go to project settings > **Signing & Capabilities**.
   - Select your **Personal Team**.
   - If "Status: No Account", re-select the team or sign in via Xcode > Settings > Accounts.
3. **Developer Mode** (Important):
   - Only for iOS 16+: Go to Settings > Privacy & Security > Developer Mode > **ON**.
   - Restart phone & click "Turn On".
4. **Run**:
   - Select your iPhone in the top bar.
   - Press **Play ▶️**.

---

## 📁 Project Structure
- `GenauTapi/` - iOS Source Code (SwiftUI).
- `backend/` - Python API (FastAPI).
- `README.md` - This guide.
