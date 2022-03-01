USE mavenfuzzyfactory;

SELECT 
	primary_product_id,
	COUNT(order_id) AS orders,
    SUM(price_usd) AS revenue,
    SUM(price_usd - cogs_usd) AS margin,
    AVG(price_usd) AS aov
FROM orders
WHERE order_id BETWEEN 10000 AND 11000
GROUP BY 1
ORDER BY 2 DESC;

SELECT *
from orders;

-- -------------------------------------------- --
-- 73. ASSIGNMENT: Product-Level Sales Analysis --
-- -------------------------------------------- --

-- email: january 02,2013
/* We are about to launch a new product, and I'd like to do a deep dive on our current flagship product. 
Can you please pull monthly trends to date for number of sales, total revenue, and total margin generated for the business? */

SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd)AS total_margin
FROM orders
WHERE created_at < "2013-01-04"
GROUP BY 1, 2
ORDER BY 1, 2 ASC;

-- ------------------------------------------ --
-- 75. ASSIGNMENT: Analyzing Product Launches --
-- ------------------------------------------ --

-- email: abril 05,2013
/* We launched our second product back on january 6. Can you pull together some trended analysis?. 
I'd like to see monthly order volume, overall conversion rates, revenue per session, and a breakdown of sales by product, all for the time period since April 1, 2012 */

SELECT 
	YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT ws.website_session_id) as sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) as conv_rate,
    SUM(o.price_usd)/COUNT(DISTINCT ws.website_session_id) AS revenue_per_session,
    COUNT(CASE WHEN o.primary_product_id = 1 THEN o.order_id ELSE NULL END) as product_one_orders,
    COUNT(CASE WHEN o.primary_product_id = 2 THEN o.order_id ELSE NULL END) as product_two_orders
FROM website_sessions as ws
	LEFT JOIN orders AS o
		ON ws.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN "2012-04-01" AND "2013-04-01"
GROUP BY 1,2;

-- ------------------------------------------- --
-- 77. Analyzing Product-Level Website Pathing --
-- ------------------------------------------- --

SELECT 
	 -- website_session_id,
     ws.pageview_url,
     COUNT(DISTINCT ws.website_session_id) AS sessions,
     COUNT(DISTINCT o.order_id) AS orders,
     COUNT(DISTINCT o.order_id)/
		COUNT(DISTINCT ws.website_session_id) AS viewed_product_to_order_rate
FROM website_pageviews as ws
	LEFT JOIN orders as o
		ON ws.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN '2013-02-01' AND '2013-03-01'
	AND ws.pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear')
GROUP BY 1;

-- --------------------------------------------- --
-- 78. ASSIGNMENT: Product-Level Website Pathing --
-- --------------------------------------------- --

-- email: abril 06,2013
/* Now that we have a new product, I'm thinking about our user path and conversion funnel. Let's look at sessions which hit the /products page and see where they went next.
Could you please pull clickthrough rates from /products since the new product launch on january 6 2013, by product, and compare to the 3 months leading up to launch as a baseline?  */

-- Step 1: find the relevant /products pageviews with website_session_id
-- Step 2: finde the next pageview id that occurs AFTER the product pageview
-- Step 3: find the pageview_url associated with any applicable next pageview id
-- Step 4: summarize the data and analyze the pre vs post periods

-- Step 1: find the relevant /products pageviews with website_session_id
CREATE TEMPORARY TABLE products_pageviews
SELECT 
	website_session_id,
    website_pageview_id,
    created_at,
	CASE
		WHEN created_at < '2013-01-06' THEN 'A. Pre_Product_2'
        WHEN created_at >= '2012-10-06' THEN 'B. Post_Product_2'
        ELSE ' check logic'
	END AS time_period
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-06' AND '2013-04-06'
	AND pageview_url = '/products';

-- Step 2: find the next pageview id that occurs AFTER the product pageview
CREATE TEMPORARY TABLE sessions_w_next_pageview_id
SELECT 
	pp.time_period,
    pp.website_session_id,
    MIN(wp.website_pageview_id) AS min_next_pageview_id
FROM products_pageviews as pp
	LEFT JOIN website_pageviews as wp
    ON wp.website_session_id = pp.website_session_id
    AND wp.website_pageview_id > pp.website_pageview_id
GROUP BY 1,2;

-- Step 3: find the pageview_url associate with applicable next pageview id
CREATE TEMPORARY TABLE sessions_w_next_pageview_url
SELECT sessions_w_next_pageview_id.time_period,
	sessions_w_next_pageview_id.website_session_id,
    website_pageviews.pageview_url AS next_pageview_url
FROM sessions_w_next_pageview_id
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = sessions_w_next_pageview_id.min_next_pageview_id;
        
-- Step 4: summarize the data and analyze the pre vs post periods
SELECT 
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) as w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT website_session_id) AS pct_w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT website_session_id) AS pct_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT website_session_id) AS pct_to_lovebear
FROM sessions_w_next_pageview_url
GROUP BY 1;

-- --------------------------------------------------------- --
-- 80. ASSIGNMENT: Building Product-Level Conversion Funnels --
-- --------------------------------------------------------- --

-- email: abril 10,2014
/* I'd like to look at our two products since January 6th and analyze the conversion funnels from each product page to conversion.
It would be great if you could produce a comparison between the two conversion funnels, for all website traffic. */

-- Step 1: select all pageviews for relevant sessions
-- Step 2: figure out which pageview urls to look for 
-- Step 3: pull all pageviews and identify the funnel steps
-- Step 4: create the session-level conversion funnel view
-- Step 5: Aggregate the data to assess funnel performance

SELECT 
	DISTINCT pageview_url
FROM website_pageviews;

-- DROP TABLE sessions_seeing_product_pages;
-- DROP TABLE sessions_w_next_pageview_id;


-- Step 1: select all pageviews for relevant sessions
CREATE TEMPORARY TABLE sessions_seeing_product_pages 
SELECT 
	website_session_id,
	website_pageview_id,
	pageview_url AS product_page_seen
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
	AND pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear');

-- Step 2: figure out which pageview urls to look for 
-- DROP TABLE sessions_seeing_product_pages;

SELECT 
	DISTINCT wp.pageview_url
FROM sessions_seeing_product_pages AS sspp
	LEFT JOIN website_pageviews AS wp
		ON sspp.website_session_id = wp.website_session_id
		AND wp.website_pageview_id > sspp.website_pageview_id;


CREATE TEMPORARY TABLE pre_last        
SELECT
	sspp.website_session_id,
	sspp.product_page_seen,
	CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
FROM sessions_seeing_product_pages AS sspp
	LEFT JOIN website_pageviews AS wp
		ON sspp.website_session_id = wp.website_session_id
		AND wp.website_pageview_id > sspp.website_pageview_id
ORDER BY 
	sspp.website_session_id,
	wp.created_at;
    
-- drop TABLE pre_last;

SELECT 
	CASE 
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
        WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
		ELSE 'check logic'
	END AS product_seen,
	COUNT(DISTINCT website_session_id) as sessions,
    SUM(cart_page) as cart_page,
    SUM(cart_page)/COUNT(DISTINCT website_session_id) ws_to_cart,
    SUM(shipping_page) as shipping_page,
    SUM(shipping_page)/SUM(cart_page) cart_to_shipping,
    SUM(billing_page) as billing_page,
    SUM(billing_page)/SUM(shipping_page) shipping_to_billing,
    SUM(thank_you_page) as thank_you_page,
    SUM(thank_you_page)/SUM(billing_page) billing_thank_you_page
FROM pre_last
group by 1;

select *
from pre_last;


-- ------------------------------------ -- 

-- CREATE TEMPORARY TABLE session_product_level_made_it_flags
SELECT
	website_session_id,
    CASE 
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
        WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
		ELSE 'check logic'
	END AS product_seen,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) As billing_made_it,
    MAX(thank_you_page) AS thank_you_made_it
FROM(
SELECT
	sspp.website_session_id,
	sspp.product_page_seen,
	CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
FROM sessions_seeing_product_pages AS sspp
	LEFT JOIN website_pageviews AS wp
		ON sspp.website_session_id = wp.website_session_id
		AND wp.website_pageview_id > sspp.website_pageview_id
ORDER BY 
sspp.website_session_id,
wp.created_at
) AS pageview_level
GROUP BY 1,2;


-- ---------------------------------------------- --
-- 82. Cross-Selling & Product Portfolio Analysis --
-- ---------------------------------------------- --

SELECT 
    o.primary_product_id,
    oi.product_id as cross_sell_prod,
    COUNT(DISTINCT o.order_id) as orders
FROM orders as o
	LEFT JOIN order_items as oi
		ON oi.order_id = o.order_id
        AND oi.is_primary_item = 0 -- cross sell only
WHERE o.order_id BETWEEN 10000 AND 11000 -- arbitrary
GROUP BY 1,2;
;

SELECT 
	o.primary_product_id,
    COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN o.order_id ELSE NULL END) as x_sell_prod_1,
    COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN o.order_id ELSE NULL END) as x_sell_prod_1,
    COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN o.order_id ELSE NULL END) as x_sell_prod_3,
    
    COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN o.order_id ELSE NULL END)/COUNT(DISTINCT o.order_id) as x_sell_prod1_rt,
    COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN o.order_id ELSE NULL END)/COUNT(DISTINCT o.order_id) as x_sell_prod2_rt,
    COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN o.order_id ELSE NULL END)/COUNT(DISTINCT o.order_id) as x_sell_prod3_rt
FROM orders as o
	LEFT JOIN order_items as oi
		ON oi.order_id = o.order_id
        AND oi.is_primary_item = 0 -- cross sell only
WHERE o.order_id BETWEEN 10000 AND 11000 -- arbitrary
GROUP BY 1;

-- ----------------------------------- --
-- 83. ASSIGNMENT: Cross-Sell Analysis --
-- ----------------------------------- --

-- email: november 22, 2013
/* On September 25 we started giving customers the option to add a 2nd product while on the /cart page. Morgan says this has been positive, bur i'd like your take on it.
Could you please compare the month before vs the month after the change? i'd like to see CTR from /cart page AVG products per Order, AOV, and overall revenue per /cart page views */

-- STEP 1: Identify the relevant /cart page views and their sessions
-- STEP 2: See which of these /cart sessions clicked through to the shipping page
-- STEP 3: Find the orders associated with the /cart sessions. Analyse products purchased, AOV 
-- STEP 4: Aggregate and analyse a summary of our findings.


-- STEP 1: Identify the relevant /cart page views and their sessions
CREATE TEMPORARY TABLE sessions_seeing_cart
SELECT 
	CASE
		WHEN wp.created_at < '2013-09-25' THEN 'A. Pre_Product_2'
        WHEN wp.created_at >= '2013-01-06' THEN 'B. Post_Product_2'
        ELSE '...check logic'
	END AS time_period,
    wp.website_session_id,
	wp.website_pageview_id
FROM website_pageviews as wp
WHERE wp.created_at BETWEEN "2013-08-25" AND "2013-10-25"
	AND pageview_url = "/cart"
;
-- drop table sessions_seeing_cart;

-- STEP 2: See which of these /cart sessions clicked through to the shipping page

CREATE TEMPORARY TABLE cart_sessions_seeing_another_page 
SELECT 
	ssc.time_period,
    ssc.website_session_id,
    MIN(wp.website_pageview_id) AS pv_id_after_cart
FROM sessions_seeing_cart as ssc
	LEFT JOIN website_pageviews as wp
		ON wp.website_session_id = ssc.website_session_id
        AND wp.website_pageview_id > ssc.website_pageview_id
GROUP BY 
	1,2
HAVING 
	MIN(wp.website_pageview_id) IS NOT NULL;
    
-- drop table cart_sessions_seeing_another_page;
    
-- first, we'll look at this select statement
-- then we'll turn it into a subquery    
    
CREATE TEMPORARY TABLE pre_post_sessions_orders    
SELECT 
	ssc.time_period,
    ssc.website_session_id,
    o.order_id,
    o.items_purchased,
    o.price_usd
FROM sessions_seeing_cart as ssc
	INNER JOIN orders as o
		ON ssc.website_session_id = o.website_session_id;

drop table pre_post_sessions_orders;

SELECT 	
	ssc.time_period,
    ssc.website_session_id,
    CASE WHEN csap.website_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN ppso.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    ppso.items_purchased,
    ppso.price_usd
FROM sessions_seeing_cart as ssc
	LEFT JOIN cart_sessions_seeing_another_page as csap 
		ON ssc.website_session_id = csap.website_session_id
	LEFT JOIN pre_post_sessions_orders as ppso
		ON ssc.website_session_id = ppso.website_session_id
ORDER BY 
	 ssc.website_session_id;
		

SELECT 
	time_period,
    COUNT(DISTINCT website_session_id) as cart_sessions,
    SUM(clicked_to_another_page) AS clickthroughs,
    SUM(clicked_to_another_page)/COUNT(DISTINCT website_session_id) AS cart_ctr,
    SUM(placed_order) AS orders_placed,
    SUM(items_purchased) AS products_purchased,
    SUM(items_purchased)/SUM(placed_order) AS productss_per_order,
    SUM(price_usd) AS revenue,
    SUM(price_usd)/SUM(placed_order) AS aov,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS rev_per_cart_session
FROM (
SELECT 	
	ssc.time_period,
    ssc.website_session_id,
    CASE WHEN csap.website_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN ppso.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    ppso.items_purchased,
    ppso.price_usd
FROM sessions_seeing_cart as ssc
	LEFT JOIN cart_sessions_seeing_another_page as csap 
		ON ssc.website_session_id = csap.website_session_id
	LEFT JOIN pre_post_sessions_orders as ppso
		ON ssc.website_session_id = ppso.website_session_id
ORDER BY 
	 ssc.website_session_id
) AS full_data
GROUP BY 
	time_period;
    
-- ------------------------------------------- --
-- 85. ASSIGNMENT: Product Portfolio Expansion --
-- ------------------------------------------- --

-- email: january 12, 2014
/* On December 12th 2013, we launched a third product targeting the birthday market (Birthday Bear).
Could you please run a pre-post analysis comparing the month before vs. the month after, in terms of session-to-order conversion rate, AOV, products per order, and revenue per session?  */
    

SELECT 
	CASE
		WHEN ws.created_at < '2013-12-12' THEN 'A. Pre_Birthday_Bear'
        WHEN ws.created_at >= '2013-12-12' THEN 'B. Post_Birthday_Bear'
        ELSE '...check logic'
	END AS time_period,
	-- COUNT(DISTINCT ws.website_session_id) as sessions,
	-- COUNT(DISTINCT o.order_id) as orders, 
	COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) as conv_rate,
	-- SUM(o.price_usd) AS total_revenue,
	-- SUM(o.items_purchased) AS total_products_sold,
	SUM(o.price_usd)/COUNT(o.order_id) as avg_order_value,
	SUM(o.items_purchased)/COUNT(DISTINCT o.order_id) AS products_per_order,
	SUM(o.price_usd)/ COUNT(DISTINCT ws.website_session_id) AS revenuw_per_session
    
FROM website_sessions as ws
	LEFT JOIN orders as o
		on o.website_session_id = ws.website_session_id
WHERE ws.created_at BETWEEN "2013-11-12" AND "2014-01-12"
GROUP BY 1;


-- ---------------------------------- --
-- 87. Analyzing Product Refund Rates --
-- ---------------------------------- --

SELECT 	
	oi.order_id,
    oi.order_item_id,
    oi.price_usd AS price_paid_usd,
    oi.created_at,
	oir.order_item_refund_id,
    oir.refund_amount_usd,
    oir.created_at
FROM order_items as oi
	LEFT JOIN order_item_refunds as oir
		ON oir.order_item_id = oi.order_item_id
WHERE oi.order_id IN(3489,32049,27061);

-- ---------------------------------------------- --
-- 88. ASSIGNMENT: Analyzing Product Refund Rates --
-- ---------------------------------------------- --

-- email: october 15, 2014
/* Our mr. fuzzy supplier had some quality issues which werent corrected until september 2013. 
Then they had a major problem where the bears arms were falling off in Aug/Sep 2014. 
As a result, we replaced them with a new supplier on september 16, 2014.
Can you pull montly product refund rates, by product, and confirm our quality issues are now fixed? */

SELECT 
	YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN o.order_id ELSE NULL END) as p1_orders,
    -- COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN oir.order_item_refund_id ELSE NULL END) as p1_refunded,
    COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN oir.order_item_refund_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN o.order_id ELSE NULL END) as p1_refund_rt,
    COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN o.order_id ELSE NULL END) as p2_orders,
    -- COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN oir.order_item_refund_id ELSE NULL END) as p2_refunded,
    COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN oir.order_item_refund_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN o.order_id ELSE NULL END) as p2_refund_rt,
    COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN o.order_id ELSE NULL END) as p3_orders,
    -- COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN oir.order_item_refund_id ELSE NULL END) as p3_refunded,
    COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN oir.order_item_refund_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN o.order_id ELSE NULL END) as p3_refund_rt,
    COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN o.order_id ELSE NULL END) as p4_orders,
    -- COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN oir.order_item_refund_id ELSE NULL END) as p4_refunded,
    COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN oir.order_item_refund_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN o.order_id ELSE NULL END) as p4_refund_rt
FROM website_sessions as ws
	LEFT JOIN orders as o
		on o.website_session_id = ws.website_session_id
	LEFT JOIN order_items as oi
		on oi.order_id = o.order_id
	LEFT JOIN order_item_refunds as oir
		ON oir.order_item_id = oi.order_item_id
WHERE ws.created_at < "2014-10-15"
GROUP BY 1, 2;


