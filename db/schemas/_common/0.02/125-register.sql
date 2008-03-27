-- create table Registration(REGID        integer PRIMARY KEY AUTOINCREMENT,
--                           GUID         text    NOT NULL,
--                           PRODUCTID    integer NOT NULL,
--                        -- InstallDate  date             -- date is not supported by sqlite3
--                        -- LastContact  date             -- date is not supported by sqlite3
--                           UNIQUE(GUID, ProductID)
--                        -- FOREIGN KEY (ProductID) REFERENCES Products  -- FOREIGN KEY not supported by sqlite3
--                         );


insert into Registration(GUID, PRODUCTID)
 values("sledsp1i586online", 446);

insert into Registration(GUID, PRODUCTID)
 values("slessp1s390online", 460);

insert into Registration(GUID, PRODUCTID)
 values("slessp1i586", 437);

insert into Registration(GUID, PRODUCTID)
 values("slessp1i586-2", 437);

insert into Registration(GUID, PRODUCTID)
 values("sledsp1x8664", 435);

insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sledsp1i586online', 'test1', 'sled-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('slessp1s390online', 'test2', 'sles-10-s390');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('slessp1i586', 'test3', 'sles-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('slessp1i586-2', 'test42', 'sles-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sledsp1x8664', 'test4', 'sles-10-x86_64');

--


insert into Registration(GUID, PRODUCTID)
 values("sles-0", 437);
insert into Registration(GUID, PRODUCTID)
 values("sles-1", 437);
insert into Registration(GUID, PRODUCTID)
 values("sles-2", 437);
insert into Registration(GUID, PRODUCTID)
 values("sles-3", 437);
insert into Registration(GUID, PRODUCTID)
 values("sles-4", 437);
insert into Registration(GUID, PRODUCTID)
 values("sles-5", 437);
insert into Registration(GUID, PRODUCTID)
 values("sles-6", 437);
insert into Registration(GUID, PRODUCTID)
 values("sles-7", 437);
insert into Registration(GUID, PRODUCTID)
 values("sles-8", 437);
insert into Registration(GUID, PRODUCTID)
 values("sles-9", 437);
insert into Registration(GUID, PRODUCTID)
 values("sles-20", 437);

-- some examples
-- sqlite> select PRODUCTID from Registration where GUID = "sledsp1x8664";
-- 435
-- sqlite> select * from ProductCatalogs where PRODUCTID = 435;
-- 435|14|N
-- sqlite> select * from Catalogs where CATALOGID IN (14);
-- 14|SLED10-SP1-Updates|SLED10-SP1-Updates|SLED10-SP1-Updates for sled-10-x86_64|sled-10-x86_64|$RCE/SLED10-SP1-Updates/sled-10-x86_64/|https://nu.novell.com/repo/$RCE/SLED10-SP1-Updates/sled-10-x86_64/|nu
-- sqlite>
