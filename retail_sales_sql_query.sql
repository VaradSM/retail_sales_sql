--SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p2

--Create Table 
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
	(
		transactions_id INT PRIMARY KEY,
		sale_date DATE,
		sale_time TIME,
		customer_id INT,
		gender VARCHAR(15),
		age INT,
		category VARCHAR(15),
		quantiTy INT,
		price_per_unit FLOAT,
		cogs FLOAT,
		total_sale FLOAT
	);

SELECT * FROM retail_sales

SELECT COUNT(*) FROM retail_sales

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'retail_sales';

--Data Cleaning

SELECT * FROM retail_sales
WHERE age IS NULL;

SELECT * FROM retail_sales
WHERE category IS NULL;

SELECT * FROM retail_sales
WHERE quantity IS NULL;

SELECT * FROM retail_sales
WHERE price_per_unit IS NULL;

SELECT * FROM retail_sales
WHERE cogs IS NULL;

SELECT * FROM retail_sales
WHERE total_sale IS NULL;

SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL 
	OR
	category IS NULL 
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL

--
DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL 
	OR
	category IS NULL 
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL

--Data Exploration

--How many sales we have?
SELECT COUNT(*) AS total_sales FROM retail_sales

--How many distinct customers are there?
SELECT COUNT(DISTINCT customer_id) AS total_cusotmers FROM retail_sales

--How many distinct categories are there?
SELECT COUNT(DISTINCT category) AS total_category FROM retail_sales

SELECT DISTINCT category FROM retail_sales

--Data Analysis and Business Key Problems
--Write a SQL query to retrieve all columns for sales made on '2022-11-05:
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05'

--Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
SELECT * FROM retail_sales
WHERE
	category = 'Clothing'
	AND
	quantity >= 4
	AND
	sale_date BETWEEN '2022-11-01' AND '2022-11-30'

--Write a SQL query to calculate the total sales (total_sale) for each category
SELECT
	category,
	sum(total_sale) AS net_sale,
	count(*) AS total_orders
FROM retail_sales
GROUP BY category

--Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
SELECT 
	category,
	round(avg(age),2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty'

--Write a SQL query to find all transactions where the total_sale is greater than 1000
SELECT * FROM retail_sales
WHERE total_sale >= 1000

--Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category
SELECT
	category,
	COUNT(transactions_id) AS num_tran,
	gender
FROM retail_sales
GROUP BY category, gender
ORDER BY category

--Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT 
	year,
	month,
	avg_total_sale
FROM
(
	SELECT 
		EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month,
		AVG(total_sale) AS avg_total_sale,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
	FROM retail_sales
	GROUP BY year, month
	--ORDER BY year, avg_total_sale DESC
) AS t1
WHERE rank = 1

--**Write a SQL query to find the top 5 customers based on the highest total sales **
SELECT
	customer_id,
	sum(total_sale) AS sum_total_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY sum_total_sale DESC
LIMIT 5

--Write a SQL query to find the number of unique customers who purchased items from each category
SELECT
	category,
	COUNT(DISTINCT customer_id) AS dist_cust
FROM retail_sales
GROUP BY category
ORDER BY dist_cust

--Write a SQL query to find the number of unique customers who purchased items from all category
SELECT
	COUNT(DISTINCT customer_id) AS unique_cus
FROM (
	SELECT
		customer_id
	FROM retail_sales
	GROUP BY customer_id
	HAVING COUNT(DISTINCT category) = (SELECT COUNT(DISTINCT category) FROM retail_sales)
) AS t1

--Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
WITH hourly_sales
AS
(
	SELECT 
		*,
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
)
SELECT
	shift,
	COUNT(transactions_id) AS total_orders
FROM hourly_sales
GROUP BY shift 
ORDER BY
	CASE shift
		WHEN 'Morning' THEN 1
		WHEN 'Afternoon'THEN 2
		WHEN 'Evening' THEN 3
	END;
	