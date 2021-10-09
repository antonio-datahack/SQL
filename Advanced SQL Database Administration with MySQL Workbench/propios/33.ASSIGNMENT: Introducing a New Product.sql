/* 
Cardinality refers to the uniqueness of values in a column (or attribute) of a table and is commonly used to describe how to tables relate (one-to-one, 
or many-to-many). 
*/

/*
Email: January 05, 2013
Tomorrow we're launching a new product called The Forever Love Bear to complement The Original Mr. Fuzzy.
Could you please create a product table in the database? 
Track when they lanched (2012-03-09 at 9am and 2013-01-06 at 1pm, respectively), 
the product name, and assign an id so we can link to other tables later.
*/
USE mavenbearbuilders;

CREATE TABLE products (
	product_id BIGINT,
    create_at DATETIME,
    product_name VARCHAR(120),
    PRIMARY KEY (product_id)
);

INSERT INTO products VALUES
(1,"2012-03-19 09:00:00", "The Original Mr. Fuzzy"),
(2,"2013-01-06 13:00:00", "The Forever Love Bear");

SELECT * FROM products;

