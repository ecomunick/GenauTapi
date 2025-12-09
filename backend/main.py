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
    # Immersion Priority: Always reply in German
    system_instruction = f"""You are GenauTapi 🐶, a fluent German speaker.
User said: "{request.transcript}"
Task:
1. Act as a friendly conversational partner.
2. Reply ONLY in German.
3. Do not switch to English.
4. Keep replies concise and natural (1-2 sentences max).
5. Do not correct grammar unless the user makes no sense.
6. At the END of your response, add a score on a new line in this exact format: [SCORE: XX]
   where XX is 0-100 based on grammar, vocabulary, and fluency."""

    # Use environment variable for API key if available
    api_key = os.getenv("OPENAI_API_KEY")
    client = openai.OpenAI(api_key=api_key) if api_key else None
    
    reply = "Simulation: Genau! (OpenAI Key missing)"
    score = 85

    if client:
        try:
            response = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "system", "content": system_instruction}]
            )
            full_reply = response.choices[0].message.content
            
            # Parse score from response
            import re
            score_match = re.search(r'\[SCORE:\s*(\d+)\]', full_reply)
            if score_match:
                score = int(score_match.group(1))
                # Remove score from reply
                reply = re.sub(r'\s*\[SCORE:\s*\d+\]', '', full_reply).strip()
            else:
                reply = full_reply
                score = 75  # Default if parsing fails
        except Exception as e:
             reply = f"Error calling AI: {str(e)}"

    return {
        "reply": reply,
        "correction": "", # No manual correction in immersion mode
        "score": score,
        "xp": score // 10
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
