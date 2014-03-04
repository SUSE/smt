
create table ProductCatalogsBak(PRODUCTDATAID integer NOT NULL,
                                CATALOGID     CHAR(50) NOT NULL,
                                OPTIONAL      CHAR(1) DEFAULT 'N',
                                SRC         CHAR(1) DEFAULT 'N',    -- N NCC   C Custom
                                PRIMARY KEY(PRODUCTDATAID, CATALOGID)
                               );

INSERT INTO ProductCatalogsBak(PRODUCTDATAID,CATALOGID,OPTIONAL,SRC) (
    SELECT PRODUCTDATAID,CATALOGID,OPTIONAL,SRC
      FROM ProductCatalogs);

drop table ProductCatalogs;

create table ProductCatalogs(PRODUCTID integer NOT NULL,
                             CATALOGID integer NOT NULL,
                             OPTIONAL  CHAR(1) DEFAULT 'N',
                             AUTOREFRESH CHAR(1) DEFAULT 'Y',
                             SRC       CHAR(1) DEFAULT 'N',    -- N NCC   C Custom
                             PRIMARY KEY(PRODUCTID, CATALOGID)
                            );

INSERT INTO ProductCatalogs (PRODUCTID, CATALOGID, OPTIONAL, SRC) (
    SELECT p.ID, c.ID, pcb.OPTIONAL, pcb.SRC
      FROM ProductCatalogsBak pcb
      JOIN Products p ON pcb.PRODUCTDATAID = p.PRODUCTDATAID
      JOIN Catalogs c ON pcb.CATALOGID = c.CATALOGID);

drop table ProductCatalogsBak;
