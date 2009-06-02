--
-- add missing autoincrement to JobID field
--
ALTER TABLE JobQueue MODIFY COLUMN ID INTEGER UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- add forgotten MESSAGE field
--
ALTER TABLE JobQueue ADD COLUMN MESSAGE MEDIUMTEXT;
