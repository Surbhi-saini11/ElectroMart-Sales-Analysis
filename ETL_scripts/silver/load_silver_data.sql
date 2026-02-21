/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$

BEGIN
  RAISE NOTICE 'Truncate silver.customers_cleaned table';
  TRUNCATE TABLE silver.customers_cleaned CASCADE;
  
  INSERT INTO silver.customers_cleaned(
  customer_id,name,city,state)
  SELECT trim(customer_id),
         nullif(trim(name),''),
         trim(case city when 'mumbai' then 'Mumbai' 
	     when 'Bangalore' then 'Bengaluru' else city end ) as city,
         nullif(trim(case state when 'karnataka' then 'Karnataka' else state end),'') as state
  FROM bronze.customers_raw;
  
  RAISE NOTICE 'Truncate silver.products_cleaned table';
  TRUNCATE TABLE silver.products_cleaned CASCADE;
  
  INSERT INTO silver.products_cleaned(
  product_id,product_name,category,price)
  SELECT trim(product_id),
         nullif(trim(product_name),''),
		 trim(case category when 'smart phones' then 'Smartphones' else category end ) as category,
		 nullif(price::text,'')::numeric
  FROM bronze.products_raw;
  
  INSERT INTO silver.orders_cleaned(
  order_id,customer_id,product_id,order_date,shipping_date,delivery_date,quantity,sales,profit,discount,shipping_mode,payment_mode)
  SELECT  order_id,
          customer_id,
		  product_id,
		  order_date,
		  shipping_date,
		  delivery_date,
		  nullif(quantity::text,'')::numeric,
		  nullif(sales::text,'')::numeric,
		  nullif(profit::text,'')::numeric,
		  nullif(discount::text,'')::numeric,
		  trim(shipping_mode),
		  trim(payment_mode)
   FROM bronze.orders_raw;
   
   INSERT INTO silver.return_cleaned(
   return_id,order_id,product_id,reason)
   SELECT return_id,order_id,product_id, trim(reason)
   FROM bronze.return_raw;
  
END;
$$;
call silver.load_silver();

UPDATE silver.customers_cleaned
SET state=(CASE WHEN city='Vadodara' then 'Gujarat'
		        WHEN city='Kolkata' then 'West Bengal' else state end);--updating silver.customers_cleaned by replacing null value