USE mavenbearbuilders;

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

-- You should see new row count that matches max_order_id
SELECT COUNT(*) AS total_records FROM orders;


