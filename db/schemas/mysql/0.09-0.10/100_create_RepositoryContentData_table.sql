
create table RepositoryContentData(localpath   VARCHAR(300) PRIMARY KEY,
                                   name        VARCHAR(300) NOT NULL,
                                   checksum    CHAR(50)     NOT NULL,
                                   INDEX idx_repo_cont_data_name_checksum (name, checksum)
                                  );
