USE mavenfuzzyfactory;

SELECT 
	utm_content,
    COUNT(DISTINCT ws.website_session_id) as sessions,
    COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) as session_to_oreder_CVR
FROM website_sessions as ws
	LEFT JOIN orders as o
		ON o.website_session_id = ws.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 1
ORDER BY sessions DESC;

-- -------------------------------------------- --
-- 55. ASSIGNMENT: Analyzing Channel Portfolios --
-- -------------------------------------------- --

-- email: november 29,2012
/* with gsearch doing well and the site performing better, we launched a second paid search channel, bsearch, around august 22. 
Can you pull weekly trended session volume since then and compare nonbrand so I can get a sense for how important this will be for the business? */

SELECT 
	YEARWEEK(created_at) AS yrwk,
    MIN(DATE (created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = "gsearch" THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = "bsearch" THEN website_session_id ELSE NULL END) AS bsearch_sessions, 
    COUNT(DISTINCT CASE WHEN utm_source = "gsearch" THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS perc_gsearch,
    COUNT(DISTINCT CASE WHEN utm_source = "bsearch" THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS perc_bsearch
FROM website_sessions
WHERE
	created_at >"2012-08-22" AND 
    created_at <"2012-11-29" AND 
	utm_campaign = "nonbrand"
GROUP BY 1;

-- ------------------------------------------------- --
-- 57. ASSIGNMENT: Comparing Channel Characteristics --
-- ------------------------------------------------- --

-- email: november 30,2012
/* I'd like to learn more about the bsearch nonbrand campaign. Could you please pull the percentage of traffic coming on Mobile, and compare that to gsearch? 
Feel free to dig around and share anything else you find interesting. Aggregate data since August 22nd is great, no need to show trending at this point. */

SELECT 
	utm_source,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN device_type = "mobile" THEN website_session_id ELSE NULL END) AS mobile_session,
    COUNT(DISTINCT CASE WHEN device_type = "mobile" THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_mobile
FROM website_sessions
WHERE
	created_at >"2012-08-22" AND 
    created_at <"2012-11-30" AND 
	utm_campaign = "nonbrand" 
GROUP BY 1;

SELECT *
from website_sessions;

-- ---------------------------------------------- --
-- 59. ASSIGNMENT: Cross-Channel Bid Optimization --
-- ---------------------------------------------- --

-- email: December 01,2012
/* I'm wonderin if bsearch nonbrand should have the same bids as gsearch. Could you pull nonbrand conversion rates from session to order for gsearch and bsearch, and slice the data by device type?
Please analyse data from August 22 to September 18; we ran a special pre-holiday campaign for gsearch starting on September 19th, so the data after that isn't fair game */

SELECT 
    ws.device_type,
    ws.utm_source,
    COUNT( DISTINCT ws.website_session_id) as sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) as conv_rate
FROM website_sessions as ws
    LEFT JOIN orders as o
		ON ws.website_session_id = o.website_session_id
WHERE
	ws.created_at >"2012-08-22" AND 
    ws.created_at <"2012-09-18" AND 
	ws.utm_campaign = "nonbrand"
GROUP BY 1, 2;


-- -------------------------------------------------- --
-- 61. ASSIGNMENT: Analyzing Channel Portfolio Trends --
-- -------------------------------------------------- --

-- email: December 22,2012
/* Based on your last analysis, we bid down nonbrand on December 2nd.
Could you pull weekly session volumne for gsearch and bsearch nonbrand, broken down by device, since November 4th?
If you cant include a comparison metric to show bsearch as percent of gsearch for each device, that would be great too */

SELECT 
    MIN(DATE(ws.created_at)) as week_start_date,
    COUNT(DISTINCT CASE WHEN ws.utm_source = "gsearch" AND ws.device_type = "desktop" THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
    COUNT(DISTINCT CASE WHEN ws.utm_source = "bsearch" AND ws.device_type = "desktop" THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
    COUNT(DISTINCT CASE WHEN ws.utm_source = "bsearch" AND ws.device_type = "desktop" THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN ws.utm_source = "gsearch" AND ws.device_type = "desktop" THEN website_session_id ELSE NULL END) as b_pct_of_g_dtop,
    COUNT(DISTINCT CASE WHEN ws.utm_source = "gsearch" AND ws.device_type = "mobile" THEN website_session_id ELSE NULL END) AS g_mob_sessions,
    COUNT(DISTINCT CASE WHEN ws.utm_source = "bsearch" AND ws.device_type = "mobile" THEN website_session_id ELSE NULL END) AS b_mob_sessions,
    COUNT(DISTINCT CASE WHEN ws.utm_source = "bsearch" AND ws.device_type = "mobile" THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN ws.utm_source = "gsearch" AND ws.device_type = "mobile" THEN website_session_id ELSE NULL END) as b_pct_of_g_mob
FROM website_sessions as ws
WHERE
	ws.created_at >"2012-11-04" AND 
    ws.created_at <"2012-12-22" AND 
	ws.utm_campaign = "nonbrand"
GROUP BY week(ws.created_at);

-- ------------------------------------------ --
-- 63. Analyzing Direct, Brand-Driven Traffic --
-- ------------------------------------------ --

SELECT
	CASE
		WHEN http_referer IS NULL THEN 'direct_type_in'
        WHEN http_referer = 'https://www.gsearch.com' AND utm_source IS NULL THEN 'gsearch_organic'
        WHEN http_referer = 'https://www.bsearch.com' AND utm_source IS NULL THEN 'bsearch_organic'
        ELSE 'other'
	END,
    COUNT(DISTINCT website_session_id) AS sessions
FROM  website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000
GROUP BY 1
ORDER BY 2 DESC;

-- ---------------------------------------- --
-- 64. ASSIGNMENT: Analyzing Direct Traffic --
-- ---------------------------------------- --
-- email: December 23,2012
/* A otential investor is asking if we are building any momentum with our brand or if we'll need to keep relying on paid traffic.
Could you pull organic search, direct type in, and paid brand search sessions by month, and show those sessions as a % of paid search nonbrand? */

SELECT DISTINCT 
	utm_source,
    utm_campaign, 
    http_referer
FROM website_sessions
WHERE created_at < '2012-12-23';

-- what I did --

SELECT 
	year(created_at) as year,
    month(created_at) as mo,
    COUNT(DISTINCT CASE WHEN utm_campaign = "nonbrand" THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign = "brand" THEN website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN utm_campaign = "brand" THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN utm_campaign = "nonbrand" THEN website_session_id ELSE NULL END) as brand_pct_of_nonbrand,
	COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN website_session_id END) AS direct,
    COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN website_session_id END)/
		COUNT(DISTINCT CASE WHEN utm_campaign = "nonbrand" THEN website_session_id ELSE NULL END) as direc_pct_of_nonbrand,
	COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN website_session_id END) as organic,
    COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN website_session_id END)/
		COUNT(DISTINCT CASE WHEN utm_campaign = "nonbrand" THEN website_session_id ELSE NULL END) as organic_pct_of_nonbrand
FROM website_sessions
WHERE created_at < '2012-12-23'
GROUP BY 1, 2
ORDER BY 2 ASC;

-- I think what I did is better than the solution provided by maven analytics --

SELECT 
	year(created_at) as year,
    month(created_at) as mo,
	COUNT(DISTINCT CASE WHEN channel_group = "paid_nonbrand" THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(DISTINCT CASE WHEN channel_group = "paid_brand" THEN website_session_id ELSE NULL END) AS brand,
    COUNT(DISTINCT CASE WHEN channel_group = "paid_brand" THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN channel_group = "paid_nonbrand" THEN website_session_id ELSE NULL END) as brand_pct_of_nonbrand,
	COUNT(DISTINCT CASE WHEN channel_group = "direct_type_in" THEN website_session_id ELSE NULL END) AS direct,
    COUNT(DISTINCT CASE WHEN channel_group = "direct_type_in" THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN channel_group = "paid_nonbrand" THEN website_session_id ELSE NULL END) as direc_pct_of_nonbrand,
	COUNT(DISTINCT CASE WHEN channel_group = "organic_search" THEN website_session_id ELSE NULL END) as organic,
    COUNT(DISTINCT CASE WHEN channel_group = "organic_search" THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT CASE WHEN channel_group = "paid_nonbrand" THEN website_session_id ELSE NULL END) as organic_pct_of_nonbrand
FROM(
SELECT 
	website_session_id,
    created_at,
	CASE
		WHEN utm_source IS NULL AND http_referer IN('https://www.gsearch.com','https://www.bsearch.com') THEN 'organic_search'
        WHEN utm_campaign = "nonbrand" THEN 'paid_nonbrand'
        WHEN utm_campaign = "brand" THEN 'paid_brand'
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
	END AS channel_group
FROM website_sessions
WHERE created_at < '2012-12-23'
) AS sessions_w_channel_group
GROUP BY
	YEAR(created_at),
    MONTH(created_at)
;
 


SELECT *
FROM website_sessions;

