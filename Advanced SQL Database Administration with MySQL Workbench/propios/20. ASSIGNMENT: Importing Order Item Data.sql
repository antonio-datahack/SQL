CREATE SCHEMA mavenbearbuilders;

USE mavenbearbuilders;

CREATE TABLE order_items (
	order_item_id BIGINT,
    created_at TIMESTAMP,
    order_id BIGINT,
    price_usd DECIMAL(6,2),
    cogs_usd DECIMAL(6,2),
    website_session_id BIGINT,
    PRIMARY KEY (order_item_id)
);

SELECT * FROM order_items;

SELECT
	MIN(created_at),
    MAX(created_at)
FROM order_items;

/*
Email: April 5, 2012
Now that we have order_items built out, could you also import this attached April refund data (weren't any in March) in a new table called order_item_refunds?
It will be great to start tracking refund rates better so we can keep an eye on product quality. 
*/

CREATE TABLE order_item_refunds (
	order_item_refund_id BIGINT,
    created_at DATETIME,
    order_item_id BIGINT,
    order_id BIGINT,
    refund_amount_id DECIMAL(6,2),
    PRIMARY KEY (order_item_refund_id),
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id)
);

SELECT * FROM order_item_refunds;

/*
Email: April 8, 2012
Turns out the new guy messed up some of our data. He flagged order_items 131, 132, 145, 151 and 153 as refunds, but they were actually customer inquires. 
Can you remove these from order_item_refunds to clean our data?
*/

DELETE FROM order_item_refunds 
WHERE order_item_refund_id BETWEEN 6 AND 10;

/*
Email: January 02, 2013
The business finished 2012 strong, and I would like to get all of our order_items and order_item_refunds data updated through the end of the year.
Can you help me import the 2 attached files into the correct tables?
*/

SELECT 
	MAX(created_at),
    COUNT(*) AS records
    
FROM order_items;
-- 159

SELECT 
	MAX(created_at),
    COUNT(*) AS records
    
FROM order_item_refunds;
-- 5
