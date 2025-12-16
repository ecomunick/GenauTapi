import base64
import os
import openai
import json
import hashlib
import time
from pydantic import BaseModel
from dotenv import load_dotenv

# Robust .env loading
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir) # Should be backend/
env_path = os.path.join(parent_dir, ".env")
load_dotenv(env_path)

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
print(f"DEBUG: Loaded API Key? {'YES' if OPENAI_API_KEY else 'NO'}")
print(f"DEBUG: ALL KEYS: {list(os.environ.keys())}")  # Check if it's there under a diff name

class ChatResponse(BaseModel):
    reply: str
    correction: str = ""
    should_repeat: bool = False
    pronunciation_tip: str = ""
    score: int
    grammar_score: int
    pronunciation_score: int
    audio_url: str = ""
    audio_base64: str = "" # New robust field
    memory: str = ""  # AI updates this

def call_ai_coach(transcript: str, user_ip: str, memory_context: str = "") -> ChatResponse:
    if not OPENAI_API_KEY:
        return ChatResponse(
            reply="Simulation: (OPENAI_API_KEY Missing)", score=50, grammar_score=50, pronunciation_score=50, memory=memory_context
        )

    system_prompt = f"""
You are "Genau Tapi!", a friendly German language friend.

**MEMORY (Context of previous chats)**:
"{memory_context}"

**Tasks**:
1. Analyize input: "{transcript}"
2. Update the MEMORY: specific topics, user's name, or what we discussed. Keep it concise (max 2 sentences).
   - If user changes topic, update memory to reflect that.
   - Example Memory: "User is Tapi. We talked about pizza yesterday."
3. Reply naturally based on MEMORY + Input.

**Chill Friend Mode**:
- Prioritize FLOW. Only correct if mistakes are HUGE (Grammar Score < 60).
- Be casual.

Return JSON:
{{
  "reply": "Spoken reply based on memory and input",
  "correction": "Written correction if needed",
  "memory": "UPDATED concise summary string (CRITICAL: Do not lose important past info)",
  "grammar_score": 0-100,
  "pronunciation_score": 0-100
}}
    """
    
    try:
        client = openai.OpenAI(api_key=OPENAI_API_KEY)
        
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "system", "content": system_prompt}],
            response_format={"type": "json_object"}
        )
        
        content = response.choices[0].message.content
        data = json.loads(content)
        
        # Calculate avg score
        avg_score = (data.get("grammar_score", 0) + data.get("pronunciation_score", 0)) // 2
        
        reply_text = data.get("reply", "")
        
        # Generate audio using OpenAI TTS
        audio_url = ""
        audio_b64 = ""
        
        if reply_text:
            try:
                # Generate TTS
                speech_response = client.audio.speech.create(
                    model="tts-1",
                    voice="nova",  # Natural female voice
                    input=reply_text,
                    response_format="mp3"
                )
                
                # Encode to Base64 (Skip FS)
                audio_b64 = base64.b64encode(speech_response.content).decode('utf-8')
                
                # Optional: Still save file for local testing? No need.
                
            except Exception as tts_error:
                print(f"TTS Error: {tts_error}")
                # Continue without audio if TTS fails
        
        return ChatResponse(
            reply=reply_text,
            correction=data.get("correction", "") or "",
            should_repeat=data.get("should_repeat", False),
            pronunciation_tip=data.get("pronunciation_tip", "") or "",
            score=avg_score,
            grammar_score=data.get("grammar_score", 0),
            pronunciation_score=data.get("pronunciation_score", 0),
            audio_url="",
            audio_base64=audio_b64,
            memory=data.get("memory", memory_context)
        )
    except Exception as e:
        print(f"AI Error: {e}")
        return ChatResponse(
            reply="Entschuldigung, ich habe ein Problem (AI Error).", 
            score=0, 
            grammar_score=0, 
            pronunciation_score=0
        )
