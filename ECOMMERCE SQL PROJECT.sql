use project;

-- PRINT THE OVERALL REVENUE MADE BY THE E-COMMERCE COMPANY */
SELECT * FROM ORDERS;

SELECT 
    ROUND(SUM(TOTAL_ORDER_AMOUNT) / 1000000 * 2, 2) AS REVENUE_IN_MILLION
FROM
    ORDERS;


--  PRINT THE ORDER DETAILS BETWEEN 10000 AND 20000 AND THEN SORT THE DATA IN ASC ORDER ON ORDER ID COLUMN */

SELECT 
    *
FROM
    ORDERS
WHERE
    TOTAL_ORDER_AMOUNT BETWEEN 10000 AND 20000
ORDER BY ORDERID ASC;

--  FIND THE NUMBER OF CUSTOMERS BELONGING TO THE CITY OF EVERY COUNTRY. PRINT CITY, COUNTRY AND NUMBER OF THE CUSTOMER TO EACH CITY AND COUNTRY (COMBINATION). */

SELECT 
    COUNT(DISTINCT (CUSTOMERID)) AS CUST_NO, COUNTRY, CITY
FROM
    CUSTOMERS
GROUP BY COUNTRY , CITY
ORDER BY CUST_NO DESC;


--  FIND THE NUMBER OF CUSTOMERS BELONGING TO THE CITY OF EVERY COUNTRY. PRINT CITY, COUNTRY AND NUMBER OF THE CUSTOMER TO EACH CITY AND COUNTRY where customers are less than 3) */

SELECT 
    COUNT(DISTINCT (CUSTOMERID)) AS CUST_NO, COUNTRY, CITY
FROM
    CUSTOMERS
GROUP BY COUNTRY , CITY
HAVING CUST_NO < 3
ORDER BY CUST_NO DESC;

-- Details of the customers where first_name starts with a vowel. sort the results in ascending order on customer id */

SELECT 
    *
FROM
    customers
WHERE
    firstname REGEXP '^[AEIOUaeiou]'
ORDER BY customerid ASC;


-- Count the number of orders placed through each payment method. Print the paymentid, payment type and number of orders placed. Sort the output in asc on paymentid column

SELECT 
    COUNT(DISTINCT (O.ORDERID)) AS 'NO_OF_ORDERS',
    P.PAYMENTID,
    P.PAYMENTTYPE
FROM
    ORDERS O
        INNER JOIN
    payments P ON P.PAYMENTID = O.PaymentID
GROUP BY P.PAYMENTID , P.PAYMENTTYPE
ORDER BY P.PAYMENTID;

-- IDENTIFY THE TOP 10 MOST EXPENSIVE ORDERS. PRINT CUSTOMER ID, FIRST NAME, LAST NAME AND TOTAL ORDER AMOUNT AND THEN SORT IN IT IN DESC ORDER ON TOTA

SELECT 
    C.CUSTOMERID,
    C.FIRSTNAME,
    C.LASTNAME,
    MAX(O.TOTAL_ORDER_AMOUNT) AS AMOUNT
FROM
    ORDERS O
        JOIN
    CUSTOMERS C ON C.CUSTOMERID = O.CUSTOMERID
GROUP BY C.CUSTOMERID , C.FIRSTNAME , C.LASTNAME
ORDER BY AMOUNT DESC
LIMIT 10;

-- PRINT ALL THE DETAILS OF THE CUSTOMER WHO ORDERED ONLY ONCE.

WITH CUST_COUNT AS
(SELECT CUSTOMERID, COUNT(CUSTOMERID) AS 'COUNT_OF_ORDERS'
FROM ORDERS
GROUP BY CUSTOMERID
HAVING COUNT(CUSTOMERID) = 1) 
SELECT C.* FROM CUSTOMERS C 
INNER JOIN CUST_COUNT 
ON CUST_COUNT.CUSTOMERID=C.CUSTOMERID;

-- IDENTIFY THE TOP 3 COUNTRIES WHO HAVE PLACED THE LEAST NUMBER OF THE ORDERS AND THEN SORT THE OUTPUT IN DESC ORDER BASED ON NUMBER OF THE ORDERS

SELECT 
    CUSTOMERS.COUNTRY,
    COUNT(DISTINCT (ORDERS.ORDERID)) AS ORDER_COUNT
FROM
    ORDERS
        JOIN
    CUSTOMERS ON CUSTOMERS.CUSTOMERID = ORDERS.CUSTOMERID
GROUP BY CUSTOMERS.COUNTRY
ORDER BY ORDER_COUNT ASC
LIMIT 3;

-- PRINT THE COUNTRY AND NUMBER OF THE ORDERS
SELECT 
    CUSTOMERS.COUNTRY,
    COUNT(DISTINCT (ORDERS.ORDERID)) AS ORDER_COUNT
FROM
    ORDERS
        JOIN
    CUSTOMERS ON CUSTOMERS.CUSTOMERID = ORDERS.CUSTOMERID
GROUP BY CUSTOMERS.COUNTRY
ORDER BY ORDER_COUNT DESC;


--  TOTAL_ORDER_AMOUNT, TOTAL REVENUE, TOTAL PROFIT AND PROFIT MARGIN FOR EACH ORDER ID
SELECT 
    O.ORDERID,
    O.TOTAL_ORDER_AMOUNT,
    SUM(O.TOTAL_ORDER_AMOUNT * OD.Quantity) AS REVENUE,
    (SUM(O.TOTAL_ORDER_AMOUNT * OD.Quantity) - O.TOTAL_ORDER_AMOUNT) AS PROFIT,
    ROUND((SUM(O.TOTAL_ORDER_AMOUNT * OD.Quantity) - O.TOTAL_ORDER_AMOUNT) / SUM(O.TOTAL_ORDER_AMOUNT * OD.Quantity) * 100,
            2) AS PROFIT_MARGIN
FROM
    ORDERS O
        JOIN
    ORDERDETAILS OD ON O.ORDERID = OD.ORDERID
GROUP BY O.ORDERID , O.TOTAL_ORDER_AMOUNT
ORDER BY REVENUE DESC;

-- PRINT THE DETAILS OF ALL DIFFERENT PAYMENT METHODS ALONGWITH THE TOTAL AMOUNT OF MONEY TRANSACTED IN YEAR 2020 AND 2021. PRINT THE PAYMENT TYPE, ALLOWED
-- TRANSACTION VALUE IN 2020, 2021 AND THE SORT THE OUTPUT IN THE ASC ORDER OF PAYMENT TYPE

SELECT 
    (P.PAYMENTTYPE) AS PAYMENT_TYPE,
    P.ALLOWED,
    SUM(CASE
        WHEN YEAR(O.ORDERDATE) = 2021 THEN O.TOTAL_ORDER_AMOUNT
    END) AS '2021 TRANSACTION',
    SUM(CASE
        WHEN YEAR(O.ORDERDATE) = 2020 THEN O.TOTAL_ORDER_AMOUNT
    END) AS '2020 TRANSACTION'
FROM
    PAYMENTS P
        JOIN
    ORDERS O ON P.PAYMENTID = O.PAYMENTID
GROUP BY P.PaymentType , P.Allowed
ORDER BY P.PaymentType;


-- PRINT THE PRODUCT_ID, QUANTITY AND ORDER DATE FOR DAILY TOP 3 SELLING PRODUCTS BETWEEN JAN 2020 TO MARCH 2020 AND THEN SORT RESULTS IN ASC ORDER OF ORDER DATE, ASC ORDER OF QUANTITY

WITH PRODUCT_ORDERDATE AS (
SELECT PRODUCTID, SUM(QUANTITY) AS 'TOTAL_Q', ORDERDATE
FROM Orders O 
JOIN OrderDetails OD
ON O.OrderID = OD.OrderID 
WHERE ORDERDATE BETWEEN '2020-01-01' AND '2020-03-31'
GROUP BY ProductID, OrderDate)
SELECT PRODUCTID, TOTAL_Q, ORDERDATE FROM
(SELECT PRODUCTID, TOTAL_Q, ORDERDATE, DENSE_RANK() OVER (PARTITION BY ORDERDATE ORDER BY TOTAL_Q DESC) AS 'RNK' FROM PRODUCT_ORDERDATE) AS X
WHERE RNK <= 3
ORDER BY ORDERDATE, TOTAL_Q;

-- IDENTIFY THE PRODUCTS WHOSE NAMES CONSISTS OF THE WORD 'BABY'. THEN COUNT THE NUMBER FOR EACH CATEGORY AND SUB CATEGORY.
-- PRINT CATEGORY_ID, CATEGORY NAME, SUB CATEGORY AND FOLLOWED BY THE COUNT AND THEN SORT THE OUTOUT ON THE BASIS OF CATEGORY ID IN ASC, FOLLOWED BY SUB

SELECT 
    C.CATEGORYID,
    C.CATEGORYNAME,
    PRODUCTS.SUB_CATEGORY,
    COUNT(C.CATEGORYID) AS PRODUCT_COUNT
FROM
    CATEGORY C
        LEFT JOIN
    PRODUCTS ON C.CategoryID = PRODUCTS.Category_ID
WHERE
    C.CATEGORYNAME LIKE 'BABY%'
GROUP BY C.CategoryID , C.CategoryName , PRODUCTS.Sub_Category
ORDER BY C.CategoryID;

-- TOP 5 CUSTOMERS WITH HIGHEST SPENDING
WITH CUSTOMER_SPENDING AS (
SELECT 
C.FIRSTNAME,
C.LASTNAME,
SUM(O.TOTAL_ORDER_AMOUNT) AS TOTAL_SPENDING
FROM CUSTOMERS C JOIN ORDERS O
ON C.CUSTOMERID = O.CUSTOMERID
GROUP BY 
C.FIRSTNAME,
C.LASTNAME
)
SELECT 
FIRSTNAME,
LASTNAME,
TOTAL_SPENDING
FROM 
CUSTOMER_SPENDING
ORDER BY TOTAL_SPENDING DESC
LIMIT 5;

-- most popular product category in terms of the number of orders placed.

WITH PRODUCTSORDER AS (
    SELECT 
        P.CATEGORY_ID,
        COUNT(OD.OrderID) AS ORDERCOUNT
    FROM 
        PRODUCTS P
        JOIN ORDERDETAILS OD ON P.PRODUCTID = OD.PRODUCTID
    GROUP BY 
        P.CATEGORY_ID
)
SELECT 
    C.CATEGORYNAME,
    PO.ORDERCOUNT
FROM 
    PRODUCTSORDER PO
    JOIN CATEGORY C ON PO.CATEGORY_ID = C.CATEGORYID
ORDER BY 
    PO.ORDERCOUNT DESC
LIMIT 1;

-- total sales for each product category

WITH CATEGORYSALES AS (
    SELECT 
        P.CATEGORY_ID,
        SUM(O.TOTAL_ORDER_AMOUNT) AS TOTALSALES
    FROM 
        PRODUCTS P
        JOIN ORDERDETAILS OD ON P.PRODUCTID = OD.PRODUCTID
        JOIN ORDERS O ON OD.ORDERID = O.ORDERID
    GROUP BY 
        P.CATEGORY_ID
)
SELECT 
    C.CATEGORYNAME,
    CS.TOTALSALES
FROM 
    CATEGORYSALES CS
    JOIN CATEGORY C ON CS.CATEGORY_ID = C.CATEGORYID
ORDER BY 
    CS.TOTALSALES DESC;
    
-- Get the number of orders and total sales amount by each customer

SELECT CUSTOMERID, COUNT(ORDERID) AS ORDER_NUM, SUM(TOTAL_ORDER_AMOUNT) AS 'TOTAL_SALES_AMOUNT' 
FROM ORDERS 
GROUP BY CUSTOMERID
ORDER BY TOTAL_SALES_AMOUNT DESC;















