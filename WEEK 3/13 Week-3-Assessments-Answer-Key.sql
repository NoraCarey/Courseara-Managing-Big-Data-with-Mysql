# Question 2. On what day was Dillard’s income based on total sum of purchases the greatest?

SELECT saledate, SUM(AMT) AS total_income
FROM trnsact
GROUP BY saledate
ORDER BY total_income DESC;


# Question 3. What are the deptdesc of the departments that have the top 3 greatest numbers of skus from the skstinfo table associated with them?
#             (The question is wroing, it should be skuinfo not skstinfo table to get the answer)

SELECT d.deptdesc, COUNT(DISTINCT s.sku) AS sku_nums
FROM skuinfo s
JOIN deptinfo d
ON d.dept = s.dept
GROUP BY d.deptdesc
ORDER BY sku_nums DESC;


# Question 4. Which table contains the most distinct sku numbers?

SELECT COUNT(DISTINCT sku)
FROM trnsact;

SELECT COUNT(DISTINCT sku)
FROM skuinfo;

SELECT COUNT(DISTINCT sku)
FROM skstinfo;


# Question 5. How many skus are in the skstinfo table, but NOT in the skuinfo table?

# Method 1:
SELECT COUNT(DISTINCT s.sku)
FROM skstinfo s
LEFT JOIN skuinfo u
ON s.sku = u.sku
WHERE u.sku IS NULL;

# Method 2:
SELECT COUNT(DISTINCT sku)
FROM skstinfo 
WHERE sku NOT IN (SELECT sku
              FROM skuinfo);


# Question 6. What is the average amount of profit Dillard’s made per day?

SELECT SUM(t.amt - t.quantity * s.cost) AS total_profit, COUNT(DISTINCT saledate) AS days_nums, 
       total_profit / days_nums AS avg_profit
FROM trnsact t
JOIN skstinfo s
ON t.sku = s.sku AND t.store = s.store
WHERE t.stype = 'p';


# Question 7. The store_msa table provides population statistics about the geographic location around a store.
#             Using one query to retrieve your answer, how many MSAs are there within the state of North Carolina
#             (abbreviated “NC”), and within these MSAs, what is the lowest population level(msa_pop) and highest income level(msa_income)?

SELECT COUNT(msa), MIN(msa_pop), MAX(msa_income)
FROM store_msa
WHERE state = 'NC';


# Question 8. What department(with department description), brand, style, and color brought in the greatest total amount of sales?

SELECT s.dept, d.deptdesc, s.brand, s.style, s.color, SUM(t.amt) AS total_sales 
FROM trnsact t
JOIN skuinfo s
ON t.sku = s.sku
JOIN deptinfo d
ON d.dept = s.dept
WHERE t.stype = 'p'
GROUP BY s.dept, d.deptdesc, s.brand, s.style, s.color
ORDER BY total_sales DESC;


# Question 9. How many stores have more than 180,000 distinct skus associated with them in the skstinfo table?

SELECT store, COUNT(DISTINCT sku) AS sku_nums
FROM skstinfo
GROUP BY store
HAVING sku_nums > 180000;


# Question 10. Look at the data from all the distinct skus in the “cop” department with a “federal” brand and a “rinse wash” color. 
#              You'll see that these skus have the same values in some of the columns, meaning that they have some features in common. 
#              In which columns do these skus have different values from one another, meaning that their features differ in the categories 
#              represented by the columns? Choose all that apply. 

SELECT DISTINCT s.sku, s.dept, d.deptdesc, s.style, s.color, s.size, s.vendor, s.brand, s.packsize
FROM skuinfo s
JOIN deptinfo d
ON s.dept = d.dept
WHERE d.deptdesc = 'cop' AND s.brand = 'federal' AND s.color = 'rinse wash';


# Question 11. How many skus are in the skuinfo table, but NOT in the skstinfo table?

SELECT COUNT(DISTINCT u.sku) 
FROM skuinfo u
LEFT JOIN skstinfo s
ON u.sku = s.sku 
WHERE s.sku IS NULL;


# Question 12. In what city and state is the store that had the greatest total sum of sales?

SELECT s.city, s.state, t.store, SUM(t.amt) AS total_sales
FROM strinfo s
JOIN trnsact t
ON s.store = t.store
GROUP BY s.city, s.state, t.store
ORDER BY total_sales DESC;


# Question 14. How many states have more than 10 Dillards stores in them?

SELECT state, COUNT(DISTINCT store) AS store_nums
FROM strinfo 
GROUP BY state
HAVING store_nums > 10;


# Question 15. What is the suggested retail price of all the skus in the “reebok” department with the “sketchers” brand and a “wht/saphire” color?

SELECT DISTINCT s.sku, s.retail, d.deptdesc, u.brand, u.color
FROM skstinfo s
JOIN skuinfo u
ON s.sku = u.sku
JOIN deptinfo d
ON u.dept = d.dept
WHERE d.deptdesc = 'reebok' AND u.brand = 'skechers' AND u.color = 'wht/saphire';




