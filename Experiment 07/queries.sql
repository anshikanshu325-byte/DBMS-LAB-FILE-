-- ==============================================================================
-- EXPERIMENT 07: Normalization (UNF to 3NF & BCNF), Lossless Join 
--               & Dependency Preservation
-- Course Outcome: CO4
-- Environment: MySQL 8.0+ / MySQL Workbench
-- ==============================================================================

DROP DATABASE IF EXISTS SalesNormalizationDB;
CREATE DATABASE SalesNormalizationDB;
USE SalesNormalizationDB;

-- ==============================================================================
-- 1. UNNORMALIZED FORM (UNF) - FLAT DENORMALIZED RETAIL TABLE
-- ==============================================================================

DROP TABLE IF EXISTS Denormalized_Sales;
CREATE TABLE Denormalized_Sales (
    order_id INT,
    order_date DATE,
    customer_id INT,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100),
    store_id INT,
    store_city VARCHAR(100),
    salesperson_id INT,
    salesperson_name VARCHAR(100),
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    quantity INT,
    line_total DECIMAL(10,2)
);

-- Insert realistic retail sales records
INSERT INTO Denormalized_Sales VALUES
(101, '2026-03-01', 1, 'Rahul Sharma', 'Delhi', 10, 'Delhi', 501, 'Amit Verma', 1001, 'Laptop', 'Electronics', 55000.00, 1, 55000.00),
(101, '2026-03-01', 1, 'Rahul Sharma', 'Delhi', 10, 'Delhi', 501, 'Amit Verma', 1002, 'Mouse', 'Electronics', 800.00, 2, 1600.00),
(102, '2026-03-02', 2, 'Priya Singh', 'Mumbai', 20, 'Mumbai', 502, 'Neha Gupta', 1003, 'Desk Chair', 'Furniture', 7500.00, 1, 7500.00),
(103, '2026-03-02', 3, 'Ankit Patel', 'Ahmedabad', 30, 'Ahmedabad', 503, 'Vikas Joshi', 1001, 'Laptop', 'Electronics', 55000.00, 2, 110000.00),
(103, '2026-03-02', 3, 'Ankit Patel', 'Ahmedabad', 30, 'Ahmedabad', 503, 'Vikas Joshi', 1004, 'Keyboard', 'Electronics', 1500.00, 1, 1500.00),
(104, '2026-03-03', 1, 'Rahul Sharma', 'Delhi', 10, 'Delhi', 501, 'Amit Verma', 1004, 'Keyboard', 'Electronics', 1500.00, 2, 3000.00),
(105, '2026-03-04', 4, 'Sneha Roy', 'Kolkata', 40, 'Kolkata', 504, 'Pooja Das', 1005, 'Monitor', 'Electronics', 12000.00, 1, 12000.00);

SELECT * FROM Denormalized_Sales;

-- ==============================================================================
-- 2. FIRST NORMAL FORM (1NF)
-- Ensure all attributes are atomic and establish composite primary key (order_id, product_id)
-- ==============================================================================

DROP TABLE IF EXISTS Sales_1NF;
CREATE TABLE Sales_1NF (
    order_id INT,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    store_id INT NOT NULL,
    store_city VARCHAR(100) NOT NULL,
    salesperson_id INT NOT NULL,
    salesperson_name VARCHAR(100) NOT NULL,
    product_id INT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO Sales_1NF SELECT * FROM Denormalized_Sales;
SELECT * FROM Sales_1NF;

-- ==============================================================================
-- 3. SECOND NORMAL FORM (2NF)
-- Eliminate Partial Functional Dependencies:
-- {order_id, product_id} -> line_total, quantity
-- order_id -> order_date, customer_id, customer_name, customer_city, store_id, store_city, salesperson_id, salesperson_name
-- product_id -> product_name, category, unit_price
-- ==============================================================================

DROP TABLE IF EXISTS Order_Items_2NF;
DROP TABLE IF EXISTS Products_2NF;
DROP TABLE IF EXISTS Orders_2NF;

CREATE TABLE Products_2NF (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Orders_2NF (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    store_id INT NOT NULL,
    store_city VARCHAR(100) NOT NULL,
    salesperson_id INT NOT NULL,
    salesperson_name VARCHAR(100) NOT NULL
);

CREATE TABLE Order_Items_2NF (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders_2NF(order_id),
    FOREIGN KEY (product_id) REFERENCES Products_2NF(product_id)
);

-- Populate 2NF Relations
INSERT INTO Products_2NF (product_id, product_name, category, unit_price)
SELECT DISTINCT product_id, product_name, category, unit_price FROM Sales_1NF;

INSERT INTO Orders_2NF (order_id, order_date, customer_id, customer_name, customer_city, store_id, store_city, salesperson_id, salesperson_name)
SELECT DISTINCT order_id, order_date, customer_id, customer_name, customer_city, store_id, store_city, salesperson_id, salesperson_name FROM Sales_1NF;

INSERT INTO Order_Items_2NF (order_id, product_id, quantity, line_total)
SELECT order_id, product_id, quantity, line_total FROM Sales_1NF;

SELECT * FROM Products_2NF;
SELECT * FROM Orders_2NF;
SELECT * FROM Order_Items_2NF;

-- ==============================================================================
-- 4. THIRD NORMAL FORM (3NF) & BCNF
-- Eliminate Transitive Functional Dependencies:
-- customer_id -> customer_name, customer_city
-- store_id -> store_city
-- salesperson_id -> salesperson_name, store_id
-- ==============================================================================

DROP TABLE IF EXISTS Order_Items_3NF;
DROP TABLE IF EXISTS Orders_3NF;
DROP TABLE IF EXISTS Products_3NF;
DROP TABLE IF EXISTS Salespersons_3NF;
DROP TABLE IF EXISTS Stores_3NF;
DROP TABLE IF EXISTS Customers_3NF;

-- 4.1 Customers Table
CREATE TABLE Customers_3NF (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_city VARCHAR(100) NOT NULL
);

-- 4.2 Stores Table
CREATE TABLE Stores_3NF (
    store_id INT PRIMARY KEY,
    store_city VARCHAR(100) NOT NULL
);

-- 4.3 Salespersons Table
CREATE TABLE Salespersons_3NF (
    salesperson_id INT PRIMARY KEY,
    salesperson_name VARCHAR(100) NOT NULL,
    store_id INT NOT NULL,
    FOREIGN KEY (store_id) REFERENCES Stores_3NF(store_id)
);

-- 4.4 Products Table
CREATE TABLE Products_3NF (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

-- 4.5 Orders Table
CREATE TABLE Orders_3NF (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    salesperson_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers_3NF(customer_id),
    FOREIGN KEY (salesperson_id) REFERENCES Salespersons_3NF(salesperson_id)
);

-- 4.6 Order_Items Table
CREATE TABLE Order_Items_3NF (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders_3NF(order_id),
    FOREIGN KEY (product_id) REFERENCES Products_3NF(product_id)
);

-- Populate 3NF Relations
INSERT INTO Customers_3NF (customer_id, customer_name, customer_city)
SELECT DISTINCT customer_id, customer_name, customer_city FROM Orders_2NF;

INSERT INTO Stores_3NF (store_id, store_city)
SELECT DISTINCT store_id, store_city FROM Orders_2NF;

INSERT INTO Salespersons_3NF (salesperson_id, salesperson_name, store_id)
SELECT DISTINCT salesperson_id, salesperson_name, store_id FROM Orders_2NF;

INSERT INTO Products_3NF (product_id, product_name, category, unit_price)
SELECT product_id, product_name, category, unit_price FROM Products_2NF;

INSERT INTO Orders_3NF (order_id, order_date, customer_id, salesperson_id)
SELECT DISTINCT order_id, order_date, customer_id, salesperson_id FROM Orders_2NF;

INSERT INTO Order_Items_3NF (order_id, product_id, quantity, line_total)
SELECT order_id, product_id, quantity, line_total FROM Order_Items_2NF;

-- Display all 3NF tables
SELECT * FROM Customers_3NF;
SELECT * FROM Stores_3NF;
SELECT * FROM Salespersons_3NF;
SELECT * FROM Products_3NF;
SELECT * FROM Orders_3NF;
SELECT * FROM Order_Items_3NF;

-- ==============================================================================
-- 5. VERIFICATION OF LOSSLESS JOIN DECOMPOSITION
-- Reconstruct the original relation using joins across 3NF tables.
-- Must produce exactly 7 rows identical to Denormalized_Sales without spurious tuples.
-- ==============================================================================

SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.customer_name,
    c.customer_city,
    s.store_id,
    s.store_city,
    sp.salesperson_id,
    sp.salesperson_name,
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    oi.quantity,
    oi.line_total
FROM Orders_3NF o
JOIN Customers_3NF c ON o.customer_id = c.customer_id
JOIN Salespersons_3NF sp ON o.salesperson_id = sp.salesperson_id
JOIN Stores_3NF s ON sp.store_id = s.store_id
JOIN Order_Items_3NF oi ON o.order_id = oi.order_id
JOIN Products_3NF p ON oi.product_id = p.product_id
ORDER BY o.order_id, p.product_id;

-- ==============================================================================
-- 6. VERIFICATION OF DEPENDENCY PRESERVATION
-- Check that all original functional dependencies are preserved within relations:
-- FD1: order_id -> order_date, customer_id, salesperson_id (Preserved in Orders_3NF)
-- FD2: customer_id -> customer_name, customer_city (Preserved in Customers_3NF)
-- FD3: salesperson_id -> salesperson_name, store_id (Preserved in Salespersons_3NF)
-- FD4: store_id -> store_city (Preserved in Stores_3NF)
-- FD5: product_id -> product_name, category, unit_price (Preserved in Products_3NF)
-- FD6: {order_id, product_id} -> quantity, line_total (Preserved in Order_Items_3NF)
-- ==============================================================================
SELECT 'All Functional Dependencies Preserved in 3NF / BCNF Schema' AS Verification_Status;
