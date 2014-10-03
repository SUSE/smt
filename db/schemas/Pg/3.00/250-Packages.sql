
-- Packages
--
-- Package data from mirrored repositories. Currently meant only to store
-- limited data of packages belonging to patches in the Patches table.
-- Can be extended in the future to support any package data, as needed.
create table Packages ( id            NUMERIC NOT NULL
                                      CONSTRAINT pkgs_id_pk PRIMARY KEY,
                        repository_id NUMERIC NOT NULL
                                      CONSTRAINT pkgs_rid_fk
                                      REFERENCES Repositories (id)
                                      ON DELETE CASCADE,
                        patch_id      NUMERIC NOT NULL
                                      CONSTRAINT pkgs_ptid_fk
                                      REFERENCES Patches (id)
                                      ON DELETE CASCADE,
                        name          VARCHAR(255) NOT NULL,
                        epoch         NUMERIC NOT NULL DEFAULT 0,
                        ver           VARCHAR(255) NOT NULL,
                        rel           VARCHAR(255) NOT NULL,
                        arch          VARCHAR(255) NOT NULL,
                        location      VARCHAR(255) NOT NULL,
                        extlocation   VARCHAR(255) NOT NULL,
                        created       TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL,
                        modified      TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL
                      );

CREATE SEQUENCE pkgs_id_seq;

create or replace function packages_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$
language plpgsql;


create trigger
packages_mod_trig
before insert or update on Packages
for each row
execute procedure packages_mod_trig_fun();

