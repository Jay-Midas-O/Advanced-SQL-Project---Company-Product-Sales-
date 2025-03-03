
---------------------------------------------------- ADVANCED DATA ANALYSIS IN SQL ------------------------------------------------------------------

----------------------------------------------------- CHANGE-OVER-TIME (TRENDS) ---------------------------------------------
USE DataWarehouseAnalytics
--- Sales Perormance Over Time (Daily) ------------
SELECT 
	order_date,
	SUM(sales_amount) Total_Sales
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date

--- Sales Perormance Over Time (Yearly) ------------
SELECT
	YEAR(order_date),
	SUM(sales_amount) TotalSales,
	COUNT(DISTINCT customer_key) AS Total_Customers
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY TotalSales DESC

---------------------------------------------- CUMULATIVE ANALYSIS ----------------------------------------------------------------
----- Calculate the total sale per month
 SELECT
	 MONTH(order_date) Order_Months,
	 SUM(sales_amount) Total_Sales
 FROM [gold.fact_sales]
 WHERE order_date IS NOT NULL
 GROUP BY MONTH(order_date)
 ORDER BY MONTH(order_date)

----- Running total of sales over time & Running Average
SELECT 
	Order_Day,
	Total_sales,
	SUM(Total_sales) OVER(PARTITION BY Order_Day ORDER BY Order_Day) AS running_total_sales,
	AVG(Avg_Price) OVER(PARTITION BY Order_Day ORDER BY Order_Day) AS moving_average_sales
FROM 
(
	SELECT
		order_date AS Order_Day,
		SUM(sales_amount) AS Total_Sales, 
		AVG(price) AS Avg_Price
	FROM [gold.fact_sales]
	WHERE order_date IS NOT NULL
	GROUP BY 
	order_date
)t

--------------------------------------------------- PERFORMANCE ANALYSIS -------------------------------------------------------

------ Analyze the yearly performance of products by comparing each Products's Sales 
------ to both its Average Sales Performance and the Previous Years Sales

SELECT 
	YEAR(f.order_date) AS Order_Year,
	p.product_name,
	SUM(f.sales_amount) AS Current_Sales
FROM [gold.fact_sales] f
LEFT JOIN [gold.products] p
ON p.product_key=f.product_key
WHERE f.order_date IS NOT NULL
GROUP BY 
YEAR(f.order_date),
p.product_name


------ USING CTE---------
WITH yearly_product_sales AS (
SELECT 
	YEAR(f.order_date) AS Order_Year,
	p.product_name AS Product_Name,
	SUM(f.sales_amount) AS Current_Sales
FROM [gold.fact_sales] f
LEFT JOIN [gold.products] p
ON p.product_key=f.product_key
WHERE f.order_date IS NOT NULL
GROUP BY 
YEAR(f.order_date),
p.product_name
)
SELECT 
	Order_Year,
	Product_Name,
	Current_Sales,
	AVG(Current_Sales) OVER(PARTITION BY Product_Name) AS Avg_Sales,
	Current_Sales - AVG(Current_Sales) OVER(PARTITION BY Product_Name) AS Difference_Sales,
CASE 
	 WHEN Current_Sales - AVG(Current_Sales) OVER(PARTITION BY Product_Name) > 0 THEN 'Above Average'
	 WHEN Current_Sales - AVG(Current_Sales) OVER(PARTITION BY Product_Name) < 0 THEN 'Below Average'
	 ELSE 'Average'
END AS Average_change_CA,
-- Year-over-year Analysis
LAG(Current_Sales) OVER(PARTITION BY Product_Name ORDER BY Order_Year) AS Previous_Year,
Current_Sales - LAG(Current_Sales) OVER(PARTITION BY Product_Name ORDER BY Order_Year) AS Difference_Previous,
CASE
	WHEN Current_Sales - LAG(Current_Sales) OVER(PARTITION BY Product_Name ORDER BY Order_Year) > 0 THEN 'Increase'
	WHEN Current_Sales - LAG(Current_Sales) OVER(PARTITION BY Product_Name ORDER BY Order_Year) < 0 THEN 'Decrease'
	ELSE 'No Change'
END AS Average_change_CP
FROM yearly_product_sales
ORDER BY Product_Name, Order_Year

------ Analyze the yearly performance of customers by comparing with  Current orders made 
------ to both the Average and Previous Years orders made.

SELECT 
YEAR(f.order_date) AS Yearly_Orders,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS Current_Orders
FROM [gold.fact_sales] f
LEFT JOIN [gold.customers] c
ON c.customer_key=f.customer_key
GROUP BY 
YEAR(f.order_date),
c.first_name,
c.last_name
ORDER BY Current_Orders DESC



WITH yearly_orders AS(

SELECT 
YEAR(f.order_date) AS Yearly_Orders,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS Current_Orders
FROM [gold.fact_sales] f
LEFT JOIN [gold.customers] c
ON c.customer_key=f.customer_key
GROUP BY 
YEAR(f.order_date),
c.first_name,
c.last_name
)
SELECT 
first_name,
last_name,
Yearly_Orders,
Current_Orders,
AVG(Current_Orders) OVER(PARTITION BY first_name, last_name) AS Avg_Order,
Current_Orders - AVG(Current_Orders) OVER(PARTITION BY first_name, last_name) AS Order_Change_CA,
CASE 
	WHEN Current_Orders - AVG(Current_Orders) OVER(PARTITION BY first_name, last_name) > 0 THEN 'High Orders'
	WHEN Current_Orders - AVG(Current_Orders) OVER(PARTITION BY first_name, last_name) < 0 THEN 'Low Orders'
	ELSE 'Standard'
END AS Order_Criteria,
LAG (Current_Orders) OVER(PARTITION BY first_name,last_name ORDER BY Yearly_Orders) AS Previous_Orders,
Current_Orders - LAG (Current_Orders) OVER(PARTITION BY first_name,last_name ORDER BY Yearly_Orders) AS Diff_Previous_Orders,
CASE	
	WHEN Current_Orders - LAG (Current_Orders) OVER(PARTITION BY first_name,last_name ORDER BY Yearly_Orders) > 0 THEN 'Good'
	WHEN Current_Orders - LAG (Current_Orders) OVER(PARTITION BY first_name,last_name ORDER BY Yearly_Orders) < 0 THEN 'Bad'
	ELSE 'Okay'
END Previous_Orders_change
FROM yearly_orders
ORDER BY Yearly_Orders DESC, Current_Orders DESC


------------------------------------------- -----PROPORTIONAL ANALYSIS ---------------------------------------------------------------

-- Which categories contribute the most to overall sales

WITH category_sales AS (
SELECT 
	p.category AS Category,
	SUM(f.sales_amount) AS Total_Sales,
	RANK() OVER(ORDER BY SUM(f.sales_amount) DESC) AS Top_Performer
FROM [gold.fact_sales] f
LEFT JOIN [gold.products] p
ON p.product_key = f.product_key
GROUP BY p.category)

SELECT 
	Category,
	Total_Sales,
	Top_Performer,
	SUM(Total_Sales) OVER() AS Overall_Sales,
	CONCAT(ROUND(CAST(Total_Sales AS FLOAT) / SUM(Total_Sales) OVER() * 100,2), '%') AS Percentage_of_total
FROM category_sales


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
	Age
)


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


