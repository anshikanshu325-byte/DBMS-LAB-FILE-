-- ==============================================================================
-- EXPERIMENT 02: Convert ER Diagram into Relational Schema
-- Course Outcome: CO2
-- Environment: MySQL 8.0+ / MySQL Workbench
-- ==============================================================================

-- Step 1: Create Database
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Step 2: Create Customer Table
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE
);

-- Step 3: Create Address Table
CREATE TABLE Address (
    address_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_line VARCHAR(200) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE
);

-- Step 4: Create Seller Table
CREATE TABLE Seller (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE
);

-- Step 5: Create Category Table
CREATE TABLE Category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- Step 6: Create Product Table
CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    category_id INT,
    seller_id INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
        ON DELETE SET NULL,
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id)
        ON DELETE SET NULL
);

-- Step 7: Create Product_Details Table
CREATE TABLE Product_Details (
    product_id INT PRIMARY KEY,
    brand VARCHAR(100),
    description VARCHAR(255),
    stock INT NOT NULL CHECK (stock >= 0),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
);

-- Step 8: Create Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE
);

-- Step 9: Create OrderItem Table
CREATE TABLE OrderItem (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
);

-- Step 10: Create Payment Table
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE
);

-- Step 11: Create Delivery Table
CREATE TABLE Delivery (
    delivery_id INT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    delivery_address_id INT,
    delivery_date DATE,
    delivery_status VARCHAR(30) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (delivery_address_id) REFERENCES Address(address_id)
        ON DELETE SET NULL
);

-- Step 12: Insert Sample Data
INSERT INTO Customer VALUES
(1, 'Rahul Sharma', 'rahul@gmail.com', '9876543210'),
(2, 'Priya Singh', 'priya@gmail.com', '9876543211'),
(3, 'Aman Verma', 'aman@gmail.com', '9876543212');

INSERT INTO Address VALUES
(101, 1, '12 MG Road', 'Lucknow', 'Uttar Pradesh', '226001'),
(102, 2, '45 Gomti Nagar', 'Lucknow', 'Uttar Pradesh', '226010'),
(103, 3, '21 Civil Lines', 'Prayagraj', 'Uttar Pradesh', '211001');

INSERT INTO Seller VALUES
(201, 'Tech World', 'techworld@gmail.com', '9000000001'),
(202, 'Smart Store', 'smartstore@gmail.com', '9000000002');

INSERT INTO Category VALUES
(301, 'Electronics'),
(302, 'Books'),
(303, 'Clothing');

INSERT INTO Product VALUES
(401, 'Laptop', 55000.00, 301, 201),
(402, 'Database Book', 750.00, 302, 202),
(403, 'T-Shirt', 599.00, 303, 201);

INSERT INTO Product_Details VALUES
(401, 'HP', 'HP Laptop with 16GB RAM', 20),
(402, 'Pearson', 'Database Management Systems Book', 50),
(403, 'Puma', 'Cotton T-Shirt', 30);

INSERT INTO Orders VALUES
(501, 1, '2026-08-20', 'Confirmed'),
(502, 2, '2026-08-21', 'Shipped');

INSERT INTO OrderItem VALUES
(501, 401, 1, 55000.00),
(501, 402, 2, 750.00),
(502, 403, 1, 599.00);

INSERT INTO Payment VALUES
(601, 501, 'UPI', 'Paid', 56500.00),
(602, 502, 'Card', 'Paid', 599.00);

INSERT INTO Delivery VALUES
(701, 501, 101, '2026-08-25', 'Delivered'),
(702, 502, 102, '2026-08-26', 'Out for Delivery');

-- Step 13: Display Initial Tables
SELECT * FROM Customer;
SELECT * FROM Address;
SELECT * FROM Seller;
SELECT * FROM Category;
SELECT * FROM Product;
SELECT * FROM Product_Details;
SELECT * FROM Orders;
SELECT * FROM OrderItem;
SELECT * FROM Payment;
SELECT * FROM Delivery;

-- ==============================================================================
-- Step 14: Constraint Demonstrations & Integrity Verification
-- ==============================================================================

-- A. Referential Integrity Violations (Expected to FAIL)
-- Example 1: Inserting an order referencing a non-existent customer (customer_id = 99)
-- INSERT INTO Orders VALUES (503, 99, '2026-08-22', 'Confirmed');

-- Example 2: Adding an order item referencing a non-existent product (product_id = 999)
-- INSERT INTO OrderItem VALUES (501, 999, 1, 1000.00);

-- Example 3: Adding an address for a non-existent customer (customer_id = 999)
-- INSERT INTO Address VALUES (104, 999, 'ABC Street', 'Lucknow', 'Uttar Pradesh', '226001');

-- B. Demonstration of ON DELETE CASCADE
-- Deleting customer_id = 1 automatically deletes associated Address (101), Order (501), OrderItem, Payment, and Delivery
-- DELETE FROM Customer WHERE customer_id = 1;
-- Verification after deletion:
-- SELECT * FROM Customer WHERE customer_id = 1;
-- SELECT * FROM Orders WHERE customer_id = 1;
-- SELECT * FROM Address WHERE customer_id = 1;

-- C. Demonstration of ON DELETE SET NULL
-- Deleting seller_id = 201 sets seller_id in Product table to NULL instead of dropping products
-- DELETE FROM Seller WHERE seller_id = 201;
-- Verification:
-- SELECT product_id, product_name, seller_id FROM Product;

-- Deleting category_id = 301 sets category_id in Product table to NULL
-- DELETE FROM Category WHERE category_id = 301;
-- Verification:
-- SELECT product_id, product_name, category_id FROM Product;

-- D. Demonstration of NOT NULL Constraint Violation (Expected to FAIL)
-- INSERT INTO Customer VALUES (4, NULL, 'test@gmail.com', '9000000003');

-- E. Demonstration of UNIQUE Constraint Violation (Expected to FAIL)
-- INSERT INTO Customer VALUES (5, 'Test User', 'rahul@gmail.com', '9000000005');
