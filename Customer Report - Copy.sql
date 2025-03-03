


/*
=======================================================================================================================================

														Customer Report

=======================================================================================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors

Highlights:
	1. Gathers essentail fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		-total orders
		-total sales
		-total quantity purchased
		-total products
		-lifespan (in months)
	4. Calculate valuable KPIs:
		-recency (months since last order)
		-average order value
		-average monthly spend

========================================================================================================================================
*/

CREATE VIEW report_customers AS
WITH basic_query AS (
/* -----------------------------------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
--------------------------------------------------------------------------------------------------------------*/
SELECT
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) AS Customer_name,
	DATEDIFF(YEAR, c.birthdate, GETDATE()) AS Age
FROM [gold.fact_sales] f
LEFT JOIN [gold.customers] c
ON c.customer_key=f.customer_key
WHERE order_date IS NOT NULL)


, customer_aggregation AS (
/* -----------------------------------------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
--------------------------------------------------------------------------------------------------------------*/
SELECT 
	customer_key,
	customer_number,
	Customer_name,
	Age,
	COUNT (DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM basic_query 
GROUP BY
	customer_key,
	customer_number,
	Customer_name,
	Age)


SELECT 
	customer_key,
	customer_number,
	Customer_name,
	Age,
CASE 
	WHEN Age< 20 THEN 'Under 20'
	WHEN Age BETWEEN 20 AND 29 THEN '20-29'
	WHEN Age BETWEEN 30 AND 39 THEN '30-39'
	WHEN Age BETWEEN 40 AND 49 THEN '40-49'
	ELSE '50 and Above'
END AS Age_group,

CASE
	WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	WHEN lifespan >=12 AND total_sales <= 5000 THEN 'Regular'
	ELSE 'New'
END AS Customer_Segment,
	last_order_date,
DATEDIFF(MONTH, last_order_date, GETDATE()) AS Recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
--- Compute average order value (AOV)
CASE WHEN total_sales = 0 THEN 0  --- Just to eliminate changes of generating error (Dividing by zero)
	ELSE total_sales / total_orders 
END AS Avg_Order_Value,
---- Compute average monthly spend
CASE
	WHEN lifespan=0 THEN total_sales
	ELSE total_sales/lifespan
END AS Avg_monthly_spend
FROM customer_aggregation
