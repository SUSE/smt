alter table ProductExtensions ADD UNIQUE KEY `ProductExtensions_pdid_extid_rtpdid_uq` (`PRODUCTID`,`EXTENSIONID`, `ROOTPRODUCTID`);
alter table ProductExtensions ADD KEY `ProductExtensions_pdid_extid_rtpdid_src_idx` (`PRODUCTID`,`EXTENSIONID`,`ROOTPRODUCTID`,`SRC`);
