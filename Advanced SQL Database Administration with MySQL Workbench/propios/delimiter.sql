USE thriftshop;


DELIMITER //

CREATE PROCEDURE sp_selectALLInventory()
BEGIN
SELECT * FROM inventory;
END // 

DELIMITER ;

CALL sp_selectALLInventory;

SELECT * FROM rental
WHERE customer_id = 135;

DELIMITER // 

CREATE PROCEDURE customer_rentals
(IN custid BIGINT)
BEGIN
SELECT * FROM rental WHERE customer_id = custid;
END //

DELIMITER ;

CALL customer_rentals(40);

DELIMITER // 

CREATE PROCEDURE customer_rentals_w_total
(IN custid BIGINT, OUT total_rentals BIGINT)
BEGIN
SELECT COUNT(rental_id) INTO total_rentals FROM rental WHERE customer_id = custid;

SELECT * FROM rental WHERE customer_id = custid;
END //

DELIMITER ;

CALL customer_rentals_w_total(50,@total_rentals);

SELECT @total_rentals;