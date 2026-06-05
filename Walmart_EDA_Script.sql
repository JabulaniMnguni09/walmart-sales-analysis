-- Original table
SELECT * 
FROM walmart.walmart;

-- Create duplicate table to avoid irreversable errors
Create table Walmart_data
Like walmart.walmart;
Insert Into Walmart_data
Select * 
From walmart.walmart;

-- Scanning for any errors in the data
SELECT * 
FROM Walmart_data;

-- COLUMN/ROW INSPECTION 
Select count(*) as 'Total Rows'
From Walmart_data;

-- Checking for dupplicates
With Duplicate_cte as (
Select *, Row_Number() Over(Partition by Store, `Date`, Weekly_Sales, Holiday_Flag, Temperature, Fuel_Price) as duplicate_count
From Walmart_data )
Select *
From Duplicate_cte
Where duplicate_count > 1;

-- Checking for nulls/ blanks
Select *
From Walmart_data
Where Store is null 
Or `Date` is null
Or  Weekly_Sales is null
or Holiday_Flag is null
or Temperature is null
or Fuel_Price is null
or Unemployment is null;


-- Check for data types
describe Walmart_data;

-- Add clean date with date data type
Select str_to_date(`Date`, '%d-%m-%Y')
as clean_date
From Walmart_data;

Alter table Walmart_data
add clean_date date;

-- Update table without removing old date column
Update Walmart_data
Set clean_date = str_to_date(`Date`, '%d-%m-%Y');

-- Validate
Select `Date`, clean_date
From Walmart_data;





-- Exploratory Data Analysis
-- Dashboard 1 Store Performance Overview

-- 1. Total weekly sales
Select Sum(Weekly_Sales) as 'Total Weekly Sales'
From Walmart_data;

-- 2. Average weekly sales
Select avg(Weekly_Sales) as 'Average Weekly Sales'
From Walmart_data;

-- 3. Top performing store
Select Store, sum(Weekly_Sales) as 'Total Revenue'
From walmart_data
Group by Store
Order by sum(Weekly_Sales) desc
Limit 1;

-- 4. Bottom 5 performing stores
Select Store, sum(Weekly_Sales) as 'Total Revenue'
From walmart_data
Group by Store
Order by sum(Weekly_Sales) asc
Limit 5;


-- 5. Sales by Store- Ranked descending
Select Store, sum(Weekly_Sales) as Total_Revenue
From walmart_data
Group by Store
Order by sum(Weekly_Sales) desc;

-- 6  Store Sales Contribution (Percentage of Total)
SELECT 
    Store,
    SUM(Weekly_Sales) AS Store_Sales,
    ROUND(
        SUM(Weekly_Sales) / (SELECT SUM(Weekly_Sales) FROM Walmart_data) * 100, 2
    ) AS Sales_Contribution_Pct
FROM Walmart_data
GROUP BY Store
ORDER BY Store_Sales DESC;

-- 7. Weekly Sales Trend Overtime
Select `Date`, sum(Weekly_Sales) as Total_Weekly_Sales
From walmart_data
Group by `Date`
Order by `Date` asc;








-- Dashboard 2  - Sales Drivers & Forecast Insights

-- 8. Holiday Average Sales
Select avg(Weekly_Sales) as Holiday_Avg_Sales
From walmart_data
Where Holiday_Flag = 1;


-- 9. Non-Holiday Average Sales
Select avg(Weekly_Sales) as Holiday_Avg_Sales
From walmart_data
Where Holiday_Flag = 0;

-- 10. Holiday Revenue Lift
SELECT 
    ROUND(
        (AVG(CASE WHEN Holiday_Flag = 1 THEN Weekly_Sales END) -
         AVG(CASE WHEN Holiday_Flag = 0 THEN Weekly_Sales END)) /
         AVG(CASE WHEN Holiday_Flag = 0 THEN Weekly_Sales END) * 100, 2
    ) AS Holiday_Revenue_Lift_Pct
FROM Walmart_data;

-- 11.  Holiday Vs Non-Holiday Average Sales Comparison
Select 
	Case 
		When Holiday_Flag = 1 Then 'Holiday'
        When Holiday_Flag = 0 Then 'Non-Holiday'
	End As Holiday_Label, 
    Avg(Weekly_Sales) As Average_Weekly_Sales
From walmart_data
Group By Holiday_Flag;

-- 12. Weekly Sales with Holiday Flag Highlighted
SELECT 
    Date,
    SUM(Weekly_Sales) AS Total_Weekly_Sales,
    MAX(Holiday_Flag) AS Holiday_Week
FROM Walmart_data
GROUP BY Date
ORDER BY Date ASC;

-- 13. Temperature vs Weekly Sales
Select Temperature, Avg(Weekly_Sales) As Avg_Weekly_Sales
From walmart_data
Group by Temperature 
Order by Temperature ASC;


-- 14.  Fuel Price Vs Weekly Sales
Select Fuel_Price, Avg(Weekly_Sales) As Avg_Weekly_Sales
From walmart_data
Group by Fuel_Price
Order by Fuel_Price ASC;

-- 15. CPI Vs Weekly Sales
Select CPI, Avg(Weekly_Sales) As Avg_Weekly_Sales
From walmart_data
Group by CPI
Order by CPI ASC;

-- 16. Unemployment Vs Weekly Sales
Select Unemployment, Avg(Weekly_Sales) As Avg_Weekly_Sales
From walmart_data
Group by Unemployment
Order by Unemployment ASC;

-- 17. Correlation — Temperature vs Weekly Sales
SELECT 
    ROUND(
        (SUM(Temperature * Weekly_Sales) - 
            SUM(Temperature) * SUM(Weekly_Sales) / COUNT(*)) /
        SQRT(
            (SUM(Temperature * Temperature) - 
                SUM(Temperature) * SUM(Temperature) / COUNT(*)) *
            (SUM(Weekly_Sales * Weekly_Sales) - 
                SUM(Weekly_Sales) * SUM(Weekly_Sales) / COUNT(*))
        ), 4
    ) AS Corr_Temperature
FROM Walmart_data;


-- 18.  Correlation — Fuel Price vs Weekly Sales
SELECT 
    ROUND(
        (SUM(Fuel_Price * Weekly_Sales) - 
            SUM(Fuel_Price) * SUM(Weekly_Sales) / COUNT(*)) /
        SQRT(
            (SUM(Fuel_Price * Fuel_Price) - 
                SUM(Fuel_Price) * SUM(Fuel_Price) / COUNT(*)) *
            (SUM(Weekly_Sales * Weekly_Sales) - 
                SUM(Weekly_Sales) * SUM(Weekly_Sales) / COUNT(*))
        ), 4
    ) AS Corr_Fuel_Price
FROM Walmart_data;


-- 19. Correlation — CPI vs Weekly Sales
SELECT 
    ROUND(
        (SUM(CPI * Weekly_Sales) - 
            SUM(CPI) * SUM(Weekly_Sales) / COUNT(*)) /
        SQRT(
            (SUM(CPI * CPI) - 
                SUM(CPI) * SUM(CPI) / COUNT(*)) *
            (SUM(Weekly_Sales * Weekly_Sales) - 
                SUM(Weekly_Sales) * SUM(Weekly_Sales) / COUNT(*))
        ), 4
    ) AS Corr_CPI
FROM Walmart_data;


-- 20. Correlation — Unemployment vs Weekly Sales
SELECT 
    ROUND(
        (SUM(Unemployment * Weekly_Sales) - 
            SUM(Unemployment) * SUM(Weekly_Sales) / COUNT(*)) /
        SQRT(
            (SUM(Unemployment * Unemployment) - 
                SUM(Unemployment) * SUM(Unemployment) / COUNT(*)) *
            (SUM(Weekly_Sales * Weekly_Sales) - 
                SUM(Weekly_Sales) * SUM(Weekly_Sales) / COUNT(*))
        ), 4
    ) AS Corr_Unemployment
FROM Walmart_data;

-- 21. Year over Year Seasonal Pattern
SELECT 
    YEAR(`Date`) AS Year,
    WEEK(`Date`) AS Week_Number,
    SUM(Weekly_Sales) AS Total_Weekly_Sales
FROM Walmart_data
GROUP BY YEAR(`Date`), WEEK(`Date`)
ORDER BY Year ASC, Week_Number ASC;






select *
FROM Walmart_data
where store like '3';