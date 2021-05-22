USE db_SQLCaseStudies





--                                           DATA ANALYSIS

-- Which channel is most frequently used for transactions?

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

-- What is the count of male and female customers in database?

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

-- From which city do we have the maximum number of customers and how many?

SELECT 
* FROM (
SELECT
city_code, COUNT(CITY_CODE) AS CNT_CUSTOMERS, ROW_NUMBER() OVER(ORDER BY (COUNT(CITY_CODE)) DESC) AS CITY_RANK_ON_CNT_CUST
FROM
Customer
GROUP BY
CITY_CODE
) T8
WHERE 
CITY_RANK_ON_CNT_CUST = 1

-- How many sub-categories are there under books category?

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

-- What is the maximum quantity of products ever ordered ?
 
 SELECT
 MAX(QTY) AS MAX_ORDERS
 FROM
 Transactions
 WHERE QTY > 0

 -- What is the net total revenue generated in categories Electronics and Books ?

SELECT
PROD_CAT,
SUM(CAST(T2.total_amt AS numeric)) AS NET_TOT_REVENUE
FROM
prod_cat_info AS T1
INNER JOIN Transactions AS T2 ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_sub_cat_code = T2.prod_subcat_code
WHERE
PROD_CAT IN ('ELECTRONICS', 'BOOKS')
GROUP BY
PROD_CAT 

-- HOW MANY CUSTOMERS HAVE >10 TRANSACTIONS WITH US, EXCLUDING RETURNS?

SELECT COUNT(*) AS [CNT_CUSTOMERS>10_TRANSACTIONS] FROM (
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

-- What is the combined revenue earned from the "Electronnics" and "Clothing"  categories, from "Flagship stores"

SELECT SUM(TOT_REVENUE) AS [TOT_FLAG_REVENUE_(ELEC + CLOTH)] FROM (
SELECT 
prod_cat,
STORE_TYPE,
SUM(CAST(T2.total_amt AS NUMERIC)) AS TOT_REVENUE
FROM
prod_cat_info AS T1
INNER JOIN Transactions AS T2 ON T1.prod_cat_code = T2.prod_cat_code AND T1.prod_sub_cat_code = T2.prod_subcat_code
WHERE
prod_cat IN ('Electronics', 'Clothing') AND Store_type LIKE 'FLAG%'
GROUP BY
prod_cat, Store_type
)T9


-- What is the total revenue generated from  "Male" customers in "Electronics" category ? Output should 
--    display total revenue by prod sub-cat.

SELECT
PROD_SUBCAT AS SUBCAT_OF_ELECTRONICS,
SUM(CAST(T2.total_amt AS numeric)) AS [TOT_REV(M)]
FROM
Customer AS T1
INNER JOIN Transactions AS T2 ON T1.customer_Id = T2.cust_id
INNER JOIN prod_cat_info AS T3 ON T2.prod_cat_code = T3.prod_cat_code AND T2.prod_subcat_code = T3.prod_sub_cat_code
WHERE
prod_cat = 'Electronics' AND Gender = 'M' 
GROUP BY
PROD_SUBCAT
ORDER BY
[TOT_REV(M)] DESC

/*
 What is percentage of sales and returns by product sub category ; display only top 5 sub categories in terms of sales?
*/

SELECT TOP 5
P.prod_subcat AS SUBCATEGORY,
(SUM(CAST(CASE WHEN T.Rate > 0 THEN T.RATE END AS NUMERIC))) / (SUM(ABS(CAST(T.RATE AS numeric)))) AS [% SALES],
(SUM(ABS(CAST(CASE WHEN T.Rate < 0 THEN T.RATE END AS NUMERIC)))) / (SUM(ABS(CAST(T.RATE AS numeric)))) AS [% RETURN]
FROM 
prod_cat_info AS P
INNER JOIN 
Transactions AS T ON P.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
GROUP BY
P.PROD_SUBCAT
ORDER BY
[% SALES] DESC


/*
 For all customers aged between 25 to 35 years find what is the net total revenue generated by these customers 
in last 30 days of transactions from max transaction date available in the data
*/

SELECT SUM(TOTAL_AMT) AS NET_TOT_REVENUE FROM (
SELECT
C.customer_Id, CONVERT(DATE, C.DOB, 103) AS DOB,
CONVERT(DATE, T.tran_date, 103) AS TRAN_DATE,
ROUND(CAST(T.total_amt AS FLOAT),2) AS TOTAL_AMT,
MAX(CONVERT(DATE, T.tran_date, 103)) OVER() AS MAX_TRAN_DATE 
FROM
Customer AS C
INNER JOIN Transactions AS T ON C.customer_Id = T.cust_id 
) ER
WHERE
DATEDIFF(YEAR, DOB, GETDATE()) BETWEEN 25 AND 35 AND
TRAN_DATE >= DATEADD(DAY, -30, MAX_TRAN_DATE)

/*
 Which product category has seen the max value of returns in the last 3 months of transactions? 
*/

SELECT TOP 1 *  FROM (
SELECT W1.prod_cat, SUM(W1.RETURN_VALUE) AS [TOT_AMOUNT(RETURNS)]  FROM (
SELECT 
P.prod_cat, CONVERT(DATE, T.tran_date, 103) AS TRAN_DATE, SUM(CAST(T.total_amt AS numeric)) AS RETURN_VALUE,
MAX(CONVERT(DATE, T.TRAN_DATE, 103)) OVER() AS MAX_TRAN_DATE
FROM
prod_cat_info AS P
INNER JOIN Transactions AS T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
WHERE
T.Qty < 0
GROUP BY
P.prod_cat, CONVERT(DATE, T.tran_date, 103)
) W1
WHERE
TRAN_DATE >= DATEADD(MONTH, -3, MAX_TRAN_DATE)
GROUP BY
  W1.prod_cat
) W2
ORDER BY
[TOT_AMOUNT(RETURNS)] ASC


/*
 Which store type sells the maximum products' by value of sales amount and by quantities sold?
*/

SELECT TOP 1 * FROM (
SELECT
T.Store_type,
SUM(CAST(T.Qty AS FLOAT)) QUANTITIES_SOLD,
SUM(ROUND(CAST(T.total_amt AS FLOAT),2)) AS TOTAL_AMOUNT
FROM
prod_cat_info AS P
INNER JOIN Transactions AS T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code 
GROUP BY
T.Store_type
) E1
ORDER BY
TOTAL_AMOUNT DESC, QUANTITIES_SOLD DESC

/*
 What are the categories for which average revenue is above the overall average?
*/
SELECT * FROM (
SELECT
P.prod_cat, SUM(CAST(T.total_amt AS numeric)) AS TOTAL_AMT, AVG(CAST(T.total_amt AS NUMERIC)) AS AVG_REVENUE 
FROM
prod_cat_info AS P
INNER JOIN Transactions AS T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
GROUP BY
P.prod_cat
)PO
WHERE
AVG_REVENUE > (SELECT AVG(CAST(TOTAL_AMT AS numeric)) FROM Transactions)


/*
 Find the average and total revenue by each sub category for the categories which are among top 5 categories
in terms of quantities sold.
*/

SELECT
P.prod_cat, prod_subcat , SUM(CAST(T.total_amt AS numeric)) AS TOT_REVENUE, AVG(CAST(T.total_amt AS numeric)) AS AVG_REVENUE
FROM
prod_cat_info AS P
INNER JOIN Transactions AS T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
WHERE
P.prod_cat IN ( 
SELECT TOP 5
PR.prod_cat
FROM
prod_cat_info AS PR
INNER JOIN
Transactions AS TR ON PR.prod_cat_code = TR.prod_cat_code AND PR.prod_sub_cat_code = TR.prod_subcat_code
GROUP BY
PR.prod_cat
ORDER BY SUM(CAST(TR.Qty AS numeric)) DESC
)
GROUP BY
P.prod_cat, P.prod_subcat
ORDER BY 
P.prod_cat ASC, P.prod_subcat ASC



--				DATA PREPARATION AND UNDERSTANDING


-- What is the total number of rows in each of the 3 tables in the database

SELECT count(*) FROM Customer UNION ALL
SELECT count(*) FROM prod_cat_info UNION ALL
SELECT count(*) FROM Transactions 

-- What is the total number of transactions that have a return

SELECT
COUNT(QTY) AS TOTAL_RETURNS
FROM
TRANSACTIONS
WHERE
QTY < 1

-- As you would have noticed, the dates provided across the datasets are not in a correct format. As first steps, pls 
--    convert the date variables into valid date formats before proceeding ahead.

SELECT
CONVERT(DATE, C.DOB, 103) AS DOB_NEW, CONVERT(DATE, T.tran_date, 103) AS NEW_TRAN_DATE
FROM
CUSTOMER as C
FULL JOIN
Transactions AS T ON C.customer_Id = T.cust_id


-- What is the time range of transaction data available for analysis? Show the output in number of days, months and 
--    years simultaneously in different columns

SELECT
DATEDIFF(YEAR, MIN(CONVERT(DATE, TRAN_DATE, 103)), MAX(CONVERT(DATE, TRAN_DATE, 103))) TOT_YEARS,
DATEDIFF(MONTH, MIN(CONVERT(DATE, TRAN_DATE, 103)), MAX(CONVERT(DATE, TRAN_DATE, 103))) TOT_MONTHS,
DATEDIFF(DAY, MIN(CONVERT(DATE, TRAN_DATE, 103)), MAX(CONVERT(DATE, TRAN_DATE, 103))) TOT_DAYS
FROM
Transactions

-- Which product category does the sub category "DIY" belong to?

SELECT
PROD_SUBCAT, PROD_CAT
FROM
prod_cat_info
WHERE prod_subcat LIKE 'DIY'








