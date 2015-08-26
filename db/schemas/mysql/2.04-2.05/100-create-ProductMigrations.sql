
create table ProductMigrations (
    SRCPDID   integer NOT NULL,
    TGTPDID   integer NOT NULL,
    SRC       CHAR(1) DEFAULT 'S',
    UNIQUE pdid_migid_unq (SRCPDID, TGTPDID),
    INDEX ProductMigrations_srcpdid_tgtpdid_src_idx (SRCPDID, TGTPDID, SRC)
);
