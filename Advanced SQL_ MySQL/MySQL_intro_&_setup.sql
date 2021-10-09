use mavenfuzzyfactory;

-- Trafic source analysis is about uderstanding where zour customers are coming from and wich channels are driving the higghest quality traffic --

-- CVR (conversion rate) is the percentage of those sessions which convert to our sales or revenue activity. --
-- with CVR we can understand how highly qualified that traffic is and how valuable each of those traffic source is to us --

-- 23. ASSIGNMENT: Traffic Source Conversion Rates--

SELECT *
FROM website_sessions
WHERE website_session_id=1059;

-- "created_at" is a timestamp, which is when that session happened --
-- "user_id" that is linked to the cookie is a user's browser. We use that to track users across multiple sessions.--
-- "is _repeat_session": is a binary flag, is going to be zero or a one, depending on whether or not this customer has benn to the website before. --
-- "utm_source", "utm_campaign", "utm_content" that we use to measure our paid marketing activity. --
-- UTM = "Urchin Tracking Module" Urchin is the predecessor to Google Analytics that Google actually bought ant then rebranded as their own--
-- Many ecommerce companies have adopted similar tracking conventions for their own internal database, sothat you can use one set of parameters for both the google analytics implementation and for the internal database --
-- "device_type" mobile or desktop --
-- "http_reffer"  where traffic is coming from --

SELECT *
FROM website_pageviews
WHERE website_session_id=1059;

-- the "website_pageviews" is basically a lof of page views that a user saw when they were on the e-commerce website. --
-- this can be really helpful when we start to do things like conversion funnel analysis --


SELECT *
FROM orders
WHERE website_session_id=1059;

-- the orders table is where the revenue avents are tracked. 
-- we will be using the "website_session_id" in the orders table as a foreign key that joins back to website sessions. --

SELECT utm_source, utm_campaign
FROM website_sessions;

SELECT 
	 utm_content,
     COUNT(DISTINCT w.website_session_id) AS sessions,
     COUNT(DISTINCT o.order_id) AS orders,
     COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id) AS session_to_order_conv_rt
FROM website_sessions w
	LEFT JOIN orders o
		ON o.website_session_id=w.website_session_id
WHERE w.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
order by 2 DESC;

-- ------------------------------------------- --
-- 21. ASSIGNMENT: Finding Top Traffic Sources --
-- ------------------------------------------- --

-- email: april 12, 2012 --
-- Could you help me understand where the bulk of our website sessions are coming from, through yesterday? --
-- I'd like to see a breakdown by UTM source, campaign and referring domain -- 

SELECT 
	utm_source,
    utm_campaign, 
    http_referer,
    COUNT(website_session_id) as number_of_sessions
FROM website_sessions
WHERE created_at <"2012-04-12"
GROUP BY
	utm_source,
	utm_campaign,
    http_referer
ORDER BY 4 DESC;


-- ----------------------------------------------- --
-- 23. ASSIGNMENT: Traffic Source Conversion Rates --
-- ----------------------------------------------- --

-- email: april 14, 2012 --
-- We should probably dig into gsearch nombrand a bit deeper to see what we can do to optimize there --
-- could zou please calculate the conversion rate (CVR) from session to order? Based on what we' re paying for clicks, we'll need a CVR at least 4% to make the numbers work.


SELECT *
FROM website_sessions;

SELECT *
FROM orders;

SELECT 
    COUNT(DISTINCT w.website_session_id) as sessions,
    COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT w.website_session_id) as session_to_order_conv_rt
FROM website_sessions as w
	LEFT JOIN orders as o
		ON w.website_session_id = o.website_session_id
WHERE w.created_at <"2012-04-14"
	AND w.utm_source = "gsearch"
    AND w.utm_campaign = "nonbrand";
    
    
