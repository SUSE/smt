--
-- drop patchstatus table
--
DROP TABLE IF EXISTS Patchstatus;

--
-- add TYPE column - it was never used, only here for consistent DB migration
--
alter table MachineData add COLUMN TYPE INTEGER UNSIGNED NOT NULL default 0;

