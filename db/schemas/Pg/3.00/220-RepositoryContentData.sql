
create table RepositoryContentData(localpath     VARCHAR(2048) NOT NULL
                                                 CONSTRAINT rcd_localpath_pk PRIMARY KEY,
                                   name          VARCHAR(300) NOT NULL,
                                   checksum      VARCHAR(255) NOT NULL,
                                   checksum_type VARCHAR(20)  NOT NULL DEFAULT 'sha1'
                                  );

CREATE INDEX rcd_name_csum_csumt_idx
  ON RepositoryContentData (name, checksum, checksum_type);


