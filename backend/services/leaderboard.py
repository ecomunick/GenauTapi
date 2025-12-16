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

def update_score(ip: str, score: int, streak: int = 1, name: str = "Anonymous"):
    """
    Update or add a user's score to the leaderboard.
    """
    loc = get_location(ip)
    
    with _lock:
        for entry in _leaderboard:
            if entry["ip"] == ip:
                if score > entry.get("top_score", 0):
                    entry["top_score"] = score
                # ALWAYS update streak from the client (Persistence Source of Truth)
                entry["streak"] = streak
                return entry
        
        # New entry
        new_entry = {
            "ip": ip,
            "name": name,
            "top_score": score, # iOS expects top_score
            "streak": streak,
            "country": loc.get("country", "Unknown"),
            "city": loc.get("city", "Unknown"),
            "flag": loc.get("countryCode", "UN")
        }
        _leaderboard.append(new_entry)
        return new_entry

def get_top_scores(limit: int = 10):
    with _lock:
        # Sort by top_score
        return sorted(_leaderboard, key=lambda x: x.get("top_score", 0), reverse=True)[:limit]
