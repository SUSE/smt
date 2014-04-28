
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


-- integer id for "Clients" for faster joins compared to GUID with CHAR(50)
--    GUID remains primary key until all code that deals with GUIDs gets adapted
--    all new tables refering to a Client should use Clients.ID from now on
create table Clients(ID          INT UNSIGNED AUTO_INCREMENT UNIQUE KEY,
                     GUID        CHAR(50) PRIMARY KEY,
                     HOSTNAME    VARCHAR(100) DEFAULT '',
                     TARGET      VARCHAR(100),
                     DESCRIPTION VARCHAR(500) DEFAULT '',
                     LASTCONTACT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                     NAMESPACE   VARCHAR(300) NOT NULL DEFAULT '',
                     SECRET      CHAR(50) NOT NULL DEFAULT '',
                     REGTYPE     CHAR(10) NOT NULL DEFAULT 'SR' -- SR = SuseRegister, SC = SUSEConnect
                    );


create table Subscriptions(SUBID          CHAR(50) PRIMARY KEY,
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
                           INDEX idx_sub_product_class (PRODUCT_CLASS)
                          );

create table ClientSubscriptions(GUID    CHAR(50) NOT NULL,
                                 SUBID   CHAR(50) NOT NULL,
                                 PRIMARY KEY(GUID, SUBID)
                                );

create table Registration(GUID         CHAR(50) NOT NULL,
                          PRODUCTID    integer NOT NULL,
                          REGDATE      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          NCCREGDATE   TIMESTAMP NULL default NULL,
                          NCCREGERROR  integer DEFAULT 0,
                          PRIMARY KEY(GUID, PRODUCTID)
                       -- FOREIGN KEY (ProductID) REFERENCES Products  -- FOREIGN KEY not supported by sqlite3
                         );

create table MachineData(GUID          CHAR(50) NOT NULL,
                         KEYNAME       CHAR(50) NOT NULL,
                         VALUE         BLOB,
                         PRIMARY KEY(GUID, KEYNAME)
                      -- FOREIGN KEY (GUID) REFERENCES Registration (GUID) ON DELETE CASCADE -- FOREIGN KEY not supported by sqlite3
                        );

-- used for NU catalogs and single RPMMD sources
create table Catalogs(ID          INT AUTO_INCREMENT PRIMARY KEY,
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
                      UNIQUE(NAME, TARGET)
                     );
alter table Catalogs add unique key CID_SRC (CATALOGID, SRC);

create table StagingGroups(ID            INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                           NAME          VARCHAR(255) NOT NULL UNIQUE,
                           TESTINGDIR    VARCHAR(255) NOT NULL UNIQUE,
                           PRODUCTIONDIR VARCHAR(255) NOT NULL UNIQUE
                          );

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
create table Filters(ID              INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                     CATALOG_ID      INT NOT NULL,
                     TYPE            INT NOT NULL DEFAULT 1,
                     VALUE           VARCHAR(255),
                     STAGINGGROUP_ID INT NOT NULL DEFAULT 1,
                     UNIQUE KEY (CATALOG_ID, STAGINGGROUP_ID, TYPE, VALUE)
                     -- FOREIGN KEY (CATALOG_ID) REFERENCES Catalogs(ID) ON DELETE CASCADE
                     -- FOREIGN KEY (SUBCATALOG_ID) REFERENCES Subcatalogs(ID) ON DELETE CASCADE
                     -- FOREIGN KEY (STAGINGGROUP_ID) REFERENCES StagingGroups(ID) ON DELETE CASCADE
                    );


-- copy of NNW_PRODUCT_DATA
create table Products (
                ID              integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
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
                PARAMLIST       TEXT,
                NEEDINFO        TEXT,
                SERVICE         TEXT,
                DESCRIPTION     TEXT,
                PRODUCT_LIST    CHAR(1),
                PRODUCT_CLASS   CHAR(50),
                SRC         CHAR(1) DEFAULT 'N',    -- N NCC   C Custom
                UNIQUE(PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER),
                UNIQUE(PRODUCTDATAID, SRC),
                INDEX idx_prod_product_class (PRODUCT_CLASS)
            ) AUTO_INCREMENT = 100000;


create table ProductExtensions (
    PRODUCTID   integer NOT NULL,
    EXTENSIONID integer NOT NULL,
    SRC         CHAR(1) DEFAULT 'S',
    UNIQUE pdid_extid_unq (PRODUCTID, EXTENSIONID)
);

create table ProductCatalogs(PRODUCTID   integer NOT NULL,
                             CATALOGID   integer NOT NULL,
                             OPTIONAL    CHAR(1) DEFAULT 'N',
                             SRC         CHAR(1) DEFAULT 'N',    -- N NCC   C Custom
                             PRIMARY KEY(PRODUCTID, CATALOGID)
                            );

create table Targets (OS      VARCHAR(200) NOT NULL PRIMARY KEY,
                      TARGET  VARCHAR(100) NOT NULL,
                      SRC         CHAR(1) DEFAULT 'N'    -- N NCC   C Custom
                     );

create table RepositoryContentData(localpath     VARCHAR(300) PRIMARY KEY,
                                   name          VARCHAR(300) NOT NULL,
                                   checksum      CHAR(130)    NOT NULL,
                                   checksum_type CHAR(20)     NOT NULL DEFAULT 'sha1',
                                   INDEX idx_repo_cont_data_name_checksum (name, checksum, checksum_type)
                                  );
-- end

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
                        PRIMARY KEY (ID, GUID_ID)
                      );

create table JobResults ( JOB_ID     INTEGER UNSIGNED NOT NULL,
                          CLIENT_ID  INTEGER UNSIGNED NOT NULL,
                          RETRIEVED  TINYINT(1) NOT NULL default 0,
                          RESULT     LONGBLOB,
                          CREATED    TIMESTAMP default CURRENT_TIMESTAMP,
                          CHANGED    TIMESTAMP NULL default NULL,
                          PRIMARY KEY (JOB_ID, CLIENT_ID)
                        );

create table Patchstatus ( CLIENT_ID    INTEGER UNSIGNED NOT NULL PRIMARY KEY,
                           PKGMGR       INTEGER UNSIGNED,
                           SECURITY     INTEGER UNSIGNED,
                           RECOMMENDED  INTEGER UNSIGNED,
                           OPTIONAL     INTEGER UNSIGNED,
                           PATCHSTATUS_DATE  TIMESTAMP default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                         );

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
                      DESCRIPTION VARCHAR(1024) NOT NULL,
                      RELDATE     TIMESTAMP NOT NULL,
                      PRIMARY KEY (ID)
                    );

-- PatchRefs
--
-- References to issue tracking systems from Patches.
create table PatchRefs( ID          INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
                        PATCHID     INTEGER UNSIGNED NOT NULL,
                        REFID       VARCHAR(32) NOT NULL,
                        REFTYPE     VARCHAR(8) NOT NULL,
                        URL         VARCHAR(256),
                        TITLE       VARCHAR(256),
                        PRIMARY KEY (ID)
                      );

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
                        PRIMARY KEY (ID)
                      );

