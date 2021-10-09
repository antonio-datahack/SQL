USE thriftshop;

SELECT * FROM inventory;

UPDATE inventory
SET number_in_stock = 0 -- we sold out
WHERE inventory_id IN (1,9);

UPDATE inventory
SET number_in_stock = 0 -- we sold out
WHERE item_name = "fur coat";
-- Esto no funciona bien... siempre es mejor borrar o hacer un update usando la PK