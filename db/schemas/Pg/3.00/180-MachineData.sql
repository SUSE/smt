
create table MachineData(client_id     NUMERIC NOT NULL
                                       CONSTRAINT mdata_cid_fk
                                       REFERENCES Clients (id)
                                       ON DELETE CASCADE,
                         md_key        VARCHAR(128) NOT NULL,
                         md_value      TEXT,
                         created       TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL,
                         modified      TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL
                        );

CREATE UNIQUE INDEX mdata_cid_key_uq
  ON MachineData (client_id, md_key);

CREATE INDEX mdata_key_idx
  ON MachineData (md_key);

create or replace function mdata_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$
language plpgsql;


create trigger
mdata_mod_trig
before insert or update on MachineData
for each row
execute procedure mdata_mod_trig_fun();


