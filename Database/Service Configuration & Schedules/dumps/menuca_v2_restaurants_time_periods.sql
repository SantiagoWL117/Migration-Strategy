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
-- Table structure for table `restaurants_time_periods`
--

DROP TABLE IF EXISTS `restaurants_time_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_time_periods` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `start` time DEFAULT NULL,
  `stop` time DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurants_time_periods`
--

LOCK TABLES `restaurants_time_periods` WRITE;
/*!40000 ALTER TABLE `restaurants_time_periods` DISABLE KEYS */;
INSERT INTO `restaurants_time_periods` VALUES (7,1603,'Lunch','08:45:00','13:20:00','y',24,'2020-03-04 10:27:14',NULL,NULL),(8,1603,'dinner','13:21:00','23:59:00','y',24,'2020-03-04 10:27:56',NULL,NULL),(9,1634,'Daily Luncheon Specials','11:30:00','14:00:00','y',40,'2022-10-12 10:50:51',NULL,NULL),(10,1656,'After 4PM','16:00:00','19:30:00','y',40,'2024-03-28 08:21:06',NULL,NULL),(11,1665,'Kabab Preparation TImes','11:00:00','19:30:00','y',40,'2024-04-29 08:54:07',NULL,NULL),(12,1641,'Dinner','14:01:00','20:50:00','y',40,'2025-02-20 02:53:00',NULL,NULL),(13,1641,'Lunch','01:00:00','14:00:00','y',40,'2025-02-20 02:53:28',NULL,NULL),(14,1668,'Lunch','11:00:00','15:00:00','y',40,'2025-05-14 15:26:18',NULL,NULL);
/*!40000 ALTER TABLE `restaurants_time_periods` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-04 13:21:37
