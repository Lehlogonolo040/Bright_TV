------------------------------- TABLE NO: 1 USER_PROFILES ----------------------------

----- 1. Viewing user_profiles table -----
SELECT *
FROM workspace.default.user_profiles;

----- 1.2 Viewing data type ------
DESCRIBE workspace.default.user_profiles;

----- 2. Number of Viewers ------
SELECT COUNT(DISTINCT UserID) AS Viewers
FROM workspace.default.user_profiles;

----- 3. Number of Viewers by Gender ---------
SELECT Gender,
       COUNT(DISTINCT UserID) AS Viewers
FROM workspace.default.user_profiles
GROUP BY Gender;

------ 4. Number of viwers by province --------
SELECT Province,
       COUNT(DISTINCT UserID) AS Viewers
FROM workspace.default.user_profiles
GROUP BY province;

----- 5. Checking the NULL values and NONE space in the columns ----
SELECT *
FROM workspace.default.user_profiles
WHERE COALESCE(Gender, '') IN ('', 'None')
     OR AGE IS NULL
     OR COALESCE(Race, '') IN ('', 'None')
     OR COALESCE(Province, '') IN ('','None');


SELECT *
FROM workspace.default.user_profiles
WHERE Age IS NULL 
OR Race IS NULL 
OR Gender IS NULL 
OR Province IS NULL;

----- 6. Checking the Duplicates --------
SELECT UserID,
       Gender,
       Age,
       Race, 
       Province, 
       COUNT(*) AS occurrences
FROM workspace.default.user_profiles
GROUP BY UserID, 
         Gender, 
         Age, 
         Race, 
         Province
HAVING COUNT(*) > 1;

--------------------------------------------------------------------------------
------------------ TABLE NO 2: VIEWERSHIP --------------------------------
------ 1. Viewing viewership table -------
SELECT *
FROM workspace.default.viewership;

----- 1.2 Viewing data type ------
DESCRIBE workspace.default.viewership;

------ 2. Number of viewers ----
SELECT COUNT(DISTINCT UserID0) AS Viewers
FROM workspace.default.viewership;

------ 3. Checking total channels ------
SELECT COUNT(DISTINCT Channel2) AS Total_channels
FROM workspace.default.viewership;

------ 4. TV channels and viewers -------
SELECT Channel2,
       COUNT(DISTINCT UserID0) AS Viewers
FROM workspace.default.viewership
GROUP BY Channel2
ORDER BY Viewers DESC;

----- 5. Checking null velues -----------
SELECT Channel2,
       Recorddate2,
       'Duration 2'
FROM workspace.default.viewership
WHERE Channel2 IS NULL
  OR  Recorddate2 IS NULL
  OR  `Duration 2`IS NULL;

----- 6. Checking start and end date of data collection --------
SELECT 
  MIN(Recorddate2) AS min_date,
  MAX(Recorddate2) AS max_date
FROM workspace.default.viewership; 

  ---------------- JOINING BOTH COLUMNS (User_profiles as A and Viewership as B) -----------------------
  SELECT UserID,
         Name,
         Surname,
         Email,
         Gender,
         Race,
         Age,
         Province,
         `Social Media Handle`,
         Channel2,
         Recorddate2,
         `Duration 2`
FROM workspace.default.user_profiles AS A
LEFT JOIN workspace.default.viewership AS B
ON A.UserID = B.UserID0;

----------- FINAL CODE --------------------
WITH Profile AS (
SELECT
CASE 
    WHEN B.Gender IS NULL OR TRIM(B.Gender) IN ('', 'None') THEN 'Unknown' 
    ELSE B.Gender 
    END AS Gender,
CASE 
    WHEN B.Race IN ('other/None combined') OR TRIM(B.Race) IN ('', 'None') THEN 'Unknown' 
    ELSE B.Race 
    END AS Race,
CASE 
    WHEN TRIM(B.Province) IN ('', 'None') THEN 'Unknown' 
    ELSE B.Province 
    END AS Province,
    A.UserID0,
    B.Age,
    A.Channel2,
    A.Recorddate2,
    A.`Duration 2`
    FROM workspace.default.viewership AS A
    LEFT JOIN workspace.default.user_profiles AS B
    ON A.UserID0 = B.UserID
)
SELECT 
    CAST(Recorddate2 AS DATE) AS Calendar_Date,
    DATE_FORMAT(Recorddate2, 'MMMM') AS Month_name,
    DATE_FORMAT(Recorddate2, 'EEEE') AS Weekday,
CASE
    WHEN HOUR(Recorddate2) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN HOUR(Recorddate2) BETWEEN 12 AND 16 THEN 'Afternoon'
    WHEN HOUR(Recorddate2) BETWEEN 17 AND 21 THEN 'Evening'
    ELSE 'Night'
    END AS Time_basket,
    Channel2,
    Gender,
    Race,
    Province,
CASE
    WHEN Age IS NULL THEN 'Unknown'
    WHEN Age BETWEEN 0 AND 12 THEN 'Children'
    WHEN Age BETWEEN 13 AND 19 THEN 'Teenagers'
    WHEN Age BETWEEN 20 AND 39 THEN 'Youth'
    WHEN Age BETWEEN 40 AND 59 THEN 'Adults'
    ELSE 'Seniors'
    END AS Age_Basket,
CASE
    WHEN `Duration 2` IS NULL THEN 'Unknown'
    WHEN (HOUR(`Duration 2`) * 60 + MINUTE(`Duration 2`)) <= 15 THEN 'Short'
    WHEN (HOUR(`Duration 2`) * 60 + MINUTE(`Duration 2`)) BETWEEN 16 AND 59 THEN 'Medium'
    WHEN (HOUR(`Duration 2`) * 60 + MINUTE(`Duration 2`)) BETWEEN 60 AND 179 THEN 'Long'
    ELSE 'Overlong'
    END AS Duration_Basket,
  COUNT(*) AS Total_Views,                     
  COUNT(DISTINCT UserID0) AS Unique_Viewers,    
  ROUND(AVG(CASE WHEN Age IS NOT NULL THEN Age END), 0) AS Average_Age
FROM Profile
GROUP BY 
  CAST(Recorddate2 AS DATE),
  DATE_FORMAT(Recorddate2, 'MMMM'),
  DATE_FORMAT(Recorddate2, 'EEEE'),
  Time_basket,
  Channel2,
  Gender,
  Race,
  Province,
  Age_Basket,
  Duration_Basket
ORDER BY 
  Calendar_Date DESC,
  Total_Views DESC;
