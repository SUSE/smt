
-- Patches
--
-- Patch data from mirrored update repositories
--
-- CATEGORY
-- 1 - security
-- 2 - recommended
-- 3 - mandatory
-- 4 - optional
create table Patches( id            NUMERIC NOT NULL
                                    CONSTRAINT patches_id_pk PRIMARY KEY,
                      repository_id NUMERIC NOT NULL
                                    CONSTRAINT patches_rid_fk
                                    REFERENCES Repositories (id),
                      name          VARCHAR(127) NOT NULL,
                      version       VARCHAR(32) NOT NULL,
                      category      NUMERIC NOT NULL DEFAULT 1,
                      summary       VARCHAR(512) NOT NULL,
                      description   VARCHAR(1024) NOT NULL,
                      reldate       TIMESTAMPTZ NOT NULL,
                      created       TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL,
                      modified      TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL
                    );

CREATE SEQUENCE patches_id_seq;

create or replace function patches_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$
language plpgsql;


create trigger
patches_mod_trig
before insert or update on Patches
for each row
execute procedure patches_mod_trig_fun();
