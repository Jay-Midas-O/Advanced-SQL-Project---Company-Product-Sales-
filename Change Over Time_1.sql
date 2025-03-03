


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