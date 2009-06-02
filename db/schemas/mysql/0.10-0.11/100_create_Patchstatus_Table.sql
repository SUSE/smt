--
-- create patchstatus table (successor of the TYPE field in MachineData)
--
create table Patchstatus ( CLIENT_ID    INTEGER UNSIGNED NOT NULL PRIMARY KEY,
                           PKGMGR       INTEGER UNSIGNED NOT NULL default 0,
                           SECURITY     INTEGER UNSIGNED NOT NULL default 0,
                           RECOMMENDED  INTEGER UNSIGNED NOT NULL default 0,
                           OPTIONAL     INTEGER UNSIGNED NOT NULL default 0
                         );

--
-- drop type column from MachineData table as it will not be used due to the new Patchstatus table
--
alter table MachineData DROP COLUMN TYPE;


--
-- JobQueue has to have an auto-incrementing primary key
--
ALTER TABLE JobQueue MODIFY COLUMN ID INTEGER UNSIGNED NOT NULL AUTO_INCREMENT;
