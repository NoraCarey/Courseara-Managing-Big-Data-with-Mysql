# Question	1:		How	many	distinct	skus	have	the	brand	“Polo	fas”,	and	are	either	size	“XXL”	or	“black”	in	color?

SELECT COUNT(DISTINCT(sku))
FROM skuinfo
WHERE brand = 'Polo fas' AND (size = 'XXL' OR color = 'black');


# Question	2:		There	was	one	store	in	the	database,	which had	only	11	days	in	one	of	its	months	(in	other	words,	that	
#                 store/month/year	combination	only	contained	11	days	of	transaction	data).		
#                 In	what	city	and	state	was	this	store	located?	

SELECT s.city, s.state, t.store
FROM (SELECT store, EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate) AS month_date, COUNT(DISTINCT saledate) AS trans_dates
      FROM trnsact 
      GROUP BY month_date, store
      HAVING trans_dates = 11) AS t
JOIN strinfo s
ON s.store = t.store;


# Question	3:	Which	sku	number	had	the	greatest	increase	in	total	sales revenue	from	November	to	December?

SELECT TOP 1 sku, 
       SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 11 THEN amt END) AS Nov_rev,
       SUM(CASE WHEN EXTRACT(MONTH FROM saledate) = 12 THEN amt END) AS Dec_rev,
       Dec_rev - Nov_rev AS rev_diff
FROM trnsact
WHERE stype = 'P'
GROUP BY sku
ORDER BY rev_diff DESC;


# Question	4.		What	vendor	has	the	greatest	number	of	distinct	skus	in	the	transaction	table	that	do	not	exist	in	the	
#                 skstinfo	table?		(Remember	that	vendors	are	listed	as	distinct	numbers	in	our	data	set).	

SELECT TOP 1 sk.vendor, COUNT(DISTINCT t.sku) AS sku_nums
FROM trnsact t
JOIN skuinfo sk
ON t.sku = sk.sku
LEFT JOIN skstinfo s
ON s.sku = sk.sku
GROUP BY sk.vendor
ORDER BY sku_nums DESC;


# Question	5:		What	is	the	brand	of	the	sku	with	the	greatest	standard	deviation	in	sprice?		Only	examine	skus	which	
#                 have	been	part	of	over	100	transactions.

SELECT TOP 1 t.sku, s.brand, COUNT(t.register), STDDEV_SAMP(t.sprice) AS stand_dev
FROM trnsact t
JOIN skuinfo s
ON t.sku = s.sku
WHERE t.stype = 'p'
GROUP BY t.sku, s.brand
HAVING COUNT(t.register) > 100
ORDER BY stand_dev DESC;


# Question	6.		What	is	the	city	and	state	of	the	store	that had	the	greatest	increase in	average	daily	revenue	(as	defined	
#                 in	Teradata	Week	5	Exercise	Guide)	from	November	to	December?

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


# Question	7:		Compare	the	average	daily	revenue	(as	defined	in	Teradata	Week	5	Exercise	Guide)	of	the	store	with	the	
#                 highest	msa_income	and	the	store	with	the	lowest	median	msa_income (according	to	the	msa_income	field).		In	what	
#                 city	and	state	were	these	two	stores,	and	which	store	had	a	higher	average	daily	revenue?









