
INSERT INTO books (isbn, title, author, price, stock) VALUES
('9780132350884', 'Clean Code', 'Robert C. Martin', 40.0, 10),
('9780201616224', 'The Pragmatic Programmer', 'Andrew Hunt', 45.0, 5),
('9780131103627', 'The C Programming Language', 'Brian Kernighan', 35.0, 7),
('9780134685991', 'Effective Java', 'Joshua Bloch', 50.0, 3),
('9781491950296', 'Learning Python', 'Mark Lutz', 55.0, 8),
('9780596007126', 'Head First Design Patterns', 'Eric Freeman', 48.0, 6),
('9780321751041', 'C++ Primer', 'Stanley Lippman', 60.0, 4),
('9780134494166', 'Clean Architecture', 'Robert C. Martin', 42.0, 9),
('9781492078005', 'Fluent Python', 'Luciano Ramalho', 58.0, 5),
('9781449355739', 'Think Python', 'Allen B. Downey', 30.0, 10);


INSERT INTO customers (name, email) VALUES
('Alice Smith', 'alice@example.com'),
('Bob Johnson', 'bob@example.com'),
('Charlie Davis', 'charlie@example.com'),
('Diana Prince', 'diana@example.com'),
('Ethan Brown', 'ethan@example.com'),
('Fiona Clark', 'fiona@example.com');


-- Order 1 for customer 1
INSERT INTO orders (customer_id) VALUES (1);
INSERT INTO order_items (order_id, isbn, qty, unit_price) VALUES
(1, '9780132350884', 1, 40.0),
(1, '9780131103627', 2, 35.0);

-- Order 2 for customer 3
INSERT INTO orders (customer_id) VALUES (3);
INSERT INTO order_items (order_id, isbn, qty, unit_price) VALUES
(2, '9780201616224', 1, 45.0);

-- Order 3 for customer 5
INSERT INTO orders (customer_id) VALUES (5);
INSERT INTO order_items (order_id, isbn, qty, unit_price) VALUES
(3, '9781491950296', 1, 55.0),
(3, '9780134494166', 1, 42.0);

-- Order 4 for customer 2
INSERT INTO orders (customer_id) VALUES (2);
INSERT INTO order_items (order_id, isbn, qty, unit_price) VALUES
(4, '9781449355739', 3, 30.0);
