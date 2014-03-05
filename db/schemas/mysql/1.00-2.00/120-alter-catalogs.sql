
ALTER TABLE Catalogs drop PRIMARY KEY;

ALTER TABLE Catalogs ADD PRIMARY KEY ID(ID);

DROP INDEX ID ON Catalogs;

alter table Catalogs add unique key CID_SRC (CATALOGID, SRC);
