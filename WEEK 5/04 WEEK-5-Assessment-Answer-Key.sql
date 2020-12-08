# Question 1: How	many distinct skus have the brand “Polo fas”, and are either size	“XXL”	or “black” in color?

SELECT COUNT(DISTINCT(sku))
FROM skuinfo
WHERE brand = 'Polo fas' AND (size = 'XXL' OR color = 'black');


# Question 2: There was one store in the	database, which had only 11 days in	one of its months (in other words, that	
#             store/month/year combination only contained 11 days of transaction	data).		
#             In	what city and state was this store located?	

SELECT s.city, s.state, t.store
FROM (SELECT store, EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate) AS month_date, COUNT(DISTINCT saledate) AS trans_dates
      FROM trnsact 
      GROUP BY month_date, store
      HAVING trans_dates = 11) AS t
JOIN strinfo s
ON s.store = t.store;


# Question 3: Which sku	number had the greatest	increase in	total	sales revenue from November to December?

SELECT TOP 1 sku, 
       SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 11 THEN amt END) AS Nov_rev,
       SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 12 THEN amt END) AS Dec_rev,
       Dec_rev - Nov_rev AS rev_diff
FROM trnsact
WHERE stype = 'P'
GROUP BY sku
ORDER BY rev_diff DESC;


# Question 4. What vendor has	the greatest number of distinct skus in the transaction table that do not exist in the	
#             skstinfo table?	(Remember that vendors are listed as distinct numbers	in our data	set).	

# Method 1                      
SELECT TOP 1 sk.vendor, COUNT(DISTINCT t.sku) AS sku_nums
FROM trnsact t
JOIN skuinfo sk
ON t.sku = sk.sku
LEFT JOIN skstinfo s
ON s.sku = sk.sku
GROUP BY sk.vendor
ORDER BY sku_nums DESC;
    
# Method 2
SELECT TOP 1 s.vendor, COUNT(DISTINCT(s.sku)) AS sku_nums
FROM trnsact t
JOIN skuinfo s
ON t.sku = s.sku
WHERE NOT EXISTS (SELECT *
              FROM skstinfo i
              WHERE i.sku = s.sku)
GROUP BY s.vendor
ORDER BY sku_nums DESC;


# Question 5: What is the brand of the sku with	the greatest standard deviation in sprice? Only	examine skus which	
#             have been	part of over 100 transactions.

SELECT TOP 1 t.sku, s.brand, COUNT(t.register), STDDEV_SAMP(t.sprice) AS stand_dev
FROM trnsact t
JOIN skuinfo s
ON t.sku = s.sku
WHERE t.stype = 'p'
GROUP BY t.sku, s.brand
HAVING COUNT(t.register) > 100
ORDER BY stand_dev DESC;


# Question 6. What is the city and state of the	store	that had the greatest increase in average	daily	revenue (as	defined	
#             in Teradata Week 5 Exercise	Guide) from	November to	December?

SELECT s.state, s.city, t.store
FROM (SELECT TOP 1 store, 
             SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 11 THEN amt END) AS Nov_rev,
             SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 12 THEN amt END) AS Dec_rev,
             COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH FROM saledate)  = 11 THEN saledate END)) AS Nov_days,
             COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH FROM saledate)  = 12 THEN saledate END)) AS Dec_days,
             Nov_rev / Nov_days AS Nov_avg,
             Dec_rev / Dec_days AS Dec_avg,
             Dec_avg - Nov_avg AS avg_diff
      FROM trnsact
      WHERE stype = 'P' 
      GROUP BY store
      HAVING Nov_days >= 20 AND Dec_days >= 20
      ORDER BY avg_diff DESC) AS t
JOIN strinfo s
ON s.store = t.store;


# Question 7: Compare the average daily revenue (as defined	in Teradata	Week 5 Exercise Guide) of the	store	with	the	
#             highest msa_income and the store with the lowest median msa_income (according to the msa_income field). In what	
#             city and state were these two stores, and which store had	a higher average daily revenue?

SELECT s.store, s.city, s.state, s.msa_income, SUM(t.total_rev) / SUM(t.month_days) AS avg_rev
FROM (SELECT EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate) AS month_date, store, 
             COUNT(DISTINCT(saledate)) AS month_days, SUM(amt) AS total_rev
      FROM trnsact
      WHERE stype = 'P' AND NOT (EXTRACT(YEAR FROM saledate) = 2005 AND EXTRACT(MONTH FROM saledate) = 8)
      GROUP BY month_date, store
      HAVING month_days >= 20) AS t
JOIN store_msa s
ON t.store = s.store
WHERE s.msa_income IN ((SELECT MAX(msa_income) FROM store_msa), (SELECT MIN(msa_income) FROM store_msa))
GROUP BY s.store, s.city, s.state, s.msa_income;

                                                                 
# Question 8: Divide the msa_income	groups up so that	msa_incomes	between 1 and 20,000 are labeled 'low',	
#             msa_incomes between 20,001 and 30,000 are labeled 'med-low', msa_incomes between 30,001	and 40,000 are	
#             labeled 'med-high', and msa_incomes between 40,001 and 60,000 are labeled 'high'.	 Which of these groups has the	
#             highest average	daily	revenue (as	defined in Teradata Week 5 Exercise	Guide) per store?             

SELECT CASE
           WHEN tbl.msa_income BETWEEN 1 AND 20000 THEN 'low'
           WHEN	tbl.msa_income BETWEEN 20001 AND 30000 THEN 'med-low'
           WHEN	tbl.msa_income BETWEEN 30001 AND 40000 THEN 'med-high'
           WHEN tbl.msa_income BETWEEN 40001 AND 60000 THEN 'high'
       END AS msa_income_label, SUM(tbl.total_rev) / SUM(tbl.month_days) AS daily_rev
FROM (SELECT s.msa_income, EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate) AS month_date, t.store,
             COUNT(DISTINCT(saledate)) AS month_days, SUM(amt) AS total_rev
      FROM trnsact t
      JOIN store_msa s
      ON t.store = s.store
      WHERE stype = 'P' AND NOT (EXTRACT(YEAR FROM saledate) = 2005 AND EXTRACT(MONTH FROM saledate) = 8) 
      GROUP BY month_date, t.store, msa_income
      HAVING month_days >= 20) AS tbl
GROUP BY msa_income_label
ORDER BY daily_rev DESC;
                   

# Question 9: Divide stores up so that stores with msa populations between 1 and 100,000 are labeled 'very small',	
#             stores with msa populations	between 100,001 and 200,000 are labeled 'small', stores with msa populations between	
#             200,001 and 500,000 are labeled 'med_small', stores with msa populations between 500,001 and 1,000,000 are	
#             labeled 'med_large', stores	with msa populations between 1,000,001 and 5,000,000 are labeled “large”, and	stores	
#             with msa_incomes greater than 5,000,000	are labeled	“very	large”. What is the average daily revenue (as defined	in	
#             Teradata Week 5	Exercise Guide) for a store in a “very arge” population msa?
                   
SELECT CASE	
           WHEN tbl.msa_pop BETWEEN 1 AND 100000 THEN 'very-small'
           WHEN	tbl.msa_pop BETWEEN 100001 AND 200000 THEN 'small'
           WHEN	tbl.msa_pop BETWEEN 200001 AND 500000 THEN 'med-small'
           WHEN	tbl.msa_pop BETWEEN 500001 AND 1000000 THEN 'med-large'
           WHEN	tbl.msa_pop BETWEEN 1000001 AND 5000000 THEN 'large'
           WHEN	tbl.msa_pop > 5000000 THEN 'very-large'
       END AS msa_pop_label, SUM(tbl.total_rev) / SUM(tbl.month_days) AS avg_rev
FROM (SELECT s.msa_pop, EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate) AS month_date,
             COUNT(DISTINCT(saledate)) AS month_days, SUM(amt) AS total_rev, t.store
      FROM trnsact t
      JOIN store_msa s
      ON t.store = s.store
      WHERE stype = 'P' AND NOT (EXTRACT(YEAR FROM saledate) = 2005 AND EXTRACT(MONTH FROM saledate) = 8)
      GROUP BY month_date, t.store, s.msa_pop
      HAVING month_days >= 20) AS tbl
GROUP BY msa_pop_label;
                   
                   
# Question 10: Which department in which store had the greatest percent	increase in	average daily sales revenue from	
#              November	to December, and what city and state was that store located	in? Only examine departments whose total	
#              sales were at least $1,000	in both November and December.    

SELECT tbl.deptdesc, tbl.store, i.city, i.state, tbl.percent_increase
FROM (SELECT TOP 1 d.deptdesc, t.store, 
             SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 11 THEN amt END) AS Nov_total,
             SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 12 THEN amt END) AS Dec_total,
             COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH FROM saledate) = 11 THEN saledate END)) AS Nov_days,
             COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH FROM saledate) = 12 THEN saledate END)) AS Dec_days,
             Nov_total / Nov_days AS Nov_daily,
             Dec_total / Dec_days AS Dec_daily, 
             ((Dec_daily - Nov_daily) / Nov_daily) * 100 AS percent_increase
     FROM trnsact t
     JOIN skuinfo s 
     ON t.sku = s.sku
     JOIN deptinfo d
     ON s.dept = d.dept
     WHERE stype = 'p'
     GROUP BY d.deptdesc, t.store
     HAVING Nov_days >= 20 AND Dec_days >= 20 AND Nov_total >= 1000 AND Dec_total >= 1000
     ORDER BY percent_increase DESC) AS tbl
JOIN strinfo i
ON i.store = tbl.store;
                   

# Question 11. Which department within what store had	the greatest decrease in average daily sales revenue from	
#              August to September,	and what city and	state	was that store located in? 

SELECT tbl.deptdesc, tbl.store, i.city, i.state, tbl.daily_diff
FROM (SELECT TOP 1 d.deptdesc, t.store, 
             SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 8 THEN amt END) AS Aug_total,
             SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 9 THEN amt END) AS Sep_total,
             COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH FROM saledate) = 8 THEN saledate END)) AS Aug_days,
             COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH FROM saledate) = 9 THEN saledate END)) AS Sep_days,
             Aug_total / Aug_days AS Aug_daily,
             Sep_total / Sep_days AS Sep_daily,
             (Sep_daily - Aug_daily) AS daily_diff
      FROM trnsact t
      JOIN skuinfo s
      ON t.sku = s.sku
      JOIN deptinfo d
      ON d.dept = s.dept
      WHERE stype = 'p' AND NOT (EXTRACT(YEAR FROM saledate) = 2005)
      GROUP BY d.deptdesc, t.store
      HAVING Aug_days >= 20 AND Sep_days >= 20
      ORDER BY daily_diff) AS tbl
JOIN strinfo i
ON i.store = tbl.store;
                   
                   
# Question 12: Identify	which	department, in which city and state of what store, had the greatest decrease in number	
#              of items sold from August to September. How many fewer items did that department sell in September compared to	August?
#              (the answer is wrong, because it ask the greatest decrease in number of items solde from August to September,
#               the number Aug_amt - Sep_amt should be negative, when the answer is 13491 the question should be the greatest increase,
#               and we could add DESC on ORDER BY column to get the right answer)
                   
SELECT tbl.deptdesc, tbl.store, i.city, i.state, tbl.amt_diff
FROM (SELECT TOP 1 d.deptdesc, t.store,
             SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 8 THEN quantity END) AS Aug_amt,
             SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 9 THEN quantity end) AS Sep_amt,
             COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH FROM saledate) = 8 THEN saledate END)) AS Aug_days,
             COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH FROM saledate) = 9 THEN saledate END)) AS Sep_days,
             (Aug_amt - Sep_amt) AS amt_diff
      FROM trnsact t
      JOIN skuinfo s
      ON t.sku = s.sku
      JOIN deptinfo d
      ON d.dept = s.dept
      WHERE stype = 'p' AND NOT (EXTRACT(YEAR FROM saledate) = 2005)
      GROUP BY d.deptdesc, t.store
      HAVING Aug_days >= 20 AND Sep_days >= 20 AND Aug_amt IS NOT NULL AND Sep_amt IS NOT NULL
      ORDER BY amt_diff) AS tbl
JOIN strinfo i
ON i.store = tbl.store;
                   
                   
# Question 13: For each store, determine the month with the minimum average daily revenue (as I define it in Teradata	
#              Week 5 Exercise Guide). For each of the twelve months of	the year, count how many stores' minimum average daily	
#              revenue was in that month. During which month(s) did over 100 stores have their minimum average daily revenue?	
     
SELECT CASE
           WHEN tbl.month_date = 1 THEN 'January'
           WHEN tbl.month_date = 2 THEN 'February'
           WHEN tbl.month_date = 3 THEN 'March'
           WHEN tbl.month_date = 4 THEN 'April'
           WHEN tbl.month_date = 5 THEN 'May'
           WHEN tbl.month_date = 6 THEN 'June'
           WHEN tbl.month_date = 7 THEN 'July'
           WHEN tbl.month_date = 8 THEN 'August'
           WHEN tbl.month_date = 9 THEN 'September'
           WHEN tbl.month_date = 10 THEN 'October'
           WHEN tbl.month_date = 11 THEN 'November'
           WHEN tbl.month_date = 12 THEN 'December'
       END, COUNT(tbl.store) AS store_nums
FROM (SELECT store, EXTRACT(MONTH FROM saledate) AS month_date, SUM(amt) AS total_rev,
             COUNT(DISTINCT saledate) AS month_days, total_rev / month_days AS daily_rev,
             RANK() OVER(PARTITION BY store 
                         ORDER BY daily_rev) AS ranking
      FROM trnsact
      WHERE stype = 'p' AND NOT (EXTRACT(YEAR FROM saledate) = 2005 AND EXTRACT(MONTH FROM saledate) = 8)
      GROUP BY store, month_date
      HAVING month_days >= 20
      QUALIFY ranking <= 1) AS tbl
GROUP BY tbl.month_date
ORDER BY store_nums DESC;
                  
                   
# Question 14: Write a query that determines the month in which each store had its maximum number of sku units	
#              returned. During which month did the greatest number of stores	have their maximum number of sku units returned?		

SELECT CASE
           WHEN tbl.month_date = 1 THEN 'January'
           WHEN tbl.month_date = 2 THEN 'February'
           WHEN tbl.month_date = 3 THEN 'March'
           WHEN tbl.month_date = 4 THEN 'April'
           WHEN tbl.month_date = 5 THEN 'May'
           WHEN tbl.month_date = 6 THEN 'June'
           WHEN tbl.month_date = 7 THEN 'July'
           WHEN tbl.month_date = 8 THEN 'August'
           WHEN tbl.month_date = 9 THEN 'September'
           WHEN tbl.month_date = 10 THEN 'October'
           WHEN tbl.month_date = 11 THEN 'November'
           WHEN tbl.month_date = 12 THEN 'December'
       END, COUNT(tbl.store) AS store_nums
FROM (SELECT store, EXTRACT(MONTH FROM saledate) AS month_date, COUNT(DISTINCT saledate) AS month_days, 
             COUNT(sku) AS return_nums,
             RANK() OVER(PARTITION BY store
                         ORDER BY return_nums DESC) AS ranking
      FROM trnsact
      WHERE stype = 'r' AND NOT (EXTRACT(YEAR FROM saledate) = 2005 AND EXTRACT(MONTH FROM saledate) = 8)
      GROUP BY store, month_date
      HAVING month_days >= 20
      QUALIFY ranking <= 1) AS tbl
GROUP BY tbl.month_date
ORDER BY store_nums DESC;
                   
                   
                   
                   
                   
                   

