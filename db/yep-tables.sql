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
                          GUID         text    NOT NULL,
                          PRODUCTID    integer NOT NULL,
                       -- InstallDate  date             -- date is not supported by sqlite3
                       -- LastContact  date             -- date is not supported by sqlite3
                          UNIQUE(GUID, ProductID)
                       -- FOREIGN KEY (ProductID) REFERENCES Products  -- FOREIGN KEY not supported by sqlite3
                         );

create table MachineData(GUID          text NOT NULL,
                         KEY           text NOT NULL,
                         VALUE         text,
                         PRIMARY KEY(GUID, Key)
                      -- FOREIGN KEY (GUID) REFERENCES Registration (GUID) ON DELETE CASCADE -- FOREIGN KEY not supported by sqlite3
                        );

-- used for NU catalogs and single YUM sources
create table Catalogs(CATALOGID   text PRIMARY KEY, 
                      NAME        text NOT NULL, 
                      DESCRIPTION text, 
                      TARGET      text,           -- null in case of YUM source
                      LOCALPATH   text NOT NULL,
                      EXTURL      text NOT NULL,  -- where to mirror from
                      CATALOGTYPE text NOT NULL,
                      DOMIRROR    text DEFAULT 'N',
                      MIRRORABLE  text DEFAULT 'N',
                      UNIQUE(NAME, TARGET)
                     );


-- copy of NNW_PRODUCT_DATA
CREATE TABLE Products (
                PRODUCTDATAID   integer NOT NULL PRIMARY KEY,
                PRODUCT         text NOT NULL,
                VERSION         text,
                RELEASE         text,
                ARCH            text,
                PRODUCTLOWER    text NOT NULL,
                VERSIONLOWER    text,
                RELEASELOWER    text,
                ARCHLOWER       text,
                FRIENDLY        text,
                PARAMLIST       text,
                NEEDINFO        text,
                SERVICE         text,
                PRODUCT_LIST    text,
                UNIQUE(PRODUCT, VERSION, RELEASE, ARCH)
                );


create table ProductCatalogs(PRODUCTDATAID integer NOT NULL,
                             CATALOGID     text NOT NULL,
                             OPTIONAL      text DEFAULT 'N',
                             PRIMARY KEY(PRODUCTDATAID, CATALOGID)
                            );

-- copy of NNW_PRODUCT_DEPENDENCIES where PARENT_PARTNUMBER is NULL
create table ProductDependencies(PARENT_PRODUCT_ID integer NOT NULL,
                                 CHILD_PRODUCT_ID  integer NOT NULL,
                                 -- Condition       text,             -- not sure about this.
                                 PRIMARY KEY(PARENT_PRODUCT_ID, CHILD_PRODUCT_ID)
                                );

-- copy of NNW_ZLM66_TARGETS
create table Targets (OS      text NOT NULL PRIMARY KEY,
                      TARGET  text NOT NULL,
                      ARCH    text NOT NULL
                     );


-----------------------------------------------------------------------------------


