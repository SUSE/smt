alter table Clients drop column GROUPID;
alter table ProductCatalogs drop column GROUPID;
alter table ProductCatalogs drop PRIMARY KEY;
alter table ProductCatalogs add PRIMARY KEY (PRODUCTDATAID, CATALOGID);
drop table Groups;

