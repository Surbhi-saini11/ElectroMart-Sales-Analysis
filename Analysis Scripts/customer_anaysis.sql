/*======================================================================
-->Customer Analysis
========================================================================*/
--Finding total customers
SELECT count(distinct customer_id)
FROM gold.dim_customers;

--Customer Analysis
SELECT o.customer_id,COUNT(o.order_id),sum(sales) as customer_spend
FROM gold.fact_orders o
LEFT JOIN gold.dim_customers c 
ON o.customer_id=c.customer_id
GROUP BY o.customer_id
ORDER BY 3 DESC
LIMIT 10;

--Repeated cutomer 
SELECT COUNT(distinct customer_id)
FROM(SELECT c.customer_id,o.order_id, row_number() over(partition by c.customer_id) as rk
FROM gold.fact_orders o
LEFT JOIN gold.dim_customers c
ON o.customer_id=c.customer_id)t
where rk>1;

--Customers by state
SELECT state,round((count(distinct customer_id)/sum(count(customer_id)) over())*100,2)
FROM gold.dim_customers
GROUP BY state;


--Customer count by year
SELECT EXTRACT(YEAR FROM order_date),EXTRACT(QUARTER FROM order_date),count(distinct c.customer_id)
FROM gold.fact_orders o
LEFT JOIN gold.dim_customers c 
on o.customer_id=c.customer_id
group by EXTRACT(YEAR FROM order_date),EXTRACT(QUARTER FROM order_date);

--Finding revenue concentration of top 10% customers
WITH customer_spent AS
(SELECT o.customer_id,sum(sales) as total_spent
FROM gold.fact_orders o 
LEFT JOIN gold.dim_customers c
ON o.customer_id=c.customer_id
GROUP BY o.customer_id),
ranked_customer AS(
SELECT *,NTILE(10) OVER(ORDER BY total_spent DESC) AS percentile_group
FROM customer_spent
)
SELECT SUM(CASE WHEN percentile_group=1 then total_spent END)*100.0/SUM(total_spent) AS revenue_share_percentage
FROM ranked_customer;
