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
-- Table structure for table `tookan_fees`
--

DROP TABLE IF EXISTS `tookan_fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tookan_fees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `area` tinyint NOT NULL,
  `driver_earnings` decimal(5,2) NOT NULL,
  `restaurant` decimal(5,2) NOT NULL DEFAULT '0.00',
  `vendor` decimal(5,2) NOT NULL DEFAULT '0.00',
  `total_fare` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_restaurant_area` (`restaurant_id`,`area`)
) ENGINE=InnoDB AUTO_INCREMENT=868 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tookan_fees`
--

LOCK TABLES `tookan_fees` WRITE;
/*!40000 ALTER TABLE `tookan_fees` DISABLE KEYS */;
INSERT INTO `tookan_fees` VALUES (4,919,0,3.54,3.54,0.00,0),(7,910,0,6.00,0.00,0.00,0),(8,910,1,7.00,0.00,0.00,0),(9,910,2,8.00,0.00,0.00,0),(10,910,3,9.00,0.00,0.00,0),(11,922,0,3.99,0.00,0.00,0),(15,929,0,3.54,3.54,0.00,0),(37,928,0,3.54,3.54,0.00,0),(38,911,0,3.54,3.54,0.00,0),(39,911,1,3.54,3.54,0.00,0),(44,138,0,3.54,3.54,0.00,0),(45,138,1,3.54,3.54,0.00,0),(51,931,0,3.54,3.54,0.00,0),(53,137,0,3.54,3.54,0.00,0),(56,137,1,4.20,4.20,0.00,0),(57,137,2,4.87,4.87,0.00,0),(58,137,3,5.53,5.53,0.00,0),(59,203,0,4.00,4.00,0.00,0),(60,255,0,4.00,4.00,0.00,0),(61,323,0,4.00,4.00,0.00,0);
/*!40000 ALTER TABLE `tookan_fees` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-06 17:04:42
