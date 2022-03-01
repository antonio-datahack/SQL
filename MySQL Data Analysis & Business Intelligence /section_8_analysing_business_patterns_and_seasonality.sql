USE mavenfuzzyfactory;
/*
SET GLOBAL max_allowed_packet = 1073741824;
SET SQL_MODE =" ";
SET global time_zone = '+01:00';
SET SQL_MODE='ALLOW_INVALID_DATES';

SET global time_zone = '-5:00';


SELECT @@time_zone;
SELECT CURRENT_TIMEZONE(); */

SELECT 
	website_session_id,
    created_at,
    HOUR(created_at) AS hr,
    WEEKDAY(created_at) AS wkday,
    CASE 
		WHEN WEEKDAY(created_at) = 0 THEN 'Monday'
        WHEN WEEKDAY(created_at) = 1 THEN 'Tuesday'
        ELSE 'other_day'
	END AS clean_weekday,
    QUARTER(created_at) AS qtr,
    MONTH(created_at) AS mo,
    DATE(created_at) AS date

FROM website_sessions

WHERE website_session_id BETWEEN 150000 AND 155000;

-- ------------------------------------- --
-- 67. ASSIGNMENT: Analyzing Seasonality --
-- ------------------------------------- --

-- email: january 02,2013
/* 2012 was a great year for us. As we continue to grow, we should take a look at 2012's monthly and weekly volume patterns, to see if we can find any seasonal trends we should plan for in 2013.
If you can pull sessions volume and order volume, that would be excellent */

SELECT
	YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions AS ws
	LEFT JOIN orders AS o
		on ws.website_session_id = o.website_session_id
WHERE YEAR(ws.created_at) = 2012
GROUP BY 1, 2;

SELECT
	MIN(DATE(ws.created_at)) as week_start_date,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions AS ws
	LEFT JOIN orders AS o
		on ws.website_session_id = o.website_session_id
WHERE YEAR(ws.created_at) = 2012
GROUP BY week(ws.created_at);

-- ------------------------------------------- --
-- 69. ASSIGNMENT: Analyzing Business Patterns --
-- ------------------------------------------- --

-- email: january 05,2013
/* We're considering adding live chat support to the website to inprove our customer experience. Could you analyze the avergae website session volume, by hour of the day and by day week, so that we can staff appropriately? 
Let's avoid the holiday time period and use a date range of Sep 15-Nov 15, 2012 */


SELECT 
	hr,
    ROUND(AVG(web_sessions),1) AS avg_sessions,
    ROUND(AVG(CASE WHEN wkday = 0 THEN web_sessions ELSE NULL END),1) AS mon,
    ROUND(AVG(CASE WHEN wkday = 1 THEN web_sessions ELSE NULL END),1) AS tue,
    ROUND(AVG(CASE WHEN wkday = 2 THEN web_sessions ELSE NULL END),1) AS wed,
    ROUND(AVG(CASE WHEN wkday = 3 THEN web_sessions ELSE NULL END),1) AS thu,
    ROUND(AVG(CASE WHEN wkday = 4 THEN web_sessions ELSE NULL END),1) AS fri,
    ROUND(AVG(CASE WHEN wkday = 5 THEN web_sessions ELSE NULL END),1) AS sat,
    ROUND(AVG(CASE WHEN wkday = 6 THEN web_sessions ELSE NULL END),1) AS sun
FROM (
SELECT
	DATE(created_at) AS created_date,
    WEEKDAY(created_at) AS wkday,
    HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS web_sessions
FROM website_sessions
WHERE created_at BETWEEN "2012-09-15" AND "2012-11-15"
GROUP BY 1,2,3
) AS daily_hourly_sessions
GROUP BY 1
ORDER BY 1;

SELECT
	HOUR(created_at) AS hr,
	AVG(COUNTD(DISTINCT website_session_id) AS count_sessions
FROM website_sessions
WHERE created_at BETWEEN "2012-09-15" AND "2012-11-15"
GROUP BY 1
ORDER BY 1;
    
    