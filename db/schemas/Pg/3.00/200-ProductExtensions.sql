
create table ProductExtensions (
                                product_id   NUMERIC NOT NULL
                                             CONSTRAINT pext_pid_fk
                                             REFERENCES Products (id)
                                             ON DELETE CASCADE,
                                extension_id NUMERIC NOT NULL
                                             CONSTRAINT pext_eid_fk
                                             REFERENCES Products (id)
                                             ON DELETE CASCADE,
                                src          VARCHAR(1) DEFAULT 'S'
                                             CONSTRAINT pext_src_ck
                                             CHECK (src in ('S', 'N', 'C'))
);

CREATE UNIQUE INDEX pext_pid_eid_uq
  ON ProductExtensions (product_id, extension_id);


