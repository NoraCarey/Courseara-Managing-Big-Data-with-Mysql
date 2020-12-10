# Exercise 1. Use HELP and SHOW to confirm the relational schema provided to us for the
              Dillard’s dataset shows the correct column names and primary keys for each table. 

SHOW table skuinfo;

HELP table skuinfo;

HELP COLUMN sku FROM skuinfo;


# Exercise 2. Look at examples of data from each of the tables. Pay particular attention to the skuinfo table. 

SELECT TOP 10 *
FROM skuinfo;

SELECT *
FROM skuinfo
SAMPLE 30;

SELECT *
FROM skuinfo 
SAMPLE .30;


# Exercise 3. Examine lists of distinct values in each of the tables. 

SELECT DISTINCT dept, brand
FROM skuinfo;

SELECT dept, brand
FROM skuinfo;


# Exercise 4. Examine instances of transaction table where “amt” is different than “sprice”.
#            What did you learn about how the values in “amt”, “quantity”, and “sprice” relate to one another? 
#            (amt = quantity * sprice)

SELECT *
FROM trnsact 
WHERE amt <> sprice;


# Exercise 5. Even though the Dillard’s dataset had primary keys declared and there were not many NULL values, 
#             there are still many bizarre entries that likely reflect entry errors.
#             To see some examples of these likely errors, examine:
#             (a) rows in the trsnact table that have “0” in their orgprice column (how could the original price be 0?),

              SELECT *
              FROM trnsact
              WHERE orgprice = 0;

#             (b) rows in the skstinfo table where both the cost and retail price are listed as 0.00, and
            
              SELECT *
              FROM skstinfo 
              WHERE cost = 0 AND retail = 0;
              
#             (c) rows in the skstinfo table where the cost is greater than the retail price (although occasionally retailers 
#                 will sell an item at a loss for strategic reasons, it is very unlikely that a manufacturer would provide 
#                 a suggested retail price that is lower than the cost of the item).

              SELECT *
              FROM skstinfo 
              WHERE cost > retail;
              
              
# Exercise 6. Write your own queries that retrieve multiple columns in a precise order from a table, 
#             and that restrict the rows retrieved from those columns using “BETWEEN”, “IN”, and references to text strings. 
#             Try at least one query that uses dates to restrict the rows you retrieve.

# BETWEEN
SELECT sku, saledate 
FROM trnsact
WHERE saledate BETWEEN '2005-02-01' AND '2005-02-23'
ORDER BY saledate;

# IN 
SELECT sku, saledate 
FROM trnsact
WHERE saledate IN ('2005-02-01','2005-02-23');

SELECT sku, saledate 
FROM trnsact 
WHERE saledate > '2005-02-01'
SAMPLE 10;






