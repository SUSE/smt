ALTER TABLE Clients change ID ID int(10) unsigned NOT NULL;
call smt.drop_index_if_exists('Clients', 'ID');
CREATE UNIQUE INDEX IF NOT EXISTS Clients_id_uq ON Clients (ID);
ALTER TABLE Clients change ID ID int(10) unsigned NOT NULL AUTO_INCREMENT;

call smt.drop_index_if_exists('Clients', 'idx_clnt_sysid');
CREATE INDEX IF NOT EXISTS Clients_systemid_idx ON Clients (SYSTEMID);

call smt.drop_index_if_exists('Subscriptions', 'idx_sub_product_class');
CREATE INDEX IF NOT EXISTS Subscriptions_product_class_idx ON Subscriptions (PRODUCT_CLASS);

call smt.drop_index_if_exists('Catalogs', 'NAME');
CREATE UNIQUE INDEX IF NOT EXISTS Catalogs_name_target_uq ON Catalogs (NAME, TARGET);

call smt.drop_index_if_exists('Catalogs', 'CID_SRC');
CREATE UNIQUE INDEX IF NOT EXISTS Catalogs_catalogid_src_uq ON Catalogs (CATALOGID, SRC);

call smt.drop_index_if_exists('StagingGroups', 'NAME');
CREATE UNIQUE INDEX IF NOT EXISTS StagingGroups_name_uq ON StagingGroups (NAME);

call smt.drop_index_if_exists('StagingGroups', 'TESTINGDIR');
CREATE UNIQUE INDEX IF NOT EXISTS StagingGroups_testingdir_uq ON StagingGroups (TESTINGDIR);

call smt.drop_index_if_exists('StagingGroups', 'PRODUCTIONDIR');
CREATE UNIQUE INDEX IF NOT EXISTS StagingGroups_productiondir_uq ON StagingGroups (PRODUCTIONDIR);

call smt.drop_index_if_exists('Filters', 'CATALOG_ID');
CREATE UNIQUE INDEX IF NOT EXISTS Filters_cid_sgid_type_value_uq ON Filters (CATALOG_ID, STAGINGGROUP_ID, TYPE, VALUE);

call smt.drop_index_if_exists('Products', 'PDID_SRC');
CREATE UNIQUE INDEX IF NOT EXISTS Products_productdataid_src_uq ON Products (PRODUCTDATAID, SRC);

call smt.drop_index_if_exists('Products', 'PRODUCTLOWER');
CREATE UNIQUE INDEX IF NOT EXISTS Products_pdl_verl_rell_archl_uq ON Products (PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER);

call smt.drop_index_if_exists('Products', 'idx_prod_product_class');
CREATE INDEX IF NOT EXISTS Products_product_class_idx ON Products (PRODUCT_CLASS);

call smt.drop_index_if_exists('ProductExtensions', 'pdid_extid_unq');
CREATE UNIQUE INDEX IF NOT EXISTS ProductExtensions_pdid_extid_uq ON ProductExtensions (PRODUCTID, EXTENSIONID);

call smt.drop_index_if_exists('ProductMigrations', 'pdid_migid_unq');
CREATE UNIQUE INDEX IF NOT EXISTS ProductMigrations_srcpdid_tgtpdid_uq ON ProductMigrations (SRCPDID, TGTPDID);

call smt.drop_index_if_exists('RepositoryContentData', 'idx_repo_cont_data_name_checksum');
CREATE INDEX IF NOT EXISTS RepositoryContentData_name_cksum_cktype_idx ON RepositoryContentData (name, checksum, checksum_type);

CREATE INDEX IF NOT EXISTS ProductExtensions_pdid_extid_src_idx ON ProductExtensions (PRODUCTID, EXTENSIONID, SRC);
