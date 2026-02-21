/*=========================================================================================================
>> Creating silver layer (the raw data is cleaned and stored in the silver layer from bronze layer)
silver schema tables 
-> 1. silver.customers_cleaned
-> 2. silver.orders_cleaned
-> 3. silver.products_cleaned
-> 4. silver.returns_cleaned

>> This script is also used for  initial exploration to detect data inconsistencies , missing data and
data in wrong format
============================================================================================================*/

/*=================================================================================================
--EXPLORING bronze.customers_raw FOR ANY DATA INCONSISTENCIES
===================================================================================================*/
SELECT * FROM bronze.customers_raw
WHERE STATE IS NULL OR name IS NULL OR city IS NULL; -- state and name columns contain null values

WITH duplicate_check AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_id,name,city,state) as rk
FROM bronze.customers_raw)
SELECT * FROM duplicate_check
where rk > 1
; -- customers_raw contain no duplicate records

--Check inconsistencies in names
SELECT DISTINCT city FROM bronze.customers_raw;-- cities name are inconsistent ( mumbai,Mumbai),(Bangalore,Bengaluru)

SELECT DISTINCT state FROM bronze.customers_raw;--state contains null value and 1 state name(karnataka, Karnataka) referencing to the same state

SELECT * FROM bronze.customers_raw
WHERE customer_id = '';-- checking for empty string value

/*=================================================================================================
--EXPLORING bronze.products_raw FOR ANY DATA INCONSISTENCIES
===================================================================================================*/

SELECT * FROM bronze.products_raw;

SELECT COUNT(DISTINCT product_id) FROM bronze.products_raw; -- 64 products
SELECT COUNT(DISTINCT category) FROM bronze.products_raw; -- 10 categories

-- checking if product price does not contain any negative value
SELECT * FROM bronze.products_raw
WHERE price < 0; -- data contain no negative value

--checking for any null values
SELECT * FROM bronze.products_raw
WHERE product_id IS NULL OR product_name IS NULL OR category IS NULL OR price IS NULL;
-- price value is null for product_id "PROD01021"

--Checking case inconsistencies
SELECT DISTINCT category FROM bronze.products_raw; --smart phone , Smartphone same category but different name case

/*=================================================================================================
--EXPLORING bronze.orders_raw FOR ANY DATA INCONSISTENCIES
===================================================================================================*/

SELECT * FROM bronze.orders_raw;

SELECT order_id,order_date FROM bronze.orders_raw
WHERE EXTRACT(day FROM order_date)>28 and EXTRACT(MONTH FROM order_date)= 02; -- leap year check and date field as clean

--checking for null values 
SELECT * FROM bronze.orders_raw
WHERE order_date IS NULL OR 
      shipping_date IS NULL OR 
	  delivery_date IS NULL OR 
	  quantity IS NULL OR 
	  sales IS NULL OR
	  profit IS NULL OR
	  discount IS NULL OR
	  shipping_mode IS NULL OR
	  payment_mode IS NULL OR
	  customer_id IS NULL OR
	  product_id IS NULL OR
	  order_id IS NULL ;-- no null  values present

--checking date logical relation 
SELECT * FROM bronze.orders_raw 
WHERE order_date > delivery_date;--dates are okay

-- checking for negative quantities
SELECT * FROM bronze.orders_raw
WHERE discount < 0; -- no negative values present

--checking inconsistencies in dimension field
SELECT DISTINCT shipping_mode
FROM bronze.orders_raw;

SELECT DISTINCT payment_mode
FROM bronze.orders_raw;
--dimension data is clean

--checking for orphaned data

SELECT o.order_id,o.customer_id,c.customer_id
FROM bronze.orders_raw o 
RIGHT JOIN bronze.customers_raw c 
ON o.customer_id=c.customer_id; -- no orphaned records

SELECT o.order_id,o.product_id,p.product_id
FROM bronze.orders_raw o 
RIGHT JOIN bronze.products_raw p 
ON o.product_id=p.product_id
where p.product_id is null;-- no orphaned records

/*=================================================================================================
--EXPLORING bronze.return_raw FOR ANY DATA INCONSISTENCIES
===================================================================================================*/

SELECT * FROM bronze.return_raw;

SELECT DISTINCT reason FROM bronze.return_raw;

/*==================================================================================================
--> SILVER LAYER SCHEMA
====================================================================================================*/

--Creating silver.customers_cleaned table
CREATE TABLE IF NOT EXISTS silver.customers_cleaned(
customer_id varchar(20) PRIMARY KEY,
name varchar(25),
city varchar(25),
state varchar(25)
);

--Creating silver.products_cleaned table
CREATE TABLE IF NOT EXISTS silver.products_cleaned(
product_id varchar(20) PRIMARY KEY,
product_name text,
category text,
price numeric
);

--Creating silver.orders_cleaned table
CREATE TABLE IF NOT EXISTS silver.orders_cleaned(
order_id	varchar(20) ,
customer_id	varchar(20),
product_id	varchar(20),
order_date	date,
shipping_date	date,
delivery_date	date,
quantity	numeric,
sales	numeric,
profit	numeric,
discount	numeric,
shipping_mode	text,
payment_mode text,
FOREIGN KEY (customer_id)
REFERENCES silver.customers_cleaned(customer_id),
FOREIGN KEY (product_id)
REFERENCES silver.products_cleaned(product_id)
);

--Creating silver.return_cleaned table
CREATE TABLE IF NOT EXISTS silver.return_cleaned(
return_id	varchar(20) PRIMARY KEY,
order_id	varchar(20),
product_id	varchar(20),
reason  text,
FOREIGN KEY (product_id)
REFERENCES silver.products_cleaned(product_id)
);

ALTER TABLE silver.orders_cleaned
DROP CONSTRAINT orders_cleaned_pkey CASCADE;