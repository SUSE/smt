
create table SystemData(client_id     NUMERIC NOT NULL
                                      CONSTRAINT sdata_cid_fk
                                      REFERENCES Clients (id)
                                      ON DELETE CASCADE,
                        data          json,
                        created       TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL,
                        modified      TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL
                       );

CREATE UNIQUE INDEX sdata_cid_uq
  ON SystemData (client_id);

create or replace function sdata_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$
language plpgsql;


create trigger
sdata_mod_trig
before insert or update on SystemData
for each row
execute procedure sdata_mod_trig_fun();


