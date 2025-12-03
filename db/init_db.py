import sqlite3
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "library.db"
SCHEMA_PATH = BASE_DIR / "schema.sql"
SEED_PATH = BASE_DIR / "seed.sql"

def init_db():
    if DB_PATH.exists():
        DB_PATH.unlink()  # start clean

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
        cur.executescript(f.read())

    with open(SEED_PATH, "r", encoding="utf-8") as f:
        cur.executescript(f.read())

    conn.commit()
    conn.close()
    print("DB initialized at", DB_PATH)

if __name__ == "__main__":
    init_db()
