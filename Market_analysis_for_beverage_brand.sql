Create database codebasics;
use codebasics;



select * from dim_cities;

select * from dim_repondents;

select * from fact_survey_responses;

-- Who prefers energy drink more?  (male/female/non-binary?) 
SELECT 
    gender, COUNT(Gender) AS gen_count
FROM
    dim_repondents
GROUP BY gender
ORDER BY gen_count DESC;

-- Which age group prefers energy drinks more? 
SELECT 
    age, COUNT(age) AS age_count
FROM
    dim_repondents
GROUP BY age
ORDER BY age_count DESC;

-- Which type of marketing reaches the most Youth (15-30)?
SELECT 
    a.age, b.marketing_channels, COUNT(a.age) AS age_count
FROM
    dim_repondents a
        JOIN
    fact_survey_responses b ON a.respondent_id = b.respondent_id
WHERE
    a.age IN ('19-30' , '15-18')
GROUP BY a.age , b.marketing_channels
ORDER BY age_count DESC;

-- What are the preferred ingredients of energy drinks among respondents? 
SELECT 
    b.Ingredients_expected, COUNT(a.respondent_id) AS ID_count
FROM
    dim_repondents a
        JOIN
    fact_survey_responses b ON a.respondent_id = b.respondent_id
GROUP BY b.Ingredients_expected
ORDER BY ID_count DESC;

-- What packaging preferences do respondents have for energy drinks? 
SELECT 
    b.Packaging_preference, COUNT(*) AS ID_count
FROM
    dim_repondents a
        JOIN
    fact_survey_responses b ON a.respondent_id = b.respondent_id
GROUP BY b.Packaging_preference
ORDER BY ID_count DESC;
-- Who are the city wise current market leaders? 
SELECT 
    city, 
    current_brands, 
    ID_count
FROM (
    SELECT 
        b.current_brands, 
        c.city, 
        COUNT(a.respondent_id) AS ID_count,
        ROW_NUMBER() OVER (PARTITION BY c.city ORDER BY COUNT(a.respondent_id) DESC) AS rn
    FROM
        dim_repondents a
        JOIN fact_survey_responses b ON a.respondent_id = b.respondent_id
        JOIN dim_cities c ON a.City_ID = c.City_ID
    GROUP BY b.current_brands, c.city
) ranked
WHERE rn <= 2
ORDER BY city, ID_count DESC;

-- Current market leader
SELECT 
    b.current_brands, COUNT(a.respondent_id) AS ID_count
FROM
    dim_repondents a
        JOIN
    fact_survey_responses b ON a.respondent_id = b.respondent_id
GROUP BY b.current_brands
ORDER BY ID_count DESC;

-- What are the primary reasons consumers prefer those brands over ours? 

SELECT 
    b.Reasons_for_choosing_brands,
    COUNT(a.respondent_id) AS ID_count
FROM
    dim_repondents a
        JOIN
    fact_survey_responses b ON a.respondent_id = b.respondent_id
GROUP BY b.Reasons_for_choosing_brands
ORDER BY ID_count DESC;

-- Which marketing channel can be used to reach more customers? 

SELECT 
    b.Marketing_channels, COUNT(a.respondent_id) AS ID_count
FROM
    dim_repondents a
        JOIN
    fact_survey_responses b ON a.respondent_id = b.respondent_id
GROUP BY b.Marketing_channels
ORDER BY ID_count DESC;

-- How effective are different marketing strategies and channels in reaching our customers?

SELECT 
    b.Marketing_channels,
    COUNT(a.respondent_id) AS ID_count
FROM
    dim_repondents a
        JOIN
    fact_survey_responses b 
    ON a.respondent_id = b.respondent_id
WHERE
    b.current_brands = 'Codex'
GROUP BY b.Marketing_channels , b.current_brands
ORDER BY ID_count DESC;

-- What do people think about our brand? (overall rating) 
SELECT 
    COUNT(*) AS count_id, Brand_perception
FROM
    fact_survey_responses
GROUP BY Brand_perception;


-- Which cities do we need to focus more on?
SELECT 
    c.city, COUNT(a.respondent_id) AS ID_count
FROM
    dim_repondents a
        JOIN
    fact_survey_responses b ON a.respondent_id = b.respondent_id
        JOIN
    dim_cities c ON a.City_ID = c.City_ID
WHERE
    b.current_brands = 'Codex'
GROUP BY b.current_brands , c.city
ORDER BY ID_count ASC;

-- Where do respondents prefer to purchase energy drinks? 

SELECT 
    b.Purchase_location, 
    COUNT(a.respondent_id) AS ID_count
FROM
    dim_repondents a
        JOIN
    fact_survey_responses b ON a.respondent_id = b.respondent_id
GROUP BY b.Purchase_location
ORDER BY ID_count DESC;

-- What are the typical consumption situations for energy drinks among respondents? 

SELECT 
    b.Typical_consumption_situations,
    COUNT(a.respondent_id) AS ID_count
FROM
    dim_repondents a
        JOIN
    fact_survey_responses b ON a.respondent_id = b.respondent_id
GROUP BY b.Typical_consumption_situations
ORDER BY ID_count DESC;


-- What factors influence respondents' purchase decisions, such as price range and  limited edition packaging?
SELECT 
    Price_range,
    Limited_edition_packaging,
    COUNT(*) AS response_count
FROM
    fact_survey_responses
GROUP BY Limited_edition_packaging , Price_range
ORDER BY response_count DESC;

-- Which area of business should we focus more on our product development? (Branding/taste/availability)

SELECT 
    b.Reasons_preventing_trying,
    COUNT(a.respondent_id) AS ID_count
FROM
    dim_repondents a
        JOIN
    fact_survey_responses b ON a.respondent_id = b.respondent_id
GROUP BY b.Reasons_preventing_trying
ORDER BY ID_count DESC;

SELECT 
    b.Taste_experience, COUNT(*) AS ID_count
FROM
    fact_survey_responses b
GROUP BY b.Taste_experience
ORDER BY ID_count DESC;


