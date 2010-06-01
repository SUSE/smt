create table Groups(
  ID     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  NAME   VARCHAR(255) NOT NULL
);

alter table Clients add column GROUPID INT UNSIGNED;
alter table ProductCatalogs add column GROUPID INT UNSIGNED;
alter table ProductCatalogs drop PRIMARY KEY;
alter table ProductCatalogs add PRIMARY KEY (PRODUCTDATAID, CATALOGID, GROUPID);

