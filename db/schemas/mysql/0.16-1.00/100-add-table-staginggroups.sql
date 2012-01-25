create table StagingGroups(ID            INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                           NAME          VARCHAR(255) NOT NULL UNIQUE,
                           TESTINGDIR    VARCHAR(255) NOT NULL UNIQUE,
                           PRODUCTIONDIR VARCHAR(255) NOT NULL UNIQUE
                          );

