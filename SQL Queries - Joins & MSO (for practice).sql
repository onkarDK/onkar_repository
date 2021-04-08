  SELECT * FROM TBL_STUDENT
  SELECT * FROM TBL_COURSE
  SELECT * FROM TBL_MAPPING
 

/*************************** QUESTIONS FROM JOINS DATA **********************************/
--Q1: Display student details and the courses they are enrolled to.
 SELECT
TBL_STUDENT.*,
TBL_COURSE.*
FROM
TBL_STUDENT
LEFT JOIN TBL_MAPPING ON TBL_STUDENT.STU_ID = TBL_MAPPING.STU_ID
LEFT JOIN TBL_COURSE ON TBL_COURSE.COURSE_ID = TBL_MAPPING.COURSE_ID
--Q2: Display details of all students and the count of courses they are enrolled to.
SELECT
TBL_STUDENT.STU_ID,	NAME,	DOB,	PHONE_CUS,	EMAIL_CUS, COUNT(TBL_MAPPING.STU_ID) AS CNT_OF_COURSES
FROM
TBL_STUDENT 
LEFT JOIN TBL_MAPPING ON TBL_STUDENT.STU_ID = TBL_MAPPING.STU_ID
GROUP BY
TBL_STUDENT.STU_ID,	NAME,	DOB,	PHONE_CUS,	EMAIL_CUS



--Q3: Display details of students which are not yet enrolled to any course.

SELECT
*
FROM
TBL_STUDENT
LEFT JOIN TBL_MAPPING ON TBL_STUDENT.STU_ID = TBL_MAPPING.STU_ID
WHERE
COURSE_ID IS NULL 

SELECT
TBL_STUDENT.STU_ID,	NAME, DOB, PHONE_CUS, EMAIL_CUS, COUNT(TBL_MAPPING.COURSE_ID) AS COURSE_COUNT
FROM
TBL_STUDENT
LEFT JOIN TBL_MAPPING ON TBL_STUDENT.STU_ID = TBL_MAPPING.STU_ID
GROUP BY
TBL_STUDENT.STU_ID,	NAME, DOB, PHONE_CUS, EMAIL_CUS
HAVING
COUNT(TBL_MAPPING.COURSE_ID) < 1


--Q4: List all courses and the count of students enrolled to each course.
SELECT 
*
FROM
TBL_STUDENT
SELECT
*
FROM TBL_COURSE
SELECT 
*
FROM
TBL_MAPPING


SELECT
TBL_COURSE.NAME, COUNT(TBL_MAPPING.STU_ID) AS CNT_STUDENTS
FROM
TBL_COURSE
LEFT JOIN TBL_MAPPING ON TBL_COURSE.COURSE_ID = TBL_MAPPING.COURSE_ID
GROUP BY
NAME


/************************* QUESTIONS FROM MSO DATABASE **********************************/
 SELECT * FROM TBL_CUSTOMER
 SELECT * FROM TBL_HOUSE
 SELECT * FROM TBL_WORK_ORDER
 SELECT * FROM TBL_COMPLAINT_ORDER
 SELECT * FROM TBL_ORDER_ITEM

--Q1: In order to post welcome letters and user guides to customers, dispatch team need 
--    customer name, address and contact details. Write SQL query to get desired info.
SELECT
CONCAT(FNAME_CUS, ' ', LNAME_CUS) AS CUS_NAME, 
PHONE_CUS AS PH_NUMBER,

CONCAT(ADDRESS_HSE, ' ', CITY_HSE, COUNTRY_HSE ) AS CUS_ADDRESS

FROM
TBL_CUSTOMER
INNER JOIN TBL_HOUSE ON CUST_ID_CUS = CUST_ID_HSE



--Q2: Get the details of customers who are using our services in more than one location.

SELECT
CUST_ID_CUS,
CONCAT(FNAME_CUS, ' ', LNAME_CUS), 
PHONE_CUS,
COUNT(HOUSE_ID_HSE) AS CNT_LOC
FROM
TBL_CUSTOMER
INNER JOIN TBL_HOUSE ON CUST_ID_CUS = CUST_ID_HSE
GROUP BY 
CUST_ID_CUS,
CONCAT(FNAME_CUS, ' ', LNAME_CUS), 
PHONE_CUS
HAVING
COUNT(HOUSE_ID_HSE) > 1

--Q3: Which are the customers that have not given their house details.
SELECT
CUST_ID_CUS,
CONCAT(FNAME_CUS, ' ', LNAME_CUS) AS C_NAME,
PHONE_CUS AS PH_NUMBER
FROM
TBL_CUSTOMER
LEFT JOIN TBL_HOUSE ON CUST_ID_CUS = CUST_ID_HSE
WHERE
HOUSE_ID_HSE IS NULL

SELECT
CUST_ID_CUS,
CONCAT(FNAME_CUS, ' ', LNAME_CUS) AS C_NAME,
PHONE_CUS AS P_NUMBER,
COUNT(HOUSE_ID_HSE) AS CNT_LOCATION
FROM
TBL_CUSTOMER
LEFT JOIN TBL_HOUSE ON CUST_ID_CUS = CUST_ID_HSE
GROUP BY
CUST_ID_CUS,
CONCAT(FNAME_CUS, ' ', LNAME_CUS),
PHONE_CUS
HAVING
COUNT(HOUSE_ID_HSE) = 0

--Q4: Get the install dates corresponding to all customers in different locations.
SELECT
ADDRESS_HSE + ',' + CITY_HSE + ',' + COUNTRY_HSE AS CUS_ADDRESS,
COMPL_DTE_WO
FROM
TBL_HOUSE
INNER JOIN TBL_WORK_ORDER ON CUST_ID_HSE = CUST_ID_WO AND HOUSE_ID_HSE = HOUSE_ID_WO
WHERE
TYPE_WO = 'INSTALL' AND STATUS_WO= 'CLOSE'




--Q5: Get the location details along with count of services installed in the location.
SELECT
ADDRESS_HSE + ',' + CITY_HSE + ',' + COUNTRY_HSE AS CUS_ADDRESS,
COMPL_DTE_WO AS INSTALL_DATE,
COUNT(ORD_ID_ITM) AS CNT_OF_SERVICES
FROM 
TBL_HOUSE
INNER JOIN TBL_WORK_ORDER ON HOUSE_ID_HSE = HOUSE_ID_WO AND CUST_ID_HSE = CUST_ID_WO
INNER JOIN TBL_ORDER_ITEM ON ORD_ID_WO = ORD_ID_ITM
WHERE
TYPE_WO ='INSTALL' AND STATUS_WO = 'CLOSE'
GROUP BY 
ADDRESS_HSE + ',' + CITY_HSE + ',' + COUNTRY_HSE, COMPL_DTE_WO 





--Q6: Get the customer name and contact details of the customers along with other info 
--   extracted in Q4 above.
SELECT
FNAME_CUS + ' ' + LNAME_CUS AS CUST_NAME,
PHONE_CUS AS PH_NUMBER,
ADDRESS_HSE + ',' + CITY_HSE + ',' + COUNTRY_HSE AS CUS_ADDRESS,
COMPL_DTE_WO AS INSTALL_DATE,
COUNT(ORD_ID_ITM) AS CNT_OF_SERVICES
FROM 
TBL_CUSTOMER
INNER JOIN TBL_HOUSE ON CUST_ID_CUS = CUST_ID_HSE
INNER JOIN TBL_WORK_ORDER ON HOUSE_ID_HSE = HOUSE_ID_WO AND CUST_ID_HSE = CUST_ID_WO
INNER JOIN TBL_ORDER_ITEM ON ORD_ID_WO = ORD_ID_ITM
WHERE
TYPE_WO ='INSTALL' AND STATUS_WO = 'CLOSE'
GROUP BY 
FNAME_CUS + ' ' + LNAME_CUS,
PHONE_CUS,
ADDRESS_HSE + ',' + CITY_HSE + ',' + COUNTRY_HSE, COMPL_DTE_WO 



--Q7: Location details where install orders are in open state.
SELECT
*
FROM
TBL_HOUSE
INNER JOIN TBL_WORK_ORDER ON CUST_ID_HSE = CUST_ID_WO AND HOUSE_ID_HSE = HOUSE_ID_WO
WHERE
TYPE_WO= 'INSTALL' AND STATUS_WO= 'CLOSE'

--Q8: Are their any customers who have made a complaint more than once?
SELECT COUNT(*) AS NO_OF_CUSTOMERS FROM (
SELECT
CUST_ID_CO, COUNT(CUST_ID_CO) AS COUNT_CO
FROM
TBL_COMPLAINT_ORDER
GROUP BY 
CUST_ID_CO
HAVING
COUNT(CUST_ID_CO) > 1
) T1

--Q9: Count total open orders in the available data.

SELECT COUNT(*) AS TOT_OPEN_ORDER FROM (
SELECT
*
FROM
TBL_COMPLAINT_ORDER
WHERE
STATUS_CO = 'OPEN'
UNION ALL
SELECT
*
FROM TBL_WORK_ORDER
WHERE
STATUS_WO = 'OPEN'
) T2




SELECT * FROM TBL_CUSTOMER
 SELECT * FROM TBL_HOUSE
 SELECT * FROM TBL_WORK_ORDER
 SELECT * FROM TBL_COMPLAINT_ORDER
 SELECT * FROM TBL_ORDER_ITEM

--Q10: Are there any location ids where we have open service orders for disconnection and open complaint orders?

--WITH INTERSECT
SELECT
HOUSE_ID_WO
FROM
TBL_WORK_ORDER
WHERE
TYPE_WO LIKE 'DISCO%' AND STATUS_WO = 'OPEN'
INTERSECT
SELECT
HOUSE_ID_CO
FROM
TBL_COMPLAINT_ORDER


-- WITH ORDINARY SUBQUERY
SELECT
HOUSE_ID_WO
FROM
TBL_WORK_ORDER
WHERE TYPE_WO LIKE 'DISCO%' AND STATUS_WO = 'OPEN' AND HOUSE_ID_WO IN (
SELECT HOUSE_ID_CO FROM TBL_COMPLAINT_ORDER WHERE STATUS_CO = 'OPEN')

-- WITH JOIN

--Q11: Locations where customers have never given any complaints but discontinued the services.

--EXCEPT
SELECT
HOUSE_ID_WO
FROM
TBL_WORK_ORDER
WHERE 
TYPE_WO LIKE 'DISC%' 
EXCEPT
SELECT
HOUSE_ID_CO
FROM
TBL_COMPLAINT_ORDER

-- SUBQUERY
SELECT
HOUSE_ID_WO
FROM
TBL_WORK_ORDER
WHERE
TYPE_WO LIKE 'DISC%' AND HOUSE_ID_WO NOT IN (
SELECT HOUSE_ID_CO FROM TBL_COMPLAINT_ORDER)


--Q12: List down the customers and no of total (WO + Complaints) orders placed by them 
SELECT
CUST_ID_CUS, FNAME_CUS, LNAME_CUS, PHONE_CUS, EMAIL_CUS, ORD_ID_WO, COUNT(ORD_ID_WO) AS CNT_ORDERS
FROM
TBL_CUSTOMER
LEFT JOIN(
SELECT
*
FROM
TBL_WORK_ORDER
UNION ALL
SELECT
*
FROM
TBL_COMPLAINT_ORDER) AS T1 ON CUST_ID_CUS = CUST_ID_WO
GROUP BY
CUST_ID_CUS, FNAME_CUS, LNAME_CUS, PHONE_CUS, EMAIL_CUS, ORD_ID_WO



SELECT
CUST_ID_CUS, FNAME_CUS, LNAME_CUS, PHONE_CUS, EMAIL_CUS, ORD_ID_WO, COUNT(ORD_ID_WO) AS CNT_ORDERS,
COUNT(CASE WHEN TYPE_WO LIKE 'DISCO%' THEN ORD_ID_WO END) AS CNT_DISC
FROM
TBL_CUSTOMER
LEFT JOIN(
SELECT
*
FROM
TBL_WORK_ORDER
UNION ALL
SELECT
*
FROM
TBL_COMPLAINT_ORDER) AS T1 ON CUST_ID_CUS = CUST_ID_WO
GROUP BY
CUST_ID_CUS, FNAME_CUS, LNAME_CUS, PHONE_CUS, EMAIL_CUS, ORD_ID_WO