/*==========================================================================================================
Creating schemas bronze, silver and gold
bronze -->> to store raw data
silver -->> cleaning and loading the raw to new cleaned tables
gold   -->> it includes the view (high-level analysis ready tables)
============================================================================================================*/
CREATE SCHEMA IF NOT EXISTS gold;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS bronze;

/*==========================================================================================================
Creating tables for bronze schema (raw data is stores here)
-> 1. customers
-> 2. orders
-> 3. order_items
-> 4. payments
-> 5. products
-> 6. returns
============================================================================================================*/
--Customers table
CREATE TABLE IF NOT EXISTS bronze.customers(
CustomerID	varchar(20),
CustomerName	text,
Email	varchar(50),
City	text,
State	text,
Pincode	numeric,
Segment	text,
AccountCreated date
);

--Orders table
CREATE TABLE IF NOT EXISTS bronze.orders(
OrderID	varchar(20),
CustomerID	varchar(20),
OrderDate	date,
ShipDate	date,
ShipMode	text,
OrderPriority	text,
Region	text,
TotalAmount	numeric,
PaymentMethod text
);

--Order items table

CREATE TABLE IF NOT EXISTS bronze.order_items(
OrderID	varchar(20),
ProductID	varchar(20),
Quantity	numeric,
UnitPrice	numeric,
Discount	numeric,
Sales	numeric,
Profit	numeric,
OrderDate date
);

--Payments table
CREATE TABLE IF NOT EXISTS bronze.payments(
OrderID	varchar(20),
TransactionID	varchar(20),
PaymentMethod	text,
PaymentDate	date,
PaymentStatus	text,
AmountPaid numeric
);

--Products table

CREATE TABLE IF NOT EXISTS bronze.products(
ProductID	varchar(20),
Category	text,
SubCategory	text,
ProductName	text,
Manufacturer	text,
UnitCost	numeric,
UnitPrice	numeric,
LaunchYear numeric
);

--Return table
CREATE TABLE IF NOT EXISTS bronze.returns(
ReturnID	varchar(20),
OrderID	varchar(20),
ReturnDate	date,
ReturnReason	text,
RefundAmount numeric
);