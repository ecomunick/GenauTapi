import json

# ...

        import json
        data = json.loads(response.choices[0].message.content)
        
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
