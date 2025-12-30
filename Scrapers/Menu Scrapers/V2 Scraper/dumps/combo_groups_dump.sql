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
-- Table structure for table `menu_v3_combo_groups`
--

DROP TABLE IF EXISTS `menu_v3_combo_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_v3_combo_groups` (
  `id` int NOT NULL,
  `restaurant_V2_id` int DEFAULT NULL,
  `group_name` varchar(125) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_v3_combo_groups`
--

LOCK TABLES `menu_v3_combo_groups` WRITE;
/*!40000 ALTER TABLE `menu_v3_combo_groups` DISABLE KEYS */;
INSERT INTO `menu_v3_combo_groups` VALUES (110,1637,'2 Pizzas 1 Topping'),(111,1637,'2 Pizzas 2 Toppings'),(112,1637,'2 Pizzas 3 Toppings'),(113,1637,'2 Dips Free'),(114,1637,'Small Pizza 3 Toppings'),(115,1637,'Medium Pizza 3 Toppings'),(116,1637,'Large Pizza 3 Toppings'),(117,1637,'2 Small Pizzas 3 Toppings'),(118,1637,'Wings Sauces'),(119,1637,'Dips'),(120,1637,'2 Medium Pizzas 3 Toppings'),(121,1637,'2 Large Pizzas 3 Toppings'),(122,1637,'2 Large Pizzas 4 Toppings'),(123,1637,'6 Dips Free'),(124,1637,'2 Subs Free'),(125,1637,'2 Wraps with Drink'),(134,1639,'Large Pizza 3 Toppings'),(135,1639,'Twins 1 Topping'),(136,1639,'Twins 2 Toppings'),(137,1639,'Twins 3 Toppings'),(138,1639,'Dipping Sauces'),(151,1660,'Le Grand Duo'),(152,1660,'2 Trempettes Gratuit'),(154,1660,'Special Chicco (Large Pizza)'),(155,1660,'Ailes Sauces'),(156,1660,'1 Dip Free'),(157,1660,'1 Large Pizza 3 Toppings'),(158,1660,'1 Small Pizza 3 Toppings'),(166,1663,'2 Large Pizzas 3 Toppings'),(167,1663,'1 Large Pizza 3 Toppings'),(168,1663,'1 Small Pizza 3 Toppings'),(169,1663,'1 X-Large Pizza 3 Toppings'),(170,1663,'1st Dip Free'),(171,1663,'2 Dips Free'),(172,1663,'Wings Sauces'),(173,1661,'2 Large Pizzas 3 Toppings'),(174,1661,'1 Large Pizza 3 Toppings'),(175,1661,'1 Small Pizza 3 Toppings'),(176,1661,'1 X-Large Pizza 3 Toppings'),(177,1661,'1st Dip Free'),(178,1661,'2 Dips Free'),(179,1661,'Wings Sauces'),(180,1664,'2 Large Pizzas 3 Toppings'),(181,1664,'1 Large Pizza 3 Toppings'),(182,1664,'1 Small Pizza 3 Toppings'),(183,1664,'1st Dip Free'),(184,1664,'2 Dips Free'),(185,1664,'Wings Sauces'),(186,1664,'1 X-Large Pizza 3 Toppings'),(210,1668,'Dineer Combo For 2'),(211,1668,'Dinner Combo For 4'),(212,1668,'Pita Combo for 2'),(213,1668,'Pita Combo for 4'),(214,1668,'Fries or Greek Salad for Pita Combo 2'),(215,1668,'Fries or Greek Salad for Pita Combo 4'),(216,1671,'Small Pizza 3 Toppings'),(217,1671,'Medium Pizza 3 Toppings'),(218,1671,'Large Pizza 3 Toppings'),(219,1671,'X-Large Pizza 3 Toppings'),(220,1671,'2 Large Pizzas 3 Toppings'),(221,1671,'1st Dip Free'),(222,1671,'2 Dips Free'),(223,1671,'Wings Sauces'),(224,1670,'Twins 1 Topping'),(225,1670,'Twins 2 Toppings'),(226,1670,'Twins 3 Toppings'),(227,1670,'Dips'),(228,1670,'1 Small Pizza 3 Toppings'),(229,1670,'1 Medium Pizza 3 Toppings'),(230,1670,'1 Large Pizza 3 Toppings'),(231,1670,'2 Small 3 Toppings'),(232,1670,'2 Medium Pizzas 3 Toppings'),(233,1670,'2 Large Pizzas 3 Toppings'),(234,1670,'Wings Sauces'),(235,1673,'2 Medium Pizza (from the menu'),(236,1673,'2 Large Pizza (from the menu)'),(237,1673,'2 Medium Special'),(238,1673,'2 Large Pizza (from the menu)'),(239,1674,'Twins Pizzas'),(240,1674,'Medium Pizza 3 Toppings'),(241,1674,'Wings Sauces'),(242,1674,'2 Dips Free'),(243,1674,'Large Pizza 3 Toppings'),(245,1663,'2 Medium Pepperoni Pizzas'),(246,1661,'2 Medium Pepperoni Pizzas'),(247,1660,'2 Medium Pepperoni Pizzas'),(248,1664,'2 Medium Pepperoni Pizzas'),(259,1670,'1 Large Pizza 1 Topping'),(260,1670,'1st Dip Free'),(261,1670,'1 Medium 1 Topping');
/*!40000 ALTER TABLE `menu_v3_combo_groups` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-30 15:07:24
