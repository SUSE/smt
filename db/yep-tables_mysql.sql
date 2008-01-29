-- We should not use this
-- drop table IF EXISTS CredentialGroup;
-- drop table IF EXISTS RepositoryGroup;

-- IF EXISTS was added in version 3.3.X
-- on SLES10 we have 3.1.X :-(

drop table if exists Catalogs;
drop table if exists Products;
drop table if exists ProductCatalogs;
drop table if exists ProductDependencies;
drop table if exists Registration;
drop table if exists MachineData;
drop table if exists Targets;

create table Registration(REGID        integer PRIMARY KEY AUTO_INCREMENT,
                          GUID         CHAR(50) NOT NULL,
                          PRODUCTID    integer NOT NULL,
                       -- InstallDate  date             -- date is not supported by sqlite3
                       -- LastContact  date             -- date is not supported by sqlite3
                          UNIQUE(GUID, ProductID)
                       -- FOREIGN KEY (ProductID) REFERENCES Products  -- FOREIGN KEY not supported by sqlite3
                         );

create table MachineData(GUID          CHAR(50) NOT NULL,
                         KEYNAME       CHAR(50) NOT NULL,
                         VALUE         BLOB,
                         PRIMARY KEY(GUID, KEYNAME)
                      -- FOREIGN KEY (GUID) REFERENCES Registration (GUID) ON DELETE CASCADE -- FOREIGN KEY not supported by sqlite3
                        );

-- used for NU catalogs and single YUM sources
create table Catalogs(CATALOGID   CHAR(50) PRIMARY KEY, 
                      NAME        CHAR(200) NOT NULL, 
                      DESCRIPTION CHAR(500), 
                      TARGET      CHAR(100),           -- null in case of YUM source
                      LOCALPATH   CHAR(300) NOT NULL,
                      EXTURL      CHAR(300) NOT NULL,  -- where to mirror from
                      CATALOGTYPE CHAR(10) NOT NULL,
                      DOMIRROR    CHAR(1) DEFAULT 'N',
                      MIRRORABLE  CHAR(1) DEFAULT 'N',
                      UNIQUE(NAME, TARGET)
                     );


-- copy of NNW_PRODUCT_DATA
create table Products (
                PRODUCTDATAID   integer NOT NULL PRIMARY KEY,
                PRODUCT         CHAR(500) NOT NULL,
                VERSION         CHAR(100),
                REL             CHAR(100),
                ARCH            CHAR(100),
                PRODUCTLOWER    CHAR(100) NOT NULL,
                VERSIONLOWER    CHAR(100),
                RELLOWER        CHAR(100),
                ARCHLOWER       CHAR(100),
                FRIENDLY        CHAR(700),
                PARAMLIST       TEXT,
                NEEDINFO        TEXT,
                SERVICE         TEXT,
                PRODUCT_LIST    CHAR(1),
                UNIQUE(PRODUCT, VERSION, REL, ARCH)
                );


create table ProductCatalogs(PRODUCTDATAID integer NOT NULL,
                             CATALOGID     CHAR(50) NOT NULL,
                             OPTIONAL      CHAR(1) DEFAULT 'N',
                             PRIMARY KEY(PRODUCTDATAID, CATALOGID)
                            );

-- copy of NNW_PRODUCT_DEPENDENCIES where PARENT_PARTNUMBER is NULL
create table ProductDependencies(PARENT_PRODUCT_ID integer NOT NULL,
                                 CHILD_PRODUCT_ID  integer NOT NULL,
                                 -- Condition       VARCHAR(200),             -- not sure about this.
                                 PRIMARY KEY(PARENT_PRODUCT_ID, CHILD_PRODUCT_ID)
                                );

-- copy of NNW_ZLM66_TARGETS
create table Targets (OS      CHAR(200) NOT NULL PRIMARY KEY,
                      TARGET  CHAR(100) NOT NULL,
                      ARCH    CHAR(200) NOT NULL
                     );


-----------------------------------------------------------------------------------


