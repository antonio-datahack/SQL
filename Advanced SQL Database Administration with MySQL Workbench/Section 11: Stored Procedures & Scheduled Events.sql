CREATE SCHEMA schema_for_events;

CREATE TABLE sillytable (
timestamps_via_events DATETIME
);

CREATE EVENT myfirstevent
	ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 5 second
    DO 
		INSERT INTO sillytable VALUES (NOW());
        
SELECT * FROM sillytable;


CREATE EVENT mysecondevent
	ON SCHEDULE EVERY 5 second
    DO 
		INSERT INTO sillytable VALUES (NOW());
        
DROP EVENT mysecondevent;