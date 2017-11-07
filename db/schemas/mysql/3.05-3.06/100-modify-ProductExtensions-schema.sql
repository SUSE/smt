alter table ProductExtensions add column ROOTPRODUCTID int not null;
alter table ProductExtensions add column RECOMMENDED bool default false;
alter table ProductExtensions drop index ProductExtensions_pdid_extid_uq;
alter table ProductExtensions drop index ProductExtensions_pdid_extid_src_idx;
