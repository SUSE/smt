
create table Registrations(client_id   NUMERIC NOT NULL
                                       CONSTRAINT reg_cid_fk
                                         REFERENCES Clients (id)
                                         ON DELETE CASCADE,
                           product_id  NUMERIC NOT NULL
                                       CONSTRAINT reg_pid_fk
                                         REFERENCES Products (id),
                           regdate     TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                           sccregdate  TIMESTAMPTZ NULL default NULL,
                           sccregerror NUMERIC DEFAULT 0,
                           created     TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL,
                           modified    TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL
                          );

CREATE UNIQUE INDEX reg_cid_pid_uq
  ON Registrations (client_id, product_id);

create or replace function registrations_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$
language plpgsql;


create trigger
registrations_mod_trig
before insert or update on Registrations
for each row
execute procedure registrations_mod_trig_fun();

