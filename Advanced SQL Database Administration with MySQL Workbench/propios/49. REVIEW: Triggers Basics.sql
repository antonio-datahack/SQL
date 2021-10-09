USE thriftshop;

/* 
CREATE TRIGGER trigger_name
{BEFORES|AFTER}{INSERT|UPDATE|DELETE}
ON table_name
FOR EACH ROW
{{FOLLOWS|PRECEDES} existing_trigger_name}}
[[some statement we want to wxwcute by trigger]]
WHERE column_name = {OLD|NEW}.column_name

*/

SELECT * FROM customer_purchases;

SELECT * FROM purchase_summary;

DROP TRIGGER purchaseUpdatePurchaseSummary_before;

CREATE TRIGGER purchaseUpdatePurchaseSummary_before
BEFORE INSERT
ON customer_purchases
FOR EACH ROW
UPDATE purchase_summary
	SET purchase_excluding_last = (
		SELECT COUNT(customer_purchase_id)
		FROM customer_purchases WHERE customer_purchases.customer_id = purchase_summary.customer_id
			)
WHERE customer_id = NEW.customer_id
AND purchase_summary_id > 0; -- this is just to handle safe update mode

DROP TRIGGER purchaseUpdatePurchaseSummary_after;
    
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
AND purchase_summary_id > 0; -- this is just to handle safe update modeWHERE customer_id = NEW.customer_id;

SELECT * FROM purchase_summary;

INSERT INTO customer_purchases VALUES
(13,6,4); -- is giving me an error, I'm going to set up a primary key

ALTER TABLE `thriftshop`.`purchase_summary` 
ADD PRIMARY KEY (`purchase_summary_id`);
; 