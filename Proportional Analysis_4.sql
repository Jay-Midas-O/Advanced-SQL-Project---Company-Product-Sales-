

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
