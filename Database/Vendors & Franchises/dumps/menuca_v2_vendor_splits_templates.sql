-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: menuca_v2
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `vendor_splits_templates`
--

DROP TABLE IF EXISTS `vendor_splits_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_splits_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(125) DEFAULT NULL,
  `commission_from` char(15) DEFAULT NULL,
  `menuottawa_share` decimal(5,2) DEFAULT NULL,
  `breakdown` text,
  `return_info` text,
  `file` varchar(125) DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendor_splits_templates`
--

LOCK TABLES `vendor_splits_templates` WRITE;
/*!40000 ALTER TABLE `vendor_splits_templates` DISABLE KEYS */;
INSERT INTO `vendor_splits_templates` VALUES (1,'mazen_milanos','gross',80.00,'$forVendor = ##total## * .3;\r\n$collection = ##total## * ##restaurant_convenience_fee##;\r\n$forMenuOttawa = ($collection - $forVendor - ##menuottawa_share##) / 2;','vendor_id => ##vendor_id##\r\nrestaurant_address => ##restaurant_address##\r\nrestaurant_name => ##restaurant_name##\r\nrestaurant_id => ##restaurant_id##\r\nrestaurant_commission => ##restaurant_commission##,\r\nforVendor => $forVendor','mazen_milanos','y',1,'2021-08-20 14:11:09'),(2,'percent_commission','net',80.00,'$tenPercent = ##total##*(##restaurant_commission## / 100);\r\n$firstSplit = $tenPercent - ##menuottawa_share##;\r\n$forVendor_0= $firstSplit / 2;\r\n$forJames=$forVendor_0 / 2;','vendor_id => ##vendor_id##\r\nrestaurant_address => ##restaurant_address##\r\nrestaurant_name => ##restaurant_name##\r\nrestaurant_id => ##restaurant_id##\r\nuseTotal=> ##total##,\r\nforVendor => $forVendor_0\r\nforJames=>$forJames','_percent','y',1,'2024-12-05 10:05:01');
/*!40000 ALTER TABLE `vendor_splits_templates` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-10 15:19:44
