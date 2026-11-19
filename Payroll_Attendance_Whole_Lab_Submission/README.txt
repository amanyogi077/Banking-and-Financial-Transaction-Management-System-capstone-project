PAYROLL AND ATTENDANCE DBMS CAPSTONE

This folder is the whole-lab package for the capstone brief shown in the lab portal. It contains:
- report/Payroll_Attendance_Capstone_Report.pdf: project report with ER diagram, schema, normalization, SQL coverage, security, optimization, reports and validation plan.
- sql/PayrollCapstoneDB.sql: MySQL 8+ schema, synthetic records, constraints, indexes, views, stored procedure, joins, subquery, UNION, CTE, window function, transaction and commented DCL examples.
- frontend/index.html: payroll-specific browser demo with dashboard, employee directory, attendance, leave, payroll and reports.

RUN THE DATABASE
1. Open MySQL Workbench and connect to your local MySQL server.
2. Choose File > Open SQL Script and select sql/PayrollCapstoneDB.sql.
3. Execute the whole script with the lightning button.
4. Refresh Schemas. The script creates PayrollCapstoneDB and does not drop or replace your existing EmployeePayrollDB.
5. Expand PayrollCapstoneDB, then Tables and Views. The script includes synthetic sample data.

OPEN THE FRONT-END DEMO
Double-click frontend/index.html to open it in a browser. It uses sample data saved in the browser and is not live-connected to MySQL. Do not use it to process real employee or payroll information.

SUBMISSION
For the portal's Whole-lab file upload, upload the ZIP containing this folder. For the Capstone PDF-only upload box, upload the report PDF separately if the instructor asks for both submission methods. The GitHub field expects a repository URL; do not paste a local file path there.

TEAM
Aman: requirements and database design.
Govind: SQL implementation, queries and reporting/testing.
Kavyan: payroll front-end demo and user interface.
Fill in each member's roll number and institution/course on the report cover before final submission.

IMPORTANT IMPLEMENTATION STATUS
The SQL schema/report and payroll-specific UI are included as separate project parts. The front end does not yet connect to MySQL through a backend/API. The report describes this limitation accurately. The test matrix lists expected results; execute the cases and capture genuine screenshots before claiming them as completed tests.
