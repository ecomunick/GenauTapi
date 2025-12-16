import requests
from threading import Lock

# Simple in-memory leaderboard for demo (Persistence requires a DB)
# Format: [{"ip": "...", "country": "DE", "city": "Berlin", "score": 85, "name": "User1"}]
_leaderboard = []
_lock = Lock()

def get_location(ip: str):
    """
    Fetch location data from ip-api.com (Free, no key, limited rate).
    """
    if ip in ["127.0.0.1", "localhost", "::1"]:
        return {"country": "Localhost", "city": "Home", "countryCode": "LO"}
    
    try:
        # Using ip-api.com (free for non-commercial)
        url = f"http://ip-api.com/json/{ip}"
        resp = requests.get(url, timeout=5)
        if resp.status_code == 200:
            return resp.json()
    except Exception as e:
        print(f"GeoIP Error: {e}")
    return {"country": "Unknown", "city": "Unknown", "countryCode": "UN"}

def update_score(ip: str, score: int, name: str = "Anonymous"):
    """
    Update or add a user's score to the leaderboard.
    """
    loc = get_location(ip)
    
    with _lock:
        # Check if user exists by IP (simplified identity)
        # In prod, use a User ID.
        for entry in _leaderboard:
            if entry["ip"] == ip:
                # Update max score or average? Let's keep MAX score for leaderboard fun
                if score > entry["score"]:
                    entry["score"] = score
                    entry["name"] = name
                return entry
        
        # New entry
        new_entry = {
            "ip": ip,
            "name": name,
            "score": score,
            "country": loc.get("country", "Unknown"),
            "city": loc.get("city", "Unknown"),
            "flag": loc.get("countryCode", "UN") # 2 letter code
        }
        _leaderboard.append(new_entry)
        return new_entry

def get_top_scores(limit: int = 10):
    with _lock:
        # Sort by score desc
        sorted_lb = sorted(_leaderboard, key=lambda x: x["score"], reverse=True)
        return sorted_lb[:limit]
