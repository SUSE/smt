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
                          GUID         VARCHAR(200) NOT NULL,
                          PRODUCTID    integer NOT NULL,
                       -- InstallDate  date             -- date is not supported by sqlite3
                       -- LastContact  date             -- date is not supported by sqlite3
                          UNIQUE(GUID, ProductID)
                       -- FOREIGN KEY (ProductID) REFERENCES Products  -- FOREIGN KEY not supported by sqlite3
                         );

create table MachineData(GUID          VARCHAR(200) NOT NULL,
                         KEYNAME       VARCHAR(200) NOT NULL,
                         VALUE         BLOB,
                         PRIMARY KEY(GUID, KEYNAME)
                      -- FOREIGN KEY (GUID) REFERENCES Registration (GUID) ON DELETE CASCADE -- FOREIGN KEY not supported by sqlite3
                        );

-- used for NU catalogs and single YUM sources
create table Catalogs(CATALOGID   VARCHAR(200) PRIMARY KEY, 
                      NAME        VARCHAR(200) NOT NULL, 
                      DESCRIPTION VARCHAR(200), 
                      TARGET      VARCHAR(200),           -- null in case of YUM source
                      LOCALPATH   VARCHAR(200) NOT NULL,
                      EXTURL      VARCHAR(200) NOT NULL,  -- where to mirror from
                      CATALOGTYPE VARCHAR(200) NOT NULL,
                      DOMIRROR    VARCHAR(200) DEFAULT 'N',
                      MIRRORABLE  VARCHAR(200) DEFAULT 'N',
                      UNIQUE(NAME, TARGET)
                     );


-- copy of NNW_PRODUCT_DATA
create table Products (
                PRODUCTDATAID   integer NOT NULL PRIMARY KEY,
                PRODUCT         VARCHAR(200) NOT NULL,
                VERSION         VARCHAR(200),
                REL             VARCHAR(200),
                ARCH            VARCHAR(200),
                PRODUCTLOWER    VARCHAR(200) NOT NULL,
                VERSIONLOWER    VARCHAR(200),
                RELLOWER        VARCHAR(200),
                ARCHLOWER       VARCHAR(200),
                FRIENDLY        VARCHAR(200),
                PARAMLIST       VARCHAR(200),
                NEEDINFO        VARCHAR(200),
                SERVICE         VARCHAR(200),
                PRODUCT_LIST    VARCHAR(200),
                UNIQUE(PRODUCT, VERSION, REL, ARCH)
                );


create table ProductCatalogs(PRODUCTDATAID integer NOT NULL,
                             CATALOGID     VARCHAR(200) NOT NULL,
                             OPTIONAL      VARCHAR(200) DEFAULT 'N',
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
                      TARGET  VARCHAR(200) NOT NULL,
                      ARCH    VARCHAR(200) NOT NULL
                     );


-----------------------------------------------------------------------------------


