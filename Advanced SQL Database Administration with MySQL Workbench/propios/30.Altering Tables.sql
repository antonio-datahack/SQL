USE thriftshop;

ALTER TABLE customer_purchases
DROP COLUMN customer_id;

SELECT * FROM customer_purchases;

ALTER TABLE customer_purchases
ADD COLUMN purchase_amount DECIMAL(10,2) AFTER customer_purchase_id;
-- Everytime you add a column you need to specify de data tipe

ALTER TABLE customer_purchases
ADD COLUMN purchased_at DATETIME;

ALTER TABLE customer_purchases
DROP COLUMN purchase_amount_two;