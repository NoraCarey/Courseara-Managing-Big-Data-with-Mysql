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

SELECT COUNT(DISTINCT s.sku)
FROM skstinfo s
JOIN skuinfo u
ON u.sku = s.sku
JOIN trnsact t
ON t.sku = u.sku;
# - 542513




#             (b) Use COUNT to determine how many instances there are of each sku associated with each store in the
#                 skstinfo table and the trnsact table? 

# Exercise 2: (a) Use COUNT and DISTINCT to determine how many distinct stores there are in the
#                 strinfo, store_msa, skstinfo, and trnsact tables.

#             (b) Which stores are common to all four tables, or unique to specific tables?

# Exercise 3: It turns out there are many skus in the trnsact table that are not in the skstinfo table. As a
#             consequence, we will not be able to complete many desirable analyses of Dillard’s profit, as opposed to
#             revenue, because we do not have the cost information for all the skus in the transact table (recall that
#             profit = revenue - cost). Examine some of the rows in the trnsact table that are not in the skstinfo table;
#             can you find any common features that could explain why the cost information is missing? 


# Exercise 4: Although we can’t complete all the analyses we’d like to on Dillard’s profit, we can look at
#             general trends. What is Dillard’s average profit per day?

# Exercise 5: On what day was the total value (in $) of returned goods the greatest? On what day was the
#             total number of individual returned items the greatest? 

# Exercise 6: What is the maximum price paid for an item in our database? What is the minimum price
#             paid for an item in our database? 

# Exercise 7: How many departments have more than 100 brands associated with them, and what are their descriptions?

# Exercise 8: Write a query that retrieves the department descriptions of each of the skus in the skstinfo table. 

# Exercise 9: What department (with department description), brand, style, and color had the greatest total value of returned items? 

# Exercise 10: In what state and zip code is the store that had the greatest total revenue during the time period monitored in our dataset? 









