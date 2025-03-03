

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
