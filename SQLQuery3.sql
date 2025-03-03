CREATE FUNCTION add_five(@num AS INT)
RETURNS INT
BEGIN
RETURN (
@num+5
)END;

SELECT dbo.add_five(123) AS Scaler_Function;
 USE Company;
SELECT * FROM Employee

--CREATING A TABLE VALUE FUNCTION

CREATE FUNCTION select_gender(@gender AS VARCHAR(20))
RETURNS TABLE
AS
RETURN (
SELECT * FROM Employee
WHERE e_gender = @gender
);

SELECT * FROM dbo.select_gender('F');

USE SHOP;


SELECT
CASE
WHEN 10>20 THEN '10 is greater than 20'
WHEN 10<20 THEN '10 is less than 20'
WHEN 10>=20 THEN '10 is greater than or equal to 20'
ELSE '10 is equalto 20'
END

USE Company

SELECT * FROM Employee

SELECT *, Condition=
CASE
WHEN e_salary>90000 THEN 'Above Minimum'
WHEN e_salary<90000 THEN 'Below Minimum, need a raise'
ELSE 'Equal Wage'
END
FROM Employee
GO

SELECT first_name, last_name, e_age, Condition=
CASE
WHEN e_age>=40 THEN 'Manage'
WHEN e_age<=39 THEN 'Principal Officer'
WHEN e_age<30 THEN 'Officer'
ELSE 'Intern'
END
FROM Employee
GO

SELECT e_id AS ID,first_name AS First_Namne,last_name AS Last_Name,e_age AS Age,
IIF (e_age>=40, 'Old Staff','Young Staff') AS Employee_Generation
FROM Employee

CREATE PROCEDURE employee_age
AS
SELECT e_age FROM Employee
GO
DROP PROCEDURE employee_age

EXEC employee_age

CREATE PROCEDURE employee_gender @gender VARCHAR(20)
AS 
SELECT * FROM Employee
WHERE e_gender=@gender
GO

EXEC employee_gender @gender='F'

BEGIN TRY
SELECT e_salary+first_name FROM Employee
END TRY
BEGIN CATCH
PRINT 'Cannot add a numerical value to a string value'
END CATCH
GO

PRINT 'Cannot add a numerical value to a string value'

SELECT * FROM Employee;

BEGIN TRANSACTION
UPDATE Employee
SET e_age=35
WHERE first_name='John';

ROLLBACK TRANSACTION