USE thriftshop;

SELECT *
FROM inventory;

-- tres formas de insertar datos

INSERT INTO inventory (inventory_id, item_name, number_in_stock) VALUES
(10,'wolf skin hat',1);

INSERT INTO inventory VALUES
(11,'fur fox skin',1),
(12,'plaid button up shirt',8),
(13,'flannel zebra jammies', 6);

INSERT INTO inventory (inventory_id, item_name) VALUES
(14,'wolf skin sneakers');

INSERT INTO inventory (inventory_id, item_name, number_in_stock) VALUES
(15,'item that will not exist',2);
