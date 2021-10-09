SET SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES,ONLY_FULL_GROUP_BY';

-- This basically tells mysql to behave like a traditional database.

SET GLOBAL max_allowed_packet = 1073741824;

SELECT @@max_allowed_packet;
