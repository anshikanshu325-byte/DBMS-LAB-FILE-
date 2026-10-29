-- ==============================================================================
-- EXPERIMENT 05: SQL Views, View Updatability & Recursive CTEs
-- Course Outcome: CO3
-- Environment: MySQL 8.0+ / MySQL Workbench
-- ==============================================================================

USE CompanyDB;

-- 1. Create Department Salary Summary View (Aggregated View - Non-Updatable)
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

-- Query the Department Salary Summary View
SELECT * FROM department_salary_summary;

-- 2. Create Employee Hierarchy View (Simple Join View)
CREATE OR REPLACE VIEW employee_hierarchy AS
SELECT
    e.emp_id,
    e.emp_name,
    e.dept_id,
    d.dept_name,
    e.salary
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id;

-- Query the Employee Hierarchy View
SELECT * FROM employee_hierarchy LIMIT 10;

-- 3. Test View Updatability
-- A. Attempting to update the aggregated view (Expected to FAIL)
-- UPDATE department_salary_summary SET total_salary = 500000 WHERE dept_id = 1;
-- MySQL Error 1288: The target table department_salary_summary of the UPDATE is not updatable

-- B. Updating through the base table / simple updatable view
UPDATE Employee
SET salary = salary + 1000
WHERE emp_id = 6;

-- Verification of updated salary
SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id = 6;

-- Verify that the underlying view dynamically reflects the change
SELECT dept_id, average_salary, total_salary
FROM department_salary_summary
WHERE dept_id = 1;

-- 4. Recursive Common Table Expression (CTE) - Multi-Level Reporting Chain
WITH RECURSIVE reporting_chain AS (
    -- Anchor Member: Root employees at level 1
    SELECT
        emp_id,
        emp_name,
        dept_id,
        1 AS level,
        CAST(emp_name AS CHAR(500)) AS reporting_path
    FROM Employee
    WHERE dept_id = 1

    UNION ALL

    -- Recursive Member: Traverse downstream reporting connections
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
LIMIT 15;
