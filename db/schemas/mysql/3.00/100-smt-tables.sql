
drop table if exists Catalogs;
drop table if exists Filters;
drop table if exists JobQueue;
drop table if exists Products;
drop table if exists ProductCatalogs;
drop table if exists Registration;
drop table if exists MachineData;
drop table if exists Targets;
drop table if exists Clients;

drop table if exists Subscriptions;
drop table if exists ClientSubscriptions;

drop table if exists RepositoryContentData;

drop table if exists StagingGroups;

CREATE TABLE migration_schema_version (
          name varchar(128) NOT NULL,
          version double NOT NULL,
          CONSTRAINT migration_schema_version_name_pk PRIMARY KEY (name)
) ENGINE=InnoDB;
insert into migration_schema_version ('smt', 3.00);

-- integer id for "Clients" for faster joins compared to GUID with CHAR(50)
--    GUID remains primary key until all code that deals with GUIDs gets adapted
--    all new tables refering to a Client should use Clients.ID from now on
create table Clients(ID          INT UNSIGNED AUTO_INCREMENT,
                     GUID        CHAR(50),
                     HOSTNAME    VARCHAR(100) DEFAULT '',
                     TARGET      VARCHAR(100),
                     DESCRIPTION VARCHAR(500) DEFAULT '',
                     LASTCONTACT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                     NAMESPACE   VARCHAR(300) NOT NULL DEFAULT '',
                     SECRET      CHAR(50) NOT NULL DEFAULT '',
                     REGTYPE     CHAR(10) NOT NULL DEFAULT 'SR', -- SR = SuseRegister, SC = SUSEConnect
                     CONSTRAINT Clients_guid_pk PRIMARY KEY (GUID),
                     UNIQUE INDEX Clients_id_uq (ID)
                    ) ENGINE=InnoDB;


create table Subscriptions(SUBID          CHAR(50),
                           REGCODE        VARCHAR(100),
                           SUBNAME        VARCHAR(100) NOT NULL,
                           SUBTYPE        CHAR(20)  DEFAULT "UNKNOWN",
                           SUBSTATUS      CHAR(20)  DEFAULT "UNKNOWN",
                           SUBSTARTDATE   TIMESTAMP NULL default NULL,
                           SUBENDDATE     TIMESTAMP NULL default CURRENT_TIMESTAMP,
                           SUBDURATION    BIGINT    DEFAULT 0,
                           SERVERCLASS    CHAR(50),
                           PRODUCT_CLASS  VARCHAR(100),
                           NODECOUNT      integer NOT NULL,
                           CONSUMED       integer DEFAULT 0,
                           CONSUMEDVIRT   integer DEFAULT 0,
                           CONSTRAINT Subscriptions_subid_pk PRIMARY KEY (SUBID),
                           INDEX Subscriptions_product_class_idx (PRODUCT_CLASS)
                          ) ENGINE=InnoDB;

create table ClientSubscriptions(GUID    CHAR(50) NOT NULL,
                                 SUBID   CHAR(50) NOT NULL,
                                 CONSTRAINT ClientSubscriptions_guid_subid_pk PRIMARY KEY(GUID, SUBID)
                                ) ENGINE=InnoDB;

create table Registration(GUID         CHAR(50) NOT NULL,
                          PRODUCTID    integer NOT NULL,
                          REGDATE      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          NCCREGDATE   TIMESTAMP NULL default NULL,
                          NCCREGERROR  integer DEFAULT 0,
                          CONSTRAINT Registration_guid_productid_pk PRIMARY KEY(GUID, PRODUCTID)
                         ) ENGINE=InnoDB;

create table MachineData(GUID          CHAR(50) NOT NULL,
                         KEYNAME       CHAR(50) NOT NULL,
                         VALUE         BLOB,
                         CONSTRAINT MachineData_guid_keyname_pk PRIMARY KEY(GUID, KEYNAME)
                        ) ENGINE=InnoDB;

-- used for NU catalogs and single RPMMD sources
create table Catalogs(ID          INT AUTO_INCREMENT,
                      CATALOGID   CHAR(50),
                      NAME        VARCHAR(200) NOT NULL,
                      DESCRIPTION VARCHAR(500),
                      TARGET      VARCHAR(100),           -- null in case of single RPMMD source
                      LOCALPATH   VARCHAR(300) NOT NULL,
                      EXTHOST     VARCHAR(300) NOT NULL,
                      EXTURL      VARCHAR(300) NOT NULL,  -- where to mirror from
                      CATALOGTYPE CHAR(10) NOT NULL,
                      DOMIRROR    CHAR(1) DEFAULT 'N',
                      MIRRORABLE  CHAR(1) DEFAULT 'N',
                      SRC         CHAR(1) DEFAULT 'N',    -- N NCC    C Custom
                      STAGING     CHAR(1) DEFAULT 'N',    -- N No  Y Yes
                      AUTOREFRESH CHAR(1) DEFAULT 'Y',
                      LAST_MIRROR TIMESTAMP NULL DEFAULT NULL,
                      AUTHTOKEN   VARCHAR(512),
                      CONSTRAINT Catalogs_id_pk PRIMARY KEY (ID),
                      UNIQUE INDEX Catalogs_name_target_uq (NAME, TARGET),
                      UNIQUE INDEX Catalogs_catalogid_src_uq (CATALOGID, SRC)
                     ) ENGINE=InnoDB;

create table StagingGroups(ID            INT NOT NULL AUTO_INCREMENT,
                           NAME          VARCHAR(255) NOT NULL,
                           TESTINGDIR    VARCHAR(255) NOT NULL,
                           PRODUCTIONDIR VARCHAR(255) NOT NULL,
                           CONSTRAINT StagingGroups_id_pk PRIMARY KEY(ID),
                           UNIQUE INDEX StagingGroups_name_uq (NAME),
                           UNIQUE INDEX StagingGroups_testingdir_uq (TESTINGDIR),
                           UNIQUE INDEX StagingGroups_productiondir_uq (PRODUCTIONDIR)
                          ) ENGINE=InnoDB;

insert into StagingGroups(ID, NAME, TESTINGDIR, PRODUCTIONDIR)
values(1, "default", "testing", "");

-- Package filters
--
-- One record represents a filter element. Filter elements referencing the same
-- CATALOG_ID make up the whole filter.
--
-- TYPE is one of
--   1 name exact
--   2 name regex
--   3 name-version exact (covers also patch ID)
--   4 patch security level (patch only)
--
create table Filters(ID              INT NOT NULL AUTO_INCREMENT,
                     CATALOG_ID      INT NOT NULL,
                     TYPE            INT NOT NULL DEFAULT 1,
                     VALUE           VARCHAR(255),
                     STAGINGGROUP_ID INT NOT NULL DEFAULT 1,
                     CONSTRAINT Filters_id_pk PRIMARY KEY(ID),
                     UNIQUE INDEX Filters_cid_sgid_type_value_uq (CATALOG_ID, STAGINGGROUP_ID, TYPE, VALUE)
                    ) ENGINE=InnoDB;


-- copy of NNW_PRODUCT_DATA
create table Products (
                ID              integer NOT NULL AUTO_INCREMENT,
                PRODUCTDATAID   integer NOT NULL,
                PRODUCT         VARCHAR(500) NOT NULL,
                VERSION         VARCHAR(100),
                REL             VARCHAR(100),
                ARCH            VARCHAR(100),
                PRODUCTLOWER    VARCHAR(500) NOT NULL,
                VERSIONLOWER    VARCHAR(100),
                RELLOWER        VARCHAR(100),
                ARCHLOWER       VARCHAR(100),
                FRIENDLY        VARCHAR(700),
                CPE             VARCHAR(255),
                EULA_URL        VARCHAR(255),
                PARAMLIST       TEXT,
                NEEDINFO        TEXT,
                SERVICE         TEXT,
                DESCRIPTION     TEXT,
                PRODUCT_LIST    CHAR(1),
                PRODUCT_CLASS   CHAR(50),
                PRODUCT_TYPE    VARCHAR(100) NOT NULL DEFAULT '',
                FORMER_IDENTIFIER VARCHAR(500) NOT NULL DEFAULT '',
                SRC         CHAR(1) DEFAULT 'N',    -- N NCC   C Custom
                CONSTRAINT Products_id_pk PRIMARY KEY (ID),
                UNIQUE INDEX Products_pdl_verl_rell_archl_uq (PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER),
                UNIQUE INDEX Products_productdataid_src_uq(PRODUCTDATAID, SRC),
                INDEX Products_product_class_idx (PRODUCT_CLASS)
            ) ENGINE=InnoDB AUTO_INCREMENT = 100000;


create table ProductExtensions (
    PRODUCTID   integer NOT NULL,
    EXTENSIONID integer NOT NULL,
    SRC         CHAR(1) DEFAULT 'S',
    UNIQUE INDEX ProductExtensions_pdid_extid_uq (PRODUCTID, EXTENSIONID)
) ENGINE=InnoDB;

create table ProductCatalogs(PRODUCTID   integer NOT NULL,
                             CATALOGID   integer NOT NULL,
                             OPTIONAL    CHAR(1) DEFAULT 'N',
                             SRC         CHAR(1) DEFAULT 'N',    -- N NCC   C Custom
                             CONSTRAINT ProductCatalogs_pdid_cid_pk PRIMARY KEY(PRODUCTID, CATALOGID)
                            ) ENGINE=InnoDB;

create table Targets (OS      VARCHAR(200) NOT NULL,
                      TARGET  VARCHAR(100) NOT NULL,
                      SRC         CHAR(1) DEFAULT 'N',    -- N NCC   C Custom
                      CONSTRAINT Targets_os_pk PRIMARY KEY (OS)
                     ) ENGINE=InnoDB;

create table RepositoryContentData(localpath     VARCHAR(512) NOT NULL,
                                   name          VARCHAR(300) NOT NULL,
                                   checksum      CHAR(130)    NOT NULL,
                                   checksum_type CHAR(20)     NOT NULL DEFAULT 'sha1',
                                   CONSTRAINT RepositoryContentData_localpath_pk PRIMARY KEY(localpath),
                                   INDEX RepositoryContentData_name_cksum_cktype_idx (name, checksum, checksum_type)
                                  ) ENGINE=InnoDB;
--
-- JobQueue
--
-- TYPE is one of  (also refer to documentation)
--      0  -  unknown/undefined
--      1  -  patchstatus
--      2  -  sw_push
--      3  -  update
--      4  -  execute
--      5  -  reboot
--      6  -  configure
--      7  -  wait (time, jobstatus)
--      8  -  eject ( eject cd-rom for debugging)
--
-- STATUS is one of
--      0  -  not yet worked on
--      1  -  successful
--      2  -  failed
--      3  -  denied by client

create table JobQueue ( ID          INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
                        GUID_ID     INTEGER UNSIGNED NOT NULL,
                        PARENT_ID   INTEGER UNSIGNED NULL default NULL,
                        NAME        VARCHAR(255) NOT NULL default '',
                        DESCRIPTION MEDIUMTEXT,
                        TYPE        INTEGER UNSIGNED NOT NULL default 0,
                        ARGUMENTS   BLOB,
                        STATUS      TINYINT UNSIGNED NOT NULL default 0, -- this is the jobstatus
                        STDOUT      BLOB,
                        STDERR      BLOB,
                        EXITCODE    INTEGER,   -- exitcode of the commands on the client side
                        MESSAGE     MEDIUMTEXT,
                        CREATED     TIMESTAMP default CURRENT_TIMESTAMP,
                        TARGETED    TIMESTAMP NULL default NULL,
                        EXPIRES     TIMESTAMP NULL default NULL,
                        RETRIEVED   TIMESTAMP NULL default NULL,
                        FINISHED    TIMESTAMP NULL default NULL,
                        PERSISTENT  TINYINT(1) NOT NULL default 0,
                        VERBOSE     TINYINT(1) NOT NULL default 0,
                        TIMELAG     TIME NULL default NULL,
                        UPSTREAM    TINYINT(1) NOT NULL default 0,
                        CACHERESULT TINYINT(1) NOT NULL default 0,
                        CONSTRAINT JobQueue_id_guid_pk PRIMARY KEY (ID, GUID_ID)
                      ) ENGINE=InnoDB;

create table JobResults ( JOB_ID     INTEGER UNSIGNED NOT NULL,
                          CLIENT_ID  INTEGER UNSIGNED NOT NULL,
                          RETRIEVED  TINYINT(1) NOT NULL default 0,
                          RESULT     LONGBLOB,
                          CREATED    TIMESTAMP default CURRENT_TIMESTAMP,
                          CHANGED    TIMESTAMP NULL default NULL,
                          CONSTRAINT JobResults_jobid_clientid_pk PRIMARY KEY (JOB_ID, CLIENT_ID)
                        ) ENGINE=InnoDB;

create table Patchstatus ( CLIENT_ID    INTEGER UNSIGNED NOT NULL,
                           PKGMGR       INTEGER UNSIGNED,
                           SECURITY     INTEGER UNSIGNED,
                           RECOMMENDED  INTEGER UNSIGNED,
                           OPTIONAL     INTEGER UNSIGNED,
                           PATCHSTATUS_DATE  TIMESTAMP default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                           CONSTRAINT Patchstatus_clientid_pk PRIMARY KEY (CLIENT_ID)
                         ) ENGINE=InnoDB;

-- Patches
--
-- Patch data from mirrored update repositories
--
-- CATEGORY
-- 1 - security
-- 2 - recommended
-- 3 - mandatory
-- 4 - optional
create table Patches( ID          INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
                      CATALOGID   INTEGER UNSIGNED NOT NULL,
                      NAME        VARCHAR(127) NOT NULL,
                      VERSION     VARCHAR(32) NOT NULL,
                      CATEGORY    INTEGER UNSIGNED NOT NULL DEFAULT 1,
                      SUMMARY     VARCHAR(512) NOT NULL,
                      DESCRIPTION TEXT NOT NULL,
                      RELDATE     TIMESTAMP NOT NULL,
                      CONSTRAINT Patches_id_pk PRIMARY KEY (ID)
                    ) ENGINE=InnoDB;

-- PatchRefs
--
-- References to issue tracking systems from Patches.
create table PatchRefs( ID          INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
                        PATCHID     INTEGER UNSIGNED NOT NULL,
                        REFID       VARCHAR(32) NOT NULL,
                        REFTYPE     VARCHAR(8) NOT NULL,
                        URL         VARCHAR(256),
                        TITLE       VARCHAR(256),
                        CONSTRAINT PatchRefs_id_pk PRIMARY KEY (ID)
                      ) ENGINE=InnoDB;

-- Packages
--
-- Package data from mirrored repositories. Currently meant only to store
-- limited data of packages belonging to patches in the Patches table.
-- Can be extended in the future to support any package data, as needed.
create table Packages ( ID          INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
                        CATALOGID   INTEGER UNSIGNED NOT NULL,
                        PATCHID     INTEGER UNSIGNED DEFAULT NULL,
                        NAME        VARCHAR(127) NOT NULL,
                        EPOCH       INTEGER UNSIGNED DEFAULT NULL,
                        VER         VARCHAR(32) NOT NULL,
                        REL         VARCHAR(64) NOT NULL,
                        ARCH        VARCHAR(32) NOT NULL,
                        LOCATION    VARCHAR(255) NOT NULL,
                        EXTLOCATION VARCHAR(255) NOT NULL,
                        CONSTRAINT Packages_id_pk PRIMARY KEY (ID)
                      ) ENGINE=InnoDB;

