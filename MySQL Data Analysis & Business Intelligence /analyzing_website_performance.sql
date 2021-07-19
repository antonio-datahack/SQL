-- Section 5: Analyzing Website Performance --

USE mavenfuzzyfactory;

SELECT *
FROM website_pageviews
WHERE website_pageview_id < 1000;

SELECT 
	 pageview_url,
     COUNT(DISTINCT website_pageview_id) as PVS
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY pageview_url
ORDER BY pvs DESC; 

CREATE TEMPORARY TABLE first_pageview
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id;

SELECT 
	f.website_session_id,
    w.pageview_url as landing_page
FROM first_pageview as f
	LEFT JOIN website_pageviews as w
		on f.min_pv_id = w.website_pageview_id;
        
SELECT 
    w.pageview_url as landing_page,
    COUNT(DISTINCT w.website_session_id) as sessions_hitting_this_lander
FROM first_pageview as f
	LEFT JOIN website_pageviews as w
		on f.min_pv_id = w.website_pageview_id
GROUP BY 1;

-- 34. ASSIGNMENT: Finding Top Website -- 

SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) as pvs
FROM website_pageviews
WHERE created_at < "2012-06-09"
GROUP BY 1
ORDER BY 2 DESC;

-- 36. ASSIGNMENT: Finding Top Entry Pages --

SELECT 
	pageview_url as landing_page,
    COUNT(DISTINCT website_session_id) as sessions_hitting_this_landing_page
FROM website_pageviews
WHERE created_at < "2012-06-12"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- STEP 1: find the first pageview for each session --



CREATE TEMPORARY TABLE first_pv_per_session
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS first_pv
FROM website_pageviews
WHERE created_at < "2012-06-12"
GROUP BY 1;

-- STEP 2: find the url the customer saw on that first pageview --

SELECT 
	w.pageview_url AS landing_page_url,
    COUNT(DISTINCT f.website_session_id) as sessions_hitting__page
FROM first_pv_per_session as f
	LEFT JOIN website_pageviews as w
		ON f.first_pv = w.website_pageview_id
GROUP BY 1;

-- --------------------------------------------------------- --
-- 38. Analyzing Bounce Rates & Landing Page Tests --

-- BUSINESS CONTEXT: we want to see landing page performance for a certain time period --

-- STEP 1: find the first website_pageview_id for relevant sessions
-- STEP 2: identifz the landing page of each session 
-- STEP 3: counting pageviews foe each session, to identify "bounces"
-- STEP 4: summarizing total sessions and bounced sessions, by LP

-- finding the minimum website pageview id associated with each session we care about

SELECT
	wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews as wp
	INNER JOIN website_sessions as w
		ON w.website_session_id = wp.website_session_id
        AND w.created_at BETWEEN "2014-01-01" AND "2014-02-01"
GROUP BY 
	wp.website_session_id;

-- same query as above, but this time we are storing the dataset as a temporary table
CREATE TEMPORARY TABLE first_pageviews_demo
SELECT
	wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews as wp
	INNER JOIN website_sessions as w
		ON w.website_session_id = wp.website_session_id
        AND w.created_at BETWEEN "2014-01-01" AND "2014-02-01"
GROUP BY 
	wp.website_session_id;
    
-- next, we'll bring in the landing page to each session

CREATE TEMPORARY TABLE sessions_w_landing_page_demo
SELECT 
	f.website_session_id,
    wp.pageview_url as landing_page
FROM first_pageviews_demo as f
	LEFT JOIN website_pageviews as wp
		ON wp.website_pageview_id = f.min_pageview_id;

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
	s.website_session_id,
    s.landing_page,
	COUNT(wp.website_session_id) as count_of_pages_viewed
FROM sessions_w_landing_page_demo as s
	LEFT JOIN website_pageviews as wp
    ON wp.website_session_id = s.website_session_id
GROUP BY 
	1,
    2
HAVING 
	COUNT(wp.website_pageview_id) = 1;
    
SELECT 
	s.landing_page,
    s.website_session_id,
    b.website_session_id as bounced_website_session_id
FROM sessions_w_landing_page_demo as s
	LEFT JOIN bounced_sessions_only as b
		ON s.website_session_id = b.website_session_id
ORDER BY 
	s.website_session_id;

SELECT 
	s.landing_page,
    COUNT(DISTINCT s.website_session_id) AS sessions,
    COUNT(DISTINCT b.website_session_id)  as bounced_session,
    COUNT(DISTINCT b.website_session_id)/COUNT(DISTINCT s.website_session_id) AS bounced_rate
FROM sessions_w_landing_page_demo as s
	LEFT JOIN bounced_sessions_only as b
		ON s.website_session_id = b.website_session_id
GROUP BY 
	1;
    
    
-- Calculating Bounce Rates -- 

-- STEP 1: find the first website_pageview_id for relevant sessions
-- STEP 2: identifz the landing page of each session 
-- STEP 3: counting pageviews foe each session, to identify "bounces"
-- STEP 4: summarizing by counting total sessions and bounced sessions.

CREATE TEMPORARY TABLE first_pageviews
SELECT 
	wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews as wp
WHERE wp.created_at < "2012-06-14"
GROUP BY 1;

CREATE TEMPORARY TABLE session_w_home_landing_page
SELECT 
	f.website_session_id, 
    wp.pageview_url as landing_page
FROM first_pageviews as f
	LEFT JOIN website_pageviews as wp
		ON wp.website_pageview_id = f.min_pageview_id
WHERE wp.pageview_url = "/home";



DROP TABLE session_w_home_landing_page;

SELECT *
FROM first_pageviews;

SELECT *
FROM session_w_home_landing_page;





