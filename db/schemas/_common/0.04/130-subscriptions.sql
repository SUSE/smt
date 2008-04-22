insert into Subscriptions VALUES('sles1', 'SLES x86', 'FULL', 'ACTIVE', '2008-01-01 00:00:00', '2009-01-01 00:00:00', '366', 'OS', 10, 20);
insert into Subscriptions VALUES('sles2', 'SLES x86', 'FULL', 'ACTIVE', '2008-01-01 00:00:00', '2009-01-01 00:00:00', '366', 'OS', 1, 1);
insert into Subscriptions VALUES('sles5', 'SLES x86', 'FULL', 'EXPIRED', '2007-01-01 00:00:00', '2008-01-01 00:00:00', '365', 'OS', 7, 2);
insert into Subscriptions VALUES('sles3', 'SLES x86', 'FULL', 'ACTIVE', '2007-04-01 00:00:00', '2008-05-10 00:00:00', '366', 'OS', 1, 1);
insert into Subscriptions VALUES('sled10', 'SLED x86', 'FULL', 'ACTIVE', '2008-01-01 00:00:00', '2009-01-01 00:00:00', '366', 'OS', 50, 2);

-- -------------------------------------------------------------------------------------------------------------------------------------

insert into ProductSubscriptions VALUES(436, 'sles1');
insert into ProductSubscriptions VALUES(437, 'sles1');
insert into ProductSubscriptions VALUES(438, 'sles1');
insert into ProductSubscriptions VALUES(439, 'sles1');

insert into ProductSubscriptions VALUES(436, 'sles2');
insert into ProductSubscriptions VALUES(437, 'sles2');
insert into ProductSubscriptions VALUES(438, 'sles2');
insert into ProductSubscriptions VALUES(439, 'sles2');

insert into ProductSubscriptions VALUES(436, 'sles5');
insert into ProductSubscriptions VALUES(437, 'sles5');
insert into ProductSubscriptions VALUES(438, 'sles5');
insert into ProductSubscriptions VALUES(439, 'sles5');

insert into ProductSubscriptions VALUES(436, 'sles3');
insert into ProductSubscriptions VALUES(437, 'sles3');
insert into ProductSubscriptions VALUES(438, 'sles3');
insert into ProductSubscriptions VALUES(439, 'sles3');


insert into ProductSubscriptions VALUES(431, 'sled10');
insert into ProductSubscriptions VALUES(432, 'sled10');
insert into ProductSubscriptions VALUES(433, 'sled10');
insert into ProductSubscriptions VALUES(434, 'sled10');
insert into ProductSubscriptions VALUES(435, 'sled10');
insert into ProductSubscriptions VALUES(446, 'sled10');

-- -------------------------------------------------------------------------------------------------------------------------------------

insert into ClientSubscriptions VALUES('d6ba99c76dd5422a969ed1e33f8e9fd8', 'sles1');
insert into ClientSubscriptions VALUES('slessp1i586', 'sled10');
insert into ClientSubscriptions VALUES('sledsp1i586online', 'sles5');
insert into ClientSubscriptions VALUES('sledsp1x8664', 'sles5');
insert into ClientSubscriptions VALUES('be780d21a3c143cd936f2c30527e7f32', 'sles3');



-- -------------------------------------------------------------------------------------------------------------------------------------


insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sles-1', 'test10', 'sles-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sles-2', 'test11', 'sles-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sles-3', 'test12', 'sles-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sles-4', 'test13', 'sles-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sles-5', 'test14', 'sles-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sles-6', 'test15', 'sles-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sles-7', 'test16', 'sles-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sles-8', 'test17', 'sles-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sles-9', 'test18', 'sles-10-i586');
insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sles-0', 'test19', 'sles-10-i586');

insert into ClientSubscriptions VALUES('sles-0', 'sles1');
insert into ClientSubscriptions VALUES('sles-1', 'sles1');
insert into ClientSubscriptions VALUES('sles-2', 'sles1');
insert into ClientSubscriptions VALUES('sles-3', 'sles1');
insert into ClientSubscriptions VALUES('sles-4', 'sles1');
insert into ClientSubscriptions VALUES('sles-5', 'sles1');
insert into ClientSubscriptions VALUES('sles-6', 'sles1');
insert into ClientSubscriptions VALUES('sles-7', 'sles1');
insert into ClientSubscriptions VALUES('sles-8', 'sles1');
insert into ClientSubscriptions VALUES('sles-9', 'sles1');


insert into Clients (GUID, HOSTNAME, TARGET) VALUES('sles-20', 'test40', 'sles-10-i586');
insert into ClientSubscriptions VALUES('sles-20', 'sles3');



