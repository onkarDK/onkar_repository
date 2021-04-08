CREATE DATABASE DB_PROJECT

SELECT * FROM Customer
SELECT * FROM prod_cat_info
SELECT * FROM Transactions


SELECT
DOB
FROM 
CUSTOMER

--				DATA PREPARATION AND UNDERSTANDING


--Q1) What is the total number of rows in each of the 3 tables in the database

SELECT count(*) FROM Customer
SELECT count(*) FROM prod_cat_info
SELECT count(*) FROM Transactions

--Q2) What is the total number of transactions that have a return

SELECT
COUNT(QTY) AS RETURN_ORD
FROM
TRANSACTIONS
WHERE
QTY < 1

--Q3) As you would have noticed, the dates provided across the datasets are not in a correct format. As first steps, pls 
--    convert the date variables into valid date formats before proceeding ahead.
 
SELECT
customer_Id, CONVERT(DATE, DOB, 103) AS DOB_NEW, Gender, city_code
FROM
CUSTOMER

SELECT transaction_id, cust_id, CONVERT(DATE, tran_date, 103) AS tran_date_new , prod_subcat_code, Qty, Rate, Tax, total_amt, Store_type
FROM
TRANSACTIONS


--Q4) What is the time range of transaction data available for analysis? Show the output in number of days, months and 
--    years simultaneously in different columns


SELECT
DATEDIFF(YEAR, MIN(CONVERT(DATE, TRAN_DATE, 103)), MAX(CONVERT(DATE, TRAN_DATE, 103))) TOT_YEARS,
DATEDIFF(MONTH, MIN(CONVERT(DATE, TRAN_DATE, 103)), MAX(CONVERT(DATE, TRAN_DATE, 103))) TOT_MONTHS,
DATEDIFF(DAY, MIN(CONVERT(DATE, TRAN_DATE, 103)), MAX(CONVERT(DATE, TRAN_DATE, 103))) TOT_DAYS
FROM
Transactions

--Q5) Which product category does the sub category "DIY" belong to?

SELECT
PROD_SUBCAT, PROD_CAT
FROM
prod_cat_info
WHERE prod_subcat LIKE 'DIY'


--          DATA ANALYSIS



--Q1) Which channel is most frequently used for transactions?



SELECT * FROM (
SELECT
STORE_TYPE,
ROW_NUMBER() OVER ( ORDER BY (COUNT(STORE_TYPE)) DESC) AS CHANNEL_RANK
FROM
Transactions
GROUP BY
STORE_TYPE
) AS T5
WHERE 
CHANNEL_RANK = 1



--Q2) What is the count of male and female customers in database?

SELECT * FROM(
SELECT
GENDER, COUNT(GENDER) AS CNT_CUSTOMERS
FROM
Customer
GROUP BY
Gender
) AS T6
WHERE
GENDER IN ('M', 'F')


--Q3) From which city do we have the maximum number of customers and how many?

SELECT 
* FROM (
SELECT
city_code, COUNT(CITY_CODE) AS CNT_CUSTOMERS, ROW_NUMBER() OVER(ORDER BY (COUNT(CITY_CODE)) DESC) AS CITY_RANK_ON_ORDERS
FROM
Customer
GROUP BY
CITY_CODE
) T8
WHERE 
CITY_RANK_ON_ORDERS = 1


--Q4) How many sub-categories are there under books category?

SELECT COUNT(*) AS CNT_SUBCAT_BOOKS FROM (
SELECT
prod_cat, prod_subcat
FROM
prod_cat_info
WHERE 
prod_cat LIKE 'BOOK%'
GROUP BY
prod_cat, prod_subcat
) T8



--Q5) What is the maximum quantity of products ever ordered ?
 
 SELECT
 MAX(QTY) AS MAX_ORDERS
 FROM
 Transactions
 WHERE QTY > 0



 --Q6) What is the net total revenue generated in categories Electronics and Books ?


SELECT
PROD_CAT,
SUM(CAST(T2.Rate AS numeric)) AS TOT_REVENUE
FROM
prod_cat_info AS T1
INNER JOIN Transactions AS T2 ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_sub_cat_code = T2.prod_subcat_code
WHERE
PROD_CAT IN ('ELECTRONICS', 'BOOKS')
GROUP BY
PROD_CAT 

--Q7) HOW MANY CUSTOMERS HAVE >10 TRANSACTIONS WITH US, EXCLUDING RETURNS?

SELECT COUNT(*) AS CNT_CUSTOMERS FROM (
SELECT
CUST_ID, COUNT(cust_id) AS TOT_ORDERS
FROM
Transactions
WHERE
QTY > 0 
GROUP BY 
cust_id
) AS T9 
WHERE TOT_ORDERS > 10

--Q8) What is the combined revenue earned from the "Electronnics" and "Clothing"  categories, from "Flagship stores"

SELECT SUM(TOT_REVENUE) AS [TOT_REVENUE_ELEC + CLOTH] FROM (
SELECT 
prod_cat,
STORE_TYPE,
SUM(CAST(RATE AS NUMERIC)) AS TOT_REVENUE
FROM
prod_cat_info AS T1
INNER JOIN Transactions AS T2 ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_sub_cat_code = T2.prod_subcat_code
WHERE
prod_cat IN ('Electronics', 'Clothing') AND Store_type LIKE 'FLAG%'
GROUP BY
prod_cat, Store_type
)T9

SELECT * FROM Customer
SELECT * FROM prod_cat_info
SELECT * FROM Transactions

--Q9) What is the total revenue generated from  "Male" customers in "Electronics" category ? Output should 
--    display total revenue by prod sub-cat.


SELECT
PROD_SUBCAT AS SUBCAT_OF_ELECTRONICS,
SUM(CAST(RATE AS numeric)) AS TOT_REV
FROM
Customer AS T1
INNER JOIN Transactions AS T2 ON T1.customer_Id = T2.cust_id
INNER JOIN prod_cat_info AS T3 ON T2.prod_cat_code = T3.prod_cat_code AND T2.prod_subcat_code = T3.prod_sub_cat_code
WHERE
prod_cat = 'Electronics' AND Gender = 'M' 
GROUP BY
PROD_SUBCAT












