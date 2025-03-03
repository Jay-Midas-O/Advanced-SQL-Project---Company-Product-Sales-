
----------------------------------------------------------- CUMULATIVE ANALYSIS ----------------------------------------------------------------
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