
CREATE DATABASE learnproject;

USE learnproject;

SELECT * FROM Marketing;

--Total customers

SELECT 
	COUNT(Customer) AS Customer_count 
FROM Marketing;

--Positive and Negetive Response Rate

WITH TotalResponses AS (
    SELECT ROUND(COUNT(*),2) AS total_count
    FROM marketing
),

PosResponses AS (
    SELECT ROUND(COUNT(*),2) AS pos_count
    FROM marketing
    WHERE Response = 'Yes'
),
NegResponses AS (
    SELECT ROUND(COUNT(*),2) AS neg_count
    FROM marketing
    WHERE Response = 'No'
)

SELECT 
		ROUND((pos.pos_count * 100.0 / total.total_count),2) AS pos_response_rate_pct,
		ROUND((neg.neg_count * 100.0 / total.total_count),2) AS neg_response_rate_pct
FROM 
    TotalResponses total,
    PosResponses pos,
    NegResponses neg;


---Gender wise responses

WITH PosResponses AS (
    SELECT 
        COUNT(*) AS pos_response,
        Gender 
    FROM Marketing
    WHERE Response = 'Yes'
    GROUP BY Gender
),
NegResponses AS (
    SELECT 
        COUNT(*) AS neg_response,
        Gender 
    FROM Marketing
    WHERE Response = 'No'
    GROUP BY Gender
)

SELECT 
    pos.Gender,
    pos.pos_response,
    neg.neg_response
FROM 
    PosResponses pos
JOIN 
    NegResponses neg
ON 
    pos.Gender = neg.Gender;

--Positive Responses by renew offer

SELECT 
	COUNT(*) AS pos_response,
	[Renew Offer Type] 
FROM marketing
WHERE Response= 'Yes'
GROUP BY [Renew Offer Type]
ORDER BY pos_response DESC;


-- Responses by Marital status

SELECT 
	COUNT(*) AS Pos_response,
	[Marital Status] 
FROM Marketing
WHERE Response= 'Yes'
GROUP BY [Marital Status]
ORDER BY Pos_response ASC;

---Response rate by Sales Channel

SELECT 
	COUNT(*) AS pos_response, 
	[Sales Channel] 
FROM marketing
WHERE Response= 'Yes'
GROUP BY [Sales Channel]
ORDER BY pos_response DESC;


--- Policy and type wise Total Claim Amount

SELECT 
	[Policy Type],Policy,
	AVG([Total Claim Amount]) AS avg_claim 
FROM Marketing
WHERE Response = 'Yes'
GROUP BY [Policy Type], Policy
ORDER BY avg_claim DESC;

---Vehicle Class wise total claim amount with positive response 

SELECT 
	[Vehicle Class], 
	SUM([Total Claim Amount]) AS TOTAL_CLAIM 
FROM marketing
WHERE Response= 'YES'
GROUP BY [Vehicle Class]
ORDER BY TOTAL_CLAIM DESC;


---Total claim BY Vehicle Class and Policy

SELECT TOP 10
	[Vehicle Class], 
	POLICY,  
	SUM([Total Claim Amount]) AS TOTAL_CLAIM
FROM Marketing
WHERE Response= 'YES'
GROUP BY [Vehicle Class], POLICY
ORDER BY TOTAL_CLAIM DESC;


--Customer's lifetime value by response rate 

SELECT 
	MAX([Customer Lifetime Value]) AS max_lifetime_value, 
	MIN([Customer Lifetime Value]) AS min_lifetime_value 
FROM Marketing
WHERE Response = 'Yes'
GROUP BY Response;


---State wise customer 

SELECT COUNT(Customer) AS NUM_CUST, [State] FROM Marketing

GROUP BY [State]
ORDER BY NUM_CUST DESC;

--List the customers who responded 'Yes' and have an income greater than 50000 Claim for premium coverage 

WITH PREMIUM_CLAIM AS (
SELECT 
	AVG([Total Claim Amount]) AS AVG_Claim, 
	COVERAGE 
FROM Marketing
WHERE Coverage = 'Premium'
GROUP BY Coverage),

CUST_SAL AS (
SELECT 
	COUNT(Customer) AS cust,
	COVERAGE 
FROM Marketing
WHERE Response= 'Yes' AND [Income]>50000
GROUP BY Coverage)

SELECT 
	PREMIUM_CLAIM.AVG_Claim,
	CUST_SAL.cust
FROM PREMIUM_CLAIM
JOIN CUST_SAL
ON PREMIUM_CLAIM.COVERAGE=CUST_SAL.COVERAGE;

---List the top 3 customers with the highest 'Customer Lifetime Value' along with their respective states and incomes.

SELECT 
	TOP 3 [Customer Lifetime Value], 
	Customer, 
	[State],
	Income
FROM Marketing
ORDER BY [Customer Lifetime Value] DESC;

---Find the average number of months since the last claim for customers grouped by their employment status.

SELECT 
	AVG([Months Since Last Claim]) AS AVG_MON, 
	EmploymentStatus 
FROM Marketing
GROUP BY EmploymentStatus
ORDER BY AVG_MON DESC;


--Count of all customers who have an average monthly premium greater than total claim amount.


SELECT COUNT(*) AS CUST_COUNT FROM (
	SELECT  customer, [Total Claim Amount], AVG([Monthly Premium Auto]) AS PREMIUM FROM Marketing
	GROUP BY  [Monthly Premium Auto], [Total Claim Amount], Customer
	HAVING AVG([Monthly Premium Auto])>([Total Claim Amount])
) AS SUB;


--Find the number of customers who have more than 2 open complaints and their respective states.

SELECT  
	COUNT(customer) AS cust, 
	[State] 
FROM Marketing
WHERE [Number of Open Complaints]>2
GROUP BY  [State]
ORDER BY cust DESC;


---  Top 3 customers within each state based on the Effective To Date

WITH ranked_cust AS (
	SELECT 
		[State],
		Customer,
		[Customer Lifetime Value],
		[Effective To Date],
		ROW_NUMBER() 
			OVER (PARTITION BY [State] 
					ORDER BY [Customer Lifetime Value] DESC) AS RANK_VALUE
		FROM Marketing
		)
	SELECT
		[State],
		Customer,
		[Customer Lifetime Value],
		[Effective To Date]
	FROM ranked_cust
	WHERE 
		RANK_VALUE<=3
	ORDER BY 
	 [State], RANK_VALUE;