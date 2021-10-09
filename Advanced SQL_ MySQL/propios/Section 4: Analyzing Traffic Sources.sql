SET global time_zone = '-5:00';

/*
21. ASSIGNMENT: Finding Top Traffic Sources
I'd like to see a breakdown by UTM source, campaign and referring domain if possible. 
*/


SELECT 
	utm_source,
    utm_campaign,
    http_referer,
	COUNT(DISTINCT website_session_id) as sessions
FROM website_sessions
WHERE created_at < "2012-04-12"
GROUP BY 1,
	2,	
    3
ORDER BY 4 DESC;

/*
23. ASSIGNMENT: Traffic Source Conversion Rates
Calculate the conversion rate (CVR) from session to order? (gsearch-nonbrand)
Based on what we're paying for clicks, we'll need a CVR of at least 4% to make the numbers work.
*/

SELECT 
	COUNT(DISTINCT ws.website_session_id) as sessions,
    COUNT(DISTINCT o.order_id) as order_sessions,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id)
FROM website_sessions as ws
	LEFT JOIN orders as o
		on ws.website_session_id = o.website_session_id
WHERE 
	ws.created_at < "2012-04-14"
	AND ws.utm_source = "gsearch"
    AND ws.utm_campaign = "nonbrand";
    
/*
26. ASSIGNMENT: Traffic Source Trending
Email: may 10, 2012
we bid down gsearch nonbrand on 2012-04-15
Can you pull gsearch nonbrand trended session volume, by week, to see if the bid changes have caused volume to drop at all?
*/

SELECT 
    MIN(DATE(created_at)) as week_started_at,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < "2012-05-12"
	AND utm_source = "gsearch"
    AND utm_campaign = "nonbrand"
GROUP BY 
	year(created_at),
	week(created_at);
    
/*
28. ASSIGNMENT: Bid Optimization for Paid Traffic
Email: May 11, 2012
Could you pull conversion rates from sesion to order, by device type? 
If desktop performance is better than a mobile we may able to bid up for the desktop specifically to get more volume?
*/
    
SELECT 
	ws.device_type,
    COUNT(DISTINCT ws.website_session_id) as sessions,
    COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS cvr
FROM website_sessions as ws
	LEFT JOIN orders as o
		ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < "2012-05-12"
	AND ws.utm_source = "gsearch"
    AND ws.utm_campaign = "nonbrand"
GROUP BY 
	1;
    
/* 
30. ASSIGNMENT: Trending w/ Granular Segments
Email: June 09, 2012
We bid our gsearch nonbrand desktop campaigns up on 2012-05-19. 
Could you pull weekly trends for both desktop and mobile so we see the impact on volume?
You can use 2012-04-15 until the bid change as a baseline. 
*/
        
SELECT
    MIN(DATE(created_at)) AS week_created_at,
    COUNT(DISTINCT CASE WHEN device_type = "desktop" THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = "mobile" THEN website_session_id ELSE NULL END) AS mobile_sessions
FROM website_sessions
WHERE created_at  > "2012-04-15"
	AND created_at  < "2012-06-09"
	AND utm_source = "gsearch"
    AND utm_campaign = "nonbrand"
GROUP BY
	WEEK(created_at);
    
    
 
    
	
    
