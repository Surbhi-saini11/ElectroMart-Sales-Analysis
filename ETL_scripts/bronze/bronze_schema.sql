/*==========================================================================================================
Creating schemas bronze, silver and gold
bronze -->> to store raw data
silver -->> cleaning and loading the raw data into new cleaned tables
gold   -->> it includes the view (high-level analysis ready tables)
============================================================================================================*/
CREATE SCHEMA IF NOT EXISTS gold;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS bronze;

/*==========================================================================================================
Creating tables for bronze schema (raw data is stores here)
-> 1. customers
-> 2. orders
-> 3. products
-> 4. returns
============================================================================================================*/
--Customer Table
CREATE TABLE IF NOT EXISTS bronze.customers_raw(
customer_id varchar(20),
name varchar(25),
city varchar(25),
state varchar(25)
);

--Products Table
CREATE TABLE IF NOT EXISTS bronze.products_raw(
product_id varchar(20),
product_name text,
category text,
price numeric
);

--Orders Table
CREATE TABLE IF NOT EXISTS bronze.orders_raw(
order_id	varchar(20),
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
payment_mode text
);

--Return Table
CREATE TABLE IF NOT EXISTS bronze.return_raw(
return_id	varchar(20),
order_id	varchar(20),
product_id	varchar(20),
reason  text
);