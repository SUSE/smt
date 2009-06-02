--
-- revert Name in JobQueue table
--
ALTER TABLE JobQueue MODIFY COLUMN NAME CHAR NOT NULL default '';
