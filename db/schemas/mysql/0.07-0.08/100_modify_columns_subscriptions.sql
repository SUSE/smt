alter table Subscriptions modify COLUMN SUBSTARTDATE timestamp NULL default NULL;
alter table Subscriptions modify COLUMN SUBENDDATE timestamp NULL default CURRENT_TIMESTAMP;

