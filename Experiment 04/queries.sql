-- ==============================================================================
-- EXPERIMENT 04: Joins, Correlated Subqueries, EXISTS, Set Operations & EXPLAIN
-- Course Outcome: CO3
-- Environment: MySQL 8.0+ / MySQL Workbench
-- ==============================================================================

USE CompanyDB;

-- 1. INNER JOIN: Match employees with their assigned department
SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    d.dept_name
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
ORDER BY e.emp_id;

-- 2. LEFT JOIN: List all departments and any associated employees
SELECT
    d.dept_id,
    d.dept_name,
    e.emp_name,
    e.salary
FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
ORDER BY d.dept_id, e.emp_id;

-- 3. SELF-JOIN: Pair distinct employees working within the exact same department
SELECT
    e1.emp_name AS employee_1,
    e2.emp_name AS employee_2,
    e1.dept_id,
    e1.salary AS salary_1,
    e2.salary AS salary_2
FROM Employee e1
INNER JOIN Employee e2 ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
ORDER BY e1.dept_id, e1.emp_id, e2.emp_id
LIMIT 10;

-- 4. 3-WAY JOIN: Combine Employee, Department, and Project entities
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name,
    e.salary
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
INNER JOIN Project p ON e.project_id = p.project_id
ORDER BY d.dept_name, e.emp_name;

-- 5. CORRELATED SUBQUERY: Identify employees earning more than their department's average
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

-- 6. EXISTS: Identify departments that employ at least one individual earning > 80,000
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

-- 7. NOT EXISTS: Identify projects that have no employees earning over 75,000
SELECT
    p.project_id,
    p.project_name,
    p.budget
FROM Project p
WHERE NOT EXISTS (
    SELECT 1
    FROM Employee e
    WHERE e.project_id = p.project_id
      AND e.salary > 75000
)
ORDER BY p.project_id;

-- 8. SIMULATED INTERSECT: Employees in Department 1 AND earning > 70,000
SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id IN (
    SELECT emp_id
    FROM Employee
    WHERE dept_id = 1
)
AND emp_id IN (
    SELECT emp_id
    FROM Employee
    WHERE salary > 70000
)
ORDER BY emp_id;

-- 9. SIMULATED EXCEPT: Employees in Department 1 EXCEPT those earning > 70,000
SELECT emp_id, emp_name, salary
FROM Employee
WHERE dept_id = 1
  AND emp_id NOT IN (
    SELECT emp_id
    FROM Employee
    WHERE salary > 70000
)
ORDER BY emp_id;

-- 10. EXPLAIN ANALYSIS: Compare execution strategies
-- Execution Plan for INNER JOIN
EXPLAIN
SELECT e.emp_name, d.dept_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id;

-- Execution Plan for Correlated Subquery
EXPLAIN
SELECT e.emp_name, e.salary
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);
