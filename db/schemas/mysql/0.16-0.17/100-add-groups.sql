create table Groups(
  ID     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  NAME   VARCHAR(255) NOT NULL
);

insert into Groups (ID, NAME) values (1, 'Default Group');

alter table Clients add column GROUPID INT UNSIGNED NOT NULL DEFAULT 1;
alter table ProductCatalogs add column GROUPID INT UNSIGNED NOT NULL DEFAULT 1;
alter table ProductCatalogs drop PRIMARY KEY;
alter table ProductCatalogs add PRIMARY KEY (PRODUCTDATAID, CATALOGID, GROUPID);

