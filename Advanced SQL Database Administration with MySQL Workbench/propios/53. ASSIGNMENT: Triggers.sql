USE mavenbearbuilders;

/*
Email: JAnuary 05, 2014
Subject: Automation to update orders table
Would you be able to set up some automation so that anytime order_items records are inserted into the database,
the orders 
*/

CREATE TRIGGER INSERT_NEW_orders
AFTER INSERT ON order_items
FOR EACH ROW
REPLACE INTO orders
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
WHERE order_id = new.order_id
GROUP BY 1
ORDER BY 1;



CREATE TRIGGER purchaseUpdatePurchaseSummary_after
AFTER INSERT
ON customer_purchases
FOR EACH ROW
UPDATE purchase_summary
	SET total_purchases = (
		SELECT COUNT(customer_purchase_id)
		FROM customer_purchases WHERE customer_purchases.customer_id = purchase_summary.customer_id
			)
WHERE customer_id = NEW.customer_id
AND purchase_summary_id > 0;

/*
Email: March 01, 2014
Subject: Putting your automation to the test
It's time to see if your trigger to sync the order_items and orders tables is working correctly.
Why don't you go ahead and update the order_items and order_item_refunds tables with the attached data 
and we'll see how everything is working.
*/

-- you should see 10033 records before trigger fires
SELECT COUNT(*) AS total_records FROM orders;

-- then, test the trigger by inserting into orer_items

-- TIP: after insert, find the max order_id
SELECT MAX(order_id) AS MAX_order_id
FROM order_items;

-- You should see new row count that matches max_ord