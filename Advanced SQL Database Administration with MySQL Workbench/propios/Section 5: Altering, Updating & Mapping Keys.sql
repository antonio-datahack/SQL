USE mavenbearbuilders;

/* 
Cardinality refers to the uniqueness of values in a column (or attribute) of a table and is commonly used to describe how to tables relate (one-to-one, 
or many-to-many). 
*/

-- --------------------------------------- --
-- 34. SOLUTION: Introducing a New Product --
-- --------------------------------------- --

/*
Email: January 05, 2013
Tomorrow we're launching a new product called The Forever Love Bear to complement The Original Mr. Fuzzy.
Could you please create a product table in the database? 
Track when they lanched (2012-03-09 at 9am and 2013-01-06 at 1pm, respectively), 
the product name, and assign an id so we can link to other tables later.
*/

CREATE TABLE products (
	product_id BIGINT,
    create_at DATETIME,
    product_name VARCHAR(120),
    PRIMARY KEY (product_id)
);

INSERT INTO products VALUES
(1,"2012-03-19 09:00:00", "The Original Mr. Fuzzy"),
(2,"2013-01-06 13:00:00", "The Forever Love Bear");

-- -------------------------------------------- --
-- 35 ASSIGNMENT: Adding Product to Order Items --
-- -------------------------------------------- --

/*
Email: January 06, 2013
Later today, we'll have multiples products selling, I would love to be hable to tie our order_items data to the product sold.
Can you please add product_id to the order_items table?
*/


SELECT * FROM order_items;

ALTER TABLE order_items
DROP COLUMN product_it;

-- --------------------------------------- --
-- 37.Updating Product Data in Order Items --
-- --------------------------------------- --

/*
Email: January 07, 2013
Subject: Back-populate sales with product_id
All of the sales reflected in the database are for product 1, so could you update the records to reflect that?
Then we'll have a perfect data to use in the future
*/


UPDATE order_items
SET product_id = 1
WHERE order_item_id >= 1;

-- -------------------------------------------------- --
-- 39. ASSIGNMENT: Primary Key to Foreign Key Mapping --
-- -------------------------------------------------- --

/*
Email: January 07, 2013
Subject: Primary and foreign keys?
I would like to make sure the newly-related order_items and products tables have right relationships specified in the database.
Can you set up the proper primary and foreign key relationships between those two tables?
*/

SET FOREIGN_KEY_CHECKS=0;

ALTER TABLE `mavenbearbuilders`.`order_items` 
ADD INDEX `order_items_product_id_idx` (`product_id` ASC) VISIBLE;
;
ALTER TABLE `mavenbearbuilders`.`order_items` 
ADD CONSTRAINT `order_items_product_id`
  FOREIGN KEY (`product_id`)
  REFERENCES `mavenbearbuilders`.`products` (`product_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
  
SET FOREIGN_KEY_CHECKS=1;

/*
Email: April 1, 2013
Subject: Help get order data into database
Now that you've done all the work to get our products and order_items tables synced up, 
let's import the attached Q1 data into order_items and order_item_refunds.
Really curious to start digging into sales trends!
*/

SELECT COUNT(*) AS total_records FROM order_items;

SELECT COUNT(*) AS total_records FROM order_item_refunds;

SELECT * FROM order_item_refunds;

ALTER TABLE order_item_refunds
RENAME COLUMN refund_amount_id TO refund_amount_usd;

CREATE TABLE order_item_refunds (
	order_item_refund_id BIGINT,
    created_at DATETIME,
    order_item_id BIGINT,
    order_id BIGINT,
    refund_amount_id DECIMAL(6,2),
    PRIMARY KEY (order_item_refund_id)
);

ALTER TABLE `mavenbearbuilders`.`order_item_refunds` 
ADD INDEX `order_items_refunds_order_items_idx` (`order_item_id` ASC) VISIBLE;
;
ALTER TABLE `mavenbearbuilders`.`order_item_refunds` 
ADD CONSTRAINT `order_items_refunds_order_items`
  FOREIGN KEY (`order_item_id`)
  REFERENCES `mavenbearbuilders`.`order_items` (`order_item_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
  
ALTER TABLE `mavenbearbuilders`.`order_items` 
ADD INDEX `order_items_product_id_idx` (`product_id` ASC) VISIBLE;
;
ALTER TABLE `mavenbearbuilders`.`order_items` 
ADD CONSTRAINT `order_items_product_id`
  FOREIGN KEY (`product_id`)
  REFERENCES `mavenbearbuilders`.`products` (`product_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
  
SET FOREIGN_KEY_CHECKS=1;