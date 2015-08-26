
create table ProductMigrations (
    SRCPDID   integer NOT NULL,
    TGTPDID   integer NOT NULL,
    SRC       CHAR(1) DEFAULT 'S',
    UNIQUE INDEX ProductMigrations_srcpdid_tgtpdid_uq (SRCPDID, TGTPDID)
);
