


/*
=======================================================================================================================================

														Product Report

=======================================================================================================================================
Purpose:
	- This report consolidates key product metrics and behaviors

Highlights:
	1. Gathers essentail fields such as product name, category, subcategory and cost.
	2. Segments products by revenue to identify High-Performaers, Mid-Range, or Low-Performers
	3. Aggregates product-level metrics:
		-total orders
		-total sales
		-total quantity sold
		-total customers (unique)
		-lifespan (in months)
	4. Calculate valuable KPIs:
		-recency (months since last sale)
		-average order value (AOR)
		-average monthly revenue

========================================================================================================================================
*/
CREATE VIEW report_products AS

WITH product_basic_query AS (
/* -----------------------------------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
--------------------------------------------------------------------------------------------------------------*/
SELECT 
	p.product_id,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost, 
	f.order_number,
	f.customer_key,
	f.quantity,
	f.sales_amount,
	f.order_date
FROM [gold.fact_sales] f
LEFT JOIN [gold.products] p
ON p.product_key=f.product_key
WHERE order_date IS NOT NULL
)

/* -----------------------------------------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
--------------------------------------------------------------------------------------------------------------*/
, product_aggregation AS (
SELECT 
	product_id,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_p,
	MAX(order_date) AS last_order_date,
	COUNT(DISTINCT order_number) AS total_orders_p,
	COUNT(DISTINCT customer_key) AS total_unique_customers,
	SUM(sales_amount) AS total_sales_p,
	RANK() OVER(ORDER BY SUM(sales_amount) DESC) AS sales_ranking,
	SUM(quantity) AS total_quantity_sold_p,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF (quantity, 0)),1) AS avg_selling_price
FROM product_basic_query 
GROUP BY
	product_id,
	product_name,
	category,
	subcategory,
	cost
)

SELECT 
	product_id,
	category,
	subcategory,
	product_name,
	total_sales_p,

CASE
	WHEN total_sales_p > 50000 THEN 'High-Performer'
	WHEN total_sales_p >= 10000 THEN 'Mid-Range'
	ELSE 'Low-Performers'
END AS Product_Segments,
	avg_selling_price,
	cost,
	total_orders_p,
	sales_ranking,
	total_quantity_sold_p,
	total_unique_customers,

/* -----------------------------------------------------------------------------------------------------------
3) Final Query: Calculate Valuable KPIs
--------------------------------------------------------------------------------------------------------------*/

last_order_date,
DATEDIFF(MONTH, last_order_date, GETDATE()) AS Recency,
lifespan_p,

--- Compute average product order value (AOV)
CASE WHEN total_sales_p = 0 THEN 0  --- Just to eliminate changes of generating error (Dividing by zero)
	ELSE total_sales_p / total_orders_p 
END AS Avg_Product_Order_Value,

---- Compute average monthly spend
CASE
	WHEN lifespan_p = 0 THEN total_sales_p
	ELSE total_sales_p/lifespan_p
END AS Avg_monthly_spend

 
FROM product_aggregation

SELECT * FROM report_products
