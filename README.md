# Database Management Systems (DBMS) Laboratory Manual

[![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue.svg?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Status](https://img.shields.io/badge/Status-Completed%20(7%2F7)-success.svg)]()
[![Curriculum](https://img.shields.io/badge/Curriculum-DBMS%20Practicals-orange.svg)]()
[![Documentation](https://img.shields.io/badge/Documentation-Complete-brightgreen.svg)]()

This repository contains the complete laboratory practical solutions, documentation, and SQL programs for the **Database Management Systems (DBMS) Laboratory** course. It covers **Experiments 01 through 07**, thoroughly aligned with standard Course Outcomes (**CO1 to CO4**).

---

## 📑 Master Index of Experiments

| Exp # | Experiment Title | Course Outcome | Documentation | SQL Source |
| :---: | :--- | :---: | :---: | :---: |
| **01** | Design an ER Diagram for Indian E-Commerce Platform | **CO1** | [README.md](Experiment%2001/README.md) / [experiment1.md](Experiment%2001/experiment1.md) | [queries.sql](Experiment%2001/queries.sql) \| [ER Diagram](Experiment%2001/er_diagram.png) |
| **02** | Convert ER Diagram into Relational Schema | **CO2** | [README.md](Experiment%2002/README.md) / [experiment2.md](Experiment%2002/experiment2.md) | [schema.sql](Experiment%2002/schema.sql) \| [queries.sql](Experiment%2002/queries.sql) |
| **03** | SQL Queries: Selection, Projection, Aggregation, GROUP BY, HAVING, CASE & JOINs | **CO3** | [README.md](Experiment%2003/README.md) / [experiment3.md](Experiment%2003/experiment3.md) | [queries.sql](Experiment%2003/queries.sql) |
| **04** | Joins, Correlated Subqueries, EXISTS, Set Operations, and EXPLAIN | **CO3** | [README.md](Experiment%2004/README.md) / [experiment4.md](Experiment%2004/experiment4.md) | [queries.sql](Experiment%2004/queries.sql) |
| **05** | SQL Views, View Updatability, and Recursive CTEs for Hierarchy | **CO3** | [README.md](Experiment%2005/README.md) / [experiment5.md](Experiment%2005/experiment5.md) | [queries.sql](Experiment%2005/queries.sql) |
| **06** | Stored Procedures, Validation Triggers, and Audit Logging | **CO3** | [README.md](Experiment%2006/README.md) / [experiment6.md](Experiment%2006/experiment6.md) | [queries.sql](Experiment%2006/queries.sql) |
| **07** | Normalization (UNF to 3NF & BCNF), Lossless Join & Dependency Preservation | **CO4** | [README.md](Experiment%2007/README.md) / [experiment7.md](Experiment%2007/experiment7.md) | [queries.sql](Experiment%2007/queries.sql) |

---

## 🔬 Detailed Experiment Descriptions

### [Experiment 01: Design an ER Diagram for Indian E-Commerce Platform](Experiment%2001/README.md)
- **Course Outcome**: `CO1` (Conceptual Data Modeling)
- **Aim**: To design a comprehensive Entity-Relationship (ER) diagram for an Indian e-commerce platform incorporating real-world attributes, multi-entity relationships, cardinality ratios, and specialization hierarchies.
- **Key Entities**: Customer, Address, Seller, Category, Product, Product_Details, Orders, OrderItem, Payment, Delivery.
- **Deliverables**: [Experiment 01/README.md](Experiment%2001/README.md), [er_diagram.png](Experiment%2001/er_diagram.png), and [queries.sql](Experiment%2001/queries.sql).

---

### [Experiment 02: Convert ER Diagram into Relational Schema](Experiment%2002/README.md)
- **Course Outcome**: `CO2` (Relational Mapping & Integrity Constraints)
- **Aim**: To convert the conceptual ER diagram into a fully normalized relational schema, enforcing primary keys, foreign keys, cardinality rules, domain constraints (`CHECK`, `NOT NULL`, `UNIQUE`), and referential actions (`ON DELETE CASCADE`, `ON DELETE SET NULL`) in MySQL.
- **Deliverables**: [Experiment 02/README.md](Experiment%2002/README.md), [schema.sql](Experiment%2002/schema.sql), and [queries.sql](Experiment%2002/queries.sql).

---

### [Experiment 03: SQL Queries - Selection, Projection, Aggregations, GROUP BY, HAVING, CASE, and JOINs](Experiment%2003/README.md)
- **Course Outcome**: `CO3` (SQL DML & Query Formulation)
- **Aim**: To create an Employee–Department–Project database (30 employees, 5 departments, 8 projects) and execute queries using Selection, Projection, Aggregate Functions (`COUNT`, `AVG`, `SUM`, `MIN`, `MAX`), `GROUP BY`, `HAVING`, conditional `CASE` expressions, `ORDER BY`, and multi-table joins.
- **Deliverables**: [Experiment 03/README.md](Experiment%2003/README.md) and [queries.sql](Experiment%2003/queries.sql).

---

### [Experiment 04: Joins, Correlated Subqueries, EXISTS, Set Operations, and EXPLAIN](Experiment%2004/README.md)
- **Course Outcome**: `CO3` (Advanced Relational Queries & Execution Plans)
- **Aim**: To formulate advanced queries using `INNER JOIN`, `LEFT JOIN`, self-joins, 3-way joins, correlated subqueries, `EXISTS`, and simulated set operations (`INTERSECT` and `EXCEPT`). Analyze and compare query execution plans using `EXPLAIN`.
- **Deliverables**: [Experiment 04/README.md](Experiment%2004/README.md) and [queries.sql](Experiment%2004/queries.sql).

---

### [Experiment 05: SQL Views, View Updatability, and Recursive CTEs for Hierarchy](Experiment%2005/README.md)
- **Course Outcome**: `CO3` (Views, Updatability & Recursive Processing)
- **Aim**: To create SQL views for department salary summaries and employee reporting hierarchies, examine conditions governing view updatability under the SQL standard, and implement a recursive Common Table Expression (CTE) to trace multi-level manager reporting chains.
- **Deliverables**: [Experiment 05/README.md](Experiment%2005/README.md) and [queries.sql](Experiment%2005/queries.sql).

---

### [Experiment 06: Stored Procedures, Validation Triggers, and Audit Logging](Experiment%2006/README.md)
- **Course Outcome**: `CO3` (Procedural SQL, Triggers & Auditing)
- **Aim**: To develop a stored procedure `transfer_employee(emp_id, new_dept_id)` with validation and transaction rollback, configure `BEFORE` triggers for salary validation (enforcing bounds ₹30,000–₹1,50,000), and `AFTER UPDATE` triggers for audit logging.
- **Deliverables**: [Experiment 06/README.md](Experiment%2006/README.md) and [queries.sql](Experiment%2006/queries.sql).

---

### [Experiment 07: Normalization from UNF to 3NF and BCNF, Lossless Join & Dependency Preservation](Experiment%2007/README.md)
- **Course Outcome**: `CO4` (Relational Design Theory & Normalization)
- **Aim**: Given a denormalized retail Sales table, identify non-trivial functional dependencies and candidate keys, normalize step-by-step from UNF to 1NF, 2NF, 3NF, and BCNF, and verify both **Lossless Join** decomposition and **Dependency Preservation** using SQL verification queries.
- **Deliverables**: [Experiment 07/README.md](Experiment%2007/README.md) and [queries.sql](Experiment%2007/queries.sql).

---

## 🛠️ Environment & Prerequisites

- **RDBMS**: MySQL Server 8.0+
- **Graphical Interface**: MySQL Workbench 8.0+
- **Command Line Interface**: MySQL CLI Shell / PowerShell

---

## 🚀 Instructions for Running SQL Files

### Option A: Using MySQL Workbench (GUI)
1. Open **MySQL Workbench** and establish a connection to your local MySQL Server instance.
2. Navigate to **File &rarr; Open SQL Script...** (or press `Ctrl + Shift + O`).
3. Select the desired `.sql` script (for example, `Experiment 03/queries.sql`).
4. Click the **Execute (Lightning icon)** button or press `Ctrl + Shift + Enter` to run all statements.
5. Inspect the generated query result grids and output console for confirmation.

### Option B: Using MySQL Command Line Shell
Execute any experiment script directly using the MySQL CLI:

```bash
# Clone the repository
git clone https://github.com/anshikanshu325-byte/DBMS-LAB-FILE-.git
cd DBMS-LAB-FILE-

# Execute specific experiments
mysql -u root -p < "Experiment 01/queries.sql"
mysql -u root -p < "Experiment 02/schema.sql"
mysql -u root -p < "Experiment 03/queries.sql"
mysql -u root -p < "Experiment 04/queries.sql"
mysql -u root -p < "Experiment 05/queries.sql"
mysql -u root -p < "Experiment 06/queries.sql"
mysql -u root -p < "Experiment 07/queries.sql"
```

---

## 📚 Textbooks & Reference Literature

1. **Elmasri, R., & Navathe, S. B.** — *Fundamentals of Database Systems*, 7th Edition, Pearson.
2. **Ramakrishnan, R., & Gehrke, J.** — *Database Management Systems*, 3rd Edition, McGraw-Hill.
3. **Silberschatz, A., Korth, H. F., & Sudarshan, S.** — *Database System Concepts*, 7th Edition, McGraw-Hill.
4. **Date, C. J.** — *An Introduction to Database Systems*, 8th Edition, Pearson.
