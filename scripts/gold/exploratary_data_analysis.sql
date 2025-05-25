/* explore database*/
-- explore all objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- explore all columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

/*explore dimension*/
SELECT DISTINCT country FROM gold.dim_customers;
SELECT DISTINCT product_category, product_subcategory, product_name FROM gold.dim_products
ORDER BY 1,2,3;

/* Date Exploration */
SELECT 
MIN(order_date) FirstOrderDate,
Max(order_date) LastOrderDate,
DATEDIFF(year, MIN(order_date),Max(order_date)) As OrderRangeYears
FROM gold.fact_sales

SELECT 
MIN(birthday) AS oldest,
DATEDIFF(year,MIN(birthday),GETDATE()) AS OldestAge,
MAX(birthday) AS youngest
FROM gold.dim_customers

/*explore measures*/
SELECT 
SUM(sales_amount) AS total_sales
FROM gold.fact_sales

SELECT 
SUM(quantity) AS total_quantity
FROM gold.fact_sales

SELECT 
AVG(price) AS avg_price
FROM gold.fact_sales

SELECT 
COUNT(order_number) AS total_orders 
FROM gold.fact_sales

SELECT 
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales

SELECT 
COUNT(product_key) AS total_products
FROM gold.dim_products

SELECT 
COUNT(customer_key) AS total_customers
FROM gold.dim_customers

SELECT 
COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales

/* generate big picture report */
SELECT 'Total Sales' as measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales -- one order may contain multiple items
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_key) FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers', COUNT(customer_key) FROM gold.dim_customers
UNION ALL
SELECT 'Total Nr. Customers with an order', COUNT(DISTINCT customer_key) FROM gold.fact_sales


/* magnitude - compare measure values by categories */

SELECT country,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

SELECT gender,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

SELECT product_category,
COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY product_category
ORDER BY total_products DESC

SELECT product_category,
AVG(product_cost) AS ave_cost
FROM gold.dim_products
GROUP BY product_category
ORDER BY ave_cost DESC

SELECT -- total rev by product category
p.product_category,
SUM(f.sales_amount) AS total_rev
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_category
ORDER BY total_rev DESC

SELECT -- total rev by customer 
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_rev
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key, 
c.first_name,
c.last_name
ORDER BY total_rev DESC

-- what is the distribution of items sold across the countries

SELECT -- total rev by customer 
c.country,
SUM(f.quantity) AS total_items_sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY 
c.country
ORDER BY total_items_sold DESC

/* top N ranking analysis*/
SELECT TOP 5 -- top 5 total rev by product category
p.product_name,
SUM(f.sales_amount) AS total_rev
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_rev DESC

SELECT TOP 5 -- bottom 5 total rev by product category
p.product_name,
SUM(f.sales_amount) AS total_rev
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_rev 

-- top 5 total rev by product category - using window functions
SELECT * 
	FROM (
	SELECT  -- top 5 total rev by product category - using window functions
	p.product_name,
	SUM(f.sales_amount) AS total_rev,
	ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY p.product_name)t
WHERE rank_products <= 5
