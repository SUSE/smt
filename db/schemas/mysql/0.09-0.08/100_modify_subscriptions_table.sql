create table ProductSubscriptions(PRODUCTDATAID integer  NOT NULL,
                                  SUBID         CHAR(50) NOT NULL,
                                  PRIMARY KEY(PRODUCTDATAID, SUBID)
                                 );

drop index idx_sub_product_class ON Subscriptions;
drop index idx_prod_product_class ON Products;
alter table Subscriptions CHANGE PRODUCT_CLASS  PRODGROUP VARCHAR(100);
