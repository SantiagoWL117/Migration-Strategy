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
-- Table structure for table `menu_v3_restaurants_courses`
--

DROP TABLE IF EXISTS `menu_v3_restaurants_courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_v3_restaurants_courses` (
  `id` int NOT NULL,
  `restaurant_v2_id` int DEFAULT NULL,
  `name` varchar(125) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_dishes`
--

DROP TABLE IF EXISTS `restaurants_dishes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_dishes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `global_dish_id` int DEFAULT NULL,
  `course_id` int DEFAULT NULL,
  `has_customization` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'n',
  `is_combo` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'n',
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `description` mediumtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `size` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `size_j` json DEFAULT NULL COMMENT 'json encoded size',
  `price` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `price_j` json DEFAULT NULL COMMENT 'json encoded price',
  `display_order` tinyint unsigned DEFAULT '0',
  `dish_image` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `upsell` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'n',
  `enabled` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'y',
  `added_by` smallint unsigned DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` smallint unsigned DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  `unavailable_until` timestamp NULL DEFAULT NULL,
  `unavailabled_by` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10667 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-30 16:16:01
