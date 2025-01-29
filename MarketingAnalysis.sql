USE PortfolioProject_MarketingAnalytics;

--To view customer details and Country & City they belong to
SELECT c.CustomerID, c.CustomerName, c.Email, c.Gender, c.Age, g.Country, g.City
FROM customers c
LEFT JOIN geography g
ON c.GeographyID = g.GeographyID;

--New column Price Category
SELECT ProductID, ProductName, Price,
CASE 
	WHEN Price < 50 THEN 'LOW'
	WHEN Price BETWEEN 50 AND 200 THEN 'MEDIUM'
	ELSE 'HIGH'
END AS PriceCategory
FROM products;

--To clean extra whitespaces in ReviewText
SELECT 
	ReviewID, 
	CustomerID, 
	ProductID, 
	ReviewDate, 
	Rating, 
	Replace (ReviewText, '  ', ' ') AS ReviewText
FROM customer_reviews;

--To Capitalize Content type, replace text, separate Views & Clicks, format date, exclude newsletter
SELECT 
	EngagementID,
	ContentID,
	CampaignID,
	ProductID,
	Upper(REPLACE(ContentType,  'Socialmedia', 'Social Media')) AS ContentType,
	LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined)-1) AS Views,
	RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS Clicks,
	Likes,
	FORMAT(CONVERT(DATE, EngagementDate), 'dd-MM-yyyy') AS EngagementDate
FROM engagement_data
WHERE ContentType != 'Newsletter';

--Inner query retrieves Stage in upper case, average of duration for each distinct visitdate, assigns a unique row number, 
--Outer query checks if duration is null it returns avg duration, only return the first row
SELECT 
	JourneyID,  
	CustomerID,
    ProductID,
    VisitDate,
    Stage,
    Action,
	COALESCE(Duration, avg_duration) AS Duration
FROM 
    (SELECT
            JourneyID,
            CustomerID,
            ProductID,
            VisitDate,
            UPPER(Stage) AS Stage,
            Action,
            Duration,
            AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,
            ROW_NUMBER() OVER (
                PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action
                ORDER BY JourneyID
            ) AS row_num  
        FROM 
            dbo.customer_journey  
    ) AS subquery  
WHERE 
    row_num = 1;  

--CTE
WITH DuplicateRecords AS (
    SELECT 
        JourneyID,  
		CustomerID,
        ProductID,
        VisitDate,
        Stage,
        Action,
        Duration,
        ROW_NUMBER() OVER 
		(PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action  
		ORDER BY JourneyID) AS row_num
    FROM dbo.customer_journey)

SELECT *
FROM DuplicateRecords
ORDER BY JourneyID;

