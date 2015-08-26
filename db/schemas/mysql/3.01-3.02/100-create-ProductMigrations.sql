
create table ProductMigrations (
    SRCPDID   integer NOT NULL,
    TGTPDID   integer NOT NULL,
    SRC       CHAR(1) DEFAULT 'S',
    UNIQUE INDEX ProductExtensions_pdid_migid_unq (SRCPDID, TGTPDID)
);
