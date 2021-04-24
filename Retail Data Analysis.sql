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

SELECT count(*) AS RECORDS_CUSTOMER FROM Customer 
SELECT count(*) AS RECORDS_prod_cat_info FROM prod_cat_info 
SELECT count(*) AS RECORDS_Transactions FROM Transactions 

--Q2) What is the total number of transactions that have a return

SELECT
COUNT(QTY) AS TOTAL_RETURNS
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

SELECT SUM(TOT_REVENUE) AS [TOT_FLAG_REVENUE_ELEC + CLOTH] FROM (
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


--Q9) What is the total revenue generated from  "Male" customers in "Electronics" category ? Output should 
--    display total revenue by prod sub-cat.


SELECT
PROD_SUBCAT AS SUBCAT_OF_ELECTRONICS,
SUM(CAST(RATE AS numeric)) AS TOT_REV_M
FROM
Customer AS T1
INNER JOIN Transactions AS T2 ON T1.customer_Id = T2.cust_id
INNER JOIN prod_cat_info AS T3 ON T2.prod_cat_code = T3.prod_cat_code AND T2.prod_subcat_code = T3.prod_sub_cat_code
WHERE
prod_cat = 'Electronics' AND Gender = 'M' 
GROUP BY
PROD_SUBCAT





/*
Q10) What is percentage of sales and returns by product sub category ; display only top 5 sub categories in terms of sales?
*/

SELECT TOP 5
P.prod_subcat AS SUBCATEGORY,
(SUM(CAST(CASE WHEN T.Rate > 0 THEN T.RATE END AS NUMERIC))) / (SUM(ABS(CAST(T.RATE AS INT)))) AS [% SALES],
(SUM(ABS(CAST(CASE WHEN T.Rate < 0 THEN T.RATE END AS NUMERIC)))) / (SUM(ABS(CAST(T.RATE AS int)))) AS [% RETURN]
FROM 
prod_cat_info AS P
INNER JOIN 
Transactions AS T ON P.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
GROUP BY
P.PROD_SUBCAT
ORDER BY
[% SALES] DESC



SELECT TOP 5
P.prod_subcat AS SUBCATEGORIES,
((SUM(CAST(CASE WHEN T.RATE > 0 THEN T.RATE END AS NUMERIC))) / 
((SUM(CAST(CASE WHEN T.RATE > 0 THEN T.RATE END AS NUMERIC))) - 
(SUM(CAST(CASE WHEN T.RATE < 0 THEN T.RATE END AS NUMERIC))))) AS [%SALES],
((SUM(CAST(CASE WHEN T.RATE < 0 THEN T.RATE END AS NUMERIC))) / 
((SUM(CAST(CASE WHEN T.RATE > 0 THEN T.RATE END AS NUMERIC))) - 
(SUM(CAST(CASE WHEN T.RATE < 0 THEN T.RATE END AS NUMERIC))))) AS [%RETURN]
FROM
prod_cat_info AS P
INNER JOIN Transactions AS T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
GROUP BY
P.prod_subcat
ORDER BY
[%SALES] DESC




SELECT
P.prod_subcat, T.Qty, T.Rate
FROM
prod_cat_info AS P
INNER JOIN Transactions AS T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
ORDER BY 
P.prod_subcat 






SELECT  
PROD_SUBCAT, T.Rate 
CASE WHEN T.QTY > 0 THEN SUM(CAST(T.RATE AS FLOAT)) END AS E1 / ( SELECT SUM(CAST(RATE AS FLOAT)) FROM Transactions),
CASE WHEN T.QTY < 0 THEN SUM(CAST(T.RATE AS FLOAT)) END AS E2 / ( SELECT SUM(CAST(RATE AS FLOAT)) FROM Transactions)
FROM
prod_cat_info AS P
INNER JOIN Transactions AS T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
GROUP BY 
PROD_SUBCAT, Rate
ORDER BY 
Rate

select
[Subcategory] = P.prod_subcat,
[Sales] =   Round(SUM(cast( case when T.Qty > 0 then total_amt else 0 end as numeric)),2) , 
[Returns] = Round(SUM(cast( case when T.Qty < 0 then total_amt else 0 end as numeric)),2) , 
[Profit] =  Round(SUM(cast(total_amt as numeric)),2) 
from Transactions as T
INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_sub_cat_code
group by P.prod_subcat







SELECT * FROM Customer
--SELECT * FROM prod_cat_info
SELECT *  FROM Transactions

/*
For all customers aged between 25 to 35 years find what is the net total revenue generated by these customers 
in last 30 days of transactions from max transaction date available in the data
*/

SELECT * FROM (


SELECT 
c.customer_Id,
SUM(CAST(T.RATE AS float)) AS NET_REVENUE,
DATEDIFF(YEAR, CONVERT(DATE, C.DOB, 103), getdate()) AS AGE,
(CONVERT(DATE, T.tran_date, 103)) AS DT1
FROM
Customer AS C
INNER JOIN Transactions AS T ON C.customer_Id = T.cust_id
WHERE 
DATEDIFF(YEAR, CONVERT(DATE, C.DOB, 103), getdate()) BETWEEN 25 AND 35
GROUP BY
c.customer_Id,
DATEDIFF(YEAR, CONVERT(DATE, C.DOB, 103), getdate()),
(CONVERT(DATE, T.tran_date, 103))
HAVING
(CONVERT(DATE, T.tran_date, 103)) > DATEADD(DAY, -30, MAX(CONVERT(DATE, T.tran_date, 103)))

) RE3
WHERE
DT1 > DATEADD(DAY, -30, MAX(DT1))



SELECT
*
FROM
Customer AS C
INNER JOIN Transactions AS T ON C.customer_Id = T.cust_id
WHERE
C.customer_Id = '266784'


/*
Q11) For all customers aged between 25 to 35 years find what is the net total revenue generated by these customers 
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
Q12) Which product category has seen the max value of returns in the last 3 months of transactions? 
*/

--VERIFY THE ANSWERS

SELECT * FROM (
SELECT PROD_CAT, RETURN_ORDERS, ROW_NUMBER() OVER(ORDER BY RETURN_ORDERS ASC) AS RETURN_RANKING FROM (
SELECT PROD_CAT, SUM(QTY) AS RETURN_ORDERS FROM(
SELECT
P.prod_cat AS PROD_CAT,
CONVERT(DATE, T.TRAN_DATE, 103) AS TRAN_DATE,
MAX(CONVERT(DATE, T.TRAN_DATE, 103)) OVER() AS MAX_TRAN_DATE,
CAST(T.Qty AS numeric) AS QTY
FROM
prod_cat_info AS P
INNER JOIN Transactions AS T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
) R1
WHERE
QTY < 0
GROUP BY 
PROD_CAT
) R2
)R3
WHERE
RETURN_RANKING = 1



/*
Q13) Which store type sells the maximum products' by value of sales amount and by quantities sold?
*/
SELECT TOP 2 * FROM Transactions


SELECT Store_type, SUM(ROUND(TOTAL_AMOUNT,2)) AS TOT_SALES, SUM(QUANTITIES_SOLD) AS TOT_QUANTITIES_SOLD FROM (
SELECT
T.Store_type,
SUM(CAST(T.Qty AS FLOAT)) QUANTITIES_SOLD,
SUM(ROUND(CAST(T.total_amt AS FLOAT),2)) AS TOTAL_AMOUNT
FROM
prod_cat_info AS P
INNER JOIN Transactions AS T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code 
GROUP BY
T.Store_type,
CAST(T.Qty AS FLOAT)
)Q1
GROUP BY
Store_type
ORDER BY 
TOT_SALES DESC, TOT_QUANTITIES_SOLD






/*
Q14) What are the categories for which average revenue is above the overall average?
*/
SELECT * FROM (
SELECT
P.prod_cat, SUM(CAST(T.total_amt AS numeric)) AS TOTAL_AMT, AVG(CAST(T.total_amt AS NUMERIC)) AS AVG_CAT 
FROM
prod_cat_info AS P
INNER JOIN Transactions AS T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
GROUP BY
P.prod_cat
)PO
WHERE
AVG_CAT > (SELECT AVG(CAST(TOTAL_AMT AS numeric)) FROM Transactions)

--SELECT * FROM Customer
SELECT TOP 2 * FROM prod_cat_info
SELECT TOP 2 * FROM Transactions

/*
Q15) Find the average and total revenue by each sub category for the categories which are among top 5 categories
in terms of quantities sold.
*/

SELECT TOP 5 *,
ROW_NUMBER () OVER (ORDER BY QUANTITIES_SOLD ) as RANK_QUANTITIES_SOLD
FROM (
SELECT
P.prod_cat,P.prod_subcat , SUM(CAST(T.total_amt AS numeric)) AS TOT_REVENUE, AVG(CAST(T.total_amt AS numeric)) AS AVG_REVENUE,
SUM(CAST(T.Qty AS numeric)) AS QUANTITIES_SOLD
FROM
prod_cat_info AS P
INNER JOIN Transactions AS T ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
GROUP BY
P.prod_cat,P.prod_subcat
) NB

 





