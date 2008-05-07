-- this table is dropped
drop table if exists ProductSubscriptions;

alter table Subscriptions CHANGE PRODGROUP PRODUCT_CLASS VARCHAR(100);
create index idx_sub_product_class ON Subscriptions (PRODUCT_CLASS);
create index idx_prod_product_class ON Products (PRODUCT_CLASS);
