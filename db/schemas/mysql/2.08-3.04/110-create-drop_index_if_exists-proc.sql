DROP PROCEDURE IF EXISTS smt.drop_index_if_exists;

DELIMITER //

CREATE PROCEDURE smt.drop_index_if_exists(in theTable varchar(128), in theIndexName varchar(128) )
BEGIN
 IF((SELECT COUNT(*) AS index_exists
       FROM information_schema.statistics
      WHERE TABLE_SCHEMA = DATABASE()
        AND table_name = theTable
        AND index_name = theIndexName) > 0) THEN
   SET @s = CONCAT('DROP INDEX ' , theIndexName , ' ON ' , theTable);
   PREPARE stmt FROM @s;
   EXECUTE stmt;
 END IF;
END;

//

DELIMITER ;

