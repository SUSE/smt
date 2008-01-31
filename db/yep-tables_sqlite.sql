-- We should not use this
-- drop table IF EXISTS CredentialGroup;
-- drop table IF EXISTS RepositoryGroup;

-- IF EXISTS was added in version 3.3.X
-- on SLES10 we have 3.1.X :-(

drop table Catalogs;
drop table Products;
drop table ProductCatalogs;
drop table ProductDependencies;
drop table Registration;
drop table MachineData;
drop table Targets;

create table Registration(REGID        integer PRIMARY KEY AUTOINCREMENT,
                          GUID         CHAR(50) NOT NULL,
                          PRODUCTID    integer NOT NULL,
                       -- InstallDate  date             -- date is not supported by sqlite3
                       -- LastContact  date             -- date is not supported by sqlite3
                          UNIQUE(GUID, PRODUCTID)
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
                UNIQUE(PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER)
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
create table Targets (OS      VARCHAR(200) NOT NULL PRIMARY KEY,
                      TARGET  VARCHAR(100) NOT NULL,
                      ARCH    VARCHAR(200) NOT NULL
                     );


-----------------------------------------------------------------------------------


