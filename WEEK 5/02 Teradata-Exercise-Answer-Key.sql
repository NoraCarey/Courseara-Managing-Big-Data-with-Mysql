# Exercise 1. How many distinct dates are there in the saledate column of the transaction 
#             table for each month/year combination in the database? 
              
SELECT EXTRACT(YEAR FROM SALEDATE) AS year_num, EXTRACT(MONTH FROM SALEDATE) AS month_num, COUNT(DISTINCT(EXTRACT(DAY FROM SALEDATE)))
FROM TRNSACT
GROUP BY year_num, month_num
ORDER BY year_num DESC, month_num DESC;


# Exercise 2. Use a CASE statement within an aggregate function to determine which sku
#             had the greatest total sales during the combined summer months of June, July, and August. 

SELECT SKU, 
       SUM(CASE WHEN EXTRACT(MONTH FROM SALEDATE) = 6 THEN AMT END) AS June_sales,
       SUM(CASE WHEN EXTRACT(MONTH FROM SALEDATE) = 7 THEN AMT END) AS July_sales,
       SUM(CASE WHEN EXTRACT(MONTH FROM SALEDATE) = 8 THEN AMT END) AS August_sales,
       (June_sales + July_sales + August_sales) AS total_sales
FROM TRNSACT 
WHERE STYPE = 'P'
GROUP BY SKU
ORDER BY total_sales DESC;

# Exercise 3. How many distinct dates are there in the saledate column of the transaction
#             table for each month/year/store combination in the database? Sort your results by the
#             number of days per combination in ascending order. 

SELECT EXTRACT(YEAR FROM SALEDATE) AS year_num, EXTRACT(MONTH FROM SALEDATE) AS month_num,
       STORE, COUNT(DISTINCT (EXTRACT(DAY FROM SALEDATE))) AS day_num
FROM TRNSACT
GROUP BY year_num, month_num, STORE
ORDER BY day_num ASC;

# Exercise 4. What is the average daily revenue for each store/month/year combination in
#             the database? Calculate this by dividing the total revenue for a group by the number of
#             sales days available in the transaction table for that group. 

SELECT EXTRACT(YEAR FROM SALEDATE) || EXTRACT(MONTH FROM SALEDATE) AS date_month, STORE,
       COUNT(DISTINCT (EXTRACT(DAY FROM SALEDATE))) AS day_num, SUM(AMT) AS total_revenue, (total_revenue / day_num) AS daily_revenue
FROM TRNSACT
WHERE STYPE = 'P' AND NOT (EXTRACT(YEAR FROM SALEDATE) = 2005 AND EXTRACT(MONTH FROM SALEDATE) = 8)
HAVING day_num > 20 
GROUP BY date_month, STORE
ORDER BY daily_revenue;

# Exercise 5. What is the average daily revenue brought in by Dillard’s stores in areas of
#             high, medium, or low levels of high school education? 

SELECT CASE
           WHEN MSA_HIGH > 50 AND MSA_HIGH <= 60 THEN 'low_edu'
           WHEN MSA_HIGH > 60 AND MSA_HIGH <= 70 THEN 'medium_edu'
           WHEN MSA_HIGH > 70 THEN 'high_edu'
       END AS education_area, (SUM(revenue_table.daily_revenue) / COUNT(education_area)) AS avg_area_daily_revenue
FROM STORE_MSA education_table
JOIN (SELECT EXTRACT(YEAR FROM SALEDATE) || EXTRACT(MONTH FROM SALEDATE) AS date_month, STORE,
             COUNT(DISTINCT (EXTRACT(DAY FROM SALEDATE))) AS day_num, SUM(AMT) AS total_revenue, (total_revenue / day_num) AS daily_revenue
      FROM TRNSACT
      WHERE STYPE = 'P' AND NOT (EXTRACT(YEAR FROM SALEDATE) = 2005 AND EXTRACT(MONTH FROM SALEDATE) = 8)
      HAVING day_num > 20 
      GROUP BY date_month, STORE) AS revenue_table
ON revenue_table.store = education_table.store
GROUP BY education_area
ORDER BY avg_area_daily_revenue;





              
           
