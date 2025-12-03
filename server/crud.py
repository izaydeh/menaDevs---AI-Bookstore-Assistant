from typing import List, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import func
from db_models import (
    Book, Customer, Order, OrderItem,
    Session as ChatSession,
    Message, ToolCall
)


def find_books(db: Session, q: str, by: str = "title") -> List[Book]:
    if by == "author":
        return db.query(Book).filter(Book.author.ilike(f"%{q}%")).all()
    return db.query(Book).filter(Book.title.ilike(f"%{q}%")).all()

def create_order(db: Session, customer_id: int, items: List[Dict[str, Any]]) -> Dict[str, Any]:
    customer = db.query(Customer).get(customer_id)
    if not customer:
        raise ValueError(f"Customer {customer_id} not found")

    order = Order(customer_id=customer_id)
    db.add(order)
    db.flush()  # get order.id

    for item in items:
        isbn = item["isbn"]
        qty = int(item["qty"])
        book = db.query(Book).get(isbn)
        if not book:
            raise ValueError(f"Book {isbn} not found")
        if book.stock < qty:
            raise ValueError(f"Not enough stock for {book.title}")
        book.stock -= qty
        order_item = OrderItem(
            order_id=order.id,
            isbn=isbn,
            qty=qty,
            unit_price=book.price
        )
        db.add(order_item)

    db.commit()
    db.refresh(order)

    return {
        "order_id": order.id,
        "items": [
            {"isbn": oi.isbn, "qty": oi.qty, "unit_price": oi.unit_price}
            for oi in order.items
        ]
    }

def restock_book(db: Session, isbn: str, qty: int) -> Dict[str, Any]:
    book = db.query(Book).get(isbn)
    if not book:
        raise ValueError(f"Book {isbn} not found")
    book.stock += qty
    db.commit()
    db.refresh(book)
    return {"isbn": book.isbn, "stock": book.stock}


def adjust_stock(db: Session, isbn: str, qty: int) -> Dict[str, Any]:
    """Adjust stock by a signed quantity. Positive to increase, negative to decrease.

    Prevents stock from going below zero.
    """
    book = db.query(Book).get(isbn)
    if not book:
        raise ValueError(f"Book {isbn} not found")

    new_stock = book.stock + int(qty)
    if new_stock < 0:
        raise ValueError(f"Not enough stock for {book.title}")

    book.stock = new_stock
    db.commit()
    db.refresh(book)
    return {"isbn": book.isbn, "stock": book.stock}

def update_price(db: Session, isbn: str, price: float) -> Dict[str, Any]:
    book = db.query(Book).get(isbn)
    if not book:
        raise ValueError(f"Book {isbn} not found")
    book.price = price
    db.commit()
    db.refresh(book)
    return {"isbn": book.isbn, "price": book.price}

def order_status(db: Session, order_id: int) -> Dict[str, Any]:
    order = db.query(Order).get(order_id)
    if not order:
        raise ValueError(f"Order {order_id} not found")
    return {
        "order_id": order.id,
        "customer": order.customer.name,
        "created_at": str(order.created_at),
        "items": [
            {
                "isbn": oi.isbn,
                "title": oi.book.title,
                "qty": oi.qty,
                "unit_price": oi.unit_price
            }
            for oi in order.items
        ]
    }

def inventory_summary(db: Session) -> Dict[str, Any]:
    books = db.query(Book).all()
    low_stock = [b for b in books if b.stock <= 3]
    return {
        "total_titles": len(books),
        "total_stock": sum(b.stock for b in books),
        "low_stock": [
            {"isbn": b.isbn, "title": b.title, "stock": b.stock}
            for b in low_stock
        ]
    }

# chat storage helpers

def create_session(db: Session, name: str | None = None) -> ChatSession:
    s = ChatSession(name=name)
    db.add(s)
    db.commit()
    db.refresh(s)
    return s

def list_sessions(db: Session):
    return db.query(ChatSession).order_by(ChatSession.created_at.desc()).all()

def add_message(db: Session, session_id: int, role: str, content: str):
    m = Message(session_id=session_id, role=role, content=content)
    db.add(m)
    db.commit()
    db.refresh(m)
    return m

def get_messages(db: Session, session_id: int):
    return (
        db.query(Message)
        .filter(Message.session_id == session_id)
        .order_by(Message.created_at.asc())
        .all()
    )

def delete_session(db: Session, session_id: int):
    # Delete related messages and tool calls explicitly to avoid FK issues
    db.query(Message).filter(Message.session_id == session_id).delete()
    db.query(ToolCall).filter(ToolCall.session_id == session_id).delete()
    db.query(ChatSession).filter(ChatSession.id == session_id).delete()
    db.commit()
    return True

def log_tool_call(db: Session, session_id: int, name: str, args_json: str, result_json: str):
    tc = ToolCall(
        session_id=session_id,
        name=name,
        args_json=args_json,
        result_json=result_json
    )
    db.add(tc)
    db.commit()
    return tc
