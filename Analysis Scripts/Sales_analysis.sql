/*=====================================================================
--> Sales Trend Analysis
=======================================================================*/
--overall Sales
SELECT ROUND(SUM(sales)/10000000,2) || 'Cr.'
FROM gold.fact_orders;

--Overall Profit Margin
SELECT SUM(profit)/SUM(sales)
FROM gold.fact_orders;

--Sales,profit and Profit margin by year
SELECT EXTRACT(YEAR FROM order_date),ROUND(SUM(sales)/10000000,0)|| ' Cr.' as Total_Revenue,
COUNT(DISTINCT order_id),
ROUND(SUM(profit)/10000000,2)|| ' Cr.' as Total_Profit,
ROUND((SUM(profit)/SUM(sales))*100,2) || '%' as Profit_margin
FROM gold.fact_orders
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY 1;

--YoY Sales Growth
SELECT year,round(total_sales/10000000,2)|| 'Cr.',round(lag(total_sales)over(order by year)/10000000,2)|| 'Cr.' as prev_year_sales,
round(((total_sales-lag(total_sales)over(order by year))/lag(total_sales)over(order by year))*100,2) as YoY_growth
FROM(SELECT EXTRACT(YEAR FROM order_date) as year,SUM(sales) as total_sales
FROM gold.fact_orders
GROUP BY EXTRACT(YEAR FROM order_date))as t;

--Quarterly Sales trends
SELECT EXTRACT(YEAR FROM order_date),
       CASE EXTRACT(QUARTER FROM order_date) 
	         WHEN 1 THEN '1st' 
	         WHEN 2 THEN '2nd'  
			 WHEN 3 THEN '3rd'
			 WHEN 4 THEN '4th' END  as Quarter,
			 ROUND(SUM(sales)/10000000,2) || 'Cr',ROUND(SUM(profit)/10000000,2) || 'Cr'
FROM gold.fact_orders
GROUP BY EXTRACT(YEAR FROM order_date),EXTRACT(QUARTER FROM order_date)
ORDER BY 1,2;

SELECT extract(quarter from order_date),sum(Sales) as quarter_rev,round(sum(sales)*100/sum(sum(sales)) over(),2)||'%'
FROM gold.fact_orders
where extract(year from order_date)=2024
group by extract(quarter from order_date);

--Profit Margin
SELECT extract(year FROM order_date), round(sum(profit)/10000000,2) as profit
FROM gold.fact_orders
group by extract(year from order_date);

--Average order Value(AOV)
SELECT ROUND(sum(sales)/count(distinct order_id),0) as AOV
FROM gold.fact_orders;