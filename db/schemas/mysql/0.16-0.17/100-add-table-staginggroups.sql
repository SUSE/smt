create table StagingGroups(ID             INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                           NAME           VARCHAR(255) NOT NULL UNIQUE,
                           TESTINGPATH    VARCHAR(255) NOT NULL UNIQUE,
                           PRODUCTIONPATH VARCHAR(255) NOT NULL UNIQUE
                          );

