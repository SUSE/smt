
create table Products (
                id                NUMERIC NOT NULL
                                  CONSTRAINT products_id_pk PRIMARY KEY,
                productdataid     NUMERIC NOT NULL,
                product           VARCHAR(512) NOT NULL,
                version           VARCHAR(512) NOT NULL,
                rel               VARCHAR(512) NOT NULL,
                arch              VARCHAR(512) NOT NULL,
                friendly          VARCHAR(700) NOT NULL,
                cpe               VARCHAR(255) NOT NULL DEFAULT '',
                eula_url          VARCHAR(255) NOT NULL DEFAULT '',
                description       TEXT,
                product_class     VARCHAR(50),
                product_type      VARCHAR(100) NOT NULL DEFAULT '',
                former_identifier VARCHAR(500) NOT NULL DEFAULT '',
                src               VARCHAR(1) DEFAULT 'N'    -- N NCC   C Custom
                                  CONSTRAINT products_src_ck
                                    CHECK (src in ('N', 'S', 'C')),
                created           TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL,
                modified          TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL
            );

CREATE SEQUENCE products_id_seq;

CREATE UNIQUE INDEX products_pvra_uq
 ON Products (product, version, rel, arch);

CREATE UNIQUE INDEX products_pdid_src_uq
 ON Products (productdataid, src);

CREATE INDEX products_pclass_idx
 ON Products (product_class);

create or replace function products_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$
language plpgsql;


create trigger
products_mod_trig
before insert or update on Products
for each row
execute procedure products_mod_trig_fun();
