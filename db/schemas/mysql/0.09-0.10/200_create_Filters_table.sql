alter table Catalogs add column ID INT NOT NULL AUTO_INCREMENT UNIQUE KEY FIRST;


create table Filters(ID            INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                     CATALOG_ID    INT NOT NULL,
                     TYPE          INT NOT NULL DEFAULT 1,
                     VALUE         VARCHAR(255)
                     -- FOREIGN KEY (CATALOG_ID) REFERENCES Catalogs(ID) ON DELETE CASCADE
                     -- FOREIGN KEY (SUBCATALOG_ID) REFERENCES Subcatalogs(ID) ON DELETE CASCADE
                    );
