-- N == NCC, C == Custom
alter table Catalogs add COLUMN SRC Char(1) DEFAULT 'N';
alter table Products add COLUMN SRC Char(1) DEFAULT 'N';
alter table ProductCatalogs add COLUMN SRC Char(1) DEFAULT 'N';
alter table Targets add COLUMN SRC Char(1) DEFAULT 'N';
