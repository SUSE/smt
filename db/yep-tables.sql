drop table IF EXISTS CredentialGroup;
drop table IF EXISTS Catalogs;
drop table IF EXISTS RepositoryGroup;
drop table IF EXISTS Products;
drop table IF EXISTS ProductCatalogs;
drop table IF EXISTS ProductDependencies;
drop table IF EXISTS Registration;
drop table IF EXISTS MachineData;

-- temporary for mirror only solution

create table CredentialGroup(GUID      text NOT NULL PRIMARY KEY, 
                             Groupname text NOT NULL);

create table RepositoryGroup(Groupname  text    NOT NULL,
                             CatalogID  integer NOT NULL,
                             PRIMARY KEY(Groupname, CatalogID)
                            );
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
                   -- BaseURL     text NOT NULL,  -- local hostname should be come from a config file
                      CatalogType text NOT NULL,
                      UNIQUE(Name, Target)
                     );


-- copy of NNW_PRODUCT_DATA
-- create table Products(ProductID integer PRIMARY KEY, -- AUTOINCREMENT, -- product id should be the same as in NCC
--                       Name      text NOT NULL,
--                       Version   text,
--                       Release   text,
--                       Arch      text,
--                       Paramlist text,
--                       Needinfo  text,
--                       Service   text,
--                       List      text NOT NULL,  -- show product in listproducts command
--                       CHECK List in ('Y', 'N'),  
--                       UNIQUE(Name, Version, Release, Arch)
--                      );

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
                             PRIMARY KEY(ProductID, CatalogID)
                            );

-- copy of NNW_PRODUCT_DEPENDENCIES where PARENT_PARTNUMBER is NULL
create table ProductDependencies(Parent_Product_ID integer NOT NULL,
                                 Child_Product_ID  integer NOT NULL,
                                 -- Condition       text,             -- not sure about this.
                                 PRIMARY KEY(Parent_Product_ID, Child_Product_ID)
                                );

-----------------------------------------------------------------------------------

insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(1, 'SLES10-Updates', 'SLES10-Updates', 
                   'SLES10-Updates for sles-10-i586', 'sles-10-i586', 
                   '$RCE/SLES10-Updates/sles-10-i586/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(2, 'SLES10-Updates', 'SLES10-Updates', 
                   'SLES10-Updates for sles-10-x86_64', 'sles-10-x86_64', 
                   '$RCE/SLES10-Updates/sles-10-x86_64/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(3, 'SLES10-Updates', 'SLES10-Updates', 
                   'SLES10-Updates for sles-10-ia64', 'sles-10-ia64', 
                   '$RCE/SLES10-Updates/sles-10-ia64/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(4, 'SLES10-Updates', 'SLES10-Updates', 
                   'SLES10-Updates for sles-10-ppc', 'sles-10-ppc', 
                   '$RCE/SLES10-Updates/sles-10-ppc/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(5, 'SLES10-Updates', 'SLES10-Updates', 
                   'SLES10-Updates for sles-10-s390x', 'sles-10-s390x', 
                   '$RCE/SLES10-Updates/sles-10-s390x/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(6, 'SLES10-Debuginfo-Updates', 'SLES10-Debuginfo-Updates', 
                   'SLES10-Debuginfo-Updates for sles-10-i586', 'sles-10-i586', 
                   '$RCE/SLES10-Debuginfo-Updates/sles-10-i586/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(7, 'SLES10-Debuginfo-Updates', 'SLES10-Debuginfo-Updates', 
                   'SLES10-Debuginfo-Updates for sles-10-x86_64', 'sles-10-x86_64', 
                   '$RCE/SLES10-Debuginfo-Updates/sles-10-x86_64/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(8, 'SLES10-Debuginfo-Updates', 'SLES10-Debuginfo-Updates', 
                   'SLES10-Debuginfo-Updates for sles-10-ia64', 'sles-10-ia64', 
                   '$RCE/SLES10-Debuginfo-Updates/sles-10-ia64/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(9, 'SLES10-Debuginfo-Updates', 'SLES10-Debuginfo-Updates', 
                   'SLES10-Debuginfo-Updates for sles-10-ppc', 'sles-10-ppc', 
                   '$RCE/SLES10-Debuginfo-Updates/sles-10-ppc/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(10, 'SLES10-Debuginfo-Updates', 'SLES10-Debuginfo-Updates', 
                   'SLES10-Debuginfo-Updates for sles-10-s390x', 'sles-10-s390x', 
                   '$RCE/SLES10-Debuginfo-Updates/sles-10-s390x/',
                   'http://mctest.suse.de/', 'nu');


insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(11, 'SLED10-Updates', 'SLED10-Updates', 
                   'SLED10-Updates for sled-10-i586', 'sled-10-i586', 
                   '$RCE/SLED10-Updates/sled-10-i586/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(12, 'SLED10-Updates', 'SLED10-Updates', 
                   'SLED10-Updates for sled-10-x86_64', 'sled-10-x86_64', 
                   '$RCE/SLED10-Updates/sled-10-x86_64/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(13, 'SLED10-Debuginfo-Updates', 'SLED10-Debuginfo-Updates', 
                   'SLED10-Debuginfo-Updates for sled-10-i586', 'sled-10-i586', 
                   '$RCE/SLED10-Debuginfo-Updates/sled-10-i586/',
                   'http://mctest.suse.de/', 'nu');
insert into Catalogs (CatalogID,Name,Alias,Description,Target,LocalPath, ExtURL, CatalogType) 
            VALUES(14, 'SLED10-Debuginfo-Updates', 'SLED10-Debuginfo-Updates', 
                   'SLED10-Debuginfo-Updates for sled-10-x86_64', 'sled-10-x86_64', 
                   '$RCE/SLED10-Debuginfo-Updates/sled-10-x86_64/',
                   'http://mctest.suse.de/', 'nu');

insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sles10-i586', 1);
insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sles10-i586', 6);

insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sles10-x86_64', 2);
insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sles10-x86_64', 7);

insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sles10-ia64', 3);
insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sles10-ia64', 8);

insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sles10-ppc', 4);
insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sles10-ppc', 9);

insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sles10-s390x', 5);
insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sles10-s390x', 10);

insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sled10-i586', 11);
insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sled10-i586', 13);

insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sled10-x86_64', 12);
insert into RepositoryGroup(Groupname, CatalogID)
            VALUES('sled10-x86_64', 14);



insert into CredentialGroup(GUID, Groupname)
            VALUES('d6ba99c76dd5422a969ed1e33f8e9fd8', 'sles10-i586');
insert into CredentialGroup(GUID, Groupname)
            VALUES('f85a99c76dd5422a969ed1e33f8e9e9a', 'sled10-x86_64');

