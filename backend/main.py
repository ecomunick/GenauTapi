from fastapi import FastAPI, Request, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel
from sqlalchemy.orm import Session
import os
import json

# Services
from services.chat import call_ai_coach
from database import get_db, engine
from models import Base, UserSession, ChatMessage

# Ensure tables exist (redundant if using alembic, but safe for dev)
# Base.metadata.create_all(bind=engine)

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
    session_id: str | None = None # Optional session ID to link history

class SessionResponse(BaseModel):
    id: str
    created_at: str

@app.post("/sessions", response_model=SessionResponse)
def create_session(request: Request, db: Session = Depends(get_db)):
    user_ip = request.client.host
    new_session = UserSession(user_ip=user_ip)
    db.add(new_session)
    db.commit()
    db.refresh(new_session)
    return {"id": new_session.id, "created_at": str(new_session.created_at)}

@app.get("/history/{session_id}")
def get_history(session_id: str, db: Session = Depends(get_db)):
    session = db.query(UserSession).filter(UserSession.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    # Format messages nicely
    history = []
    for msg in session.messages:
        history.append({
            "role": msg.role,
            "content": msg.content,
            # "meta": msg.meta_data 
        })
    return {"messages": history}

@app.post("/chat")
async def chat_endpoint(req: ChatRequest, request: Request, db: Session = Depends(get_db)):
    user_ip = request.client.host

    session = None
    if req.session_id:
        session = db.query(UserSession).filter(UserSession.id == req.session_id).first()
        # If session not found, we could error or just proceed without saving history. 
        # Let's proceed but warn or just skip saving. 
        # For strictness: raise HTTPException(status_code=404, detail="Session ID invalid")
    
    # Save User Message
    if session:
        user_msg = ChatMessage(
            session_id=session.id,
            role="user",
            content=req.transcript,
            meta_data={"streak": req.streak}
        )
        db.add(user_msg)
        db.commit()

    # 1. AI Logic
    response = call_ai_coach(req.transcript, user_ip, req.memory)
    
    # Save Assistant Message
    if session:
        ai_msg = ChatMessage(
            session_id=session.id,
            role="assistant",
            content=response.reply,
            meta_data={
                "score": response.score,
                "grammar_score": response.grammar_score,
                "pronunciation_score": response.pronunciation_score,
                "created_at": str(response.memory) # stash memory if needed?
            }
        )
        db.add(ai_msg)
        db.commit()
    
    return response

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
