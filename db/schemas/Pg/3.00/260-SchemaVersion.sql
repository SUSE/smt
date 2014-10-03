CREATE TABLE SchemaVersion (
    name        VARCHAR(128) NOT NULL
                CONSTRAINT schema_version_pk PRIMARY KEY,
    version     REAL NOT NULL,
    created     TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL,
    modified    TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL
);

create or replace function schema_version_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$
language plpgsql;


create trigger
schema_version_mod_trig
before insert or update on SchemaVersion
for each row
execute procedure schema_version_mod_trig_fun();

insert into SchemaVersion (name, version) values ('smt', 3.00);
