import json
from typing import List, Dict, Any
from langchain.tools import tool
from sqlalchemy.orm import Session

from crud import (
    find_books as _find_books,
    create_order as _create_order,
    restock_book as _restock_book,
    adjust_stock as _adjust_stock,
    update_price as _update_price,
    order_status as _order_status,
    inventory_summary as _inventory_summary
)


@tool("find_books", return_direct=False)
def find_books_tool(q: str, by: str = "title") -> List[Dict[str, Any]]:
    """Find books by title or author."""
    if not q or not isinstance(q, str):
        return {"error": "You must provide a search query string (q)."}

    if by not in ["title", "author"]:
        return {"error": "Invalid 'by' parameter. Must be 'title' or 'author'."}

    from db_models import SessionLocal
    db: Session = SessionLocal()
    try:
        books = _find_books(db, q, by)
        return [
            {
                "isbn": b.isbn,
                "title": b.title,
                "author": b.author,
                "price": b.price,
                "stock": b.stock
            }
            for b in books
        ]
    finally:
        db.close()


@tool("create_order", return_direct=False)
def create_order_tool(customer_id: int, items: List[Dict[str, Any]] | None = None) -> Dict[str, Any]:
    """
    Create a customer order.

    PARAMETERS:
    - customer_id: ID of the customer.
    - items: A list of items in the form:
        [
            {"isbn": "string", "qty": number}
        ]

    IMPORTANT:
    The agent MUST ALWAYS provide both customer_id and items.
    """
    # Defensive validation: ensure 'items' is provided and well-formed
    if items is None or not isinstance(items, list) or len(items) == 0:
        return {"error": "'items' parameter is required and must be a non-empty list of {isbn, qty} objects."}
    

    from db_models import SessionLocal, Book
    db: Session = SessionLocal()
    try:
        # Normalize items: allow the agent to pass a book title in place of ISBN.
        normalized_items = []
        for it in items:
            if not isinstance(it, dict):
                return {"error": "Each item must be an object like {isbn: string, qty: number}."}

            isbn = it.get("isbn")
            qty = it.get("qty")
            if isbn is None:
                return {"error": "Each item must include an 'isbn' (or title) and 'qty'."}

            # If ISBN doesn't exist, try finding by title substring
            book = db.query(Book).get(isbn)
            if not book:
                # search by title fuzzy match
                found = db.query(Book).filter(Book.title.ilike(f"%{isbn}%")).first()
                if found:
                    isbn = found.isbn
                else:
                    return {"error": f"Book '{isbn}' not found"}

            try:
                normalized_items.append({"isbn": isbn, "qty": int(qty)})
            except Exception:
                return {"error": "Invalid qty for item; must be a number."}

        try:
            return _create_order(db, customer_id, normalized_items)
        except ValueError as e:
            return {"error": str(e)}
    finally:
        db.close()


@tool("restock_book", return_direct=False)
def restock_book_tool(isbn: str, qty: int | None = None) -> Dict[str, Any]:
    """Adjust stock of a book. `qty` may be positive (increase) or negative (decrease).

    The agent may pass a negative `qty` to represent removing stock (e.g., after a sale).
    """

    # VALIDATION
    if not isbn or not isinstance(isbn, str):
        return {"error": "isbn must be a non-empty string."}

    if qty is None:
        return {"error": "'qty' parameter is required and must be a non-zero integer."}

    if not isinstance(qty, int) or qty == 0:
        return {"error": "qty must be a non-zero integer (positive to add, negative to remove)."}

    from db_models import SessionLocal, Book
    db: Session = SessionLocal()
    try:
        try:
            return _adjust_stock(db, isbn, qty)
        except ValueError as e:
            # If ISBN not found, try resolving as a title substring
            found = db.query(Book).filter(Book.title.ilike(f"%{isbn}%")).first()
            if found:
                try:
                    return _adjust_stock(db, found.isbn, qty)
                except ValueError as e2:
                    return {"error": str(e2)}
            return {"error": str(e)}
    finally:
        db.close()



@tool("update_price", return_direct=False)
def update_price_tool(isbn: str, price: float) -> Dict[str, Any]:
    """Update price of a book."""

    # VALIDATION
    if not isbn or not isinstance(isbn, str):
        return {"error": "isbn must be a non-empty string."}

    if not isinstance(price, (int, float)) or price <= 0:
        return {"error": "price must be a positive number."}

    from db_models import SessionLocal
    db: Session = SessionLocal()
    try:
        return _update_price(db, isbn, price)
    finally:
        db.close()


@tool("order_status", return_direct=False)
def order_status_tool(order_id: int) -> Dict[str, Any]:
    """Return order status and details."""

    # VALIDATION
    if not isinstance(order_id, int) or order_id <= 0:
        return {"error": "order_id must be a positive integer."}

    from db_models import SessionLocal
    db: Session = SessionLocal()
    try:
        return _order_status(db, order_id)
    finally:
        db.close()



@tool("inventory_summary", return_direct=False)
def inventory_summary_tool() -> Dict[str, Any]:
    """Return inventory summary including low-stock titles."""

    from db_models import SessionLocal
    db: Session = SessionLocal()
    try:
        return _inventory_summary(db)
    finally:
        db.close()
