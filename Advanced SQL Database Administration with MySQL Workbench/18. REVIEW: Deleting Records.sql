USE thriftshop;

SELECT * FROM inventory;

SELECT @@autocommit; -- it's going to return either a one or a zero, and that's whether auto permit is turned off or turnet on.

SET autocommit = 1;

-- I can use either the number 1 or 0, or the words ON or OFF
-- !!!!! If I dont have autocommit on, I will need to run a commit statement as well. And until I run that commit statement, my changes can be considered temporary.

DELETE FROM inventory
WHERE inventory_id = 7;

-- I can probably get an error that say's that I am traying to run a delete statement using safe mode...
-- ... and targeting records that are not using a primary key. GOOD TIP: always run these deletes using the primary key if i can.

ROLLBACK;

COMMIT;
-- After I run this, the rollback is going to be no longer effective because that delection will be considered permanent

INSERT INTO inventory VALUES
(7,'ski blanket',1);