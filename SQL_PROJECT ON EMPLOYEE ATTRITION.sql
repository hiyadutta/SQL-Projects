USE learnproject;
SELECT * FROM attrition;


--OVERALL ATTRITION COUNT

SELECT COUNT(*) AS Total_attrition FROM attrition
WHERE attrition = 'Yes';

SELECT COUNT(*) AS Total_attrition FROM attrition;


--TOTAL EMPLOYEES VS ATRRITION

SELECT SUM(CASE WHEN attrition = 'Yes' THEN 1 END) as attri_emp, COUNT(*) AS Total_Emp FROM attrition;


--OVERTIME AND ATTRITION CORELATION

SELECT OverTime, COUNT(*) AS attri_emp_no FROM attrition
WHERE attrition= 'Yes' 
GROUP BY OverTime
ORDER BY attri_emp_no DESC;


--GENDER AND ATTRITION CORELATION
SELECT gender, COUNT(*) AS attri_gen FROM attrition
WHERE attrition= 'YES' 
GROUP BY gender
ORDER BY attri_gen DESC;


-- PERFORMANCE RATING AND ATTRITION

SELECT performanceRating, COUNT(*) AS ATTRI_COUNT FROM attrition 
WHERE attrition = 'Yes'
GROUP BY performanceRating
ORDER BY performanceRating DESC;


--PERCENT_SALARY_HIKE AND ATTRITION COUNT

 SELECT percentsalaryhike, COUNT(*) AS ATTRI_COUNT FROM attrition
 WHERE attrition='Yes'
 GROUP BY percentsalaryhike
 ORDER BY ATTRI_COUNT DESC;


 --RELATIONSHIP BETWEEN YEARS IN CURRENT ROLE AND ATTRITION COUNT 

 SELECT TOP 20 
	TotalWorkingYears, 
	COUNT (CASE WHEN attrition='Yes' THEN 1 END) AS ATTRI_COUNT 
 FROM attrition 
 GROUP BY TotalWorkingYears
 ORDER BY ATTRI_COUNT DESC;


 ---- YEARS IN CURRENT ROLE VS ATTRITION 

 SELECT yearsincurrentrole, COUNT(CASE WHEN attrition='Yes' THEN 1 END) AS TS 
 FROM attrition 
 GROUP BY yearsincurrentrole
 ORDER BY yearsincurrentrole ASC;

 ----EMPLOYEE ATTRITION BY AGES

 SELECT CASE WHEN age <=29 THEN '18-29'
			WHEN age >= 30 AND age<=39 THEN '30-39'
			WHEN age >=40 AND age <=49 THEN '40-49'
			WHEN age >=50 AND age <=59 THEN '50-59'
			ELSE '60 or old' END AS 'age_range', COUNT (*) AS TS 
FROM attrition
WHERE attrition='Yes'
GROUP BY CASE WHEN age <=29 THEN '18-29'
			WHEN age >= 30 AND age<=39 THEN '30-39'
			WHEN age >=40 AND age <=49 THEN '40-49'
			WHEN age >=50 AND age <=59 THEN '50-59'
			ELSE '60 or old' END;

 --DEPARTMENT WISE ATTRITION

 SELECT department, COUNT(*) AS ATTRI FROM attrition 
 WHERE attrition= 'Yes'
 GROUP BY department
 ORDER BY ATTRI DESC;


 --ENVIRIONMENT SATISFACTION, JOB SATISFACTION AND RELATIONSHIP SATISFACTION VS ATTRITION 

 SELECT 
	EnvironmentSatisfaction, 
	COUNT(*) AS TA_ENV 
 FROM attrition 
 WHERE attrition = 'Yes'
 GROUP BY EnvironmentSatisfaction
 ORDER BY TA_ENV DESC;


 SELECT 
	jobsatisfaction, 
	COUNT(CASE WHEN attrition='Yes' THEN 1 END) AS TA_JOB 
FROM attrition 
GROUP BY jobsatisfaction
ORDER BY TA_JOB DESC;


 SELECT 
	relationshipsatisfaction, 
	COUNT(*) AS TA_R 
FROM attrition 
WHERE attrition = 'Yes'
GROUP BY relationshipsatisfaction
ORDER BY TA_R DESC;


 --WORKLIFE BALANCE VS ATTRITION COUNT

SELECT 
	worklifebalance, 
	COUNT(CASE WHEN attrition='Yes' THEN 1 END) AS TA_W FROM attrition 
GROUP BY worklifebalance
ORDER BY TA_W DESC;

 ---DISTANCE FROM HOME VS ATTRITION COUNT

 SELECT 
	distancefromhome , 
	COUNT(*) AS DA 
 FROM attrition 
 WHERE attrition = 'Yes'
 GROUP BY distancefromhome
 ORDER BY DA DESC;

