# main.py

from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from sqlalchemy.orm import Session

from db_models import SessionLocal, init_orm
import crud
from agent import build_agent

app = FastAPI(title="Library Desk Agent")

origins = ["http://localhost:5173", "http://localhost:3000"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

init_orm()



class ChatRequest(BaseModel):
    session_id: Optional[int] = None
    message: str

class ChatResponse(BaseModel):
    session_id: int
    answer: str

class SessionOut(BaseModel):
    id: int
    name: Optional[str]
    created_at: Optional[str] = None



@app.post("/sessions", response_model=SessionOut)
def create_session(name: Optional[str] = None, db: Session = Depends(get_db)):
    s = crud.create_session(db, name)
    return SessionOut(id=s.id, name=s.name, created_at=s.created_at.isoformat())

@app.get("/sessions", response_model=List[SessionOut])
def list_sessions(db: Session = Depends(get_db)):
    sessions = crud.list_sessions(db)
    return [
        SessionOut(id=s.id, name=s.name, created_at=s.created_at.isoformat())
        for s in sessions
    ]


@app.delete("/sessions/{session_id}")
def delete_session(session_id: int, db: Session = Depends(get_db)):
    crud.delete_session(db, session_id)
    return {"status": "ok"}

@app.get("/sessions/{session_id}/messages")
def get_session_messages(session_id: int, db: Session = Depends(get_db)):
    msgs = crud.get_messages(db, session_id)
    return [
        {
            "id": m.id,
            "role": m.role,
            "content": m.content,
            "created_at": m.created_at.isoformat(),
        }
        for m in msgs
    ]



@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest, db: Session = Depends(get_db)):
    # ensure session
    if req.session_id is None:
        s = crud.create_session(db, name="Session")
        session_id = s.id
    else:
        session_id = req.session_id

    # save user message
    crud.add_message(db, session_id, role="user", content=req.message)

    # get history
    history = crud.get_messages(db, session_id)
    history_simple = [{"role": m.role, "content": m.content} for m in history]

    # build agent
    agent = build_agent(history_simple)

    # call agent
    result = agent.invoke({"input": req.message})

    # extract answer
    answer = result["output"] if isinstance(result, dict) else str(result)

    # save response
    crud.add_message(db, session_id, role="assistant", content=answer)

    return ChatResponse(session_id=session_id, answer=answer)
