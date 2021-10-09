/* 
with all this great data, I would love to be able to quickly pull together the total orders and revenue for a given time period. 
I'm not a SQL guru though.
Is there a way I could specify a startDate and endDate and see total orders and revenue during that period?
*/

-- drop procedure order_performance;

DELIMITER //
CREATE PROCEDURE order_performance(IN startdate DATE, IN enddate DATE)
BEGIN
SELECT 
	COUNT(order_id) AS total_orders,
    SUM(price_usd) AS total_revenue
FROM orders
WHERE DATE(created_at) BETWEEN startdate AND enddate;

END //

DELIMITER ;

CALL order_performance('2013-11-01', '2013-12-31');