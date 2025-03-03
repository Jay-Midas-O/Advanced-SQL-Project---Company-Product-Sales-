

--------------------------------------------------------- MEASURE EXLPORATION --------------------------------------------------------------------
-- Find the Total Sales
SELECT 
	SUM (sales_amount) AS Total_Sales
FROM [gold.fact_sales]

-- Show how many items are sold
SELECT 
	SUM (quantity) AS Items_Sold
FROM [gold.fact_sales]

-- Find the Average Selling Price
SELECT 
	AVG(price) AS Average_Selling_Price
FROM [gold.fact_sales]

-- Find the Total numbers of Orders
SELECT 
	COUNT(order_number) AS Total_Orders,
	COUNT(DISTINCT order_number) AS Total_Distinct_Orders
FROM [gold.fact_sales]

-- Find the Total numbers of Products
SELECT
	COUNT(product_number) AS Total_Products
FROM [gold.products]

-- Find the Total numbers of Customers
SELECT
	COUNT(customer_id) AS Total_Customers
FROM [gold.customers]

-- Find the Total number of Customers that has place an order
SELECT
	COUNT(DISTINCT customer_key) AS Total_Customers
FROM [gold.fact_sales]

-- Generate a Report that shows all key metrucs of the business

SELECT 'Total Sales' AS Measure_Name, SUM (sales_amount) AS Measure_Value FROM [gold.fact_sales]
UNION ALL
SELECT 'Total Quantity' AS Measure_Name, SUM (quantity) FROM [gold.fact_sales]
UNION ALL
SELECT 'Average Price' AS Measure_Name, AVG(price) FROM [gold.fact_sales]
UNION ALL
SELECT 'Total No. Orders' AS Measure_Name, COUNT (DISTINCT order_number) FROM [gold.fact_sales]
UNION ALL
SELECT 'Total No. Products' AS Measure_Name, COUNT (product_name) FROM [gold.products]
UNION ALL
SELECT 'Total No. Customers' AS Measure_Name, COUNT (customer_key) FROM [gold.fact_sales]