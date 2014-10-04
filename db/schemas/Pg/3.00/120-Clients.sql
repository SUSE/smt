
create table Clients(id          NUMERIC
                                 CONSTRAINT clients_id_pk PRIMARY KEY,
                     guid        VARCHAR(50) NOT NULL,
                     hostname    VARCHAR(500) NOT NULL DEFAULT '',
                     target      VARCHAR(100) NOT NULL,
                     description VARCHAR(500) NOT NULL DEFAULT '',
                     lastcontact TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                     secret      VARCHAR(50) NOT NULL DEFAULT '',
                     regtype     VARCHAR(10) NOT NULL DEFAULT 'SR', -- SR = SuseRegister, SC = SUSEConnect
                     created     TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL,
                     modified    TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL
                    );

CREATE UNIQUE INDEX clients_guid_uq
  ON Clients (guid);

CREATE INDEX client_secret_idx
  ON Clients (secret);

CREATE SEQUENCE clients_id_seq;


create or replace function clients_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$
language plpgsql;

create trigger
clients_mod_trig
before insert or update on Clients
for each row
execute procedure clients_mod_trig_fun();

