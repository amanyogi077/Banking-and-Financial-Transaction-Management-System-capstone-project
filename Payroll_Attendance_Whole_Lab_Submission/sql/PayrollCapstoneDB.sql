-- Payroll and Attendance Management System
-- MySQL 8.0+ | Synthetic classroom data only
-- Creates an isolated schema; it does not drop EmployeePayrollDB.

CREATE DATABASE IF NOT EXISTS PayrollCapstoneDB
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE PayrollCapstoneDB;

CREATE TABLE IF NOT EXISTS Employee (
  employee_id INT PRIMARY KEY AUTO_INCREMENT,
  employee_code VARCHAR(16) NOT NULL UNIQUE,
  first_name VARCHAR(60) NOT NULL,
  last_name VARCHAR(60) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  department VARCHAR(60) NOT NULL,
  designation VARCHAR(60) NOT NULL,
  hire_date DATE NOT NULL,
  employment_status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE IF NOT EXISTS Salary (
  salary_id INT PRIMARY KEY AUTO_INCREMENT,
  employee_id INT NOT NULL,
  basic_salary DECIMAL(12,2) NOT NULL,
  hra DECIMAL(12,2) NOT NULL DEFAULT 0,
  allowance DECIMAL(12,2) NOT NULL DEFAULT 0,
  standard_deduction DECIMAL(12,2) NOT NULL DEFAULT 0,
  effective_from DATE NOT NULL,
  effective_to DATE NULL,
  CONSTRAINT fk_salary_employee FOREIGN KEY(employee_id) REFERENCES Employee(employee_id),
  CONSTRAINT uq_salary_employee_date UNIQUE(employee_id,effective_from),
  CONSTRAINT chk_salary_amounts CHECK(basic_salary>=0 AND hra>=0 AND allowance>=0 AND standard_deduction>=0),
  CONSTRAINT chk_salary_dates CHECK(effective_to IS NULL OR effective_to>=effective_from)
);

CREATE TABLE IF NOT EXISTS Attendance (
  attendance_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  employee_id INT NOT NULL,
  attendance_date DATE NOT NULL,
  attendance_status ENUM('PRESENT','ABSENT','HALF_DAY','HOLIDAY') NOT NULL,
  check_in TIME NULL,
  check_out TIME NULL,
  hours_worked DECIMAL(5,2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_attendance_employee FOREIGN KEY(employee_id) REFERENCES Employee(employee_id),
  CONSTRAINT uq_att_employee_day UNIQUE(employee_id,attendance_date),
  CONSTRAINT chk_att_hours CHECK(hours_worked>=0 AND hours_worked<=24),
  INDEX idx_att_employee_date(employee_id,attendance_date),
  INDEX idx_att_date_status(attendance_date,attendance_status)
);

CREATE TABLE IF NOT EXISTS LeaveRecords (
  leave_id INT PRIMARY KEY AUTO_INCREMENT,
  employee_id INT NOT NULL,
  leave_type ENUM('ANNUAL','SICK','PERSONAL','UNPAID') NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  leave_status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  requested_on DATE NOT NULL,
  reviewed_by VARCHAR(100) NULL,
  CONSTRAINT fk_leave_employee FOREIGN KEY(employee_id) REFERENCES Employee(employee_id),
  CONSTRAINT chk_leave_dates CHECK(end_date>=start_date),
  INDEX idx_leave_employee_start(employee_id,start_date),
  INDEX idx_leave_status(leave_status)
);

CREATE TABLE IF NOT EXISTS Payroll (
  payroll_id BIGINT PRIMARY KEY AUTO_INCREMENT,
  employee_id INT NOT NULL,
  payroll_month DATE NOT NULL,
  paid_days DECIMAL(5,2) NOT NULL,
  gross_pay DECIMAL(12,2) NOT NULL,
  total_deductions DECIMAL(12,2) NOT NULL,
  net_pay DECIMAL(12,2) NOT NULL,
  generated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payroll_employee FOREIGN KEY(employee_id) REFERENCES Employee(employee_id),
  CONSTRAINT uq_payroll_employee_month UNIQUE(employee_id,payroll_month),
  CONSTRAINT chk_payroll_values CHECK(paid_days>=0 AND gross_pay>=0 AND total_deductions>=0 AND net_pay>=0),
  CONSTRAINT chk_payroll_net CHECK(net_pay=gross_pay-total_deductions),
  INDEX idx_payroll_month_employee(payroll_month,employee_id)
);

INSERT IGNORE INTO Employee(employee_id,employee_code,first_name,last_name,email,department,designation,hire_date,employment_status) VALUES
(1,'IT-1001','Aarav','Mehta','aarav.mehta@example.test','Engineering','Software Engineer','2023-04-10','ACTIVE'),
(2,'IT-1002','Sara','Khan','sara.khan@example.test','Quality Assurance','QA Analyst','2024-01-15','ACTIVE'),
(3,'IT-1003','Rohan','Das','rohan.das@example.test','Engineering','Senior Developer','2022-09-01','ACTIVE');

INSERT IGNORE INTO Salary(salary_id,employee_id,basic_salary,hra,allowance,standard_deduction,effective_from,effective_to) VALUES
(1,1,70000.00,21000.00,5000.00,5000.00,'2025-04-01',NULL),
(2,2,55000.00,16500.00,3500.00,4000.00,'2025-04-01',NULL),
(3,3,80000.00,24000.00,6000.00,8000.00,'2025-04-01',NULL);

INSERT IGNORE INTO Attendance(attendance_id,employee_id,attendance_date,attendance_status,check_in,check_out,hours_worked) VALUES
(1,1,'2026-10-01','PRESENT','09:05:00','17:35:00',8.50),
(2,1,'2026-10-02','PRESENT','09:00:00','17:30:00',8.50),
(3,1,'2026-10-03','ABSENT',NULL,NULL,0),
(4,2,'2026-10-01','PRESENT','09:15:00','17:15:00',8.00),
(5,2,'2026-10-02','HALF_DAY','09:00:00','13:00:00',4.00),
(6,2,'2026-10-03','PRESENT','09:10:00','17:25:00',8.25),
(7,3,'2026-10-01','PRESENT','08:55:00','17:45:00',8.83),
(8,3,'2026-10-02','PRESENT','09:00:00','17:40:00',8.67),
(9,3,'2026-10-03','PRESENT','09:10:00','17:30:00',8.33);

INSERT IGNORE INTO LeaveRecords(leave_id,employee_id,leave_type,start_date,end_date,leave_status,requested_on,reviewed_by) VALUES
(1,2,'ANNUAL','2026-10-12','2026-10-13','APPROVED','2026-10-01','HR Manager'),
(2,3,'SICK','2026-10-20','2026-10-20','PENDING','2026-10-19',NULL);

INSERT IGNORE INTO Payroll(payroll_id,employee_id,payroll_month,paid_days,gross_pay,total_deductions,net_pay) VALUES
(1,1,'2026-10-01',22,96000.00,5000.00,91000.00),
(2,2,'2026-10-01',21,75000.00,4000.00,71000.00),
(3,3,'2026-10-01',22,110000.00,8000.00,102000.00);

CREATE OR REPLACE VIEW v_attendance_summary AS
SELECT e.employee_id,e.employee_code,CONCAT(e.first_name,' ',e.last_name) AS employee_name,
       DATE_FORMAT(a.attendance_date,'%Y-%m') AS attendance_month,
       COUNT(*) AS recorded_days,
       SUM(a.attendance_status='PRESENT') AS present_days,
       SUM(a.attendance_status='ABSENT') AS absent_days,
       SUM(a.attendance_status='HALF_DAY') AS half_days,
       SUM(a.hours_worked) AS total_hours
FROM Employee e JOIN Attendance a ON a.employee_id=e.employee_id
GROUP BY e.employee_id,e.employee_code,e.first_name,e.last_name,DATE_FORMAT(a.attendance_date,'%Y-%m');

CREATE OR REPLACE VIEW v_monthly_payroll_summary AS
SELECT e.department,p.payroll_month,COUNT(*) AS employees_paid,
       SUM(p.gross_pay) AS gross_total,SUM(p.total_deductions) AS deductions_total,
       SUM(p.net_pay) AS net_total
FROM Payroll p JOIN Employee e ON e.employee_id=p.employee_id
GROUP BY e.department,p.payroll_month;

-- Stored procedure example: one controlled way to record an attendance day.
DROP PROCEDURE IF EXISTS sp_mark_attendance;
DELIMITER //
CREATE PROCEDURE sp_mark_attendance(
  IN p_employee_id INT, IN p_date DATE, IN p_status VARCHAR(20),
  IN p_check_in TIME, IN p_check_out TIME, IN p_hours DECIMAL(5,2)
)
BEGIN
  IF p_hours<0 OR p_hours>24 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Hours must be between 0 and 24';
  END IF;
  INSERT INTO Attendance(employee_id,attendance_date,attendance_status,check_in,check_out,hours_worked)
  VALUES(p_employee_id,p_date,p_status,p_check_in,p_check_out,p_hours);
END//
DELIMITER ;

-- Monthly attendance analysis using a date range and joins.
SELECT e.employee_code,CONCAT(e.first_name,' ',e.last_name) AS employee_name,
       COUNT(CASE WHEN a.attendance_status='PRESENT' THEN 1 END) AS present_days,
       COUNT(CASE WHEN a.attendance_status='ABSENT' THEN 1 END) AS absent_days,
       SUM(a.hours_worked) AS total_hours
FROM Employee e LEFT JOIN Attendance a ON a.employee_id=e.employee_id
  AND a.attendance_date>='2026-10-01' AND a.attendance_date<'2026-11-01'
WHERE e.employment_status='ACTIVE'
GROUP BY e.employee_id,e.employee_code,e.first_name,e.last_name
ORDER BY e.employee_code;

-- CTE and window function: rank net payroll within each department/month.
WITH department_pay AS (
  SELECT e.department,p.payroll_month,e.employee_id,e.employee_code,p.net_pay
  FROM Payroll p JOIN Employee e ON e.employee_id=p.employee_id
)
SELECT department,payroll_month,employee_code,net_pay,
       DENSE_RANK() OVER(PARTITION BY department,payroll_month ORDER BY net_pay DESC) AS salary_rank
FROM department_pay ORDER BY department,payroll_month,salary_rank;

-- Subquery: active employees who have at least one absent day in October.
SELECT e.employee_code,e.first_name,e.last_name
FROM Employee e
WHERE e.employment_status='ACTIVE'
  AND EXISTS(SELECT 1 FROM Attendance a WHERE a.employee_id=e.employee_id
             AND a.attendance_status='ABSENT'
             AND a.attendance_date>='2026-10-01' AND a.attendance_date<'2026-11-01');

-- Set operation: combine absences and half-days into one exception report.
SELECT employee_id,attendance_date,'ABSENT' AS exception_type FROM Attendance WHERE attendance_status='ABSENT'
UNION
SELECT employee_id,attendance_date,'HALF_DAY' AS exception_type FROM Attendance WHERE attendance_status='HALF_DAY';

-- Run report views.
SELECT * FROM v_attendance_summary ORDER BY attendance_month,employee_code;
SELECT * FROM v_monthly_payroll_summary ORDER BY payroll_month,department;

-- TCL example: approval change can be committed or rolled back as a unit.
START TRANSACTION;
UPDATE LeaveRecords SET leave_status='APPROVED',reviewed_by='HR Manager' WHERE leave_id=2;
ROLLBACK; -- demo rollback restores the original PENDING state

START TRANSACTION;
UPDATE LeaveRecords SET reviewed_by='HR Manager' WHERE leave_id=1;
COMMIT; -- demo commit saves the reviewed_by value

-- DCL examples are commented because they require database-admin privileges.
-- CREATE ROLE 'hr_report_reader';
-- GRANT SELECT ON PayrollCapstoneDB.v_attendance_summary TO 'hr_report_reader';
-- GRANT SELECT ON PayrollCapstoneDB.v_monthly_payroll_summary TO 'hr_report_reader';
