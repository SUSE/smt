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
 values("sledsp1x8664", 435);



-------------- some examples --------------------
-- sqlite> select PRODUCTID from Registration where GUID = "sledsp1x8664";
-- 435
-- sqlite> select * from ProductCatalogs where PRODUCTID = 435;
-- 435|14|N
-- sqlite> select * from Catalogs where CATALOGID IN (14);
-- 14|SLED10-SP1-Updates|SLED10-SP1-Updates|SLED10-SP1-Updates for sled-10-x86_64|sled-10-x86_64|$RCE/SLED10-SP1-Updates/sled-10-x86_64/|https://nu.novell.com/repo/$RCE/SLED10-SP1-Updates/sled-10-x86_64/|nu
-- sqlite>