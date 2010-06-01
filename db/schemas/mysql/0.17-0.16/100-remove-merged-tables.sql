drop table MergedCatalogs;

delete from Catalogs where EXTURL is null or EXTHOST is null;

alter table Catalogs
  change column EXTURL EXTURL VARCHAR(300) NOT NULL,
  change column EXTHOST EXTHOST VARCHAR(300) NOT NULL;

