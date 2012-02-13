
ALTER TABLE RepositoryContentData DROP KEY idx_repo_cont_data_name_checksum;
ALTER TABLE RepositoryContentData MODIFY COLUMN checksum   CHAR(130) NOT NULL;
ALTER TABLE RepositoryContentData ADD COLUMN checksum_type CHAR(20)  NOT NULL DEFAULT 'sha1';
ALTER TABLE RepositoryContentData ADD KEY idx_repo_cont_data_name_checksum (name, checksum, checksum_type);


