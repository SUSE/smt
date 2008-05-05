drop table if exists Subscriptions;
drop table if exists ProductSubscriptions;
drop table if exists ClientSubscriptions;

create table Subscriptions(REGCODE        VARCHAR(100) PRIMARY KEY,
                           SUBNAME        VARCHAR(100) NOT NULL,
                           SUBTYPE        CHAR(20)  DEFAULT "UNKNOWN",
                           SUBSTATUS      CHAR(20)  DEFAULT "UNKNOWN",
                           SUBSTARTDATE   TIMESTAMP NOT NULL,
                           SUBENDDATE     TIMESTAMP NOT NULL,
                           SUBDURATION    BIGINT    DEFAULT 0,
                           SERVERCLASS    CHAR(50),
                           NODECOUNT      integer NOT NULL,
                           CONSUMED       integer DEFAULT 0
                          );

create table ProductSubscriptions(PRODUCTDATAID integer NOT NULL,
                                  REGCODE       VARCHAR(100) NOT NULL,
                                  PRIMARY KEY(PRODUCTDATAID, REGCODE)
                                 );


create table ClientSubscriptions(GUID    CHAR(50)     NOT NULL,
                                 REGCODE VARCHAR(100) NOT NULL,
                                 PRIMARY KEY(GUID, REGCODE)
                                );
