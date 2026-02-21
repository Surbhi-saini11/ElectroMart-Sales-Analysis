/*=====================================================================
-->Product Analysis
Business Questions :
      1. which product drives the highest sales and profit?
	  2. which category is the most profitable and which is the least?
	  3. Identify products that are not ordered frequently?
=======================================================================*/
--Finding the count of unique products
SELECT count(distinct product_id)
FROM gold.dim_products;

--Most Expensive Product
SELECT product_id,product_name, price
FROM gold.dim_products
ORDER BY price desc;

--
SELECT product_id,sales,profit,discount
FROM gold.fact_orders
where product_id = 'PROD01021' and quantity=1

--Finding the products
SELECT DISTINCT product_name, category,price FROM gold.dim_products
ORDER BY category,product_name ;

--Top 10 Products by Sales 

SELECT p.product_name,ROUND(SUM(o.sales)/10000000,2) || ' Cr.' AS total_sales
FROM gold.fact_orders o
LEFT JOIN gold.dim_products p 
ON o.product_id=p.product_id
GROUP BY p.product_name
ORDER BY 2 desc
LIMIT 10;

--Highest sales,profit & profit margin by category

SELECT p.category,count(quantity),ROUND(SUM(o.sales)/10000000,2) || ' Cr.' AS total_sales,ROUND(SUM(o.profit)/10000000,2) || ' Cr.' AS profit,
ROUND((SUM(o.profit)/SUM(o.sales))*100,2) profit_margin
FROM gold.fact_orders o
LEFT JOIN gold.dim_products p 
ON o.product_id=p.product_id
GROUP BY p.category
ORDER BY sum(o.sales) DESC
LIMIT 10;


--Most purchased item
SELECT p.product_name,SUM(o.quantity)
FROM gold.fact_orders o
LEFT JOIN gold.dim_products p
ON o.product_id=p.product_id
GROUP BY p.product_name
ORDER BY 2 DESC
LIMIT 5;

--Profit margin by product
SELECT product_name,round((profit/revenue)*100,2) as profit_margin
FROM (SELECT p.product_name,sum(sales) as revenue,sum(profit) as profit
FROM gold.fact_orders o 
LEFT JOIN gold.dim_products p
ON o.product_id=p.product_id
GROUP BY p.product_name)
order by 2 desc
limit 5;
