/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/ 

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
CREATE VIEW gold.dim_customers AS 
SELECT customerid as customer_id,
       customername as customer_name,
	   city,
	   state,
	   segment, 
	   accountcreated as account_created
FROM silver.customers_cleaned;

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
CREATE VIEW gold.dim_products AS
SELECT productid as product_id,
       category,
	   subcategory,
	   productname as product_name,
	   unitcost as unit_cost,
	   unitprice as unit_price,
	   launchyear as launch_year
FROM silver.products_cleaned;

-- =============================================================================
-- Create Dimension: gold.dim_payments
-- =============================================================================

CREATE VIEW gold.dim_payments AS
SELECT orderid as order_id,
       transactionid as transaction_id,
	   paymentmethod as payment_method,
	   paymentdate as payment_date,
	   amountpaid as amount_paid
FROM silver.payments_cleaned;

-- =============================================================================
-- Create Dimension: gold.dim_returns
-- =============================================================================
CREATE VIEW gold.dim_returns AS
SELECT returnid as return_id,
       orderid as order_id,
	   returndate as return_date,
	   returnreason as return_reason,
	   refundamount as refund_amount
FROM silver.returns_cleaned;

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================

CREATE VIEW gold.fact_sales AS
SELECT o.orderid AS order_id,
       o.customerid as customer_id,
	   i.productid as product_id,
	   o.orderdate as order_date,
	   o.shipdate as ship_date,
	   o.shipmode as ship_mode,
       o.orderpriority as order_priority,
	   i.quantity ,
	   i.unitprice as unit_price,
	   i.discount,
	   i.sales,
	   i.profit
FROM silver.orders_cleaned o
LEFT JOIN silver.order_items_cleaned i
ON o.orderid=i.orderid;
