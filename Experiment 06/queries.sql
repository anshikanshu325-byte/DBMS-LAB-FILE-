-- ==============================================================================
-- EXPERIMENT 06: Stored Procedures, Validation Triggers & Audit Logging
-- Course Outcome: CO3
-- Environment: MySQL 8.0+ / MySQL Workbench
-- ==============================================================================

USE CompanyDB;

-- 1. Create Employee Salary Audit Table
DROP TABLE IF EXISTS Employee_Salary_Audit;
CREATE TABLE Employee_Salary_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(50) NOT NULL
);

-- 2. Create Salary Validation Triggers (Salary must be between ₹30,000 and ₹1,50,000)
DROP TRIGGER IF EXISTS validate_employee_salary_insert;
DELIMITER //
CREATE TRIGGER validate_employee_salary_insert
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary < 30000.00 OR NEW.salary > 150000.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Salary must be between 30000 and 150000';
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS validate_employee_salary_update;
DELIMITER //
CREATE TRIGGER validate_employee_salary_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary < 30000.00 OR NEW.salary > 150000.00 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Validation Error: Salary must be between 30000 and 150000';
    END IF;
END//
DELIMITER ;

-- 3. Create Audit Logging Trigger
DROP TRIGGER IF EXISTS audit_salary_update;
DELIMITER //
CREATE TRIGGER audit_salary_update
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO Employee_Salary_Audit (emp_id, old_salary, new_salary, action)
        VALUES (NEW.emp_id, OLD.salary, NEW.salary, 'SALARY UPDATE');
    END IF;
END//
DELIMITER ;

-- 4. Test Salary Triggers
-- A. Attempting invalid salary update (Expected to FAIL)
-- UPDATE Employee SET salary = 20000 WHERE emp_id = 6;
-- Error 1644: Validation Error: Salary must be between 30000 and 150000

-- B. Valid salary update
UPDATE Employee SET salary = 85000.00 WHERE emp_id = 6;

-- C. Another valid update to test audit logging
UPDATE Employee SET salary = 52000.00 WHERE emp_id = 8;

-- D. Inspect Audit Log
SELECT audit_id, emp_id, old_salary, new_salary, changed_at, action
FROM Employee_Salary_Audit
ORDER BY audit_id;

-- 5. Create Stored Procedure for Department Transfer
DROP PROCEDURE IF EXISTS transfer_employee;
DELIMITER //
CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_emp_count INT DEFAULT 0;
    DECLARE v_dept_count INT DEFAULT 0;
    DECLARE v_old_dept_id INT;

    -- Error handler to roll back on any SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Validate employee existence
    SELECT COUNT(*), dept_id INTO v_emp_count, v_old_dept_id
    FROM Employee
    WHERE emp_id = p_emp_id
    GROUP BY dept_id;

    IF v_emp_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer Error: Specified Employee ID does not exist';
    END IF;

    -- Validate target department existence
    SELECT COUNT(*) INTO v_dept_count
    FROM Department
    WHERE dept_id = p_new_dept_id;

    IF v_dept_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer Error: Target Department ID does not exist';
    END IF;

    -- Validate whether employee is already in that department
    IF v_old_dept_id = p_new_dept_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer Notice: Employee is already in the specified department';
    END IF;

    -- Execute Department Transfer
    UPDATE Employee
    SET dept_id = p_new_dept_id
    WHERE emp_id = p_emp_id;

    COMMIT;
    SELECT CONCAT('Successfully transferred Employee ', p_emp_id, ' to Department ', p_new_dept_id) AS Status_Message;
END//
DELIMITER ;

-- 6. Test Stored Procedure Cases
-- Case A: Valid transfer of Employee 1 to Department 2 (HR)
CALL transfer_employee(1, 2);

-- Verification:
SELECT emp_id, emp_name, dept_id FROM Employee WHERE emp_id = 1;

-- Case B: Invalid transfer with non-existent employee ID 999 (Expected to FAIL)
-- CALL transfer_employee(999, 2);

-- Case C: Invalid transfer to non-existent department ID 99 (Expected to FAIL)
-- CALL transfer_employee(2, 99);
