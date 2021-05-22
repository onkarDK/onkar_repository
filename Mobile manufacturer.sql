use db_SQLCaseStudies

 /*
  List all the states in which we have customers who brought cell phones from 2005 till today
 */

SELECT STATE, COUNT(IDCustomer) AS CNT_OF_CUSTOMERS_POST2005 FROM (
SELECT 
T.IDCustomer, L.STATE, CAST(T.DATE AS date) AS PURCHASE_DATE
FROM 
DIM_LOCATION AS L
INNER JOIN
FACT_TRANSACTIONS AS T ON L.IDLocation = T.IDLocation
INNER JOIN
DIM_DATE AS D ON T.DATE = D.DATE
) QQ
WHERE
DATEPART(YEAR, PURCHASE_DATE) >= 2005
GROUP BY
STATE

/*
 What state in the US is buying more "Samsung" cell phones?
*/

SELECT 
L.State, MA.Manufacturer_Name, COUNT(T.IDCustomer) AS CNT_CUSTOMERS
FROM 
DIM_LOCATION AS L
INNER JOIN 
FACT_TRANSACTIONS AS T ON L.IDLocation = T.IDLocation
INNER JOIN 
DIM_MODEL AS MO ON T.IDModel = MO.IDModel
INNER JOIN 
DIM_MANUFACTURER AS MA ON MO.IDManufacturer = MA.IDManufacturer
WHERE 
L.Country = 'US' AND MA.Manufacturer_Name LIKE 'SAMSUNG' 
Group BY
L.State, MA.Manufacturer_Name
ORDER BY
CNT_CUSTOMERS DESC


/*
 Show the number of Transactions for each model per zip code per state. 
*/

SELECT
M.Model_Name, L.State, L.ZipCode, COUNT(T.IDCustomer) AS NO_OF_TRANSACTIONS
FROM
DIM_LOCATION AS L
INNER JOIN FACT_TRANSACTIONS AS T ON L.IDLocation = T.IDLocation
INNER JOIN DIM_MODEL AS M ON T.IDModel = M.IDModel
GROUP BY
M.Model_Name, L.State, L.ZipCode
 
/*
 Show the cheapest cellphone.
*/

SELECT
TOP 1
 Model_Name, MIN(Unit_price) AS UNIT_PRICE
FROM
DIM_MODEL
GROUP BY
Model_Name
ORDER BY
UNIT_PRICE

 SELECT TOP 1 * FROM DIM_CUSTOMER

/*
 Find out the average price for each model in top5 manufacturers in terms of sales quantity and order by
average price
*/

SELECT MA.Manufacturer_Name, MO.Model_Name, SUM(T.TotalPrice) / SUM(T.Quantity) AS AVG_PRICE
FROM
DIM_MANUFACTURER AS MA
INNER JOIN
DIM_MODEL AS MO ON MA.IDManufacturer = MO.IDManufacturer
INNER JOIN 
FACT_TRANSACTIONS AS T ON MO.IDModel= T.IDModel
WHERE
Manufacturer_Name IN (
SELECT TOP 5 
MA.Manufacturer_Name 
FROM DIM_MANUFACTURER AS MA INNER JOIN DIM_MODEL AS MO ON MA.IDManufacturer = MO.IDManufacturer 
INNER JOIN FACT_TRANSACTIONS AS T ON MO.IDModel = T.IDModel 
GROUP BY 
MA.Manufacturer_Name 
ORDER BY SUM(T.Quantity) DESC
)
GROUP BY
MA.Manufacturer_Name, MO.Model_Name
ORDER BY
AVG_PRICE

/*
 List the names of the customers and the average amount spent in 2009, where the average is higher than 500
*/

SELECT 
C.Customer_Name, YEAR(T.Date) AS YEAR, AVG(T.TotalPrice) AS AVERAGE_SPEND
FROM
DIM_CUSTOMER AS C
INNER JOIN FACT_TRANSACTIONS AS T ON C.IDCustomer = T.IDCustomer
GROUP BY
C.Customer_Name, YEAR(T.Date)
HAVING 
YEAR(T.Date) = 2009 AND AVG(T.TotalPrice) > 500


/*
 List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010 . 
*/
SELECT * FROM ( 
SELECT Model_Name, COUNT(Model_Name) AS CNT_2008_9_10 FROM (
SELECT * FROM (
SELECT 
*,
RN = ROW_NUMBER() OVER (PARTITION BY BUY_YEAR ORDER BY TOT_QTY DESC) 
FROM (
SELECT
M.Model_Name, YEAR(T.Date) AS BUY_YEAR, SUM(T.Quantity) AS TOT_QTY
FROM
DIM_MODEL AS M
INNER JOIN FACT_TRANSACTIONS AS T ON M.IDModel = T.IDModel
GROUP BY
M.Model_Name, YEAR(T.Date)
HAVING
YEAR(T.Date) IN (2008, 2009, 2010)
)A1
) A2
WHERE RN IN (1,2,3,4,5)
)A3
GROUP BY
Model_Name
)A4
WHERE
CNT_2008_9_10 >= 3

/*
 Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in 
    the year of 2010
	*/
SELECT * FROM(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY YEAR ORDER BY TOT_SALES DESC) AS SALES_RANK
FROM (
SELECT
MA.Manufacturer_Name, D.YEAR, SUM(T.TotalPrice) AS TOT_SALES
FROM
DIM_DATE AS D
INNER JOIN FACT_TRANSACTIONS AS T ON D.DATE = T.Date
INNER JOIN DIM_MODEL AS MO ON T.IDModel = MO.IDModel
INNER JOIN DIM_MANUFACTURER AS MA ON MO.IDManufacturer = MA.IDManufacturer
WHERE
D.YEAR IN ('2009', '2010')
GROUP BY 
MA.Manufacturer_Name, D.YEAR
) WQ
)WE
WHERE
SALES_RANK = 2

/*
 Show the manufacturerS that sold cellphone in 2010 but didn't in 2009.
*/
SELECT E3.Manufacturer_Name FROM (
SELECT E2.Manufacturer_Name, COUNT(E2.Manufacturer_Name) AS CNT FROM (
SELECT
MA.Manufacturer_Name, D.YEAR
FROM
DIM_MANUFACTURER AS MA
INNER JOIN DIM_MODEL AS MO ON MA.IDManufacturer = MO.IDManufacturer
INNER JOIN FACT_TRANSACTIONS AS T ON MO.IDModel = T.IDModel
INNER JOIN DIM_DATE AS D ON T.Date = D.DATE
WHERE
D.YEAR IN ('2009', '2010')
GROUP BY
MA.Manufacturer_Name, D.YEAR
) E2
GROUP BY
E2.Manufacturer_Name
) E3
WHERE
CNT = 1
GROUP BY
E3.Manufacturer_Name

/*
 Find top 10 customers and their average spend, average quantity by each year. Also find the 
     percentage of change in their spend
*/

SELECT TOP 10
Customer_Name, YEAR, AVG_QTY, AVG_SPEND,
CASE WHEN NEWQ IS NULL THEN NULL 
ELSE (TOT_PRICE - NEWQ) / (NEWQ)
END AS [%CHANGE_SPEND] 
FROM (
SELECT *, 
lag(TOT_PRICE) OVER (PARTITION BY CUSTOMER_NAME ORDER BY CUSTOMER_NAME) AS NEWQ
FROM (
SELECT
C.Customer_Name, YEAR(T.Date) AS YEAR, AVG(T.Quantity) AS AVG_QTY, AVG(T.TotalPrice) AS AVG_SPEND, SUM(T.TotalPrice) AS TOT_PRICE
FROM
DIM_CUSTOMER AS C
INNER JOIN FACT_TRANSACTIONS AS T ON C.IDCustomer = T.IDCustomer
GROUP BY
C.Customer_Name, YEAR(T.Date)
) Ee3
)EE4
ORDER BY
AVG_SPEND desc





