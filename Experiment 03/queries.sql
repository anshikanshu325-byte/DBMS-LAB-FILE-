-- ==============================================================================
-- EXPERIMENT 03: SQL Queries - Selection, Projection, Aggregation, 
--               GROUP BY, HAVING, CASE & JOINs
-- Course Outcome: CO3
-- Environment: MySQL 8.0+ / MySQL Workbench
-- ==============================================================================

-- 1. Database Creation
DROP DATABASE IF EXISTS CompanyDB;
CREATE DATABASE CompanyDB;
USE CompanyDB;

-- 2. Department Table
CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

-- 3. Project Table
CREATE TABLE Project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

-- 4. Employee Table
CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    hire_date DATE NOT NULL,
    dept_id INT,
    project_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id),
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

-- 5. Insert 5 Departments
INSERT INTO Department VALUES
(1, 'IT'),
(2, 'HR'),
(3, 'Finance'),
(4, 'Marketing'),
(5, 'Operations');

-- 6. Insert 8 Projects
INSERT INTO Project VALUES
(101, 'Cloud Migration', 150000.00, 1),
(102, 'AI Analytics', 200000.00, 1),
(103, 'Recruitment Portal', 80000.00, 2),
(104, 'Financial Dashboard', 120000.00, 3),
(105, 'Digital Campaign', 90000.00, 4),
(106, 'Supply Chain System', 180000.00, 5),
(107, 'Mobile Application', 140000.00, 1),
(108, 'Employee Wellness', 60000.00, 2);

-- 7. Insert 30 Employees
INSERT INTO Employee VALUES
(1, 'Aarav', 65000.00, '2022-01-10', 1, 101),
(2, 'Vivaan', 72000.00, '2021-03-15', 1, 102),
(3, 'Aditya', 58000.00, '2023-06-20', 1, 107),
(4, 'Arjun', 81000.00, '2020-08-12', 1, 101),
(5, 'Kabir', 69000.00, '2022-11-05', 1, 102),
(6, 'Reyansh', 62000.00, '2024-02-18', 1, 107),
(7, 'Ananya', 52000.00, '2022-04-11', 2, 103),
(8, 'Diya', 48000.00, '2023-01-22', 2, 108),
(9, 'Myra', 61000.00, '2021-07-19', 2, 103),
(10, 'Sara', 55000.00, '2022-09-30', 2, 108),
(11, 'Ishita', 47000.00, '2024-03-14', 2, 103),
(12, 'Meera', 59000.00, '2020-12-01', 2, 108),
(13, 'Rohan', 75000.00, '2021-02-17', 3, 104),
(14, 'Karan', 68000.00, '2022-05-09', 3, 104),
(15, 'Nikhil', 83000.00, '2019-10-21', 3, 104),
(16, 'Yash', 62000.00, '2023-08-13', 3, 104),
(17, 'Manav', 71000.00, '2021-11-28', 3, 104),
(18, 'Dev', 56000.00, '2024-01-09', 3, 104),
(19, 'Aanya', 54000.00, '2022-02-25', 4, 105),
(20, 'Kiara', 63000.00, '2021-06-16', 4, 105),
(21, 'Tanya', 57000.00, '2023-04-10', 4, 105),
(22, 'Riya', 66000.00, '2020-09-07', 4, 105),
(23, 'Avni', 51000.00, '2024-02-05', 4, 105),
(24, 'Navya', 70000.00, '2022-12-19', 4, 105),
(25, 'Samar', 60000.00, '2021-01-12', 5, 106),
(26, 'Dhruv', 73000.00, '2020-04-23', 5, 106),
(27, 'Atharv', 67000.00, '2022-07-18', 5, 106),
(28, 'Parth', 59000.00, '2023-05-29', 5, 106),
(29, 'Rudra', 76000.00, '2019-08-31', 5, 106),
(30, 'Veer', 64000.00, '2024-01-20', 5, 106);

-- ==============================================================================
-- SQL Demonstration Queries
-- ==============================================================================

-- 1. Selection: Display employees whose salary is greater than 70,000
SELECT emp_id, emp_name, salary, hire_date, dept_id, project_id
FROM Employee
WHERE salary > 70000
ORDER BY salary DESC;

-- 2. Projection: Display only employee names and salaries
SELECT emp_name, salary
FROM Employee
ORDER BY emp_name ASC;

-- 3. Aggregate Functions: Overall Employee Salary Metrics
SELECT
    COUNT(*) AS total_employees,
    AVG(salary) AS average_salary,
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary,
    SUM(salary) AS total_salary
FROM Employee;

-- 4. GROUP BY: Department-wise Salary Aggregation
SELECT
    dept_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    SUM(salary) AS total_payroll
FROM Employee
GROUP BY dept_id
ORDER BY dept_id;

-- 5. HAVING: Departments where Average Salary exceeds 65,000
SELECT
    dept_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM Employee
GROUP BY dept_id
HAVING AVG(salary) > 65000
ORDER BY average_salary DESC;

-- 6. CASE Expression: Classify Employees into Compensation Brackets
SELECT
    emp_name,
    salary,
    CASE
        WHEN salary >= 75000 THEN 'Tier 1 - Senior Compensation'
        WHEN salary >= 60000 THEN 'Tier 2 - Mid Compensation'
        ELSE 'Tier 3 - Associate Compensation'
    END AS compensation_tier
FROM Employee
ORDER BY salary DESC;

-- 7. ORDER BY: Sort Employees by Department and Salary
SELECT emp_name, dept_id, salary
FROM Employee
ORDER BY dept_id ASC, salary DESC;

-- 8. Multi-Table JOIN: Combine Employee, Department, and Project
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name,
    e.salary
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
INNER JOIN Project p ON e.project_id = p.project_id
ORDER BY d.dept_name, e.salary DESC;
