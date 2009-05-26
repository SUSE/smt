--
-- create patchstatus table (successor of the TYPE field in MachineData)
--
create table Patchstatus ( CLIENT_ID    INTEGER UNSIGEND NOT NULL PRIMARY KEY,
                           PKGMGR       INTEGER UNSIGNED NULL default 0,
                           SECURITY     INTEGER UNSIGNED NULL default 0,
                           RECOMMENDED  INTEGER UNSIGNED NULL default 0,
                           OPTIONAL     INTEGER UNSIGNED NULL default 0
                         );

--
-- drop type column from MachineData table as it will not be used due to the new Patchstatus table
--
alter table MachineData DROP COLUMN TYPE;

