from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from database import Base

def generate_uuid():
    return str(uuid.uuid4())

class UserSession(Base):
    __tablename__ = "user_sessions"

    id = Column(String, primary_key=True, default=generate_uuid, index=True)
    user_ip = Column(String, index=True, nullable=True) # Optional, can invoke without IP in some contexts
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationship
    messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan")

class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String, ForeignKey("user_sessions.id"), nullable=False)
    role = Column(String, nullable=False) # "user", "assistant", "system"
    content = Column(Text, nullable=False)
    
    # Store extra data: scores, corrections, memory snapshot
    meta_data = Column(JSON, default={}) 
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    session = relationship("UserSession", back_populates="messages")
