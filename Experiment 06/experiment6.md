# Experiment 06: Stored Procedures, Validation Triggers, and Audit Logging

- **Course Outcome**: `CO3` (Develop stored procedures, transaction-safe business logic, and automated audit triggers)
- **Environment**: MySQL 8.0+ / MySQL Workbench

---

## 1. Aim
To develop a transaction-safe stored procedure `transfer_employee(emp_id, new_dept_id)` with rigorous input validation and error handling, implement `BEFORE` triggers for domain salary validation (enforcing bounds ₹30,000 to ₹1,50,000), and configure `AFTER UPDATE` triggers for automated audit logging into a dedicated audit table.

---

## 2. Theory

### 2.1 Stored Procedures in MySQL
A **Stored Procedure** is a precompiled collection of SQL statements and procedural control logic (conditions, loops, local variables, transaction blocks) stored directly in the database data dictionary.
- **Advantages**:
  - **Reduced Network Traffic**: Complex multistep transactions execute on the server in a single call.
  - **Enhanced Security**: Grants execution permissions (`EXECUTE`) without providing direct `UPDATE` privileges on underlying base tables.
  - **Encapsulated Business Logic**: Enforces consistency across heterogeneous client applications.
- **Transaction Safety**: Uses `START TRANSACTION`, `COMMIT`, and `ROLLBACK` along with condition handlers (`DECLARE EXIT HANDLER FOR SQLEXCEPTION`) to guarantee ACID atomicity during operational errors.

### 2.2 Database Triggers
A **Trigger** is a specialized procedural block executed automatically by the database engine in response to specific DML events (`INSERT`, `UPDATE`, `DELETE`) on a specified table.
- **Trigger Timing**:
  - `BEFORE`: Fires prior to data persistence, ideal for constraint validation, sanitization, and value transformation.
  - `AFTER`: Fires after successful mutation, ideal for audit logging, cascading side-effects, and summary updates.
- **Row-Level Pseudo-Records**:
  - `NEW`: Exposes column values being inserted or modified.
  - `OLD`: Exposes existing pre-modification column values.
- **Custom Error Signaling**: `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ...` throws a user-defined fatal exception, terminating execution and preventing unauthorized mutations.

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
-- 1. Create Audit Table
CREATE TABLE IF NOT EXISTS Employee_Salary_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(50) NOT NULL
);

-- 2. Validation Triggers
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

-- 3. Audit Trigger
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

-- 4. Stored Procedure for Transfer
DELIMITER //
CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_emp_count INT DEFAULT 0;
    DECLARE v_dept_count INT DEFAULT 0;
    DECLARE v_old_dept_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*), dept_id INTO v_emp_count, v_old_dept_id
    FROM Employee
    WHERE emp_id = p_emp_id
    GROUP BY dept_id;

    IF v_emp_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer Error: Specified Employee ID does not exist';
    END IF;

    SELECT COUNT(*) INTO v_dept_count
    FROM Department
    WHERE dept_id = p_new_dept_id;

    IF v_dept_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer Error: Target Department ID does not exist';
    END IF;

    IF v_old_dept_id = p_new_dept_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer Notice: Employee is already in the specified department';
    END IF;

    UPDATE Employee
    SET dept_id = p_new_dept_id
    WHERE emp_id = p_emp_id;

    COMMIT;
    SELECT CONCAT('Successfully transferred Employee ', p_emp_id, ' to Department ', p_new_dept_id) AS Status_Message;
END//
DELIMITER ;
```

---

## 5. Expected Outputs & Verification Scenarios

### 5.1 Salary Validation Failure (Trigger Rejection)
Attempting to assign a salary below ₹30,000:
```sql
UPDATE Employee SET salary = 20000.00 WHERE emp_id = 6;
```
#### Expected Engine Response:
```text
ERROR 1644 (45000): Validation Error: Salary must be between 30000 and 150000
```

---

### 5.2 Valid Salary Updates & Audit Logging
Execute valid compensation changes:
```sql
UPDATE Employee SET salary = 85000.00 WHERE emp_id = 6;
UPDATE Employee SET salary = 52000.00 WHERE emp_id = 8;

SELECT audit_id, emp_id, old_salary, new_salary, changed_at, action
FROM Employee_Salary_Audit
ORDER BY audit_id;
```
#### Expected Output:
```text
+----------+--------+------------+------------+---------------------+---------------+
| audit_id | emp_id | old_salary | new_salary | changed_at          | action        |
+----------+--------+------------+------------+---------------------+---------------+
|        1 |      6 |   63000.00 |   85000.00 | 2026-10-29 11:45:10 | SALARY UPDATE |
|        2 |      8 |   48000.00 |   52000.00 | 2026-10-29 11:45:12 | SALARY UPDATE |
+----------+--------+------------+------------+---------------------+---------------+
2 rows in set (0.00 sec)
```

---

### 5.3 Stored Procedure Execution Tests

#### Case A: Successful Employee Transfer
Transfer Employee `1` from Department `1` (IT) to Department `2` (HR):
```sql
CALL transfer_employee(1, 2);
```
#### Expected Output:
```text
+-------------------------------------------------------+
| Status_Message                                        |
+-------------------------------------------------------+
| Successfully transferred Employee 1 to Department 2   |
+-------------------------------------------------------+
1 row in set (0.01 sec)
```

#### Case B: Transfer with Non-Existent Employee
Attempt to transfer invalid `emp_id = 999`:
```sql
CALL transfer_employee(999, 2);
```
#### Expected Engine Response:
```text
ERROR 1644 (45000): Transfer Error: Specified Employee ID does not exist
```

#### Case C: Transfer to Non-Existent Department
Attempt to transfer Employee `2` to invalid `dept_id = 99`:
```sql
CALL transfer_employee(2, 99);
```
#### Expected Engine Response:
```text
ERROR 1644 (45000): Transfer Error: Target Department ID does not exist
```

---

## 6. Result / Conclusion
The `transfer_employee` stored procedure was successfully developed with transaction rollbacks and input validation. In addition, `BEFORE` and `AFTER` triggers were implemented to enforce domain bounds on salary data and maintain an immutable historical audit log.
