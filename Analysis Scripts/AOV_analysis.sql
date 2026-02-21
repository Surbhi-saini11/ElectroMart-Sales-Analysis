/*======================================================================
-->AOV Analysis
========================================================================*/
--Finding average order value(AOV)
SELECT ROUND(sum(sales)/count(distinct order_id),2) as AOV
FROM gold.fact_orders;

--Finding AOV by year
SELECT EXTRACT(YEAR FROM order_date),ROUND(sum(sales)/count(distinct order_id),2) as AOV
FROM gold.fact_orders
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY 1 ;

--Finding AOV by quarter
SELECT EXTRACT(YEAR FROM order_date),EXTRACT(QUARTER FROM order_date),
ROUND(sum(sales)/count(distinct order_id),2) as AOV
FROM gold.fact_orders
GROUP BY EXTRACT(YEAR FROM order_date),EXTRACT(QUARTER FROM order_date)
ORDER BY 1 ;

--Finding AOV by product category
SELECT p.category,sum(sales)/count(distinct order_id) as AOV
FROM gold.fact_orders o
LEFT JOIN gold.dim_products p
ON o.product_id=p.product_id
GROUP BY p.category
ORDER BY 2 DESC;

----Finding AOV by state
SELECT c.state,sum(sales)/count(distinct order_id) as AOV
FROM gold.fact_orders o
LEFT JOIN gold.dim_customers c
ON o.customer_id=c.customer_id
GROUP BY c.state
ORDER BY 2 DESC;

