
drop table if exists RepositoryContentData;
alter table Clients drop COLUMN NAMESPACE;
alter table Clients drop COLUMN SECRET;
alter table Subscriptions drop COLUMN CONSUMEDVIRT;