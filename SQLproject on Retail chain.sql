

SELECT * FROM CLEANED_CALENDAR1;

SELECT * FROM inventory;

SELECT * FROM products;

SELECT * FROM sales;



-- 1. Production Performance Analysis: Identify top-performing products based on total sales and profit.

WITH CTE AS (
    SELECT 
		Products.product_id,
        Products.Product_Name,
		(Products.Product_Price * Sales.Units) as REVENUE,
       (Sales.Units *(Products.Product_Price)-(Products.Product_Cost)) AS PROFIT 
    FROM Products
    JOIN Sales ON Sales.Product_ID = Products.Product_ID
)
SELECT TOP 10
    Product_Name, 
    SUM(REVENUE) AS 'TOTAL_SALES($)', 
    SUM(PROFIT) AS 'TOTAL_PROFIT($)'
FROM CTE
GROUP BY 
	Product_Name
ORDER BY 
	'TOTAL_SALES($)' DESC, 'TOTAL_PROFIT($)' DESC;

--  2.  Store Performance Analysis: Analyse sales performance for each store, including total revenue and profit margin.

SELECT 
	Stores.Store_ID,
	Stores.Store_name, 
	SUM(Products.Product_Price * sales.Units) AS 'Total_Revenue_$', 
	SUM(sales.Units *(Products.Product_Price-Products.Product_Cost)) AS 'Total_profit_$', 
	ROUND(SUM(sales.Units *(Products.Product_Price-Products.Product_Cost))/SUM(Products.Product_Price * sales.Units) * 100,2) AS 'Profit_margin_%'
FROM 
	Sales 
	INNER JOIN Stores
	ON Stores.Store_ID = Sales.Store_ID
	INNER JOIN products
	ON Products.Product_ID = Sales.Product_ID
GROUP BY 
	Stores.Store_ID,Stores.Store_name
ORDER BY 
	'Total_Revenue_$' DESC,	'Profit_margin_%' DESC;	


-- Complex Monthly Sales Trend Analysis:Examine monthly sales trends, considering the rolling 3-month average and identifying months with significant growth or decline.


WITH MonthlySales AS (
    SELECT 
        YEAR(s.Dates) AS year,
        MONTH(s.Dates) AS month,
        SUM(s.Units * p.Product_Price) AS total_sales
    FROM 
        sales s
    JOIN 
        products p ON s.Product_ID = p.product_id
    GROUP BY 
        YEAR(s.Dates), MONTH(s.Dates)
),
RollingAverage AS (
    SELECT 
        year,
        month,
        total_sales,
        ROUND(AVG(total_sales) OVER (ORDER BY year, month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3_month_avg
    FROM 
        MonthlySales
),
SalesWithTrend AS (
    SELECT 
        year,
        month,
        total_sales,
        rolling_3_month_avg,
        CASE 
            WHEN total_sales > rolling_3_month_avg * 1.1 THEN 'Significant Growth'
            WHEN total_sales < rolling_3_month_avg * 0.9 THEN 'Significant Decline'
            ELSE 'Stable'
        END AS trend
    FROM 
        RollingAverage
)
SELECT 
    year,
    month,
    total_sales,
    rolling_3_month_avg,
    trend
FROM 
    SalesWithTrend
ORDER BY 
    year, month;



-- Cumulative Distribution of Profit Margin:Calculate the cumulative distribution of profit margin for each product category, consider where products are having profit.

WITH ProductProfits AS (
    SELECT 
        p.Product_Category AS category,
        p.product_id AS product_id,
        (SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost)) AS profit,
        ROUND((SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost)) / SUM(s.Units * p.Product_Price) * 100,2) AS profit_margin
    FROM 
        sales s
    JOIN 
        products p ON s.Product_ID = p.product_id
    GROUP BY 
        p.Product_Category, p.product_id
    HAVING 
        (SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost)) / SUM(s.Units * p.Product_Price) * 100 > 0
),
CumulativeDistribution AS (
    SELECT 
        category,
        product_id,
        profit,
        profit_margin,
        PERCENT_RANK() OVER (PARTITION BY category ORDER BY profit_margin) AS cum_dist
    FROM 
        ProductProfits
)
SELECT 
    category,
    product_id,
    profit,
    profit_margin,
    cum_dist
FROM 
    CumulativeDistribution
ORDER BY 
    profit_margin DESC, cum_dist DESC;


-- Store Inventory Turnover Analysis:Analyze the efficiency of inventory turnover for each store by calculating the Inventory Turnover Ratio.

WITH COGS AS (
    SELECT 
        s.Store_ID,
        SUM(s.Units * p.Product_Cost) AS cogs
    FROM 
        sales s
    JOIN 
        products p ON s.Product_ID = p.product_id
    GROUP BY 
        s.Store_ID
),
AverageInventory AS (
    SELECT 
        i.Store_ID,
        AVG(i.Stock_On_Hand * p.Product_Cost) AS avg_inventory
    FROM 
        inventory i
    JOIN 
        products p ON i.Product_ID = p.product_id
    GROUP BY 
        i.Store_ID
)
SELECT 
    c.Store_ID,
    c.cogs,
    a.avg_inventory,
    CASE 
        WHEN a.avg_inventory = 0 THEN 0
        ELSE ROUND(c.cogs / a.avg_inventory, 2)
    END AS inventory_turnover_ratio
FROM 
    COGS c
JOIN 
    AverageInventory a ON c.Store_ID = a.Store_ID
ORDER BY 
    inventory_turnover_ratio DESC;
