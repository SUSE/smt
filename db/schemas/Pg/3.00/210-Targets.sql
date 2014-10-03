
create table Targets (os      VARCHAR(200) NOT NULL
                              CONSTRAINT target_od_pk PRIMARY KEY,
                      target  VARCHAR(100) NOT NULL,
                      src     VARCHAR(1) DEFAULT 'S'    -- N NCC   C Custom
                              CONSTRAINT target_src_ck
                              CHECK (src in ('S', 'N', 'C'))
                     );


