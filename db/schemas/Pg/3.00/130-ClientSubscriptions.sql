
create table ClientSubscriptions(subscription_id NUMERIC NOT NULL
                                     CONSTRAINT clnt_sub_sid_fk
                                     REFERENCES Subscriptions (id)
                                     ON DELETE CASCADE,
                                 client_id       NUMERIC NOT NULL
                                     CONSTRAINT clnt_sub_cid_fk
                                     REFERENCES Clients (id)
                                     ON DELETE CASCADE
                                );

CREATE UNIQUE INDEX clnt_sub_sid_cid_uq
  ON ClientSubscriptions (subscription_id, client_id);

