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
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `language_id` tinyint NOT NULL,
  `name` varchar(45) NOT NULL,
  `description` varchar(255) NOT NULL,
  `display_order` tinyint NOT NULL,
  `time_period` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_courses_restaurants_id_idx` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16398 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES (16384,1,1,'Pizza','Small pizza 4 slices, Medium pizza 6 slices, Large pizza 8 slices, X-Large 10 slices. Choose between Thick Crust, Thin Crust and Gluten Free Crust at $4.00.',0,0),(16385,1,1,'Gourmet Pizza','Gourmet Pizza not available with any coupons or any other offers. Choose between Thick Crust, Thin Crust and Gluten Free Crust',0,0),(16386,1,1,'Appetizers','',0,0),(16387,1,1,'Salads','Dressing Available: Ranch, Italian, Greek and Creamy Garlic',0,0),(16388,1,1,'Platters','Platters served with fries and gravy',0,0),(16389,1,1,'Donairs','Served with lettuce, tomatoes, pickles and your choice of sauce: garlic, hot or sweet and sour. Platters served with fries and gravy',0,0),(16390,1,1,'Subs','All subs are 12\\\" and they are  served with cheese,mayonnaise, lettuce, tomatoes and pickles',0,0),(16391,1,1,'Pasta','',0,0),(16392,1,1,'Specials','<a href=\\\'#f_pizza\\\' id=\\\'bannerclick\\\'><img src=\\\'http://menu.ca/clientimages/milano/pizza.png\\\'/></a>',0,0),(16393,1,1,'2 Pizza Deal','Place your toppings on your twin pizza any way you like.(For example if you order 2 toppings you get a total of 2 toppings that you can divide between the 2 pizza in the pop up window. Once you dress your 1st pizza you can place what\\\\\\\'s left on the next',0,0),(16394,1,1,'Unlisted Dishes','',0,0),(16395,1,1,'Drinks','',0,0),(16396,1,1,'Pizza','',0,0),(16397,1,1,'Special-test','This is a test',0,0);
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
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
