import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, StaticPool
from sqlalchemy.orm import sessionmaker
import sys
import os

# Add backend to path
sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

from database import Base, get_db
from main import app

# Create in-memory SQLite DB for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(name="db_session")
def fixture_db_session():
    # Create tables
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        # Drop tables to clean up
        Base.metadata.drop_all(bind=engine)

@pytest.fixture(name="client")
def fixture_client(db_session):
    def get_db_override():
        return db_session
    
    app.dependency_overrides[get_db] = get_db_override
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()

def test_read_main(client):
    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]

def test_create_session(client):
    response = client.post("/sessions")
    assert response.status_code == 200
    data = response.json()
    assert "id" in data

def test_chat_without_session(client):
    payload = {
        "transcript": "Hallo, wie geht es dir?"
    }
    response = client.post("/chat", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "reply" in data
    assert "score" in data

def test_chat_with_session(client):
    # 1. Create session
    response = client.post("/sessions")
    assert response.status_code == 200
    session_id = response.json()["id"]
    
    # 2. Chat with session
    payload = {
        "transcript": "Ich bin ein Berliner.",
        "session_id": session_id
    }
    response = client.post("/chat", json=payload)
    assert response.status_code == 200
    
    # 3. Check history
    hist_response = client.get(f"/history/{session_id}")
    assert hist_response.status_code == 200
    history = hist_response.json()["messages"]
    
    # Expect 2 messages: User + Assistant
    assert len(history) == 2
    assert history[0]["role"] == "user"
    assert history[0]["content"] == "Ich bin ein Berliner."
    assert history[1]["role"] == "assistant"

def test_get_history_invalid_session(client):
    response = client.get("/history/invalid-uuid-123")
    assert response.status_code == 404
