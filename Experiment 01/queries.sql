-- ==============================================================================
-- EXPERIMENT 01: Design an ER Diagram for Indian E-Commerce Platform
-- Course Outcome: CO1
-- Environment: MySQL 8.0+ / MySQL Workbench
-- ==============================================================================

-- 1. Create and Select Database
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- 2. Customer Table (Strong Entity)
-- Represents registered Indian e-commerce customers
CREATE TABLE IF NOT EXISTS Customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE
);

-- 3. Address Table (Entity related to Customer via 1:N)
-- Stores multiple delivery addresses per customer
CREATE TABLE IF NOT EXISTS Address (
    address_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_line VARCHAR(200) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    address_type VARCHAR(20) DEFAULT 'Home',
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE
);

-- 4. Seller Table (Strong Entity)
-- Represents Indian marketplace merchants
CREATE TABLE IF NOT EXISTS Seller (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE
);

-- 5. Category Table (Classification Entity)
-- Represents item classifications (Electronics, Books, Clothing, etc.)
CREATE TABLE IF NOT EXISTS Category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- 6. Product Table (Entity related to Category N:1 and Seller 1:N)
CREATE TABLE IF NOT EXISTS Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    category_id INT,
    seller_id INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
        ON DELETE SET NULL,
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id)
        ON DELETE SET NULL
);

-- 7. Product_Details Table (Specialization / Extension 1:1)
CREATE TABLE IF NOT EXISTS Product_Details (
    product_id INT PRIMARY KEY,
    brand VARCHAR(100),
    description VARCHAR(255),
    specifications TEXT,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
);

-- 8. Orders Table (Entity related to Customer N:1)
CREATE TABLE IF NOT EXISTS Orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE
);

-- 9. OrderItem Table (Weak Entity / M:N Bridge between Orders and Products)
CREATE TABLE IF NOT EXISTS OrderItem (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
);

-- 10. Payment Table (1:1 Relationship with Orders)
CREATE TABLE IF NOT EXISTS Payment (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(30) NOT NULL, -- UPI, NetBanking, Card, COD
    payment_status VARCHAR(30) NOT NULL, -- Paid, Pending, Failed
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE
);

-- 11. Delivery Table (1:1 Relationship with Orders)
CREATE TABLE IF NOT EXISTS Delivery (
    delivery_id INT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    delivery_address_id INT,
    delivery_date DATE,
    delivery_status VARCHAR(30) NOT NULL, -- Dispatched, In Transit, Delivered
    tracking_number VARCHAR(50) UNIQUE,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (delivery_address_id) REFERENCES Address(address_id)
        ON DELETE SET NULL
);

-- 12. Insert Sample Records for Conceptual Validation
INSERT INTO Customer VALUES
(1, 'Rahul Sharma', 'rahul@gmail.com', '9876543210'),
(2, 'Priya Singh', 'priya@gmail.com', '9876543211'),
(3, 'Aman Verma', 'aman@gmail.com', '9876543212');

INSERT INTO Address VALUES
(101, 1, '12 MG Road', 'Lucknow', 'Uttar Pradesh', '226001', 'Home'),
(102, 2, '45 Gomti Nagar', 'Lucknow', 'Uttar Pradesh', '226010', 'Office'),
(103, 3, '21 Civil Lines', 'Prayagraj', 'Uttar Pradesh', '211001', 'Home');

INSERT INTO Seller VALUES
(201, 'Tech World Pvt Ltd', 'techworld@gmail.com', '9000000001'),
(202, 'Smart Retailers', 'smartstore@gmail.com', '9000000002');

INSERT INTO Category VALUES
(301, 'Electronics'),
(302, 'Books'),
(303, 'Clothing');

INSERT INTO Product VALUES
(401, 'HP Pavilion Laptop', 55000.00, 20, 301, 201),
(402, 'Fundamentals of DBMS', 750.00, 50, 302, 202),
(403, 'Men Cotton T-Shirt', 599.00, 30, 303, 201);

INSERT INTO Product_Details VALUES
(401, 'HP', '16GB RAM, 512GB SSD Windows 11', '15.6 inch FHD, Intel i5'),
(402, 'Pearson', 'Database Management Systems by Navathe', '8th Edition Paperback'),
(403, 'Puma', '100% Combed Cotton Regular Fit', 'Size L, Blue Color');

INSERT INTO Orders VALUES
(501, 1, '2026-08-20', 'Confirmed', 56500.00),
(502, 2, '2026-08-21', 'Shipped', 599.00);

INSERT INTO OrderItem VALUES
(501, 401, 1, 55000.00),
(501, 402, 2, 750.00),
(502, 403, 1, 599.00);

INSERT INTO Payment VALUES
(601, 501, 'UPI', 'Paid', 56500.00),
(602, 502, 'Card', 'Paid', 599.00);

INSERT INTO Delivery VALUES
(701, 501, 101, '2026-08-25', 'Delivered', 'TRK90281231'),
(702, 502, 102, '2026-08-26', 'Out for Delivery', 'TRK90281232');

-- 13. Verify Tables & Data
SHOW TABLES;
SELECT * FROM Customer;
SELECT * FROM Product;
SELECT * FROM Orders;
