from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import openai

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

class ChatRequest(BaseModel):
    transcript: str
    source_lang: str
    target_lang: str
    topic: str

TOPICS = {
    "Daily Life": "Act as friendly neighbor chatting about weather, family, weekend plans",
    "Shopping": "Act as German supermarket cashier. Keep it simple, correct politely",
    "Job Interview": "Act as HR manager conducting B1 German job interview. Professional but encouraging",
    "Free Conversation": "Act as a friendly conversational partner. Chat naturally. Do not correct grammar unless it makes the sentence excessively hard to understand. Prioritize keeping the conversation flowing."
}

@app.get("/")
def home():
    return {"message": "GenauTapi Backend is LIVE! 🐶", "status": "Ready to chat"}

@app.post("/chat")
async def chat(request: ChatRequest):
    # Immersion Priority: Always reply in German if the user wants "Lili" style
    # simple map for clarity
    lang_map = {"de-DE": "German", "en-US": "English"}
    target_lang_name = lang_map.get(request.target_lang, request.target_lang)
    
    system_instruction = f"""You are GenauTapi 🐶, a fluent German speaker.
User said: "{request.transcript}"
Task:
1. Act as a friendly conversational partner.
2. Reply ONLY in {target_lang_name} (German).
3. Do not switch to English.
4. Keep replies concise and natural.
5. Do not correct grammar unless the user makes no sense.
6. Score the user's proficiency (0-100)."""
            )
            reply = response.choices[0].message.content
        except Exception as e:
             reply = f"Error calling AI: {str(e)}"
    else:
        reply = "Simulation: Genau! (OpenAI Key missing)"

    # Simple heuristic scoring if parsing fails or mocked
    score = 85
    
    return {
        "reply": reply,
        "correction": f"Genau! Say: {request.transcript.upper()}",
        "score": score,
        "xp": score // 10
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
