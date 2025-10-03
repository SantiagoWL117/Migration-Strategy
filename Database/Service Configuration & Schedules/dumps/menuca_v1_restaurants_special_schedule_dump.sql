-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: menuca_v1
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
-- Table structure for table `restaurants_special_schedule`
--

DROP TABLE IF EXISTS `restaurants_special_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_special_schedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `special_date` date NOT NULL,
  `time_start` time DEFAULT NULL,
  `time_stop` time DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_restaurant_date` (`restaurant_id`,`special_date`),
  KEY `idx_enabled_special` (`enabled`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurants_special_schedule`
--

LOCK TABLES `restaurants_special_schedule` WRITE;
/*!40000 ALTER TABLE `restaurants_special_schedule` DISABLE KEYS */;
INSERT INTO `restaurants_special_schedule` VALUES (1,642,'2016-07-01','15:00:00','21:00:00','y',NULL,'2025-09-22 15:27:40','2025-09-22 15:27:40'),(2,642,'2016-07-01','15:00:00','21:00:00','y',NULL,'2025-09-22 15:27:40','2025-09-22 15:27:40'),(3,642,'2016-09-05','15:00:00','22:00:00','y',NULL,'2025-09-22 15:27:40','2025-09-22 15:27:40'),(4,931,'2020-12-25','16:00:00','22:00:00','y',NULL,'2025-09-22 15:27:40','2025-09-22 15:27:40'),(5,931,'2021-01-01','16:00:00','22:00:00','y',NULL,'2025-09-22 15:27:40','2025-09-22 15:27:40');
/*!40000 ALTER TABLE `restaurants_special_schedule` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-02 15:41:44
