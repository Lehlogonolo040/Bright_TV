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
WITH Profile AS 
(SELECT DISTINCT
CASE 
    WHEN Gender IS NULL OR TRIM(Gender) = '' OR Gender = 'None' THEN 'Unknown'
    ELSE Gender
    END AS Gender,
CASE 
    WHEN Race IN ('other/None combined') THEN 'Unknown'
    WHEN TRIM(Race) = '' OR Race = 'None' THEN 'Unknown'
    ELSE Race 
    END AS Race,
CASE 
    WHEN TRIM(Province) = '' OR Province = 'None' THEN 'Unknown'
    ELSE Province
    END AS Province,
    A.UserID0,
    Age,
    Channel2,
    Recorddate2,
    `Duration 2`
FROM workspace.default.viewership AS A
LEFT JOIN workspace.default.user_profiles AS B
ON A.UserID0 = B.UserID  )
SELECT Gender,
       Race,
       Channel2,
       Province,
       Age,
       UserID0,
       Recorddate2,
       `Duration 2`,
       DATE_FORMAT(Recorddate2, 'HH:MM') AS Time,
       DATE_FORMAT(Recorddate2, 'mm-yyyy') AS Month_id,
       DATE_FORMAT(Recorddate2, 'yyyy-mm-dd') AS Calendar_Date,
       DATE_FORMAT(Recorddate2, 'EEEE') AS Weekday,
       DATE_FORMAT(Recorddate2, 'MMMM') AS Month_name,
       DATE_FORMAT(`Duration 2`, 'HH:MM:SS') AS Duration,
CASE 
    WHEN Age IS NULL THEN 'Unknown'
    WHEN Age BETWEEN 0 AND 12 THEN 'Children'
    WHEN Age BETWEEN 13 AND 19 THEN 'Teenagers'
    WHEN Age BETWEEN 20 AND 39 THEN 'Youth'
    WHEN Age BETWEEN 40 AND 59 THEN 'Adults'
    ELSE 'Siniors'
    END AS Age_Basket,
CASE 
    WHEN `Duration 2` IS NULL THEN 'Unknown'
    WHEN `Duration 2` < '16:00' THEN 'Short'
    WHEN `Duration 2` < '01:00' THEN 'Medium'
    WHEN `Duration 2` < '03:00' THEN 'Long'
    ELSE 'Overlong'
    END AS Duration_Basket, 
CASE 
    WHEN DATE_FORMAT(recorddate2, 'HH:mm') BETWEEN '06:00' AND '11:59' THEN 'Morning'
    WHEN DATE_FORMAT(recorddate2, 'HH:mm') BETWEEN '12:00' AND '16:59' THEN 'Afternoon'
    WHEN DATE_FORMAT(recorddate2, 'HH:mm') BETWEEN '17:00' AND '21:59' THEN 'Evening'
    ELSE 'Night'
    END AS Time_basket,
COUNT(UserID0) AS Total_viewership,
COUNT(DISTINCT UserID0) AS Viewers,
COUNT(DISTINCT Channel2) AS Total_channels,
COUNT(Channel2) AS Channels_viewed,
ROUND(AVG(Age),0) AS Average_Age
FROM Profile
GROUP BY Calendar_Date,
         Month_name,
         Month_id,
         Weekday,
         Time,
         Duration,
         Age_basket,
         Duration_basket,
         Time_basket,
         Gender,
         Race,
         Channel2,
         Province,
         Age,
         UserID0,
         Recorddate2,
         `Duration 2`
ORDER BY Month_id,
         Calendar_date,
         Time;
