-- MySQL dump 10.11
--
-- Host: localhost    Database: smt
-- ------------------------------------------------------
-- Server version	5.0.67

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `MachineData`
--

DROP TABLE IF EXISTS `MachineData`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `MachineData` (
  `GUID` char(50) NOT NULL,
  `KEYNAME` char(50) NOT NULL,
  `VALUE` blob,
  PRIMARY KEY  (`GUID`,`KEYNAME`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `MachineData`
--

LOCK TABLES `MachineData` WRITE;
/*!40000 ALTER TABLE `MachineData` DISABLE KEYS */;

INSERT INTO `MachineData` VALUES ('4f6d81cabd5343548dda08f425b0ceea', 'host', '');
INSERT INTO `MachineData` VALUES ('f7ef7ef5a8be4884991a9f7b153515f9', 'host', '');
INSERT INTO `MachineData` VALUES ('65f411b03c4e4009867c316a798b960c', 'host', '');
INSERT INTO `MachineData` VALUES ('abcd1', 'host', '');
INSERT INTO `MachineData` VALUES ('abcd2', 'host', '');
INSERT INTO `MachineData` VALUES ('abcd3', 'host', '');
INSERT INTO `MachineData` VALUES ('abcd4', 'host', '');
INSERT INTO `MachineData` VALUES ('abcd5', 'host', '');
INSERT INTO `MachineData` VALUES ('abcd6', 'host', '');
INSERT INTO `MachineData` VALUES ('abcd7', 'host', '');
INSERT INTO `MachineData` VALUES ('abcd8', 'host', '');
INSERT INTO `MachineData` VALUES ('abcd9', 'host', '');
INSERT INTO `MachineData` VALUES ('abcd10', 'host', '');
INSERT INTO `MachineData` VALUES ('abcd11', 'host', '');
INSERT INTO `MachineData` VALUES ('xyz1', 'host', '');
INSERT INTO `MachineData` VALUES ('xyz2', 'host', '');
INSERT INTO `MachineData` VALUES ('xyz3', 'host', 'Y');
INSERT INTO `MachineData` VALUES ('xyz4', 'host', 'Y');
INSERT INTO `MachineData` VALUES ('xyz5', 'host', '');
/* INSERT INTO `MachineData` VALUES ('', 'host', ''); */

/*!40000 ALTER TABLE `MachineData` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-06-09 11:28:44
