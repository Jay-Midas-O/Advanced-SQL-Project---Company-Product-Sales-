

-------------------------------------------------------- RANKING --------------------------------------------------------------------------
-- Which 5 Products generate the Highest Revenue
SELECT TOP 5
	p. product_name Product_Name,
	p.product_number Product_Number,
SUM(f.sales_amount) AS Highest_Revenue
FROM [gold.fact_sales] f
LEFT JOIN [gold.products] p
ON p.product_key=f.product_key
GROUP BY
	p. product_name,
	p.product_number
ORDER BY Highest_Revenue DESC

SELECT TOP 5
	p. product_line Product_Line,
	SUM(f.sales_amount) AS Highest_Revenue
FROM [gold.fact_sales] f
LEFT JOIN [gold.products] p
ON p.product_key=f.product_key
GROUP BY
	p. product_line
ORDER BY Highest_Revenue DESC 

SELECT *
FROM (
	SELECT
	p.product_name Product_Name,
	SUM(f.sales_amount) AS Highest_Revenue,
	ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount)  DESC) AS rank_products
FROM [gold.fact_sales] f
LEFT JOIN [gold.products] p
ON p.product_key=f.product_key
GROUP BY
	p. product_name)t
WHERE rank_products <= 5

-- What are the 5 Worst-Performing Products in the terms sales
SELECT TOP 5
	p. product_name Product_Name,
	p.product_number Product_Number,
SUM(f.sales_amount) AS Highest_Revenue
FROM [gold.fact_sales] f
LEFT JOIN [gold.products] p
ON p.product_key=f.product_key
GROUP BY
	p. product_name,
	p.product_number
ORDER BY Highest_Revenue 

-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
	c.first_name First_Name,
	c.last_name Last_Name,
SUM(f.sales_amount) AS Highest_Revenue
FROM [gold.fact_sales] f
LEFT JOIN [gold.customers] c
ON c.customer_key=f.customer_key
GROUP BY
	c.first_name,
	c.last_name
ORDER BY Highest_Revenue DESC


SELECT *
 FROM (
	SELECT 
	c.first_name First_Name,
	c.last_name Last_Name,
	SUM(f.sales_amount) AS Highest_Revenue,
	ROW_NUMBER () OVER (ORDER BY SUM(f.sales_amount) DESC) rank_customers
	FROM [gold.fact_sales] f
	LEFT JOIN [gold.customers] c
	ON c.customer_key=f.customer_key
	GROUP BY
	c.first_name,
	c.last_name)t

WHERE rank_customers <=10

--The 3 Customers with fewest orders

SELECT TOP 3
	c.first_name First_Name,
	c.last_name Last_Name,
COUNT(quantity) AS Total_Orders
FROM [gold.fact_sales] f
LEFT JOIN [gold.customers] c
ON c.customer_key=f.customer_key
GROUP BY
	c.first_name,
	c.last_name
ORDER BY Total_Orders




----------------------------------------------------------- WITH WINDOWS FUNCTION ------------------------------------------------------

SELECT * 
FROM (
		SELECT
		c.first_name First_Name,
		c.last_name Last_Name,
		SUM(f.sales_amount) Total_Sales,
		ROW_NUMBER() OVER(ORDER BY SUM (f.sales_amount)) ranking_sales
		FROM [gold.fact_sales] f
		LEFT JOIN [gold.customers] c
		ON c.customer_key =f.customer_key
		GROUP BY 
		c.first_name,
		c.last_name
	)t
WHERE ranking_sales <= 3


SELECT TOP 3
	c.first_name First_Name,
	c.last_name Last_Name,
SUM(f.sales_amount) Total_Sales,
ROW_NUMBER() OVER(ORDER BY SUM (f.sales_amount)) ranking_sales
FROM [gold.fact_sales] f
LEFT JOIN [gold.customers] c
ON c.customer_key =f.customer_key
GROUP BY 
	c.first_name,
	c.last_name