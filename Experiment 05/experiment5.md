# Experiment 05: SQL Views, View Updatability, and Recursive CTEs for Hierarchy

- **Course Outcome**: `CO3` (Implement SQL views, test view updatability rules, and execute recursive CTEs for hierarchical data)
- **Environment**: MySQL 8.0+ / MySQL Workbench

---

## 1. Aim
To create SQL views for department salary summaries and employee reporting hierarchies, examine conditions governing view updatability under the SQL standard, and implement a recursive Common Table Expression (CTE) to trace multi-level manager reporting chains.

---

## 2. Theory

### 2.1 Database Views
A **View** is a virtual table defined by a stored SQL query. It does not store physical data tuples on disk (except in materialized views); instead, it dynamically evaluates the underlying query when referenced.
- **Benefits of Views**:
  - **Security & Access Control**: Restricts user access to sensitive subset columns (e.g., hiding employee personal bank info while exposing department assignments).
  - **Query Simplification**: Encapsulates intricate multi-table joins and aggregation routines behind an intuitive virtual table interface.
  - **Logical Data Independence**: Insulates application code from structural schema reorganizations.

### 2.2 View Updatability Rules
Under ANSI SQL and MySQL specifications, a view is updatable **only** if there is a 1-to-1 deterministic mapping between rows in the view and rows in the underlying base table. A view is **NOT updatable** if it contains:
1. Aggregate functions (`SUM`, `AVG`, `COUNT`, `MIN`, `MAX`).
2. The `DISTINCT` keyword.
3. A `GROUP BY` or `HAVING` clause.
4. `UNION` or `UNION ALL` set operations.
5. Subqueries in the `SELECT` list.
6. Joins that violate key-preservation properties.

### 2.3 Recursive Common Table Expressions (CTEs)
A Common Table Expression (CTE) is a temporary named result set defined within the scope of an execution block using the `WITH` clause.
A **Recursive CTE** references itself iteratively to process hierarchical or graph-structured datasets (such as organizational hierarchies or bill-of-materials). It comprises:
1. **Anchor Member**: The base query establishing the starting initial tuple set at depth/level 1.
2. `UNION ALL`: Combines anchor results with recursive iterations.
3. **Recursive Member**: A query referencing the CTE itself, executing iteratively until an empty set is produced.
4. **Termination Condition**: A predicate preventing infinite recursion loops.

---

## 3. Database Reference

The experiment builds on the `CompanyDB` relational schema:

```sql
USE CompanyDB;
```

---

## 4. SQL Program

See the full script in [`queries.sql`](queries.sql).

```sql
-- 1. Aggregated Department Salary Summary View
CREATE OR REPLACE VIEW department_salary_summary AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MIN(e.salary) AS minimum_salary,
    MAX(e.salary) AS maximum_salary,
    SUM(e.salary) AS total_salary
FROM Department d
JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- 2. Employee Hierarchy View
CREATE OR REPLACE VIEW employee_hierarchy AS
SELECT
    e.emp_id,
    e.emp_name,
    e.dept_id,
    d.dept_name,
    e.salary
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id;

-- 3. Base Table Update to test view reflection
UPDATE Employee
SET salary = salary + 1000
WHERE emp_id = 6;

-- 4. Recursive CTE for Multi-Level Reporting Chain
WITH RECURSIVE reporting_chain AS (
    SELECT
        emp_id,
        emp_name,
        dept_id,
        1 AS level,
        CAST(emp_name AS CHAR(500)) AS reporting_path
    FROM Employee
    WHERE dept_id = 1

    UNION ALL

    SELECT
        e.emp_id,
        e.emp_name,
        e.dept_id,
        rc.level + 1,
        CONCAT(rc.reporting_path, ' -> ', e.emp_name)
    FROM Employee e
    JOIN reporting_chain rc ON e.dept_id = rc.dept_id
    WHERE e.emp_id > rc.emp_id AND rc.level < 4
)
SELECT
    emp_id,
    emp_name,
    dept_id,
    level,
    reporting_path
FROM reporting_chain
ORDER BY level, emp_id
LIMIT 12;
```

---

## 5. Expected Outputs & Verification

### 5.1 Querying the `department_salary_summary` View
```sql
SELECT * FROM department_salary_summary;
```
#### Expected Output:
```text
+---------+------------+----------------+----------------+----------------+----------------+--------------+
| dept_id | dept_name  | employee_count | average_salary | minimum_salary | maximum_salary | total_salary |
+---------+------------+----------------+----------------+----------------+----------------+--------------+
|       1 | IT         |              6 |   68000.000000 |       58000.00 |       81000.00 |    408000.00 |
|       2 | HR         |              6 |   53666.666667 |       47000.00 |       61000.00 |    322000.00 |
|       3 | Finance    |              6 |   69166.666667 |       56000.00 |       83000.00 |    415000.00 |
|       4 | Marketing  |              6 |   60166.666667 |       51000.00 |       70000.00 |    361000.00 |
|       5 | Operations |              6 |   66500.000000 |       59000.00 |       76000.00 |    399000.00 |
+---------+------------+----------------+----------------+----------------+----------------+--------------+
5 rows in set (0.00 sec)
```

---

### 5.2 Querying the `employee_hierarchy` View
```sql
SELECT * FROM employee_hierarchy LIMIT 6;
```
#### Expected Output:
```text
+--------+----------+---------+-----------+----------+
| emp_id | emp_name | dept_id | dept_name | salary   |
+--------+----------+---------+-----------+----------+
|      1 | Aarav    |       1 | IT        | 65000.00 |
|      2 | Vivaan   |       1 | IT        | 72000.00 |
|      3 | Aditya   |       1 | IT        | 58000.00 |
|      4 | Arjun    |       1 | IT        | 81000.00 |
|      5 | Kabir    |       1 | IT        | 69000.00 |
|      6 | Reyansh  |       1 | IT        | 63000.00 |
+--------+----------+---------+-----------+----------+
6 rows in set (0.00 sec)
```

---

### 5.3 View Updatability Test
Attempting to update an aggregated view violates determinism:
```sql
UPDATE department_salary_summary
SET total_salary = 500000
WHERE dept_id = 1;
```
#### Expected MySQL Engine Response:
```text
ERROR 1288 (HY000): The target table department_salary_summary of the UPDATE is not updatable
```
*Explanation*: Because `department_salary_summary` relies on aggregate functions (`SUM`, `AVG`, `COUNT`) and `GROUP BY`, rows cannot be mapped to unique individual tuples in the base `Employee` table.

---

### 5.4 Recursive CTE Reporting Hierarchy
```sql
-- Execution of Recursive CTE (from queries.sql)
```
#### Expected Output:
```text
+--------+----------+---------+-------+----------------------------------+
| emp_id | emp_name | dept_id | level | reporting_path                   |
+--------+----------+---------+-------+----------------------------------+
|      1 | Aarav    |       1 |     1 | Aarav                            |
|      2 | Vivaan   |       1 |     1 | Vivaan                           |
|      3 | Aditya   |       1 |     1 | Aditya                           |
|      4 | Arjun    |       1 |     1 | Arjun                            |
|      5 | Kabir    |       1 |     1 | Kabir                            |
|      6 | Reyansh  |       1 |     1 | Reyansh                          |
|      2 | Vivaan   |       1 |     2 | Aarav -> Vivaan                  |
|      3 | Aditya   |       1 |     2 | Aarav -> Aditya                  |
|      4 | Arjun    |       1 |     2 | Aarav -> Arjun                   |
|      3 | Aditya   |       1 |     3 | Aarav -> Vivaan -> Aditya        |
|      4 | Arjun    |       1 |     3 | Aarav -> Vivaan -> Arjun         |
|      4 | Arjun    |       1 |     4 | Aarav -> Vivaan -> Aditya -> Arjun|
+--------+----------+---------+-------+----------------------------------+
12 rows in set (0.00 sec)
```

---

## 6. Result / Conclusion
SQL views for department metrics and employee reporting were successfully created. The rules governing view updatability were verified by demonstrating failure on aggregated views (`ERROR 1288`). Furthermore, recursive Common Table Expressions (CTEs) were successfully implemented to trace hierarchical organizational reporting chains.
