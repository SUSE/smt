
create table Repositories(id          NUMERIC
                                      CONSTRAINT repos_id_pk PRIMARY KEY,
                          catalog_id  NUMERIC NOT NULL,      -- internal CC id
                          name        VARCHAR(512) NOT NULL,
                          description VARCHAR(512) NOT NULL,
                          target      VARCHAR(512) NOT NULL, -- '' (empty) in case of single RPMMD source
                          localpath   VARCHAR(512) NOT NULL,
                          exthost     VARCHAR(512) NOT NULL,
                          exturl      VARCHAR(512) NOT NULL,  -- where to mirror from
                          authtoken   VARCHAR(512) NOT NULL DEFAULT '',
                          catalogtype VARCHAR(10) NOT NULL,
                          domirror    VARCHAR(1) NOT NULL DEFAULT 'N'
                                      CONSTRAINT repos_domirror_ck
                                        CHECK (domirror in ('Y', 'N')),
                          mirrorable  VARCHAR(1) NOT NULL DEFAULT 'N'
                                      CONSTRAINT repos_mable_ck
                                        CHECK (mirrorable in ('Y', 'N')),
                          src         VARCHAR(1) NOT NULL DEFAULT 'S'    -- S SCC N NCC C Custom
                                      CONSTRAINT repos_src_ck
                                        CHECK (src in ('N', 'C', 'S')),
                          autorefresh VARCHAR(1) NOT NULL DEFAULT 'Y'
                                      CONSTRAINT repos_aref_ck
                                        CHECK (autorefresh in ('Y', 'N')),
                          last_mirror TIMESTAMPTZ NULL DEFAULT NULL,
                          created     TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL,
                          modified    TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL
                         );

CREATE SEQUENCE repos_id_seq;

CREATE UNIQUE INDEX repos_cid_src_uq
  ON Repositories (catalog_id, src);

CREATE UNIQUE INDEX repos_name_target_uq
  ON Repositories (name, target);

create or replace function repositories_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$
language plpgsql;


create trigger
repositories_mod_trig
before insert or update on Repositories
for each row
execute procedure repositories_mod_trig_fun();


