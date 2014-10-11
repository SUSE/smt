
-- PatchRefs
--
-- References to issue tracking systems from Patches.
create table PatchRefs( id          NUMERIC NOT NULL
                                    CONSTRAINT pref_id_pk PRIMARY KEY,
                        patch_id    NUMERIC NOT NULL
                                    CONSTRAINT pref_ptid_fk
                                    REFERENCES Patches (id),
                        refid       VARCHAR(32)  NOT NULL,
                        reftype     VARCHAR(8)   NOT NULL,
                        url         VARCHAR(256) NOT NULL,
                        title       VARCHAR(256) NOT NULL,
                        created     TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL,
                        modified    TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL
                      );

CREATE SEQUENCE patchrefs_id_seq;

create or replace function pref_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$
language plpgsql;


create trigger
pref_mod_trig
before insert or update on PatchRefs
for each row
execute procedure pref_mod_trig_fun();


