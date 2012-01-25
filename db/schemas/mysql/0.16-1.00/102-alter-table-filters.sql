
alter table Filters add column STAGINGGROUP_ID INT NOT NULL DEFAULT 1;
alter table Filters drop key CATALOG_ID;
alter table Filters add unique key CATALOG_ID (CATALOG_ID, STAGINGGROUP_ID, TYPE, VALUE);

