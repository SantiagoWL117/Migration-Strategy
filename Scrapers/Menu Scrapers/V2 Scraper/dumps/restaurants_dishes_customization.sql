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
-- Table structure for table `restaurants_dishes_customization`
--

DROP TABLE IF EXISTS `restaurants_dishes_customization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_dishes_customization` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dish_id` int DEFAULT NULL,
  `dish_info` json DEFAULT NULL,
  `has_customization` enum('y','n') DEFAULT 'n',
  `crust` enum('y','n') DEFAULT 'n',
  `crust_customization` json DEFAULT NULL,
  `crust_display_order` tinyint DEFAULT NULL,
  `custom_ingredient` enum('y','n') DEFAULT 'n',
  `custom_ingredient_customization` json DEFAULT NULL,
  `custom_ingredient_display_order` tinyint DEFAULT NULL,
  `premium_toppings` enum('y','n') DEFAULT 'n',
  `premium_toppings_customization` json DEFAULT NULL,
  `premium_toppings_display_order` tinyint DEFAULT NULL,
  `extra` enum('y','n') DEFAULT 'n',
  `extra_customization` json DEFAULT NULL,
  `extra_display_order` tinyint DEFAULT NULL,
  `dressing` enum('y','n') DEFAULT 'n',
  `dressing_customization` json DEFAULT NULL,
  `dressing_display_order` tinyint DEFAULT NULL,
  `sauce` enum('y','n') DEFAULT 'n',
  `sauce_customization` json DEFAULT NULL,
  `sauce_display_order` tinyint DEFAULT NULL,
  `dip` enum('y','n') DEFAULT 'n',
  `dip_customization` json DEFAULT NULL,
  `dip_display_order` tinyint DEFAULT NULL,
  `drink` enum('y','n') DEFAULT 'n',
  `drink_customization` json DEFAULT NULL,
  `drink_display_order` tinyint DEFAULT NULL,
  `side_dish` enum('y','n') DEFAULT 'n',
  `side_dish_customization` json DEFAULT NULL,
  `side_dish_display_order` tinyint DEFAULT NULL,
  `cook_method` enum('y','n') DEFAULT 'n',
  `cook_method_customization` json DEFAULT NULL,
  `cook_method_display_order` tinyint DEFAULT NULL,
  `desert` enum('y','n') DEFAULT 'n',
  `desert_customization` json DEFAULT NULL,
  `desert_display_order` tinyint DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dish` (`dish_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13414 DEFAULT CHARSET=latin1 COMMENT='store dish customization here';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-30 16:16:29
