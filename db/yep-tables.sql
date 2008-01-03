-- We should not use this
-- drop table IF EXISTS CredentialGroup;
-- drop table IF EXISTS RepositoryGroup;

drop table IF EXISTS Catalogs;
drop table IF EXISTS Products;
drop table IF EXISTS ProductCatalogs;
drop table IF EXISTS ProductDependencies;
drop table IF EXISTS Registration;
drop table IF EXISTS MachineData;
drop table IF EXISTS Targets;

-- temporary for mirror only solution - bad idea we should work with the final once

-- create table CredentialGroup(GUID      text NOT NULL PRIMARY KEY, 
--                              Groupname text NOT NULL);

-- create table RepositoryGroup(Groupname  text    NOT NULL,
--                              CatalogID  integer NOT NULL,
--                              PRIMARY KEY(Groupname, CatalogID)
--                             );
-- end temporary

create table Registration(RegID        integer PRIMARY KEY AUTOINCREMENT,
                          GUID         text    NOT NULL,
                          ProductID    integer NOT NULL,
                       -- InstallDate  date             -- date is not supported by sqlite3
                       -- LastContact  date             -- date is not supported by sqlite3
                          UNIQUE(GUID, ProductID)
                       -- FOREIGN KEY (ProductID) REFERENCES Products  -- FOREIGN KEY not supported by sqlite3
                         );

create table MachineData(GUID          text NOT NULL,
                         Key           text NOT NULL,
                         Value         text,
                         PRIMARY KEY(GUID, Key)
                      -- FOREIGN KEY (GUID) REFERENCES Registration (GUID) ON DELETE CASCADE -- FOREIGN KEY not supported by sqlite3
                        );

-- used for NU catalogs and single YUM sources
create table Catalogs(CatalogID   integer PRIMARY KEY AUTOINCREMENT, 
                      Name        text NOT NULL, 
                      Alias       text, 
                      Description text, 
                      Target      text,           -- null in case of YUM source
                      LocalPath   text NOT NULL,
                      ExtUrl      text NOT NULL,  -- where to mirror from
                      CatalogType text NOT NULL,
		      DoMirror    text DEFAULT 'N',
		      Mirrorable  text DEFAULT 'N',
                      UNIQUE(Name, Target)
                     );


-- copy of NNW_PRODUCT_DATA
CREATE TABLE Products (
                PRODUCTDATAID   integer NOT NULL PRIMARY KEY,
                PRODUCT         text NOT NULL,
                VERSION         text,
                RELEASE         text,
                ARCH            text,
                FRIENDLY        text,
                PARAMLIST       text,
                NEEDINFO        text,
                SERVICE         text,
                PRODUCT_LIST    text,
                UNIQUE(PRODUCT, VERSION, RELEASE, ARCH)
                );


create table ProductCatalogs(ProductID   integer NOT NULL,
                             CatalogID   integer NOT NULL,
                             Optional    text DEFAULT 'N',
                             PRIMARY KEY(ProductID, CatalogID)
                            );

-- copy of NNW_PRODUCT_DEPENDENCIES where PARENT_PARTNUMBER is NULL
create table ProductDependencies(Parent_Product_ID integer NOT NULL,
                                 Child_Product_ID  integer NOT NULL,
                                 -- Condition       text,             -- not sure about this.
                                 PRIMARY KEY(Parent_Product_ID, Child_Product_ID)
                                );

-- copy of NNW_ZLM66_TARGETS
create table Targets (OS      text NOT NULL PRIMARY KEY,
                      Target  text NOT NULL
                     );


-----------------------------------------------------------------------------------


