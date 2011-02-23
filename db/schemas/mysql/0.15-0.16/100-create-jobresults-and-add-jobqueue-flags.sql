--
-- create table JobResults
--
create table JobResults ( JOB_ID     INTEGER UNSIGNED NOT NULL,
                          CLIENT_ID  INTEGER UNSIGNED NOT NULL,
                          RETRIEVED  TINYINT(1) NOT NULL default 0,
                          RESULT     LONGBLOB,
                          CREATED    TIMESTAMP default CURRENT_TIMESTAMP,
                          CHANGED    TIMESTAMP default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                          PRIMARY KEY (JOB_ID, CLIENT_ID)
                        );

--
-- add flags to JobQueue
--
ALTER TABLE JobQueue ADD COLUMN CACHERESULT TINYINT(1) NOT NULL default 0 AFTER TIMELAG;
ALTER TABLE JobQueue ADD COLUMN    UPSTREAM TINYINT(1) NOT NULL default 0 AFTER TIMELAG;
