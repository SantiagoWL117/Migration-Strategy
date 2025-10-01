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
-- Table structure for table `global_courses`
--

DROP TABLE IF EXISTS `global_courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `global_courses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant_type` int DEFAULT NULL,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `language_id` tinyint unsigned DEFAULT NULL,
  `enabled` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT 'y',
  `added_at` timestamp NULL DEFAULT NULL,
  `added_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_type` (`restaurant_type`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_courses`
--

LOCK TABLES `global_courses` WRITE;
/*!40000 ALTER TABLE `global_courses` DISABLE KEYS */;
INSERT INTO `global_courses` VALUES (1,1,'Appetizers','',1,'y','2017-03-17 12:20:55',24,NULL,NULL),(2,1,'Wings','',1,'y','2017-03-17 12:21:14',24,NULL,NULL),(3,1,'Southern Fried Chicken','',1,'y','2017-03-17 12:21:26',24,NULL,NULL),(4,1,'Salads','',1,'y','2017-03-17 12:21:31',24,NULL,NULL),(5,1,'Sandwiches','',1,'y','2017-03-17 12:21:37',24,NULL,NULL),(6,1,'Shawarma','',1,'y','2017-03-17 12:21:50',24,NULL,NULL),(7,1,'Hot Subs','',1,'y','2017-03-17 12:21:58',24,NULL,NULL),(8,1,'Cold Subs','',1,'y','2017-03-17 12:22:06',24,NULL,NULL),(9,1,'Donairs','',1,'y','2017-03-17 12:22:14',24,NULL,NULL),(10,1,'Poutine','',1,'y','2017-03-17 12:22:21',24,NULL,NULL),(11,1,'Pizza and Free 591ml Beverage','',1,'y','2017-03-17 12:22:39',24,NULL,NULL),(12,1,'Gourmet Pizza and 591ml Beverage','',1,'y','2017-03-17 12:22:53',24,NULL,NULL),(13,1,'Pasta','',1,'y','2017-03-17 12:23:00',24,NULL,NULL),(14,1,'Platters','\r\n',1,'y','2017-03-17 12:23:06',24,NULL,NULL),(15,1,'Shawarma Platters','',1,'y','2017-03-17 12:23:17',24,NULL,NULL),(16,1,'Desserts','',1,'y','2017-03-17 12:23:23',24,NULL,NULL),(17,1,'Drinks','',1,'y','2017-03-17 12:23:29',24,NULL,NULL),(18,2,'indan course 1','',1,'n','2021-01-26 15:37:36',24,'2021-01-26 15:39:07',24),(19,2,'indan course 2','',1,'n','2021-01-26 15:38:16',24,'2021-01-26 15:39:36',24),(20,2,'test','',1,'y','2021-01-26 15:44:40',1,NULL,NULL),(21,2,'kjhgf','',1,'y','2021-01-26 15:44:51',1,NULL,NULL),(22,3,'test','',1,'y','2021-01-26 15:50:28',40,NULL,NULL),(23,2,'indian 1','',1,'y','2021-01-26 16:26:58',24,NULL,NULL),(24,3,'Appetizers','',1,'y','2022-02-21 16:59:10',44,NULL,NULL),(25,3,'Soups','',1,'y','2022-02-21 16:59:24',44,NULL,NULL),(26,3,'Fried Rice','',1,'y','2022-02-21 16:59:30',44,NULL,NULL),(27,3,'Seafood','',1,'y','2022-02-21 17:00:08',44,NULL,NULL),(28,3,'Chicken','',1,'y','2022-02-21 17:00:28',44,NULL,NULL),(29,3,'Beef','',1,'y','2022-02-21 17:00:40',44,NULL,NULL),(30,3,'Egg Foo Young','',1,'y','2022-02-21 17:02:14',44,NULL,NULL),(31,3,'Side Orders','',1,'y','2022-02-21 17:02:23',44,NULL,NULL),(32,3,'Family Dinners','',1,'y','2022-02-21 17:02:33',44,NULL,NULL),(33,3,'Combination Plates','',1,'y','2022-02-23 19:53:32',44,NULL,NULL);
/*!40000 ALTER TABLE `global_courses` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-01 10:30:17
