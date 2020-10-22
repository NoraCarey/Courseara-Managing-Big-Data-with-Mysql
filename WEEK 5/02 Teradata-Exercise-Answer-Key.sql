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
HAVING day_num >= 20 
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
      HAVING day_num >= 20 
      GROUP BY date_month, STORE) AS revenue_table
ON revenue_table.store = education_table.store
GROUP BY education_area
ORDER BY avg_area_daily_revenue;
                             

# Exercise 6. Compare the average daily revenues of the stores with the highest median
#             msa_income and the lowest median msa_income. In what city and state were these stores,
#             and which store had a higher average daily revenue?                              
                  
SELECT s.state, s.city, s.store, s.msa_income, (SUM(t.daily_revenue) / COUNT(t.store)) AS avg_daily_revenue
FROM (SELECT store, EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate) AS date_month, 
             COUNT(DISTINCT(EXTRACT(DAY FROM saledate))) AS day_num, SUM(amt) AS total_revenue,
             total_revenue / day_num AS daily_revenue
      FROM trnsact
      WHERE stype = 'P' AND NOT (EXTRACT(YEAR FROM saledate) = 2005 AND EXTRACT(MONTH FROM saledate) = 8)
      HAVING day_num >= 20
      GROUP BY date_month, store) AS t
JOIN (SELECT store, state, city, msa_income
      FROM store_msa
      WHERE msa_income IN ((SELECT MAX(msa_income) FROM store_msa), (SELECT MIN(msa_income) FROM store_msa))) AS s
ON t.store = s.store
GROUP BY s.state, s.city, s.store, s.msa_income;

                                                                     
# Exercise 7: What is the brand of the sku with the greatest standard deviation in sprice?
#             Only examine skus that have been part of over 100 transactions.     

SELECT s.sku, s.brand, top1.std
FROM (SELECT TOP 1 sku, STDDEV_SAMP(sprice) AS std, COUNT(sku) AS trans_num
      FROM trnsact 
      GROUP BY sku
      ORDER BY std DESC
      HAVING trans_num > 100) AS top1
JOIN skuinfo s
ON s.sku = top1.sku;
                                                                  
                                                                                                                                    
# Exercise 8: Examine all the transactions for the sku with the greatest standard deviation in
#             sprice, but only consider skus that are part of more than 100 transactions. 

SELECT *
FROM (SELECT top 1 sku, STDDEV_SAMP(sprice) AS std, COUNT(sku) as sku_num
      FROM trnsact 
      GROUP BY sku
      ORDER BY std DESC
      HAVING sku_num > 100) AS top1
JOIN trnsact t
ON t.sku = top1.sku;                                                                     
                                                                     
  
# Exercise 9: What was the average daily revenue Dillard’s brought in during each month of the year?   

SELECT table1.date_month, SUM(table1.total_revenue) / SUM(table1.day_num) AS daily_revenue
FROM (SELECT EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate) AS date_month, store, SUM(amt) as total_revenue, 
             COUNT(DISTINCT saledate) AS day_num
      FROM trnsact
      WHERE stype = 'P' AND NOT (EXTRACT(YEAR FROM saledate) = 2005 AND EXTRACT(MONTH FROM saledate) = 8)
      GROUP BY date_month, store
      HAVING day_num >= 20) AS table1
GROUP BY table1.date_month
ORDER BY daily_revenue DESC;
                                                                     
                                                                     
# Exercise 10: Which department, in which city and state of what store, had the greatest %
#              increase in average daily sales revenue from November to December? 
                                                                     
SELECT best.dept, i.state, i.city, best.store, best.Percent_increase
FROM (SELECT TOP 1 t.store, d.dept,
             SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 11 THEN amt END) AS Nov_rev,
             SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 12 THEN amt END) AS Dec_rev,
             COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH FROM saledate) = 11 THEN saledate END))AS Nov_days,
             COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH FROM saledate) = 12 THEN saledate END)) AS Dec_days,
             Nov_rev / Nov_days AS Nov_daily,
             Dec_rev / Dec_days AS Dec_daily,
             ((Dec_daily - Nov_daily) / Nov_daily) * 100 AS Percent_increase
      FROM trnsact t, skuinfo s, deptinfo d
      WHERE t.sku = s.sku AND s.dept = d.dept AND t.stype = 'P' 
      GROUP BY t.store, d.dept
      HAVING Nov_days >= 20 AND Dec_days >= 20
      ORDER BY Percent_increase DESC) AS best
JOIN strinfo i 
ON i.store = best.store;
                   
                                                                     
# Exercise 11: What is the city and state of the store that had the greatest decrease in average daily revenue from August to September? 
                                                                     
                                                                     
# Exercise 12: Determine the month of maximum total revenue for each store. Count the
#              number of stores whose month of maximum total revenue was in each of the twelve
#              months. Then determine the month of maximum average daily revenue. Count the
#              number of stores whose month of maximum average daily revenue was in each of the
#              twelve months. How do they compare?
              
           
