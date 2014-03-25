create table ProductExtensions (
    PRODUCTID   integer NOT NULL,
    EXTENSIONID integer NOT NULL,
    SRC         CHAR(1) DEFAULT 'S',
    UNIQUE pdid_extid_unq (PRODUCTID, EXTENSIONID)
);

