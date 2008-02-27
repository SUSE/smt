
drop table if exists Catalogs;
drop table if exists Products;
drop table if exists ProductCatalogs;
drop table if exists Registration;
drop table if exists MachineData;
drop table if exists Targets;
drop table if exists SubscriptionStatus;
drop table if exists Clients;


create table Clients(GUID        CHAR(50) PRIMARY KEY,
                     HOSTNAME    VARCHAR(100) DEFAULT '',
                     TARGET      VARCHAR(100),
                     DESCRIPTION VARCHAR(500) DEFAULT '',
                     LASTCONTACT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    );

create table SubscriptionStatus(GUID         CHAR(50),
                                SUBSCRIPTION VARCHAR(100),
                                SUBTYPE      CHAR(20)  DEFAULT "UNKNOWN",
                                SUBSTATUS    CHAR(20)  DEFAULT "UNKNOWN",
                                SUBSTARTDATE TIMESTAMP DEFAULT '0000-00-00 00:00:00',
                                SUBENDDATE   TIMESTAMP DEFAULT '0000-00-00 00:00:00',
                                SUBDURATION  BIGINT    DEFAULT 0,
                                SERVERCLASS  CHAR(50)  DEFAULT '',
                           --   LASTMODIFIED TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                PRIMARY KEY (GUID, SUBSCRIPTION)
                               );

create table Registration(GUID         CHAR(50) NOT NULL,
                          PRODUCTID    integer NOT NULL,
                          REGDATE      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          NCCREGDATE   TIMESTAMP DEFAULT '0000-00-00 00:00:00',
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
create table Catalogs(CATALOGID   CHAR(50) PRIMARY KEY, 
                      NAME        VARCHAR(200) NOT NULL, 
                      DESCRIPTION VARCHAR(500), 
                      TARGET      VARCHAR(100),           -- null in case of single RPMMD source
                      LOCALPATH   VARCHAR(300) NOT NULL,
                      EXTHOST     VARCHAR(300) NOT NULL,  
                      EXTURL      VARCHAR(300) NOT NULL,  -- where to mirror from
                      CATALOGTYPE CHAR(10) NOT NULL,
                      DOMIRROR    CHAR(1) DEFAULT 'N',
                      MIRRORABLE  CHAR(1) DEFAULT 'N',
                      UNIQUE(NAME, TARGET)
                     );


-- copy of NNW_PRODUCT_DATA
create table Products (
                PRODUCTDATAID   integer NOT NULL PRIMARY KEY,
                PRODUCT         VARCHAR(500) NOT NULL,
                VERSION         VARCHAR(100),
                REL             VARCHAR(100),
                ARCH            VARCHAR(100),
                PRODUCTLOWER    VARCHAR(500) NOT NULL,
                VERSIONLOWER    VARCHAR(100),
                RELLOWER        VARCHAR(100),
                ARCHLOWER       VARCHAR(100),
                FRIENDLY        VARCHAR(700),
                PARAMLIST       TEXT,
                NEEDINFO        TEXT,
                SERVICE         TEXT,
                PRODUCT_LIST    CHAR(1),
                PRODUCT_CLASS   CHAR(50),
                UNIQUE(PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER)
                );


create table ProductCatalogs(PRODUCTDATAID integer NOT NULL,
                             CATALOGID     CHAR(50) NOT NULL,
                             OPTIONAL      CHAR(1) DEFAULT 'N',
                             PRIMARY KEY(PRODUCTDATAID, CATALOGID)
                            );

-- this table is dropped
--
-- copy of NNW_PRODUCT_DEPENDENCIES where PARENT_PARTNUMBER is NULL
-- create table ProductDependencies(PARENT_PRODUCT_ID integer NOT NULL,
--                                  CHILD_PRODUCT_ID  integer NOT NULL,
--                                  -- Condition       VARCHAR(200),             -- not sure about this.
--                                  PRIMARY KEY(PARENT_PRODUCT_ID, CHILD_PRODUCT_ID)
--                                 );

-- copy of NNW_ZLM66_TARGETS
create table Targets (OS      VARCHAR(200) NOT NULL PRIMARY KEY,
                      TARGET  VARCHAR(100) NOT NULL,
                      ARCH    VARCHAR(200) NOT NULL
                     );


-----------------------------------------------------------------------------------


