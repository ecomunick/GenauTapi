# GenauTapi 🐶 - AI Speech Coach

GenauTapi is an internal AI-powered language learning assistant focused on German-English speech practice. It uses OpenAI/Perplexity to act as a conversational partner, correcting your grammar and helping you speak like a local.

## Features
- **Speech Recognition**: Local speech-to-text processing (German/English).
- **AI Coach**: Interactive roleplay scenarios (Daily Life, Shopping, Job Interview).
- **TTS**: Voice replies from the AI.
- **Gamification**: XP tracking and daily streaks to keep you motivated.
- **Backend API**: Python FastAPI backend for AI processing.

## Setup

### Backend (Python)
The backend requires Python 3.9+.

1. Navigate to the `backend` folder.
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Set your OpenAI API Key (optional for mock mode):
   ```bash
   export OPENAI_API_KEY="sk-..."
   ```
4. Run the server:
   ```bash
   uvicorn main:app --reload
   ```

### Frontend (iOS)
1. Open `GenauTapi.xcodeproj` in Xcode.
2. Select your development team in the Signing & Capabilities tab.
3. Build and run on a Simulator or Device.
   - **Note**: Speech Recognition requires microphone permission which works best on a physical device.

## Deployment to Render.com
1. Connect this repository to your Render.com account.
2. Select "Web Service".
3. Render will detect the `Procfile` in `backend/`.
4. Add environment variable `OPENAI_API_KEY`.
5. Update `GenauTapiModel.swift` in the iOS app with your new Render URL.

## Architecture
- **Frontend**: SwiftUI, SFSpeechRecognizer, AVSpeechSynthesizer.
- **Backend**: FastAPI, OpenAI API.
