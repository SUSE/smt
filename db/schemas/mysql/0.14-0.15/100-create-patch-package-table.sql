create table Patches( ID          INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
                      CATALOGID   INTEGER UNSIGNED NOT NULL,
                      NAME        VARCHAR(127) NOT NULL,
                      VERSION     VARCHAR(32) NOT NULL,
                      CATEGORY    INTEGER UNSIGNED NOT NULL DEFAULT 1,
                      SUMMARY     VARCHAR(512) NOT NULL,
                      DESCRIPTION VARCHAR(1024) NOT NULL,
                      RELDATE     TIMESTAMP NOT NULL,
                      PRIMARY KEY (ID)
                    );
                    
create table PatchRefs( ID          INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
                        PATCHID     INTEGER UNSIGNED NOT NULL,
                        REFID       VARCHAR(32) NOT NULL,
                        REFTYPE     VARCHAR(8) NOT NULL,  
                        URL         VARCHAR(256),
                        TITLE       VARCHAR(256),
                        PRIMARY KEY (ID)
                      );

create table Packages ( ID          INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
                        CATALOGID   INTEGER UNSIGNED NOT NULL,
                        PATCHID     INTEGER UNSIGNED DEFAULT NULL,
                        NAME        VARCHAR(127) NOT NULL,
                        VERSION     VARCHAR(32) NOT NULL,
                        RELEASE     VARCHAR(64) NOT NULL,
                        ARCH        VARCHAR(32) NOT NULL,
                        -- relative .rpm file path within the repository
                        LOCATION    VARCHAR(255) NOT NULL,
                        PRIMARY KEY (ID)
                      );


