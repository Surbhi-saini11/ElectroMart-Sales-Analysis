/*=========================================================================================================
>> Creating silver layer (the raw data is cleaned and stored in the silver layer from bronze layer)
silver schema tables 
-> 1. silver.customers_cleaned
-> 2. silver.order_items_cleaned
-> 3. silver.orders_cleaned
-> 4. silver.payments_cleaned
-> 5. silver.products_cleaned
-> 6. silver.returns_cleaned

>> This script is also used for  initial exploration to detect data inconsistencies , missing data and
data in wrong format
============================================================================================================*/

SELECT *
FROM bronze.customers; -- data is in right format

SELECT *
FROM bronze.order_items --checking if there is negative sales values (unitprice and sales contain negative data)
WHERE sales < 0;

--checking for duplicate records in the order_items table
with order_items_cte as(
SELECT orderid,
       productid,
	   orderdate,
	   unitprice,
	   quantity,
	   sales,
	   ROW_NUMBER() OVER(PARTITION BY orderid,productid) as duplicate_count
FROM bronze.order_items)
SELECT COUNT(*)
FROM order_items_cte
WHERE duplicate_count>1;
;--order_items table does contain some multiple records(but we have to investigate it further)

SELECT * 
FROM bronze.orders
where totalamount < 0; --order total contains some negative values

-- checking for date inconsistencies in the orders table

SELECT *
FROM bronze.orders
WHERE orderdate > shipdate; 
--there are some records where orderdate > shipdate i.e.(99/5000) ~ 1.98% of invalid shipdate out of all shipdate

--investing if the ordate and shipdate columns are swapped( by checking the difference in days)
with datediff as(
SELECT orderdate,shipdate, orderdate-shipdate as diff_ship_and_orderdate
FROM bronze.orders
WHERE orderdate > shipdate 
)
SELECT *
FROM datediff
WHERE diff_ship_and_orderdate > 7; --difference in shipdate and orderdate is small (which shows the dates are swapped)

SELECT *
FROM bronze.payments
WHERE amountpaid < 0; --amountpaid column contains negative value in payments table

SELECT * 
FROM bronze.products;--no data inconsistency till now

SELECT * 
FROM bronze.returns
WHERE refundamount < 0; -- invalid refundamount(amount is negative)

/*============================================================================================================
DESIGNING SILVER LAYER
==============================================================================================================*/

CREATE TABLE IF NOT EXISTS silver.customers_cleaned(
CustomerID	varchar(20),
CustomerName	text,
Email	varchar(50),
City	text,
State	text,
Pincode	numeric,
Segment	text,
AccountCreated date, 
dwh_create_date   timestamp DEFAULT now()
);

CREATE TABLE IF NOT EXISTS silver.orders_cleaned(
OrderID	varchar(20),
CustomerID	varchar(20),
OrderDate	date,
ShipDate	date,
ShipMode	text,
OrderPriority	text,
Region	text,
TotalAmount	numeric,
PaymentMethod text,
dwh_create_date   timestamp DEFAULT now()
);
ALTER TABLE silver.orders_cleaned
DROP COLUMN region;

CREATE TABLE IF NOT EXISTS silver.order_items_cleaned(
OrderID	varchar(20),
ProductID	varchar(20),
Quantity	numeric,
UnitPrice	numeric,
Discount	numeric,
Sales	numeric,
Profit	numeric,
OrderDate date,
dwh_create_date   timestamp DEFAULT now()
);

--Payments table
CREATE TABLE IF NOT EXISTS silver.payments_cleaned(
OrderID	varchar(20),
TransactionID	varchar(20),
PaymentMethod	text,
PaymentDate	date,
PaymentStatus	text,
AmountPaid numeric,
dwh_create_date   timestamp DEFAULT now()
);

--Products table

CREATE TABLE IF NOT EXISTS silver.products_cleaned(
ProductID	varchar(20),
Category	text,
SubCategory	text,
ProductName	text,
Manufacturer	text,
UnitCost	numeric,
UnitPrice	numeric,
LaunchYear numeric,
dwh_create_date   timestamp DEFAULT now()
);

--Return table
CREATE TABLE IF NOT EXISTS silver.returns_cleaned(
ReturnID	varchar(20),
OrderID	varchar(20),
ReturnDate	date,
ReturnReason	text,
RefundAmount numeric,
dwh_create_date   timestamp DEFAULT now()
);

