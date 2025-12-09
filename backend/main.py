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
    topic_instruction = TOPICS.get(request.topic, "General Conversation")
    
    # Adjust prompt style based on topic
    if request.topic == "Free Conversation":
        system_instruction = f"""You are GenauTapi 🐶, a friendly German-English chat partner.
Topic: {topic_instruction}
User said (in {request.source_lang}): "{request.transcript}"
Reply naturally in {request.target_lang}. Only correct grammar if strictly necessary. Score 0-100 based on flow and vocabulary."""
    else:
        system_instruction = f"""You are GenauTapi 🐶, patient German-English speech coach.
Topic: {topic_instruction}
User said (in {request.source_lang}): "{request.transcript}"
Give short reply in {request.target_lang}, correct grammar, score 0-100."""
    
    # Use environment variable for API key if available
    api_key = os.getenv("OPENAI_API_KEY")
    client = openai.OpenAI(api_key=api_key) if api_key else None

    if client:
        try:
            response = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "system", "content": system_instruction}]
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
