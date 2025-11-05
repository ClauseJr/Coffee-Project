DROP TABLE IF EXISTS city_states;
DROP TABLE IF EXISTS products_sales;
DROP TABLE IF EXISTS coffee_customers;
DROP TABLE IF EXISTS coffee_sales;


CREATE TABLE city_states(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population BIGINT,
	estimated_rent FLOAT,	
	city_rank INT
);

CREATE TABLE coffee_customers(
	customer_id	INT PRIMARY KEY,
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city_states(city_id)
);

CREATE TABLE products_sales(
	product_id INT PRIMARY KEY,
	product_name VARCHAR(35),	
	price FLOAT
);

CREATE TABLE coffee_sales(
	sale_id	INT PRIMARY KEY,
	sale_date DATE,
	product_id INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products_sales(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES coffee_customers(customer_id)
);

SELECT * FROM coffee_customers;
SELECT * FROM products_sales;
SELECT * FROM coffee_sales;
SELECT * FROM city_states;

