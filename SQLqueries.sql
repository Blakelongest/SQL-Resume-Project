SELECT * FROM categories
SELECT * FROM customers
SELECT * FROM products
SELECT * FROM sales
SELECT * FROM subcategories
SELECT * FROM territories

			--- Sales Performance Analysis ---
(1)
---- Total Profit
SELECT SUM((sales.orderquantity)*(products.productprice-products.productcost))::money 
	AS "Total Profit"
FROM products
JOIN sales ON sales.productkey = products.productkey

(2)
---- Monthly Profit
SELECT EXTRACT (MONTH FROM sales.orderdate) AS "Month", 
	SUM((sales.orderquantity)*(products.productprice-products.productcost))::money AS "Profit"
FROM sales 
JOIN products ON products.productkey = sales.productkey
GROUP BY "Month"
ORDER BY "Month"

(3)
---- Top 3 Most Profitable Days 
SELECT sales.orderdate AS "Top 3 Most Profitable Days", 
	SUM((sales.orderquantity)*(products.productprice-products.productcost))::money AS "Daily Profit"
FROM sales 
JOIN products ON products.productkey = sales.productkey
GROUP BY sales.orderdate
ORDER BY "Daily Profit" DESC
LIMIT 3

(4)
---- Total Category Order Volume (No Sales Contain Products In "Components" Category)
SELECT categories.categoryname AS "Product Categories",
	SUM(sales.orderquantity) AS "Order Volume" 
FROM sales 
JOIN products ON products.productkey = sales.productkey
JOIN subcategories ON subcategories.productsubcategorykey = products.productsubcategorykey
RIGHT JOIN categories ON categories.productcategorykey = subcategories.productcategorykey
GROUP BY "Product Categories"

(5)
---- Monthly Product Category Order Volume
SELECT EXTRACT (MONTH FROM sales.orderdate) AS "Month",
categories.categoryname AS "Product Categories",
	SUM(sales.orderquantity) AS "Order Volume" 
FROM sales 
JOIN products ON products.productkey = sales.productkey
JOIN subcategories ON subcategories.productsubcategorykey = products.productsubcategorykey
RIGHT JOIN categories ON categories.productcategorykey = subcategories.productcategorykey
GROUP BY "Month", "Product Categories"
ORDER BY "Month", "Product Categories"

(6)
---- Revenue Growth Rate Between January(1) and June(6)
SELECT CONCAT(
ROUND((((SELECT SUM((products.productprice*sales.orderquantity))::money AS "Revenue" 
	FROM products
	JOIN sales ON sales.productkey = products.productkey
	GROUP BY EXTRACT (MONTH FROM sales.orderdate)
		HAVING EXTRACT (MONTH FROM sales.orderdate) = 6) - 
	(SELECT SUM((products.productprice*sales.orderquantity))::money AS "Revenue" 
	FROM products
	JOIN sales ON sales.productkey = products.productkey
	GROUP BY EXTRACT (MONTH FROM sales.orderdate)
		HAVING EXTRACT (MONTH FROM sales.orderdate) = 1)) /
	(SELECT SUM((products.productprice*sales.orderquantity))::money AS "Revenue" 
	FROM products
	JOIN sales ON sales.productkey = products.productkey
	GROUP BY EXTRACT (MONTH FROM sales.orderdate)
		HAVING EXTRACT (MONTH FROM sales.orderdate) = 1)*100)), '%') 
AS "Revenue Growth Rate Between January & June"

		--- Customer Segmentation Analysis ---
(1)
---- Top 10 Customers (Ranked by Profit Contribution)
SELECT customers.firstname AS "Customer First Name",
	customers.lastname AS "Customer Last Name", 
	SUM((sales.orderquantity)*(products.productprice-products.productcost))::money AS "Profit Contribution"
FROM customers
JOIN sales ON sales.customerkey = customers.customerkey 
JOIN products ON products.productkey = sales.productkey
GROUP BY customers.firstname, customers.lastname
ORDER BY "Profit Contribution" DESC
LIMIT 10

(2)
---- Average Customer Age
SELECT ROUND(AVG((CURRENT_DATE - birthdate)/365)) AS "Average Age of Customer"
FROM customers

(3)
--- Number of Customers by Gender
SELECT gender, COUNT(*)
FROM customers
GROUP BY gender 

(4)
---- Customer Order Frequency 
SELECT customers.firstname, 
	customers.lastname,
COUNT(sales.ordernumber) AS "Number of Orders",
	CASE 
		WHEN COUNT(sales.ordernumber) = 0
			THEN 'No Orders'
		WHEN COUNT(sales.ordernumber) >= 1
			AND COUNT(sales.ordernumber) < 5 THEN 'Infrequent Customer'
		ELSE 'Frequent Customer'
	END "Customer Order Frequency"
FROM sales 
JOIN customers ON customers.customerkey = sales.customerkey 
GROUP BY customers.firstname, customers.lastname
--Include to See Most Frequent Customers 
ORDER BY "Number of Orders" DESC


		--- Product Performance Analysis ---
(1)
----Top 5 Most Purchased Products
SELECT products.productname, 
	SUM(sales.orderquantity) AS "Total Number of Orders"
FROM products 
JOIN sales ON sales.productkey = products.productkey
GROUP BY products.productname
ORDER BY "Total Number of Orders" DESC
LIMIT 5

(2)
----Top 5 Most Profitable Products for Firm
SELECT products.productname,
SUM((sales.orderquantity)*(products.productprice-products.productcost))::money AS "Product Contribution to Total Profit"
FROM Sales 
JOIN products ON products.productkey = sales.productkey
GROUP BY products.productname
ORDER BY "Product Contribution to Total Profit" DESC

(3)
----Profit Contribution of Products with Profit Margin > 500
SELECT products.productname,
SUM((sales.orderquantity)*(products.productprice-products.productcost))::money AS "Product Contribution to Firm Total Profit", 
(products.productprice-products.productcost) AS "Profit Margin"
FROM Sales 
JOIN products ON products.productkey = sales.productkey
GROUP BY products.productname, "Profit Margin"
	HAVING (products.productprice-products.productcost) > 500
ORDER BY "Product Contribution to Firm Total Profit" DESC
