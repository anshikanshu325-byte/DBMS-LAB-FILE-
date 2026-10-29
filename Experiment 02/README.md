# Experiment 02: Convert ER Diagram into Relational Schema

- **Course Outcome**: `CO2` (Map conceptual ER models to relational schemas and enforce database constraints)
- **Environment**: MySQL 8.0+ / MySQL Workbench

---

## 1. Aim
To convert the conceptual ER diagram of an Indian e-commerce platform into a normalized relational schema and implement it using MySQL with appropriate integrity constraints (`PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK`, `ON DELETE CASCADE`, and `ON DELETE SET NULL`). To insert realistic sample data, query the schema, and demonstrate referential integrity violations and cascading actions.

---

## 2. Theory

### 2.1 ER-to-Relational Mapping Principles
Transforming an ER diagram into a relational model follows standard mapping algorithms:
1. **Strong Entity Types**: Each strong entity is mapped directly to a separate relation. Simple attributes become table columns, and the key attribute becomes the relation's `PRIMARY KEY`.
2. **Weak Entity Types**: Mapped to a relation containing columns for all partial attributes plus the primary key of the owner entity as a `FOREIGN KEY`. The composite of the owner PK and partial key forms the composite `PRIMARY KEY`.
3. **1:1 Relationships**: Implemented by including the primary key of one relation as a foreign key in the other with a `UNIQUE` constraint.
4. **1:N Relationships**: Implemented by adding the primary key from the "1" side as a foreign key column on the "N" (many) side.
5. **M:N Relationships**: Represented as a separate relationship table (bridge/associative table, e.g., `OrderItem`) whose primary key is the composite of the foreign keys referencing the two participating entities.

### 2.2 Integrity Constraints and Referential Actions
- **Entity Integrity**: Every table must have a primary key, and no primary key column can contain `NULL`.
- **Domain Integrity**: Column values must adhere to defined data types, sizes, and optional `CHECK` conditions.
- **Referential Integrity**: A foreign key value in a referencing relation must either match an existing primary key value in the referenced relation or be `NULL`.
- **ON DELETE CASCADE**: Automatically deletes all matching child rows when a parent row is deleted.
- **ON DELETE SET NULL**: Sets foreign key values in child rows to `NULL` when the referenced parent row is deleted.

---

## 3. Relational Schema Specification

1. **Customer** (`customer_id` [PK], `customer_name`, `email` [UK], `phone` [UK])
2. **Address** (`address_id` [PK], `customer_id` [FK &rarr; Customer], `address_line`, `city`, `state`, `pincode`)
3. **Seller** (`seller_id` [PK], `seller_name`, `email` [UK], `phone` [UK])
4. **Category** (`category_id` [PK], `category_name` [UK])
5. **Product** (`product_id` [PK], `product_name`, `price`, `category_id` [FK &rarr; Category], `seller_id` [FK &rarr; Seller])
6. **Product_Details** (`product_id` [PK, FK &rarr; Product], `brand`, `description`, `stock`)
7. **Orders** (`order_id` [PK], `customer_id` [FK &rarr; Customer], `order_date`, `order_status`)
8. **OrderItem** (`order_id` [PK, FK &rarr; Orders], `product_id` [PK, FK &rarr; Product], `quantity`, `price`)
9. **Payment** (`payment_id` [PK], `order_id` [FK &rarr; Orders, UK], `payment_method`, `payment_status`, `amount`)
10. **Delivery** (`delivery_id` [PK], `order_id` [FK &rarr; Orders, UK], `delivery_address_id` [FK &rarr; Address], `delivery_date`, `delivery_status`)

---

## 4. SQL Program

See the full script in [`schema.sql`](schema.sql) or [`queries.sql`](queries.sql).

```sql
-- Database Creation
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- 1. Customer
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE
);

-- 2. Address
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

-- 3. Seller
CREATE TABLE Seller (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE
);

-- 4. Category
CREATE TABLE Category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- 5. Product
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

-- 6. Product_Details
CREATE TABLE Product_Details (
    product_id INT PRIMARY KEY,
    brand VARCHAR(100),
    description VARCHAR(255),
    stock INT NOT NULL CHECK (stock >= 0),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON DELETE CASCADE
);

-- 7. Orders
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE CASCADE
);

-- 8. OrderItem
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

-- 9. Payment
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE
);

-- 10. Delivery
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
```

---

## 5. Sample Data & Expected Outputs

### 5.1 Sample Input Data Insertion
```sql
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
```

### 5.2 Expected Output Tables

#### Query: `SELECT * FROM Customer;`
```text
+-------------+---------------+-----------------+------------+
| customer_id | customer_name | email           | phone      |
+-------------+---------------+-----------------+------------+
|           1 | Rahul Sharma  | rahul@gmail.com | 9876543210 |
|           2 | Priya Singh   | priya@gmail.com | 9876543211 |
|           3 | Aman Verma    | aman@gmail.com  | 9876543212 |
+-------------+---------------+-----------------+------------+
```

#### Query: `SELECT * FROM Product;`
```text
+------------+---------------+----------+-------------+-----------+
| product_id | product_name  | price    | category_id | seller_id |
+------------+---------------+----------+-------------+-----------+
|        401 | Laptop        | 55000.00 |         301 |       201 |
|        402 | Database Book |   750.00 |         302 |       202 |
|        403 | T-Shirt       |   599.00 |         303 |       201 |
+------------+---------------+----------+-------------+-----------+
```

#### Query: `SELECT * FROM Orders;`
```text
+----------+-------------+------------+--------------+
| order_id | customer_id | order_date | order_status |
+----------+-------------+------------+--------------+
|      501 |           1 | 2026-08-20 | Confirmed    |
|      502 |           2 | 2026-08-21 | Shipped      |
+----------+-------------+------------+--------------+
```

---

## 6. Constraint Demonstrations & Failure Scenarios

### 6.1 Referential Integrity Violations (Foreign Key Rejections)
```sql
-- Attempting to insert an order with an invalid customer ID (customer_id = 99)
INSERT INTO Orders VALUES (503, 99, '2026-08-22', 'Confirmed');
```
**Expected MySQL Engine Response**:
```text
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails 
(`ecommerce_db`.`Orders`, CONSTRAINT `Orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `Customer` (`customer_id`))
```

### 6.2 `ON DELETE CASCADE` Action
```sql
-- Deleting customer with customer_id = 1
DELETE FROM Customer WHERE customer_id = 1;
```
**Observation**:
Executing `SELECT * FROM Orders WHERE customer_id = 1;` and `SELECT * FROM Address WHERE customer_id = 1;` returns **empty sets**. Because `customer_id` is defined with `ON DELETE CASCADE`, removing the customer automatically and safely deletes their corresponding addresses, orders, order items, and payment transactions.

### 6.3 `ON DELETE SET NULL` Action
```sql
-- Deleting seller with seller_id = 201
DELETE FROM Seller WHERE seller_id = 201;
```
**Observation**:
Querying `SELECT product_id, product_name, seller_id FROM Product;` shows:
```text
+------------+---------------+-----------+
| product_id | product_name  | seller_id |
+------------+---------------+-----------+
|        401 | Laptop        |      NULL |
|        402 | Database Book |       202 |
|        403 | T-Shirt       |      NULL |
+------------+---------------+-----------+
```
The products are preserved in the catalog, but the seller reference is automatically updated to `NULL`.

### 6.4 `NOT NULL` & `UNIQUE` Violations
```sql
-- Attempting to insert a NULL customer name (NOT NULL violation)
INSERT INTO Customer VALUES (4, NULL, 'test@gmail.com', '9000000003');
```
**Expected Output**:
```text
ERROR 1048 (23000): Column 'customer_name' cannot be null
```

```sql
-- Attempting to insert duplicate email (UNIQUE violation)
INSERT INTO Customer VALUES (5, 'Test User', 'rahul@gmail.com', '9000000005');
```
**Expected Output**:
```text
ERROR 1062 (23000): Duplicate entry 'rahul@gmail.com' for key 'Customer.email'
```

---

## 7. Result / Conclusion
The conceptual ER diagram was successfully translated into a normalized relational schema with 10 tables. Referential integrity rules, cascading operations (`CASCADE` and `SET NULL`), and domain constraints were implemented in MySQL and validated through comprehensive execution test cases.
