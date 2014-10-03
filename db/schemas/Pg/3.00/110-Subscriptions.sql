
create table Subscriptions(id             NUMERIC
                                          CONSTRAINT subscriptions_id_pk PRIMARY KEY,
                           subid          NUMERIC NOT NULL,
                           regcode        VARCHAR(100) NOT NULL,
                           subname        VARCHAR(100) NOT NULL,
                           subtype        VARCHAR(20) NOT NULL DEFAULT 'UNKNOWN',
                           substatus      VARCHAR(20) NOT NULL DEFAULT 'UNKNOWN',
                           substartdate   TIMESTAMPTZ NULL default NULL,
                           subenddate     TIMESTAMPTZ NULL default CURRENT_TIMESTAMP,
                           product_class  VARCHAR(100) NOT NULL,
                           nodecount      numeric NOT NULL,
                           consumed       numeric DEFAULT 0,
                           consumedvirt   numeric DEFAULT 0,
                           created        TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL,
                           modified       TIMESTAMPTZ DEFAULT (current_timestamp) NOT NULL
                          );

CREATE INDEX sub_prod_class
  ON Subscriptions (product_class);

CREATE UNIQUE INDEX sub_subid_uq
  ON Subscriptions (subid);

CREATE SEQUENCE subscriptions_id_seq;


create or replace function subscriptions_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$
language plpgsql;


create trigger
subscriptions_mod_trig
before insert or update on Subscriptions
for each row
execute procedure subscriptions_mod_trig_fun();

