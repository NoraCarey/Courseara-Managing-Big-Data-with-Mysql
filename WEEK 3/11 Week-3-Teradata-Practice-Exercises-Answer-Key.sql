# Exercise 1: (a) Use COUNT and DISTINCT to determine how many distinct skus there are in pairs of the skuinfo, 
#                 skstinfo, and trnsact tables. Which skus are common to pairs of tables, or unique to specific tables? 

SELECT COUNT(DISTINCT sku)
FROM skuinfo;
# - 1564178

SELECT COUNT(DISTINCT sku)
FROM skstinfo;
# - 760212

SELECT COUNT(DISTINCT sku)
FROM trnsact;
# - 714499

SELECT COUNT(DISTINCT u.sku)
FROM skuinfo u
JOIN skstinfo s
ON u.sku = s.sku;
# - 760212

SELECT COUNT(DISTINCT u.sku) 
FROM skuinfo u
JOIN trnsact t
ON t.sku = u.sku;
# - 714499

# Method 1:
SELECT COUNT(DISTINCT s.sku)
FROM skstinfo s
JOIN skuinfo u
ON u.sku = s.sku
JOIN trnsact t
ON t.sku = u.sku;

# Method 2:
SELECT COUNT(DISTINCT s.sku)
FROM skstinfo s
JOIN trnsact t
ON s.sku = t.sku;
# - 542513


#             (b) Use COUNT to determine how many instances there are of each sku associated with each store in the
#                 skstinfo table and the trnsact table? 

SELECT COUNT(*)
FROM skstinfo s
JOIN trnsact t
ON t.sku = s.sku AND t.store = s.store;
# - 68578056


# Exercise 2: (a) Use COUNT and DISTINCT to determine how many distinct stores there are in the
#                 strinfo, store_msa, skstinfo, and trnsact tables.

SELECT COUNT(DISTINCT store)
FROM strinfo;
# - 453

SELECT COUNT(DISTINCT store)
FROM store_msa;
# - 333

SELECT COUNT(DISTINCT store)
FROM skstinfo;
# - 357

SELECT COUNT(DISTINCT store)
FROM trnsact;
# - 332


#             (b) Which stores are common to all four tables, or unique to specific tables?

# Common
SELECT DISTINCT s.store
FROM skstinfo s
JOIN strinfo r
ON r.store = s.store
JOIN trnsact t
ON r.store = t.store
JOIN store_msa m
ON m.store = t.store;

# Unique
SELECT s.store
FROM skstinfo s
WHERE s.store NOT IN (SELECT r.store
                      FROM strinfo r
                      JOIN trnsact t
                      ON t.store = r.store
                      JOIN store_msa m
                      ON m.store = t.store);


# Exercise 3: It turns out there are many skus in the trnsact table that are not in the skstinfo table. As a
#             consequence, we will not be able to complete many desirable analyses of Dillard’s profit, as opposed to
#             revenue, because we do not have the cost information for all the skus in the transact table (recall that
#             profit = revenue - cost). Examine some of the rows in the trnsact table that are not in the skstinfo table;
#             can you find any common features that could explain why the cost information is missing? 

SELECT *
FROM trnsact t
LEFT JOIN skstinfo s
ON s.sku = t.sku
WHERE s.sku IS NULL;

# Exercise 4: Although we can’t complete all the analyses we’d like to on Dillard’s profit, we can look at
#             general trends. What is Dillard’s average profit per day?

SELECT SUM(t.amt - s.cost * t.quantity) AS total_profit, COUNT(DISTINCT saledate) AS days_nums,
       total_profit / days_nums AS avg_profit
FROM trnsact t
LEFT JOIN skstinfo s
ON t.sku = s.sku AND t.store = s.store
WHERE stype = 'p' AND s.sku IS NOT NULL;


# Exercise 5: On what day was the total value (in $) of returned goods the greatest? On what day was the
#             total number of individual returned items the greatest? 

SELECT TOP 1 saledate, SUM(amt) AS total_return
FROM trnsact
WHERE stype = 'r'
GROUP BY saledate
ORDER BY total_return DESC;
# - 04/12/27

SELECT TOP 1 saledate, SUM(quantity) AS return_nums
FROM trnsact
WHERE stype = 'r'
GROUP BY saledate
ORDER BY return_nums DESC;
# - 04/12/27


# Exercise 6: What is the maximum price paid for an item in our database? What is the minimum price
#             paid for an item in our database? 

SELECT TOP 1 sprice
FROM trnsact
WHERE stype = 'p'
ORDER BY sprice DESC;
# - 6017.00

SELECT TOP 1 sprice
FROM trnsact
WHERE stype = 'p' AND sprice <> 0
ORDER BY sprice ASC;
# - 0.01


# Exercise 7: How many departments have more than 100 brands associated with them, and what are their descriptions?

SELECT s.dept, d.deptdesc, COUNT(DISTINCT brand) AS brand_nums
FROM skuinfo s
JOIN deptinfo d
ON d.dept = s.dept
GROUP BY s.dept, d.deptdesc
HAVING brand_nums > 100;
# - 3

# Exercise 8: Write a query that retrieves the department descriptions of each of the skus in the skstinfo table. 

SELECT DISTINCT s.sku, d.deptdesc
FROM skstinfo s
JOIN skuinfo u
ON s.sku = u.sku
JOIN deptinfo d
ON d.dept = u.dept
WHERE s.sku = 5020024;


# Exercise 9: What department (with department description), brand, style, and color had the greatest total value of returned items? 

SELECT s.dept, d.deptdesc, s.brand, s.style, s.color, SUM(t.amt) AS total_return
FROM trnsact t
JOIN skuinfo s
ON t.sku = s.sku
JOIN deptinfo d
ON d.dept = s.dept
WHERE t.stype = 'r'
GROUP BY s.dept, d.deptdesc, s.brand, s.style, s.color
ORDER BY total_return DESC;
      

# Exercise 10: In what state and zip code is the store that had the greatest total revenue during the time period monitored in our dataset? 

SELECT s.state, s.city, t.store, SUM(t.amt) AS total_rev
FROM trnsact t
JOIN strinfo s
ON t.store = s.store
WHERE t.stype = 'p'
GROUP BY s.state, s.city, t.store
ORDER BY total_rev DESC;





