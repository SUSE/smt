
create table RepositoryContentData(localpath   VARCHAR(300) PRIMARY KEY,
                                   name        VARCHAR(300) NOT NULL,
                                   checksum    CHAR(50)     NOT NULL,
                                   INDEX idx_repo_cont_data_name_checksum (name, checksum)
                                  );

alter table Clients add COLUMN NAMESPACE   VARCHAR(300) NOT NULL DEFAULT '';
alter table Clients add COLUMN SECRET      CHAR(50) NOT NULL DEFAULT '';
alter table Subscriptions add COLUMN CONSUMEDVIRT integer DEFAULT 0;
alter table Catalogs add COLUMN STAGING    CHAR(1) DEFAULT 'N';