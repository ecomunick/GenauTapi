import os
import openai
import json
import hashlib
import time
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

class ChatResponse(BaseModel):
    reply: str
    correction: str = ""
    should_repeat: bool = False
    pronunciation_tip: str = ""
    score: int
    grammar_score: int
    pronunciation_score: int
    audio_url: str = ""  # For TTS audio

def call_ai_coach(transcript: str, user_ip: str) -> ChatResponse:
    if not OPENAI_API_KEY:
        # Fallback simulation
        return ChatResponse(
            reply="Simulation: (OPENAI_API_KEY Missing) Hallo! Wie geht es dir?",
            score=50,
            grammar_score=50,
            pronunciation_score=50
        )

    system_prompt = f"""
You are "Genau Tapi!", a friendly German accent & grammar coach.

Your tasks:
1. Carry a fluid conversation in German.
2. Analyze the user's German input: "{transcript}"
3. Detect grammar mistakes but DO NOT obsess over them.
4. Score the user (0-100) based on Grammar + Style.
5. **Conversational Rule: "Chill Friend Mode"**
   - **Prioritize FLOW**: Respond to the *meaning*, not the grammar.
   - **Correction Policy**: 
     - If Grammar Score >= 60: **DO NOT mentioned the mistake in your spoken reply.** Just reply naturally. (You can still set the 'correction' field for the UI, but don't speak it).
     - If Grammar Score < 60: Gently mention the correct form, but keep it brief (e.g. "Du meinst X? Ja...").
   - Never sound like a teacher. Be casual.

Return this exact JSON format:
{{
  "reply": "Your natural spoken reply. DO NOT include corrections unless score is very low.",
  "correction": "Written correction for the UI (always include if there is a mistake, for user reference)",
  "should_repeat": false, 
  "pronunciation_tip": "Short tip on style or grammar if needed",
  "grammar_score": number from 0-100,
  "pronunciation_score": number from 0-100 (Style/Naturalness)
}}
    """
    
    try:
        client = openai.OpenAI(api_key=OPENAI_API_KEY)
        
        # Get text response
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
        if reply_text:
            try:
                # Generate TTS
                speech_response = client.audio.speech.create(
                    model="tts-1",
                    voice="nova",  # Natural female voice
                    input=reply_text,
                    response_format="mp3"
                )
                
                # Save audio file with unique name
                audio_dir = "static/audio"
                os.makedirs(audio_dir, exist_ok=True)
                
                # Create unique filename based on content hash
                file_hash = hashlib.md5(reply_text.encode()).hexdigest()[:8]
                timestamp = int(time.time())
                filename = f"tts_{timestamp}_{file_hash}.mp3"
                filepath = os.path.join(audio_dir, filename)
                
                # Save audio to file
                speech_response.stream_to_file(filepath)
                
                # Return relative URL
                audio_url = f"/audio/{filename}"
                
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
            audio_url=audio_url
        )
    except Exception as e:
        print(f"AI Error: {e}")
        return ChatResponse(
            reply="Entschuldigung, ich habe ein Problem (AI Error).", 
            score=0, 
            grammar_score=0, 
            pronunciation_score=0
        )
