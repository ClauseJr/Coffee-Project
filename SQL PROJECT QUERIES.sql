
-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?


SELECT 
	city_name,
	ROUND((population * 0.25)/1000000,2) Coffee_consumers_in_M,
	city_rank
FROM city_states
ORDER BY Coffee_consumers_in_M DESC;

-- Q.2 Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT 
	EXTRACT(YEAR FROM sale_date) yr,
	EXTRACT(QUARTER FROM sale_date) qtr,
	SUM(total) total_revenue
FROM coffee_sales
WHERE EXTRACT(YEAR FROM sale_date) = 2023 
	AND 
	EXTRACT(QUARTER FROM sale_date) = 4
GROUP BY yr, qtr;

-- Q.3 Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT 
	ps.product_id,
	COUNT(cs.sale_id) unit_sales
FROM products_sales ps
INNER JOIN coffee_sales cs
	ON ps.product_id = cs.product_id
GROUP BY ps.product_id
ORDER BY unit_sales DESC;

-- Q.4 Average Sales Amount per City
-- What is the average sales amount per customer in each city?

SELECT
	cit.city_name,
	SUM(cs.total) total_revenue,
	COUNT(DISTINCT cs.customer_id) num_customers,
	ROUND(SUM(cs.total)::numeric/COUNT(DISTINCT cs.customer_id)::numeric,2) avg_sales
FROM coffee_sales cs
LEFT JOIN coffee_customers cc
	ON cs.customer_id = cc.customer_id
LEFT JOIN city_states cit
	ON cc.city_id = cit.city_id
GROUP BY cit.city_name
ORDER BY total_revenue DESC, avg_sales DESC ;

-- Q.5 City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

SELECT
	COUNT(DISTINCT cc.customer_id) num_customers,
	cit.city_name,
	ROUND((cit.population * 0.25/1000000),2) Pop_in_Millions
FROM city_states cit
INNER JOIN coffee_customers cc
	ON cit.city_id = cc.city_id
GROUP BY cit.city_name, cit.population
ORDER BY Pop_in_Millions DESC;


-- Q6 Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT 
*
FROM(
	SELECT 
		cit.city_name,
		ps.product_name,
		COUNT(cs.sale_id) sales_orders,
		DENSE_RANK() OVER(PARTITION BY cit.city_name ORDER BY COUNT(cs.sale_id) DESC) city_rank
	FROM coffee_sales cs
	INNER JOIN products_sales ps
		ON cs.product_id = ps.product_id
	INNER JOIN coffee_customers cc
		ON cs.customer_id = cc.customer_id
	INNER JOIN city_states cit
		ON cc.city_id = cit.city_id
	GROUP BY cit.city_name, ps.product_name 
	-- ORDER BY sales_orders DESC, city_rank DESC
	)t
WHERE city_rank < 4 ;



-- Q.7 Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT
	cit.city_name,
	COUNT(DISTINCT cc.customer_id) num_customers
FROM coffee_customers cc
LEFT JOIN  city_states cit
	ON cc.city_id = cit.city_id
LEFT JOIN coffee_sales cs
	ON cc.customer_id = cs.customer_id
LEFT JOIN products_sales ps
	ON cs.product_id = ps.product_id
-- WHERE ps.product_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
GROUP BY cit.city_name
ORDER BY  num_customers DESC; 



-- Q.8 Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer


WITH CTE_AvgSales AS 
(
	SELECT
		cit.city_name,
		SUM(cs.total) total_revenue,
		COUNT(DISTINCT cs.customer_id) num_customers,
		ROUND(SUM(cs.total)::numeric/COUNT(DISTINCT cs.customer_id)::numeric,2) avg_sales
	FROM coffee_sales cs
	INNER JOIN coffee_customers cc
		ON cs.customer_id = cc.customer_id
	INNER JOIN city_states cit
		ON cc.city_id = cit.city_id
	GROUP BY cit.city_name
	ORDER BY total_revenue DESC
),
CTE_AvgRent AS 
(
	SELECT
		city_name,
		estimated_rent
	FROM city_states
)

SELECT 
	car.city_name,
	car.estimated_rent,
	cas.num_customers,
	cas.avg_sales,
	ROUND(car.estimated_rent::numeric/cas.num_customers::numeric,2) avg_rent_customer
FROM CTE_AvgSales cas
INNER JOIN CTE_AvgRent car
	ON cas.city_name = car.city_name
ORDER BY cas.avg_sales DESC;




-- Q.9 Monthly Sales Growth
-- Sales growth rate: 
-- Calculate the percentage growth (or decline) in sales over different time periods (monthly) by each city

WITH CTE_monthly_growth AS
(
	SELECT 
		cit.city_name,
		EXTRACT(MONTH FROM cs.sale_date) ex_month,
		EXTRACT(YEAR FROM cs.sale_date) ex_year,
		SUM(total) total_revenue
	FROM coffee_sales cs
	INNER JOIN coffee_customers cc
		ON cs.customer_id = cc.customer_id
	INNER JOIN city_states cit
		ON cc.city_id = cit.city_id
	GROUP BY 1, 2, 3
	ORDER BY 1,3,2 
),
CTE_growth_rate AS
(
	SELECT 
		city_name,
		ex_month,
		ex_year,
		total_revenue AS sale_revenue,
		LAG(total_revenue,1) OVER(PARTITION BY city_name ORDER BY ex_year, ex_month) diff_revenue_sales
	FROM CTE_monthly_growth
)
SELECT 
	city_name,
	ex_month,
	ex_year,
	sale_revenue,
	diff_revenue_sales,
	ROUND((sale_revenue - diff_revenue_sales)::numeric/diff_revenue_sales::numeric * 100,2) pec_sales_growth
FROM CTE_growth_rate
WHERE diff_revenue_sales IS NOT NULL


-- Q.10 Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

WITH CTE_AvgSales AS 
(
	SELECT
		cit.city_name,
		SUM(cs.total) total_revenue,
		COUNT(DISTINCT cs.customer_id) num_customers,
		ROUND(SUM(cs.total)::numeric/COUNT(DISTINCT cs.customer_id)::numeric,2) avg_sales
	FROM coffee_sales cs
	INNER JOIN coffee_customers cc
		ON cs.customer_id = cc.customer_id
	INNER JOIN city_states cit
		ON cc.city_id = cit.city_id
	GROUP BY cit.city_name
	ORDER BY total_revenue DES
),
CTE_AvgRent AS 
(
	SELECT
		city_name,
		estimated_rent,
		ROUND((population * 0.25)::numeric/1000000,2) pop_in_millions
	FROM city_states
)

SELECT 
	car.city_name,
	cas.total_revenue,
	car.estimated_rent,
	cas.num_customers,
	cas.avg_sales,
	car.pop_in_millions,
	ROUND(car.estimated_rent::numeric/cas.num_customers::numeric,2) avg_rent_customer
FROM CTE_AvgSales cas
INNER JOIN CTE_AvgRent car
	ON cas.city_name = car.city_name
ORDER BY cas.avg_sales DESC;



/*
RECOMMENDATIONS OF THE TOP 3 CITIES TO CONSIDER 

City 1.Pune
	a. Highest total revenue.
	b. Highest average sales with 52 customers.
	c. The average rent per customer in the city is low. 
City 2. Jaipur
	a. The average rent per customer in the city is low, 156.
	b. Highest number of customers, 69 was recorded.
	c. Average sale per customer is at leat high, 11.644k.
City 3.Delhi 
	a. The average rent per customer in the city is low, 330.
	b. Highest number of customers, 68 was recorded.
	c. high estimated consumers is to be recorded with a population of 7.7 million.


