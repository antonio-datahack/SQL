-- Section 5: Analyzing Website Performance --

USE mavenfuzzyfactory;

-- --------------------------------------------- --
-- 33. Analyzing Top Website Pages & Entry Pages --
-- --------------------------------------------- --

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

-- We just want to look at the page URLs that are the first page view of a given website session --
-- we're goin to be lloking for the website session ID and then trying to find the first page view that that website session ID sees --
 -- and then we' ll find either the minimum create at or in this case because the website pageview ID is auto incrementing we can also...
 -- ...just do the minimum website pageview and thats actually going to be a little bit faster --

CREATE TEMPORARY TABLE first_pageview
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id;

select *
from first_pageview;

SELECT 
	f.website_session_id,
    w.pageview_url as landing_page -- aka sometimes this is called "entry page" --
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

-- ----------------------------------- --
-- 34. ASSIGNMENT: Finding Top Website -- 
-- ----------------------------------- -- 

-- email: june 09, 2012 --
-- Could you help me get my head around the site by pulling the most-viewed pages, ranked by session volume? --

SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) as pvs
FROM website_pageviews
WHERE created_at < "2012-06-09"
GROUP BY 1
ORDER BY 2 DESC;

-- --------------------------------------- --
-- 36. ASSIGNMENT: Finding Top Entry Pages --
-- --------------------------------------- --

-- email: june 12, 2012 --
-- Would you be able to pull a list of top entry pages? I want to confir where our users are hitting the site. --
-- If you could pull all entry pages and rank them on entry volume, that could be great. --

SELECT 
	pageview_url as landing_page,
    COUNT(DISTINCT website_session_id) as sessions_hitting_this_landing_page
FROM website_pageviews
WHERE created_at < "2012-06-12"
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

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

-- ----------------------------------------------- --
-- 38. Analyzing Bounce Rates & Landing Page Tests --
-- ----------------------------------------------- --

-- email: june 12, 2012 --
-- I will likely have some follow up requests to look into performance for the homepage --

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
where wp.created_at BETWEEN "2014-01-01" AND "2014-02-01"
GROUP BY 
	wp.website_session_id;

-- same query as above, but this time we are storing the dataset as a temporary table
CREATE TEMPORARY TABLE first_pageviews_demo
SELECT
	wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews as wp
where wp.created_at BETWEEN "2014-01-01" AND "2014-02-01"
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
        
-- we're going to make a table that will include a count of page views per session --

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
    
select *
from bounced_sessions_only;
  
    
SELECT 
	s.landing_page,
    s.website_session_id,
    b.website_session_id as bounced_website_session_id
FROM sessions_w_landing_page_demo as s
	LEFT JOIN bounced_sessions_only as b -- we are doing a left session, if there is no match, we will still return our result from the first table sessions with landing page
		ON s.website_session_id = b.website_session_id
ORDER BY 
	s.website_session_id;
    
-- final output   
	-- we wil use the same querz we previousl ran, and ran a count of records --
	-- we will group by landing page, and then we'll add a bounce rate column --

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
    
-- ---------------------------------- --    
-- 39. ASSIGNMENT: Calculating Bounce -- 
-- ---------------------------------- --    

-- email: june 14, 2012 --
-- The other day you showed us that our traffic is landing on the homepage right now. we should check how that landing page is performing.
-- can you pull bounce rates for traffic landing on the homepage? i would like to see three numbers... Sessions, Bounced sessions, and % of sessions wich bounced (aka "Bounced Rate) 

CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	  website_session_id,
	  COUNT(website_pageview_id) AS website_pageview_id_count
FROM website_pageviews
WHERE created_at < "2012-06-14"
GROUP BY 
	website_session_id
HAVING COUNT(website_pageview_id) = 1;

-- drop table bounced_sessions;

SELECT *
FROM bounced_sessions;

CREATE TEMPORARY TABLE bounced_sessions_landing_page
SELECT
	b.website_session_id,
	b.website_pageview_id_count AS website_pageview_id_unique,
    wp.pageview_url AS landing_page
FROM bounced_sessions AS b
	LEFT JOIN website_pageviews AS wp
		ON wp.website_pageview_id = b.website_pageview_id_count;

SELECT *
FROM bounced_sessions_landing_page;



SELECT	
    COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(b.website_pageview_id_unique) AS bounced,
    COUNT(b.website_pageview_id_unique)/COUNT(DISTINCT w.website_session_id) AS percentage
FROM website_pageviews AS w
	LEFT JOIN bounced_sessions_landing_page AS b
		ON w.website_session_id= b.website_session_id
WHERE w.created_at < "2012-06-14";

-- --------------
--  FASTER WAY --
-- ----------- --
CREATE TEMPORARY TABLE bounced_sessions6
SELECT 
	  website_session_id,
	  COUNT(website_pageview_id) AS website_pageview_id
FROM website_pageviews
GROUP BY 
	website_session_id
HAVING COUNT(website_pageview_id) = 1;

select *
from bounced_sessions6;


SELECT	
    COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(b.website_pageview_id) AS bounced,
    COUNT(b.website_pageview_id)/COUNT(DISTINCT w.website_session_id)*100 AS percentage
FROM website_pageviews AS w
	LEFT JOIN bounced_sessions6 AS b
		ON w.website_session_id= b.website_session_id
WHERE w.created_at < "2012-06-14";



-- -------------------------------------------- --
-- 41. ASSIGNMENT: Analyzing Landing Page Tests --
-- -------------------------------------------- --

-- email: July 28, 2012 --
-- Based on your bounce rate analysis, we run a new custom landing page (/lander-1) in a 50/50 percent test against the homepage (/home) for our gsearch nonbrand trafic --
-- Can you pull bounce rates for the two groups so we can evaluate the new page? make sure to just look at the time period where /lander-1 ..
-- ...was getting traffic, so that it is a fair comparison -- 

SELECT 
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url ="/lander-1"
	AND created_at IS NOT NULL;
    
CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
	wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews as wp
	INNER JOIN website_sessions as  w
		ON w.website_session_id = wp.website_session_id
        AND w.created_at < "2012-07-28" -- prescribe by the assigment
        AND wp.website_pageview_id >= 23504 -- the min_pageview_is we found
        AND utm_source = "gsearch"
        AND utm_campaign = "nonbrand"
GROUP BY 
	wp.website_session_id;

-- drop table first_test_pageviews;
    
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT 
	f.website_session_id,
    wp.pageview_url AS landing_page
FROM first_test_pageviews as f 
	LEFT JOIN website_pageviews as wp
     ON wp.website_pageview_id = f.min_pageview_id
WHERE wp.pageview_url IN ("/home", "/lander-1");


-- then a table to have count of pageviews per session
	-- then limit it to just bounced_sessions
    
CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT
	n.website_session_id,
    n.landing_page,
    COUNT(wp.website_pageview_id) AS count_of_pages_viewed
FROM nonbrand_test_sessions_w_landing_page as n
LEFT JOIN website_pageviews as wp
	ON wp.website_session_id = n.website_session_id
GROUP BY 	
	n.website_session_id,
    n.landing_page
HAVING 
	COUNT(wp.website_pageview_id) = 1;
    
-- drop table nonbrand_test_bounced_sessions;

SELECT 
	nw.landing_page,
    nw.website_session_id,
    nb.website_session_id AS bounced_website_session_id
FROM nonbrand_test_sessions_w_landing_page nw
	LEFT JOIN nonbrand_test_bounced_sessions nb
		ON nw.website_session_id = nb.website_session_id
ORDER BY 
	2;

SELECT 
	nw.landing_page,
    COUNT(DISTINCT nw.website_session_id) AS sessions,
    COUNT(DISTINCT nb.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT nb.website_session_id)/COUNT(DISTINCT nw.website_session_id) as bounced_rate
FROM nonbrand_test_sessions_w_landing_page nw
	LEFT JOIN nonbrand_test_bounced_sessions nb
		ON nw.website_session_id = nb.website_session_id
GROUP BY 
	nw.landing_page;
    
-- ------------------------------------------- --
-- 43. ASSIGNMENT: Landing Page Trend Analysis --
-- ------------------------------------------- --

-- email: August 31, 2012 -- 
-- Could you pull the volume of paid search nonbrand traffic landing on /home and..
-- .. /lander-1, trended weekly since June 1st? I want to confirm the traffic is..
-- .. all routet correctly
-- Could you also pull our overall paid search bounce rate trended weekly? I want to..
-- .. make sure the lander change has inproved the overall picture.

    
