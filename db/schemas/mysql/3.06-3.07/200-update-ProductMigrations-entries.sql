update ProductMigrations set KIND = 'online';
alter table ProductMigrations change column KIND KIND enum('online', 'offline') not null;
