

------------------------------------------------------------ DATE EXPLORATION -------------------------------------------------------------

---- Find the Youngest and Oldest Customer
SELECT 
	MIN(birthdate) AS Oldest_birthdate,
	MAX(birthdate) AS Youngest_birthdate 
FROM [gold.customers]

--- Find the date of the first and last order
SELECT 
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order
FROM [gold.fact_sales]

-- How many years of sales are avaliable
SELECT 
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(YEAR, MIN(order_date),MAX(order_date)) AS order_range_years
FROM [gold.fact_sales]

-- Determine the exact date
SELECT 
	MIN(birthdate) AS Oldest_age,
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS Oldest_age,
	MAX(birthdate) AS Youngest_age,
	DATEDIFF(YEAR, MAX(birthdate), GETDATE ()) AS Youngest_age
FROM [gold.customers]