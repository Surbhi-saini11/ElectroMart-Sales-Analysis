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
  RAISE NOTICE 'Truncate silver.customers_cleaned';
  TRUNCATE TABLE silver.customers_cleaned;

  INSERT INTO silver.customers_cleaned(
  CustomerID,
  CustomerName,
  Email,
  City,
  State,
  Pincode,
  Segment,
  AccountCreated)
  SELECT TRIM(CustomerID),
  TRIM(CustomerName),
  TRIM(Email),
  Phone,
  TRIM(Address),
  TRIM(coalesce(city,split_part(address,',',2))),
  TRIM(State),
  Pincode,
  NULLIF(Segment,''),
  AccountCreated
  FROM bronze.customers;

 RAISE NOTICE 'Truncate silver.order_items_cleaned';
 TRUNCATE TABLE silver.order_items_cleaned;
 
 INSERT INTO silver.order_items_cleaned(
	 orderid,productid,quantity,unitprice,discount,sales, profit, orderdate
 )
 SELECT 
trim(orderid),
trim(productid),
nullif(quantity::text,'')::numeric as quantity,
nullif(abs(unitprice)::text,'')::numeric as unitprice,
nullif(discount::text,'')::numeric as discount,
nullif(abs(sales)::text,'')::numeric as sales,
nullif(profit::text,'') :: numeric as price,
orderdate
FROM bronze.order_items;

RAISE NOTICE 'Truncate silver.orders_cleaned';
TRUNCATE TABLE silver.orders_cleaned;


INSERT INTO silver.orders_cleaned(
orderid,customerid,orderdate,shipdate,shipmode,orderpriority,totalamount,paymentmethod
)SELECT orderid,
       customerid,
	   nullif(orderdate::text,'')::date,
       nullif(shipdate::text,'')::date,
	   nullif(trim(shipmode),''),
	   nullif(trim(orderpriority),''),
	   abs(totalamount),
	   nullif(trim(paymentmethod),'')
FROM bronze.orders;

RAISE NOTICE 'shipdate and orderdate record updated by swapping dates where shipdate is less than orderdate';

UPDATE silver.orders_cleaned
SET orderdate=shipdate,
    shipdate=orderdate
WHERE shipdate < orderdate;

RAISE NOTICE 'Updating silver.orders_cleaned column orderdate where the values are null using ship date';

UPDATE silver.orders_cleaned
SET orderdate= shipdate - INTERVAL '6 days'
WHERE orderdate is null;

RAISE NOTICE 'Truncate silver.payments_cleaned';

TRUNCATE silver.payments_cleaned;

INSERT INTO silver.payments_cleaned(
orderid,transactionid,paymentmethod,paymentdate,paymentstatus,amountpaid
)
SELECT orderid,
       transactionid,
	   nullif(trim(paymentmethod),''),
	   nullif(paymentdate::text,'')::date,
	   nullif(trim(paymentstatus),''),
	   nullif(abs(amountpaid)::text,'')::numeric
FROM bronze.payments;

RAISE NOTICE 'Truncate silver.products_cleaned';
TRUNCATE silver.products_cleaned;
INSERT INTO silver.products_cleaned(
productid,category,subcategory,productname,manufacturer,unitcost,unitprice,launchyear
)
SELECT productid,
       nullif(trim(category),''),
	   nullif(trim(subcategory),''),
	   nullif(trim(productname),''),
	   nullif(trim(manufacturer),''),
	   nullif(unitcost::text,'')::numeric,
	   nullif(unitprice::text,'')::numeric,
	   nullif(launchyear::text,'')::numeric
FROM bronze.products;

RAISE NOTICE 'Truncate silver.returns_cleaned';
TRUNCATE silver.returns_cleaned;

INSERT INTO silver.returns_cleaned(
returnid,orderid,returndate,returnreason,refundamount
)
SELECT trim(returnid),
       trim(orderid),
	   nullif(returndate::text,'')::date,
	   nullif(trim(returnreason),''),
	   nullif(abs(refundamount)::text,'')::numeric
FROM bronze.returns;
END;
$$;
call silver.load_silver()