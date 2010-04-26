create table reg_sessions ( id          INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                            guid        CHAR(50) NOT NULL UNIQUE KEY,
                            yaml        BLOB,
                            updated_at  TIMESTAMP default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                            INDEX reg_session_guid_idx (GUID),
                            INDEX reg_session_updated_at_idx (updated_at)
                          );
create table needinfo_params ( id          INTEGER UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                               product_id  INTEGER UNSIGNED NOT NULL,
                               param_name  VARCHAR(50) NOT NULL,
                               description VARCHAR(300),
                               command     VARCHAR(300),
                               mandatory   TINYINT(1) NOT NULL default 0,
                               INDEX needinfo_params_name_idx (param_name),
                               UNIQUE(product_id, param_name)
                             );