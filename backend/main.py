from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel
import os
import json

# Services
from services.chat import call_ai_coach
from services.leaderboard import update_score, get_top_scores

app = FastAPI(title="Genau Tapi! Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    transcript: str
    streak: int = 1
    memory: str = ""  # The AI's summary of previous conversations

@app.post("/chat")
async def chat_endpoint(req: ChatRequest, request: Request):
    user_ip = request.client.host
    # 1. AI Logic
    response = call_ai_coach(req.transcript, user_ip, req.memory)
    
    # 2. Update Leaderboard (Sync persistent steak)
    if len(req.transcript) > 2:
        update_score(user_ip, response.score, req.streak)
    
    return response

@app.get("/leaderboard")
def leaderboard_endpoint():
    return get_top_scores(10)

@app.get("/logo.png")
async def get_logo():
    current_dir = os.path.dirname(os.path.abspath(__file__)) # .../backend
    # Logo is in project root: .../backend/../tapi_1_logo.png
    logo_path = os.path.join(current_dir, "../tapi_1_logo.png")
    if os.path.exists(logo_path):
        return FileResponse(logo_path)
    return {"error": "Logo not found"}

@app.get("/")
async def read_index():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    # Reliable path: ./static/index.html inside backend
    frontend_path = os.path.join(current_dir, "static/index.html")
    if os.path.exists(frontend_path):
        return FileResponse(frontend_path)
    return {"message": "Genau Tapi! Backend is running. Frontend not found (checked static/index.html)."}

# Serve Audio Files
@app.get("/audio/{filename}")
async def get_audio(filename: str):
    audio_path = os.path.join("static/audio", filename)
    if os.path.exists(audio_path):
        return FileResponse(audio_path, media_type="audio/mpeg")
    return {"error": "Audio not found"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
