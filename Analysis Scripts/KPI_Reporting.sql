/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/
--Finding total sales made
SELECT '₹'  || round(SUM(sales)/10000000,0) || ' '||'Cr' as Revenue FROM gold.fact_orders;

--Finding total orders placed
SELECT COUNT(DISTINCT order_id) as Total_orders FROM gold.fact_orders;

--Finding total number of units sold
SELECT SUM(quantity) as Products_sold FROM gold.fact_orders;

--Finding total products
SELECT COUNT(DISTINCT product_id) as total_products FROM gold.dim_products;

--Finding customers who placed an order
SELECT COUNT(DISTINCT customer_id) as total_customer from gold.fact_orders;

--Finding total profit made
SELECT SUM(profit) as profit FROM gold.fact_orders;

--Finding total orders placed
SELECT COUNT(Distinct order_id) FROM gold.fact_orders;

--Generating a report that shows all the key metrics of the business
SELECT 'Revenue' as Measure_name,SUM(sales) as Measure_value FROM gold.fact_orders
UNION ALL
SELECT 'Total Profit', ROUND(SUM(profit)/10000000,2)  FROM gold.fact_orders
UNION ALL
SELECT 'Units sold' ,SUM(quantity) as Products_sold FROM gold.fact_orders
UNION ALL
SELECT 'Total Products',COUNT(DISTINCT product_id) as total_products FROM gold.dim_products
UNION ALL
SELECT 'Total Customers',COUNT(DISTINCT customer_id) as total_customer from gold.fact_orders
UNION ALL
SELECT 'Total Orders' ,COUNT(Distinct order_id) FROM gold.fact_orders;