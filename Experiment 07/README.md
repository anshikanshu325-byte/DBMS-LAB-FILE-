# Experiment 07: Normalization from UNF to 3NF and BCNF, Lossless Join & Dependency Preservation

- **Course Outcome**: `CO4` (Analyze functional dependencies, perform relational schema normalization, and verify decomposition properties)
- **Environment**: MySQL 8.0+ / MySQL Workbench

---

## 1. Aim
Given a denormalized retail Sales dataset, identify all non-trivial functional dependencies and candidate keys, normalize step-by-step from Unnormalized Form (UNF) through First (1NF), Second (2NF), Third (3NF), and Boyce-Codd Normal Form (BCNF), and verify both **Lossless Join Decomposition** and **Dependency Preservation** using SQL queries.

---

## 2. Theory

### 2.1 Database Anomalies & Normalization Goals
Relational normalization is a systematic formal design technique developed by E. F. Codd to organize database schemas:
- **Redundancy Elimination**: Minimizes duplicate storage of repeated data items.
- **Update Anomaly**: Modifying an attribute in one record requires updating multiple rows, risking inconsistent state.
- **Insertion Anomaly**: Inability to record independent facts without fabricating dummy values for other attributes.
- **Deletion Anomaly**: Unintentional loss of independent facts when deleting a related record.

### 2.2 Functional Dependencies & Keys
Given a relation $R$, a functional dependency $X \to Y$ holds if whenever two tuples agree on attributes $X$, they must also agree on attributes $Y$.
- **Candidate Key**: A minimal superkey whose closure includes all attributes of $R$.
- In the retail sales relation with attributes $\{ \text{order\_id}, \text{product\_id}, \dots \}$, the composite key is:
  $$\text{Candidate Key} = \{ \text{order\_id}, \text{product\_id} \}$$

### 2.3 Step-by-Step Normal Forms
1. **First Normal Form (1NF)**: All attribute values must be atomic (no repeating groups, sets, or nested records), and a primary key must uniquely identify each row.
2. **Second Normal Form (2NF)**: The relation is in 1NF and contains **no partial dependencies**—every non-prime attribute must be fully functionally dependent on the entire candidate key.
3. **Third Normal Form (3NF)**: The relation is in 2NF and contains **no transitive dependencies**—no non-prime attribute is transitively dependent on any candidate key. Formally, for every non-trivial FD $X \to Y$, either $X$ is a superkey or $Y$ is a prime attribute.
4. **Boyce-Codd Normal Form (BCNF)**: A stricter variant of 3NF where for every non-trivial FD $X \to Y$, the determinant $X$ must be a superkey.

### 2.4 Decomposition Properties
- **Lossless-Join Decomposition**: Guarantees that applying natural joins across decomposed relations reproduces the exact original relation without spurious or missing tuples:
  $$R_1 \bowtie R_2 = R$$
- **Dependency Preservation**: Ensures that every functional dependency in the original schema can be verified directly on a single decomposed relation without computing expensive joins.

---

## 3. Functional Dependencies Identified

In the denormalized sales relation:
- **FD1**: $\{ \text{order\_id}, \text{product\_id} \} \to \{ \text{quantity}, \text{line\_total} \}$ *(Full dependency on composite key)*
- **FD2**: $\text{order\_id} \to \{ \text{order\_date}, \text{customer\_id}, \text{customer\_name}, \text{customer\_city}, \text{store\_id}, \text{store\_city}, \text{salesperson\_id}, \text{salesperson\_name} \}$ *(Partial dependency on composite key)*
- **FD3**: $\text{product\_id} \to \{ \text{product\_name}, \text{category}, \text{unit\_price} \}$ *(Partial dependency on composite key)*
- **FD4**: $\text{customer\_id} \to \{ \text{customer\_name}, \text{customer\_city} \}$ *(Transitive dependency via order_id)*
- **FD5**: $\text{store\_id} \to \{ \text{store\_city} \}$ *(Transitive dependency via salesperson_id)*
- **FD6**: $\text{salesperson\_id} \to \{ \text{salesperson\_name}, \text{store\_id} \}$ *(Transitive dependency via order_id)*

---

## 4. SQL Program

See the full script in [`queries.sql`](queries.sql).

```sql
DROP DATABASE IF EXISTS SalesNormalizationDB;
CREATE DATABASE SalesNormalizationDB;
USE SalesNormalizationDB;

-- 1NF Relation
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

-- 2NF Decomposition
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

-- 3NF Decomposition
CREATE TABLE Customers_3NF (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_city VARCHAR(100) NOT NULL
);

CREATE TABLE Stores_3NF (
    store_id INT PRIMARY KEY,
    store_city VARCHAR(100) NOT NULL
);

CREATE TABLE Salespersons_3NF (
    salesperson_id INT PRIMARY KEY,
    salesperson_name VARCHAR(100) NOT NULL,
    store_id INT NOT NULL,
    FOREIGN KEY (store_id) REFERENCES Stores_3NF(store_id)
);

CREATE TABLE Products_3NF (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Orders_3NF (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    salesperson_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers_3NF(customer_id),
    FOREIGN KEY (salesperson_id) REFERENCES Salespersons_3NF(salesperson_id)
);

CREATE TABLE Order_Items_3NF (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders_3NF(order_id),
    FOREIGN KEY (product_id) REFERENCES Products_3NF(product_id)
);
```

---

## 5. Sample Data & Decomposition Results

### 5.1 Unnormalized Sales Input Data (UNF)
```text
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+------------+--------------+-------------+------------+----------+------------+
| order_id | order_date | customer_id | customer_name | customer_city | store_id | store_city | salesperson_id | salesperson_name | product_id | product_name | category    | unit_price | quantity | line_total |
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+------------+--------------+-------------+------------+----------+------------+
|      101 | 2026-03-01 |           1 | Rahul Sharma  | Delhi         |       10 | Delhi      |            501 | Amit Verma       |       1001 | Laptop       | Electronics |   55000.00 |        1 |   55000.00 |
|      101 | 2026-03-01 |           1 | Rahul Sharma  | Delhi         |       10 | Delhi      |            501 | Amit Verma       |       1002 | Mouse        | Electronics |     800.00 |        2 |    1600.00 |
|      102 | 2026-03-02 |           2 | Priya Singh   | Mumbai        |       20 | Mumbai     |            502 | Neha Gupta       |       1003 | Desk Chair   | Furniture   |    7500.00 |        1 |    7500.00 |
|      103 | 2026-03-02 |           3 | Ankit Patel   | Ahmedabad     |       30 | Ahmedabad  |            503 | Vikas Joshi      |       1001 | Laptop       | Electronics |   55000.00 |        2 |  110000.00 |
|      103 | 2026-03-02 |           3 | Ankit Patel   | Ahmedabad     |       30 | Ahmedabad  |            503 | Vikas Joshi      |       1004 | Keyboard     | Electronics |    1500.00 |        1 |    1500.00 |
|      104 | 2026-03-03 |           1 | Rahul Sharma  | Delhi         |       10 | Delhi      |            501 | Amit Verma       |       1004 | Keyboard     | Electronics |    1500.00 |        2 |    3000.00 |
|      105 | 2026-03-04 |           4 | Sneha Roy     | Kolkata       |       40 | Kolkata    |            504 | Pooja Das        |       1005 | Monitor      | Electronics |   12000.00 |        1 |   12000.00 |
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+------------+--------------+-------------+------------+----------+------------+
7 rows in set (0.00 sec)
```

---

### 5.2 Decomposed 3NF / BCNF Tables Preview

#### `Customers_3NF`:
```text
+-------------+---------------+---------------+
| customer_id | customer_name | customer_city |
+-------------+---------------+---------------+
|           1 | Rahul Sharma  | Delhi         |
|           2 | Priya Singh   | Mumbai        |
|           3 | Ankit Patel   | Ahmedabad     |
|           4 | Sneha Roy     | Kolkata       |
+-------------+---------------+---------------+
```

#### `Stores_3NF`:
```text
+----------+------------+
| store_id | store_city |
+----------+------------+
|       10 | Delhi      |
|       20 | Mumbai     |
|       30 | Ahmedabad  |
|       40 | Kolkata    |
+----------+------------+
```

#### `Salespersons_3NF`:
```text
+----------------+------------------+----------+
| salesperson_id | salesperson_name | store_id |
+----------------+------------------+----------+
|            501 | Amit Verma       |       10 |
|            502 | Neha Gupta       |       20 |
|            503 | Vikas Joshi      |       30 |
|            504 | Pooja Das        |       40 |
+----------------+------------------+----------+
```

#### `Products_3NF`:
```text
+------------+--------------+-------------+------------+
| product_id | product_name | category    | unit_price |
+------------+--------------+-------------+------------+
|       1001 | Laptop       | Electronics |   55000.00 |
|       1002 | Mouse        | Electronics |     800.00 |
|       1003 | Desk Chair   | Furniture   |    7500.00 |
|       1004 | Keyboard     | Electronics |    1500.00 |
|       1005 | Monitor      | Electronics |   12000.00 |
+------------+--------------+-------------+------------+
```

---

## 6. Verification of Decomposition Properties

### 6.1 Lossless Join Verification
To verify that the decomposition is lossless, we reconstruct the complete denormalized view by joining the 3NF tables:
```sql
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
```
#### Verification Result:
```text
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+------------+--------------+-------------+------------+----------+------------+
| order_id | order_date | customer_id | customer_name | customer_city | store_id | store_city | salesperson_id | salesperson_name | product_id | product_name | category    | unit_price | quantity | line_total |
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+------------+--------------+-------------+------------+----------+------------+
|      101 | 2026-03-01 |           1 | Rahul Sharma  | Delhi         |       10 | Delhi      |            501 | Amit Verma       |       1001 | Laptop       | Electronics |   55000.00 |        1 |   55000.00 |
|      101 | 2026-03-01 |           1 | Rahul Sharma  | Delhi         |       10 | Delhi      |            501 | Amit Verma       |       1002 | Mouse        | Electronics |     800.00 |        2 |    1600.00 |
|      102 | 2026-03-02 |           2 | Priya Singh   | Mumbai        |       20 | Mumbai     |            502 | Neha Gupta       |       1003 | Desk Chair   | Furniture   |    7500.00 |        1 |    7500.00 |
|      103 | 2026-03-02 |           3 | Ankit Patel   | Ahmedabad     |       30 | Ahmedabad  |            503 | Vikas Joshi      |       1001 | Laptop       | Electronics |   55000.00 |        2 |  110000.00 |
|      103 | 2026-03-02 |           3 | Ankit Patel   | Ahmedabad     |       30 | Ahmedabad  |            503 | Vikas Joshi      |       1004 | Keyboard     | Electronics |    1500.00 |        1 |    1500.00 |
|      104 | 2026-03-03 |           1 | Rahul Sharma  | Delhi         |       10 | Delhi      |            501 | Amit Verma       |       1004 | Keyboard     | Electronics |    1500.00 |        2 |    3000.00 |
|      105 | 2026-03-04 |           4 | Sneha Roy     | Kolkata       |       40 | Kolkata    |            504 | Pooja Das        |       1005 | Monitor      | Electronics |   12000.00 |        1 |   12000.00 |
+----------+------------+-------------+---------------+---------------+----------+------------+----------------+------------------+------------+--------------+-------------+------------+----------+------------+
7 rows in set (0.00 sec)
```
**Lossless Condition Proved**: The join produces exactly the 7 original rows with identical values—zero spurious records, zero dropped records.

---

### 6.2 Dependency Preservation Verification
Every functional dependency identified in the initial relation is preserved directly as a primary key constraint in one of the decomposed tables:
- $\text{FD1}: \{ \text{order\_id}, \text{product\_id} \} \to \{ \text{quantity}, \text{line\_total} \}$ &rarr; Preserved in `Order_Items_3NF`
- $\text{FD2}: \text{order\_id} \to \{ \text{order\_date}, \text{customer\_id}, \text{salesperson\_id} \}$ &rarr; Preserved in `Orders_3NF`
- $\text{FD3}: \text{product\_id} \to \{ \text{product\_name}, \text{category}, \text{unit\_price} \}$ &rarr; Preserved in `Products_3NF`
- $\text{FD4}: \text{customer\_id} \to \{ \text{customer\_name}, \text{customer\_city} \}$ &rarr; Preserved in `Customers_3NF`
- $\text{FD5}: \text{store\_id} \to \{ \text{store\_city} \}$ &rarr; Preserved in `Stores_3NF`
- $\text{FD6}: \text{salesperson\_id} \to \{ \text{salesperson\_name}, \text{store\_id} \}$ &rarr; Preserved in `Salespersons_3NF`

Since all original FDs can be checked using single relations without joins, the decomposition is **fully dependency-preserving**.

---

## 7. Result / Conclusion
The denormalized retail sales dataset was analyzed and normalized systematically through 1NF, 2NF, 3NF, and BCNF. Partial and transitive functional dependencies were eliminated. Both **Lossless Join Decomposition** and **Dependency Preservation** were verified via SQL queries.
