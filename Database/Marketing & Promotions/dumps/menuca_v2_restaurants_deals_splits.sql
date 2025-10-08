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
-- Table structure for table `restaurants_deals_splits`
--

DROP TABLE IF EXISTS `restaurants_deals_splits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_deals_splits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `deal_id` int DEFAULT NULL,
  `content` json DEFAULT NULL COMMENT 'contains array with split information',
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `deal_id` (`deal_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurants_deals_splits`
--

LOCK TABLES `restaurants_deals_splits` WRITE;
/*!40000 ALTER TABLE `restaurants_deals_splits` DISABLE KEYS */;
INSERT INTO `restaurants_deals_splits` VALUES (2,3,'[{\"from\": \"-1\", \"value\": \"13\"}, {\"from\": \"r\", \"value\": \"77\"}, {\"from\": \"v - 38\", \"value\": \"10\"}, {\"from\": \"r\", \"value\": \"1\"}, {\"from\": \"-1\", \"value\": \"\"}, {\"from\": \"-1\", \"value\": \"\"}, {\"from\": \"-1\", \"value\": \"\"}, {\"from\": \"-1\", \"value\": \"\"}]','y',1,'2017-05-03 17:42:23',1,'2017-06-09 12:41:11',NULL,NULL);
/*!40000 ALTER TABLE `restaurants_deals_splits` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-07 14:53:37
