-- we need to change the primary key.
-- we drop the table and create them new. 
-- All data in this table get lost, but they come from NCC and can be
-- re-filled again with smt ncc-sync command
drop table if exists Subscriptions;
drop table if exists ProductSubscriptions;
drop table if exists ClientSubscriptions;

create table Subscriptions(SUBID          CHAR(50) PRIMARY KEY, 
                           REGCODE        VARCHAR(100),
                           SUBNAME        VARCHAR(100) NOT NULL,
                           SUBTYPE        CHAR(20)  DEFAULT "UNKNOWN",
                           SUBSTATUS      CHAR(20)  DEFAULT "UNKNOWN",
                           SUBSTARTDATE   TIMESTAMP NULL default NULL,
                           SUBENDDATE     TIMESTAMP NULL default CURRENT_TIMESTAMP,
                           SUBDURATION    BIGINT    DEFAULT 0,
                           SERVERCLASS    CHAR(50),
                           PRODGROUP      VARCHAR(100),
                           NODECOUNT      integer NOT NULL,
                           CONSUMED       integer DEFAULT 0
                          );

create table ProductSubscriptions(PRODUCTDATAID integer  NOT NULL,
                                  SUBID         CHAR(50) NOT NULL,
                                  PRIMARY KEY(PRODUCTDATAID, SUBID)
                                 );


create table ClientSubscriptions(GUID    CHAR(50) NOT NULL,
                                 SUBID   CHAR(50) NOT NULL,
                                 PRIMARY KEY(GUID, SUBID)
                                );
