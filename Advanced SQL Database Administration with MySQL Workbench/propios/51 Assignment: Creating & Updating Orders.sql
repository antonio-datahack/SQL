/* 
Email: JAnuary 03, 2014
Subject: Create and orden summary table
Morning!Now that we're selling multiple products, it would be great to have a table summarizing full orders.
Can you create a table to capture order_id, a create_at timestamp, website_session_id, primary product_id, # of items purchased, 
price and cogs in USD?
Could you also back-populate the table using the records from our orders_items table?
*/ 
USE mavenbearbuilders;

CREATE TABLE orders(
	order_id BIGINT,
    created_at DATETIME,
    website_session_id BIGINT,
    primary_product_id BIGINT,
    items_purchased BIGINT,
    price_usd DECIMAL(6,2),
    cogs_usd DECIMAL(6,2),
    PRIMARY KEY (order_id)
);
-- back-populating the orders table

INSERT INTO orders
SELECT 
	order_id,
    MIN(created_at) AS created_at,
    MIN(website_session_id) AS website_session_id,
    SUM(CASE
		WHEN is_primary_item = 1 THEN product_id
        ELSE NULL
        END),
	COUNT(order_item_id) AS items_purchased,
    SUM(price_usd) AS price_usd,
    SUM(cogs_usd) AS cogs_usd
FROM order_items
GROUP BY 1
ORDER BY 1;

SELECT * FROM order_items;
SELECT * FROM orders;