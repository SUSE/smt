
create table ProductRepositories(product_id    NUMERIC NOT NULL
                                               CONSTRAINT prod_repos_pid_fk
                                               REFERENCES Products (id)
                                               ON DELETE CASCADE,
                                 repository_id NUMERIC NOT NULL
                                               CONSTRAINT prod_repos_rid_fk
                                               REFERENCES Repositories (id)
                                               ON DELETE CASCADE,
                                 optional      VARCHAR(1) DEFAULT 'N'  -- ??? rename to enabled?
                                               CONSTRAINT prod_repos_opt_ck
                                               CHECK (optional in ('Y', 'N')),
                                 src           VARCHAR(1) DEFAULT 'S'    -- S SCC  N NCC  C Custom
                                               CONSTRAINT prod_repos_src_ck
                                               CHECK (src in ('S', 'N', 'C'))
                                );

CREATE UNIQUE INDEX prod_repos_pid_rid_uq
  ON ProductRepositories (product_id, repository_id);

