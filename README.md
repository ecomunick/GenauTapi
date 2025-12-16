# Genau Tapi! 🐶🇩🇪
> *Your Chill German Conversational Companion*

**Genau Tapi!** is an AI-powered language coach designed to help you speak German naturally. Unlike strict grammar teachers, Tapi acts like a "chill friend"—prioritizing conversation flow and only correcting you when it really matters.

The core experience is built for **iOS**, providing a native, fluid voice interface. A web version is available for demonstration.

---

## 🌟 Key Features

### 🧠 **Distributed "Long-Term" Memory**
- **Context Awareness**: Tapi remembers your name, hobbies, and past topics even if you restart the app or the server wipes.
- **Client-Side Persistence**: To save tokens and ensure privacy, the "Memory Context" is stored on your device (iOS UserDefaults) and synced with the AI during conversation.

### 🗣️ **Natural Voice Interaction**
- **"Chill Friend" Persona**: The AI ignores minor mistakes (Grammar Score > 60) to keep the conversation flowing. It only interrupts with corrections if you make significant errors.
- **High-Quality TTS**: Uses OpenAI's `nova` voice for a warm, natural German accent.
- **Robust Audio Streaming**: Audio is streamed as Base64 data, ensuring instant playback without relying on temporary server files (Cloud-Native design).

### 📊 **Smart Scoring & Analytics**
- **Real-time Feedback**: Get instant scores on **Grammar** and **Style** (Naturalness).
- **Streak Tracking**: Keeps you motivated with a daily streak counter.
- **Leaderboard**: Compete globally with other users (tracked via IP and persistent streak sync).

---

## 📱 iOS App (Main Experience)
The **Genau Tapi iOS App** is the primary way to use the platform.
- **Native SwiftUI Interface**: Smooth animations and haptic feedback.
- **Continuous Speech Recognition**: Just speak naturally; the app listens.
- **Smart Audio Session**: Seamlessly handles recording and playback without cutting off background audio ungracefully.

*(Code located in `GenauTapi/` folder)*

---

## 🌐 Web Demo
A web-based "Walkie-Talkie" version is available for testing and demonstration.
- **URL**: [https://genautapi.onrender.com/](https://genautapi.onrender.com/)
- **Toggle-to-Talk**: Tap the mic to start listening, speak freely (even with pauses), and tap again to send. Perfect for thoughtful practice.

---

## 🛠️ Technical Stack

- **Backend**: Python (FastAPI)
  - `openai` (GPT-4o-mini + TTS-1)
  - `pydantic` for data validation
  - Stateless architecture with client-injected state
- **Frontend (iOS)**: Swift (SwiftUI)
  - `AVFoundation` for audio
  - `Speech` framework for recognition
- **Frontend (Web)**: HTML/JS (Vanilla)
  - Web Speech API
- **Deployment**: Render (Docker/Python)

## 🚀 Deployment

The backend is deployed on **Render** free tier.
- **Base URL**: `https://genautapi.onrender.com`
- **Environment Inputs**: `OPENAI_API_KEY`

---

*Made with 🥨 and 🍺 by ecomunick*
