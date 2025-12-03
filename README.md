# 📚 MenaDevs – AI Bookstore Assistant

An AI-powered bookstore assistant built with:

- 🧠 **OpenAI + LangChain** (natural language understanding)
- ⚙️ **FastAPI** backend with tool-based actions
- 🗂 **SQLite** database (books, customers, orders, stock)
- 📱 **Flutter frontend** for a chat interface

---

## 🚀 Project Structure

```
.
├── app/                 # Flutter frontend (UI)
├── server/              # FastAPI backend + LangChain agent
└── db/                  # SQLite DB + schema + seed files
```

### **app/**
Flutter app containing:

- `lib/main.dart` – app entry point  
- `lib/pages/` – chat page, home, session list  
- `lib/models/` – message & session models  
- `lib/api_service.dart` – handles communication with backend  

### **server/**
Backend containing:

- `main.py` – FastAPI server & endpoints  
- `agent.py` – LangChain + OpenAI agent  
- `tools.py` – Tools used by the agent  
- `crud.py` – Database logic  
- `db_models.py` – SQLAlchemy models  
- `requirements.txt` – Python dependencies  

### **db/**
Database assets:

- `schema.sql` – table definitions  
- `seed.sql` – initial data  
- `init_db.py` – script to generate *library.db*  
- `library.db` – SQLite database  

---

# 🔧 1. Backend Setup (FastAPI + LangChain + OpenAI)

### ✔ 1.1 Requirements

- Python **3.10+**  
- pip  
- **OpenAI API key** (saved inside `.env` file)

---

## ✔ 1.3 Install Backend Dependencies

From the project root:

```bash
cd server
python -m venv venv
```

Activate it:

**Windows**
```bash
venv\Scripts\activate
```

**macOS / Linux**
```bash
source venv/bin/activate
```

Install deps:

```bash
pip install -r requirements.txt
```

---

# 🗄 2. Database Setup

From the project root:

```bash
cd db
python init_db.py
```

This will:

- Create **library.db**
- Run schema.sql
- Insert initial books, customers, sample order

If you want to reset the DB, run it again.

---

# ⚙️ 3. Run the Backend Server

From the project root:

```bash
cd server
uvicorn main:app --reload
```

Backend will run at:

📌 http://127.0.0.1:8000

Endpoints used by the Flutter app:

- `GET /sessions`
- `GET /sessions/{session_id}/messages`
- `POST /chat` – main AI chat endpoint

---

# 📱 4. Frontend (Flutter App)

## ✔ 4.1 Requirements

- Flutter SDK installed  
- Android Studio / VS Code  
- `flutter run` must work

---

## ✔ 4.2 Install Flutter Dependencies

From the project root:

```bash
cd app
flutter pub get
```

---

## ✔ 4.3 Configure Backend URL

Inside:

`app/lib/api_service.dart`

Set your backend URL:

### Windows / macOS / Chrome / Real device:
```dart
const String baseUrl = "http://127.0.0.1:8000";
```

Make sure it matches the backend.

---

## ✔ 4.4 Run Flutter App

```bash
flutter run
```

You can run on:

- Emulator  
- Physical device  
- Chrome (`flutter run -d chrome`)

---

# 🤖 5. What the AI Agent Can Do

Your AI assistant understands natural language and can execute actions:

### 🔍 **find_books**
Search by title or author

### 🛒 **create_order**
Sell books + decrease stock

### 📦 **restock_book**
Increase quantity

### 💵 **update_price**
Change book price

### 🧾 **order_status**
Check a customer order

### 📊 **inventory_summary**
See all books + low stock

---

# ✨ 6. Example Prompts

Use natural language:

- “Do we have Clean Code in stock?”  
- “Sell 3 copies of Clean Code to customer 2.”  
- “Restock The Pragmatic Programmer by 10.”  
- “Show me inventory summary.”  
- “What’s the status of order 1?”  

The agent:

1. Understands the request  
2. Selects the correct tool  
3. Executes CRUD operation  
4. Returns a clean human answer  

---

# 🧩 7. Run Everything From Scratch (Checklist)

### 🛠 Backend
```bash
cd server
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### 🗄 Initialize DB
```bash
cd db
python init_db.py
```

### 🚀 Run backend
```bash
cd ../server
uvicorn main:app --reload
```

---

### 📱 Run frontend
```bash
cd ../app
flutter pub get
flutter run
```

---

# 🎉 Done!

Your full AI-powered bookstore system is now running:

- **FastAPI backend**
- **OpenAI + LangChain agent**
- **SQLite database**
- **Flutter UI**

You can chat with the AI and manage your bookstore with natural language.

---

# 💙 Credits
Built for **MenaDevs Interview Task** – by *Ismail Abuzaydeh*.

