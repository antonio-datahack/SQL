USE mavenbearbuilders;

SELECT * FROM order_items;

/* 
1) import Q2 orders and refunds into the database using the files below:
-- 08.order_items_2013_apr-June
-- 08.order_item_refunds_2013_apr-June
*/
-- Deleting Foreign key to import the new data

ALTER TABLE `mavenbearbuilders`.`order_items` 
DROP FOREIGN KEY `order_items_product_id`;
ALTER TABLE `mavenbearbuilders`.`order_items` 
DROP INDEX `order_items_product_id_idx` ;
;


-- Establishing foreign key again

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
2) Next, help update the structure of the order_items table:
-- The company is going to start cross-selling products and will want to track... 
-- ... whether each item sold is the primary item (the first one put into user's shopping cart) or a cross-sold item

-- Add a binary column to the order_items table called is _primary_item

*/

ALTER TABLE order_items
ADD COLUMN is_primary_item INT;

/*
3) Update all previous records in the order_items table, setting is_primary_item = 1 for all records 

-- Up until now, all items sold were the primary item (since cross-selling is new)

-- confirm this change has execute succesfully 
*/


UPDATE order_items
SET is_primary_item = 1
WHERE order_item_id > 0;

SELECT * FROM order_items;

/* Add two new products to the products table, then import the remainder of 2013 orders ad refunds, using the products detail and files show below:
-- 10.orders_items_2013_Jul-Dec
-- 11.orders_items_refunds_2013_Jul-Dec
*/ 

SELECT * FROM products;

INSERT INTO products VALUES 
(3,'2013-12-12 09:00:00','The Birthday Sugar Panda'), 
(4,'2014-02-05 10:00:00','The Hudson River Mini bear');

SELECT *
FROM order_item_refunds;

ALTER TABLE order_item_refunds
CHANGE COLUMN refund_amount_id refund_amount_usd DECIMAL(6,2);

SELECT COUNT(*),
	MAX(created_at) as most_recent_created_at
FROM order_item_refunds;


/*
5) Your CEO would like to make sure the database has a high degree od data integrity and avoid potential issues as more people start using the database.
If you see any opportunities to ensure data integrity
 by using constrains like NON-NULL, add them to the relevants columns in the table ypu have created.
 */
 
 -- esto se puede hacer directamente desde la consola de workbench
ALTER TABLE `mavenbearbuilders`.`products` 
CHANGE COLUMN `create_at` `create_at` DATETIME NOT NULL ,
CHANGE COLUMN `product_name` `product_name` VARCHAR(120) NOT NULL ,
ADD UNIQUE INDEX `product_name_UNIQUE` (`product_name` ASC) VISIBLE;
;

-- al de order_items lo hice directamente desde la consola

-- order_item_refunds
ALTER TABLE `mavenbearbuilders`.`order_item_refunds` 
DROP FOREIGN KEY `order_items_refunds_order_items`;
ALTER TABLE `mavenbearbuilders`.`order_item_refunds` 
CHANGE COLUMN `created_at` `created_at` DATETIME NOT NULL ,
CHANGE COLUMN `order_item_id` `order_item_id` BIGINT NOT NULL ,
CHANGE COLUMN `order_id` `order_id` BIGINT NOT NULL ,
CHANGE COLUMN `refund_amount_usd` `refund_amount_usd` DECIMAL(6,2) NOT NULL ,
ADD UNIQUE INDEX `order_item_id_UNIQUE` (`order_item_id` ASC) VISIBLE;
;
ALTER TABLE `mavenbearbuilders`.`order_item_refunds` 
ADD CONSTRAINT `order_items_refunds_order_items`
  FOREIGN KEY (`order_item_id`)
  REFERENCES `mavenbearbuilders`.`order_items` (`order_item_id`);

 
/* 
6) One of the company's board asvisors is pressuring your CEO on data risk and making sure she has a great backup and recovery plan. 
Prepare a report on possible risks for data loss and steps the company can take to mitigate these concerns.
*/
