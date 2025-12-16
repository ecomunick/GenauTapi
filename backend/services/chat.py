import os
import openai
import json
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

def call_ai_coach(transcript: str, user_ip: str) -> ChatResponse:
    if not OPENAI_API_KEY:
        # Fallback simulation
        return ChatResponse(
            reply="Simulation: (OpenAI Key Missing) Hallo! Wie geht es dir?",
            score=50,
            grammar_score=50,
            pronunciation_score=50
        )

    system_prompt = f"""
You are "Genau Tapi!", a friendly German accent & grammar coach.

Your tasks:
1. Carry a fluid conversation in German.
2. Analyze the user's German input: "{transcript}"
3. Detect grammar mistakes and pronunciation/phonetic issues (inferred from spelling/ASR errors).
4. Score the user (0-100) based on accuracy and naturalness.
5. If the score is low (<60) or pronunciation seems very off, ask to REPEAT.

Return JSON format:
{{
  "reply": "Your conversational reply in German",
  "correction": "Corrected sentence if needed (or empty)",
  "should_repeat": true/false,
  "pronunciation_tip": "Short tip if needed",
  "grammar_score": 0-100,
  "pronunciation_score": 0-100
}}
    """
    
    try:
        client = openai.OpenAI(api_key=OPENAI_API_KEY)
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "system", "content": system_prompt}],
            response_format={"type": "json_object"}
        )
        # Safe JSON parsing
        content = response.choices[0].message.content
        data = json.loads(content)
        
        # Calculate avg score
        avg_score = (data.get("grammar_score", 0) + data.get("pronunciation_score", 0)) // 2
        
        return ChatResponse(
            reply=data.get("reply", ""),
            correction=data.get("correction", "") or "",
            should_repeat=data.get("should_repeat", False),
            pronunciation_tip=data.get("pronunciation_tip", "") or "",
            score=avg_score,
            grammar_score=data.get("grammar_score", 0),
            pronunciation_score=data.get("pronunciation_score", 0)
        )
    except Exception as e:
        print(f"AI Error: {e}")
        return ChatResponse(reply="Entschuldigung, ich habe ein Problem.", score=0, grammar_score=0, pronunciation_score=0)
