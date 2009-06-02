--
-- revert to non-autoincrement JobID
--
ALTER TABLE JobQueue MODIFY COLUMN ID INTEGER UNSIGNED NOT NULL;

--
-- drop MESSAGE field
--
ALTER TABLE JobQueue DROP COLUMN MESSAGE;

