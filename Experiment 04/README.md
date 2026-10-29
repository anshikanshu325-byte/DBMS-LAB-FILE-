# Experiment 04: Joins, Correlated Subqueries, EXISTS, Set Operations, and EXPLAIN

- **Course Outcome**: `CO3` (Execute complex multi-table joins, subqueries, set operations, and inspect execution plans)
- **Environment**: MySQL 8.0+ / MySQL Workbench

---

## 1. Aim
Using the Employee schema in `CompanyDB`, formulate and execute SQL queries utilizing **INNER JOIN**, **LEFT JOIN**, **Self-Join**, **3-Way Join**, **Correlated Subqueries**, **EXISTS / NOT EXISTS**, and **Simulated Set Operations (INTERSECT and EXCEPT)**. Inspect and compare query execution plans using **EXPLAIN**.

---

## 2. Theory

### 2.1 Join Mechanics
- **INNER JOIN**: Returns only matching records where the join predicate evaluates to true across participating relations.
- **LEFT (OUTER) JOIN**: Preserves all tuples from the left relation, pairing them with matching attributes from the right relation or populating with `NULL` where no match exists.
- **Self-Join**: A join operation in which a table is joined with itself using table aliases to compare rows within the same relation (e.g., matching peers in the same department).
- **3-Way Join**: Extends relational join logic sequentially across three distinct relations using pairwise foreign-to-primary key references.

### 2.2 Subqueries & Existence Tests
- **Uncorrelated Subquery**: Evaluates independently of the outer query once, returning a constant scalar or list.
- **Correlated Subquery**: References one or more columns from the outer query relation. The nested query is re-evaluated for each candidate row processed by the outer query.
- **`EXISTS` Operator**: Returns a boolean `TRUE` if the nested subquery returns at least one tuple. Because it terminates immediately upon encountering the first match (short-circuit evaluation), it is highly efficient.

### 2.3 Set Operations in MySQL
- Mathematical set operations include Union ($\cup$), Intersection ($\cap$), and Set Difference ($-$).
- While `UNION` is natively supported in MySQL, `INTERSECT` and `EXCEPT` are simulated in standard MySQL queries using `IN`, `EXISTS`, `NOT IN`, or `NOT EXISTS` subqueries.

### 2.4 Query Execution Plan Inspection with `EXPLAIN`
The `EXPLAIN` statement reveals the MySQL query optimizer's execution strategy:
- `select_type`: Distinguishes `SIMPLE`, `PRIMARY`, `SUBQUERY`, or `DEPENDENT SUBQUERY`.
- `type`: Access type indicating efficiency (`const` > `eq_ref` > `ref` > `range` > `index` > `ALL`).
- `possible_keys` & `key`: Candidate indexes vs. index chosen by optimizer.
- `rows`: Estimated number of rows the database engine must examine.
- `Extra`: Additional processing details such as `Using where`, `Using temporary`, or `Using filesort`.

---

## 3. Schema & Database Reference

The queries operate on the `CompanyDB` database established in Experiment 03.

```sql
USE CompanyDB;
```

| Relation | Primary Key | Foreign Keys | Key Attributes |
| :--- | :--- | :--- | :--- |
| **Department** | `dept_id` | *None* | `dept_name` |
| **Project** | `project_id` | `dept_id` &rarr; `Department(dept_id)` | `project_name`, `budget` |
| **Employee** | `emp_id` | `dept_id` &rarr; `Department`, `project_id` &rarr; `Project` | `emp_name`, `salary`, `hire_date` |

---

## 4. SQL Program & Expected Outputs

See the complete script in [`queries.sql`](queries.sql).

### 4.1 INNER JOIN: Match Employees to Department
```sql
SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    d.dept_name
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
ORDER BY e.emp_id
LIMIT 8;
```
#### Expected Output:
```text
+--------+----------+----------+-----------+
| emp_id | emp_name | salary   | dept_name |
+--------+----------+----------+-----------+
|      1 | Aarav    | 65000.00 | IT        |
|      2 | Vivaan   | 72000.00 | IT        |
|      3 | Aditya   | 58000.00 | IT        |
|      4 | Arjun    | 81000.00 | IT        |
|      5 | Kabir    | 69000.00 | IT        |
|      6 | Reyansh  | 62000.00 | IT        |
|      7 | Ananya   | 52000.00 | HR        |
|      8 | Diya     | 48000.00 | HR        |
+--------+----------+----------+-----------+
8 rows in set (0.00 sec)
```

---

### 4.2 LEFT JOIN: List Departments and Any Associated Employees
```sql
SELECT
    d.dept_id,
    d.dept_name,
    e.emp_name,
    e.salary
FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
ORDER BY d.dept_id, e.emp_id
LIMIT 8;
```
#### Expected Output:
```text
+---------+-----------+----------+----------+
| dept_id | dept_name | emp_name | salary   |
+---------+-----------+----------+----------+
|       1 | IT        | Aarav    | 65000.00 |
|       1 | IT        | Vivaan   | 72000.00 |
|       1 | IT        | Aditya   | 58000.00 |
|       1 | IT        | Arjun    | 81000.00 |
|       1 | IT        | Kabir    | 69000.00 |
|       1 | IT        | Reyansh  | 62000.00 |
|       2 | HR        | Ananya   | 52000.00 |
|       2 | HR        | Diya     | 48000.00 |
+---------+-----------+----------+----------+
8 rows in set (0.00 sec)
```

---

### 4.3 Self-Join: Compare Peer Employees in Same Department
```sql
SELECT
    e1.emp_name AS employee_1,
    e2.emp_name AS employee_2,
    e1.dept_id,
    e1.salary AS salary_1,
    e2.salary AS salary_2
FROM Employee e1
INNER JOIN Employee e2 ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
ORDER BY e1.dept_id, e1.emp_id, e2.emp_id
LIMIT 6;
```
#### Expected Output:
```text
+------------+------------+---------+----------+----------+
| employee_1 | employee_2 | dept_id | salary_1 | salary_2 |
+------------+------------+---------+----------+----------+
| Aarav      | Vivaan     |       1 | 65000.00 | 72000.00 |
| Aarav      | Aditya     |       1 | 65000.00 | 58000.00 |
| Aarav      | Arjun      |       1 | 65000.00 | 81000.00 |
| Aarav      | Kabir      |       1 | 65000.00 | 69000.00 |
| Aarav      | Reyansh    |       1 | 65000.00 | 62000.00 |
| Vivaan     | Aditya     |       1 | 72000.00 | 58000.00 |
+------------+------------+---------+----------+----------+
6 rows in set (0.00 sec)
```

---

### 4.4 3-Way Join: Combine Employee, Department, and Project
```sql
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name,
    e.salary
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
INNER JOIN Project p ON e.project_id = p.project_id
ORDER BY d.dept_name, e.emp_name
LIMIT 8;
```
#### Expected Output:
```text
+----------+-----------+---------------------+----------+
| emp_name | dept_name | project_name        | salary   |
+----------+-----------+---------------------+----------+
| Dev      | Finance   | Financial Dashboard | 56000.00 |
| Karan    | Finance   | Financial Dashboard | 68000.00 |
| Manav    | Finance   | Financial Dashboard | 71000.00 |
| Nikhil   | Finance   | Financial Dashboard | 83000.00 |
| Rohan    | Finance   | Financial Dashboard | 75000.00 |
| Yash     | Finance   | Financial Dashboard | 62000.00 |
| Ananya   | HR        | Recruitment Portal  | 52000.00 |
| Diya     | HR        | Employee Wellness   | 48000.00 |
+----------+-----------+---------------------+----------+
8 rows in set (0.00 sec)
```

---

### 4.5 Correlated Subquery: Earning Above Department Average
```sql
SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    e.dept_id
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
)
ORDER BY e.dept_id, e.salary DESC;
```
#### Expected Output:
```text
+--------+----------+----------+---------+
| emp_id | emp_name | salary   | dept_id |
+--------+----------+----------+---------+
|      4 | Arjun    | 81000.00 |       1 |
|      2 | Vivaan   | 72000.00 |       1 |
|      5 | Kabir    | 69000.00 |       1 |
|      9 | Myra     | 61000.00 |       2 |
|     12 | Meera    | 59000.00 |       2 |
|     10 | Sara     | 55000.00 |       2 |
|     15 | Nikhil   | 83000.00 |       3 |
|     13 | Rohan    | 75000.00 |       3 |
|     17 | Manav    | 71000.00 |       3 |
|     24 | Navya    | 70000.00 |       4 |
|     22 | Riya     | 66000.00 |       4 |
|     20 | Kiara    | 63000.00 |       4 |
|     29 | Rudra    | 76000.00 |       5 |
|     26 | Dhruv    | 73000.00 |       5 |
|     27 | Atharv   | 67000.00 |       5 |
+--------+----------+----------+---------+
15 rows in set (0.00 sec)
```

---

### 4.6 EXISTS: Departments with High Earners (> ₹80,000)
```sql
SELECT
    d.dept_id,
    d.dept_name
FROM Department d
WHERE EXISTS (
    SELECT 1
    FROM Employee e
    WHERE e.dept_id = d.dept_id
      AND e.salary > 80000
)
ORDER BY d.dept_id;
```
#### Expected Output:
```text
+---------+-----------+
| dept_id | dept_name |
+---------+-----------+
|       1 | IT        |
|       3 | Finance   |
+---------+-----------+
2 rows in set (0.00 sec)
```

---

### 4.7 Simulated INTERSECT: In Dept 1 AND Salary > ₹70,000
```sql
SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id IN (
    SELECT emp_id FROM Employee WHERE dept_id = 1
)
AND emp_id IN (
    SELECT emp_id FROM Employee WHERE salary > 70000
)
ORDER BY emp_id;
```
#### Expected Output:
```text
+--------+----------+----------+
| emp_id | emp_name | salary   |
+--------+----------+----------+
|      2 | Vivaan   | 72000.00 |
|      4 | Arjun    | 81000.00 |
+--------+----------+----------+
2 rows in set (0.00 sec)
```

---

### 4.8 Simulated EXCEPT: In Dept 1 EXCEPT Salary > ₹70,000
```sql
SELECT emp_id, emp_name, salary
FROM Employee
WHERE dept_id = 1
  AND emp_id NOT IN (
    SELECT emp_id FROM Employee WHERE salary > 70000
)
ORDER BY emp_id;
```
#### Expected Output:
```text
+--------+----------+----------+
| emp_id | emp_name | salary   |
+--------+----------+----------+
|      1 | Aarav    | 65000.00 |
|      3 | Aditya   | 58000.00 |
|      5 | Kabir    | 69000.00 |
|      6 | Reyansh  | 62000.00 |
+--------+----------+----------+
4 rows in set (0.00 sec)
```

---

### 4.9 EXPLAIN Analysis Comparison
```sql
EXPLAIN
SELECT e.emp_name, d.dept_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id;
```
#### Expected Execution Plan:
```text
+----+-------------+-------+------------+--------+---------------+---------+---------+--------------------+------+----------+-------+
| id | select_type | table | partitions | type   | possible_keys | key     | key_len | ref                | rows | filtered | Extra |
+----+-------------+-------+------------+--------+---------------+---------+---------+--------------------+------+----------+-------+
|  1 | SIMPLE      | e     | NULL       | ALL    | dept_id       | NULL    | NULL    | NULL               |   30 |   100.00 | NULL  |
|  1 | SIMPLE      | d     | NULL       | eq_ref | PRIMARY       | PRIMARY | 4       | CompanyDB.e.dept_id|    1 |   100.00 | NULL  |
+----+-------------+-------+------------+--------+---------------+---------+---------+--------------------+------+----------+-------+
```

---

## 5. Result / Conclusion
Complex multi-table operations (Inner Join, Left Join, Self-Join, 3-Way Join), correlated subqueries, `EXISTS`, and simulated `INTERSECT`/`EXCEPT` set logic were successfully formulated and executed. Query execution plans were analyzed using `EXPLAIN`, demonstrating index-based primary key lookups (`eq_ref`) and subquery dependency behaviors.
