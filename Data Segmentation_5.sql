

--------------------------------------------------- DATA SEGMENTATION ---------------------------------------------------------------
---- Segment products into cost ranges and count how many products fall into each segment

WITH product_segments AS(

SELECT 
	product_key,
	product_name,
	cost,
CASE
	WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'Above 1000'
END AS cost_range
FROM [gold.products])

SELECT
	cost_range,
	COUNT(product_key) AS Total_products
FROM product_segments
GROUP BY cost_range
ORDER BY Total_products DESC

/* Group customers into three segments based on their spending behavior:
- VIP: at least 12 months of history and spending more than $ 5,000.
- Regular: at least 12 months of history but spending $ 5,000 or less.
- New: lifespan less than 12 months. 
- Find the total number of customers by each group*/

WITH customer_spending AS (
SELECT
	c.customer_key,
	SUM(f.sales_amount) AS total_sales,
	MIN(f.order_date) AS first_order,
	MAX(f.order_date) AS last_order,
	DATEDIFF (month, MIN(order_date), MAX(order_date)) AS lifespan
FROM [gold.fact_sales] f
LEFT JOIN [gold.customers] c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key)

SELECT 
	Customer_Segment,
	COUNT(customer_key) AS total_customers
FROM (
		SELECT 
		customer_key,
		CASE
			WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			WHEN lifespan >=12 AND total_sales <= 5000 THEN 'Regular'
			ELSE 'New'
		END AS Customer_Segment
FROM customer_spending) t
GROUP BY Customer_Segment
ORDER BY total_customers DESC