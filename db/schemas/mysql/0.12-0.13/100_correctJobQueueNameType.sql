--
-- correct Name in JobQueue table
--
ALTER TABLE JobQueue MODIFY COLUMN NAME VARCHAR(255) NOT NULL default '';

