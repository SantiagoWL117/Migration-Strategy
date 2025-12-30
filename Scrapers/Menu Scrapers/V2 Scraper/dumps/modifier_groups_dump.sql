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
-- Table structure for table `menu_v3_modifier_groups`
--

DROP TABLE IF EXISTS `menu_v3_modifier_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_v3_modifier_groups` (
  `id` int NOT NULL,
  `restaurant_v2_id` int DEFAULT NULL,
  `group_name` varchar(125) DEFAULT NULL,
  `group_type` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_v3_modifier_groups`
--

LOCK TABLES `menu_v3_modifier_groups` WRITE;
/*!40000 ALTER TABLE `menu_v3_modifier_groups` DISABLE KEYS */;
INSERT INTO `menu_v3_modifier_groups` VALUES (280,1171,'Spice Level','cook_method'),(281,1171,'Items for Steamed Rice','side_dish'),(413,1637,'Shawarma & Donairs Sauces','sauce'),(414,1637,'Wings Sauces','sauce'),(415,1637,'Salad Dressings','dressing'),(416,1637,'Pizza Toppings','custom_ingredient'),(417,1637,'Premium Toppings','premium_toppings'),(418,1637,'Dipping Sauces','dip'),(419,1637,'Drinks Can','drink'),(426,1639,'Crust with GF','crust'),(427,1639,'Crust NO GF','crust'),(428,1639,'Pizza Toppings','custom_ingredient'),(429,1639,'Premium Toppings','premium_toppings'),(430,1639,'Pizza Sauce','sauce'),(431,1639,'Wings Sauces','sauce'),(432,1639,'Donairs Sauces','sauce'),(433,1639,'Drinks Can','drink'),(434,1639,'Drinks 2L','drink'),(436,1641,'Meat for Dinner Courses','custom_ingredient'),(437,1641,'Meat for Lunch Courses','custom_ingredient'),(438,1641,'Spiciness Level','sauce'),(439,1641,'Chicken or Shrimp or Tofu','custom_ingredient'),(440,1642,'Salad for Biryani','side_dish'),(441,1642,'Salad for Biryani','side_dish'),(442,1639,'Dipping Sauces','dip'),(460,1654,'Crust Type','crust'),(461,1654,'Pizza Toppings','custom_ingredient'),(462,1654,'Premium Toppings','premium_toppings'),(463,1654,'Pizza Sauces','sauce'),(464,1654,'Dips','dip'),(465,1654,'Wings Sauces','sauce'),(466,1654,'Toppings for PASTA','custom_ingredient'),(467,1654,'Chicken for SALADS','custom_ingredient'),(486,1658,'Ajouter une autre personne 12.99','extra'),(487,1658,'Ajouter une autre personne 14.50','extra'),(488,1658,'TRIO Side Dishes','side_dish'),(489,1658,'Drinks Can','drink'),(499,1660,'TRIO Side Dishes','side_dish'),(500,1660,'Drinks Can','drink'),(501,1660,'Ajouter une autre personne 12.99','extra'),(502,1660,'Ajouter une autre personne 14.50','extra'),(503,1660,'Pizza Toppings','custom_ingredient'),(504,1660,'Premium Toppings','premium_toppings'),(505,1660,'Dips','dip'),(506,1660,'Wings Sauces','sauce'),(507,1661,'TRIO Side Dishes','side_dish'),(508,1661,'Drinks Can','drink'),(509,1661,'Ajouter une autre personne 12.99','extra'),(510,1661,'Ajouter une autre personne 14.50','extra'),(511,1661,'Pizza Toppings','custom_ingredient'),(512,1661,'Premium Toppings','premium_toppings'),(513,1661,'Dips','dip'),(514,1661,'Wings Sauces','sauce'),(515,1662,'TRIO Side Dishes','side_dish'),(516,1662,'Drinks Can','drink'),(517,1662,'Ajouter une autre personne 12.99','extra'),(518,1662,'Ajouter une autre personne 14.50','extra'),(519,1663,'Pizza Toppings','custom_ingredient'),(520,1663,'Premium Toppings','premium_toppings'),(521,1663,'Dips','dip'),(522,1663,'Wings Sauces','sauce'),(523,1664,'Pizza Toppings','custom_ingredient'),(524,1664,'Premium Toppings','premium_toppings'),(525,1664,'Dips','dip'),(526,1663,'Drinks Can','drink'),(527,1664,'Wings Sauces','sauce'),(528,1664,'Drinks Can','drink'),(547,1668,'Salad Toppings for Greek Dinners','custom_ingredient'),(548,1668,'For Gyros, Chicken Souvlaki, Pork Souvlaki DINNERS Extras','extra'),(549,1668,'Drinks Can','drink'),(550,1668,'BURGERS Extras','extra'),(551,1668,'Sides for PITA COMBOS from Pitas & Pitas Combo and Burgers','side_dish'),(552,1668,'The Mikes Classic 6oz. Burger toppings','custom_ingredient'),(553,1668,'Gravy for Chicken Fingers','extra'),(554,1668,'Dips for Chicken Fingers','sauce'),(555,1668,'Gravy for Fish & CHips','extra'),(556,1668,'Custom Ingredients for Greek Salad from SALADS','custom_ingredient'),(557,1668,'Custom Ingredients for Caesar Salad from SALADS','custom_ingredient'),(558,1668,'Options for Pitas','custom_ingredient'),(559,1668,'Pitas EXTRAS','extra'),(560,1668,'Side Dishes For Pita Combos from FAMILY COMBOS','side_dish'),(561,1668,'Kid’s Chicken Fingers Dipping Sauces','sauce'),(562,1668,'KIDS Side Dishes','side_dish'),(564,1285,'Pokebowls Extras','extra'),(565,1285,'Pokebowls Extras','extra'),(568,1670,'Donair Sauces','sauce'),(569,1670,'Pasta Extra Cheese','extra'),(570,1670,'Crust Type','crust'),(571,1670,'Pizza Toppings','custom_ingredient'),(572,1670,'Wings Sauces','sauce'),(573,1670,'Dips','dip'),(576,1671,'Pizza Toppings','custom_ingredient'),(577,1671,'Premium Toppings','premium_toppings'),(578,1671,'Dips','dip'),(579,1671,'Wings Sauces','sauce'),(580,1671,'Crazy Cheese Bread ADD BACON','custom_ingredient'),(581,1671,'Drinks Can','drink'),(582,1671,'Kebab Sandwich Option','side_dish'),(583,1670,'Drinks Can','drink'),(584,1673,'Extras for SUBS','extra'),(585,1673,'Extras for Pastas','extra'),(586,1673,'Pizza Toppings','custom_ingredient'),(587,1673,'Premium Toppings','premium_toppings'),(588,1673,'Chicken Pizza Sauces','sauce'),(589,1673,'Wings Sauces','sauce'),(590,1673,'Dips','dip'),(591,1673,'Drinks 710ml','drink'),(592,1673,'Pizza Selection','side_dish'),(593,1673,'Extra Cheese for Spaghetti','extra'),(594,1673,'Extras for SUBS','extra'),(595,1673,'Pizza Toppings','custom_ingredient'),(596,1673,'Premium Toppings','premium_toppings'),(597,1673,'Dips','dip'),(598,1673,'Wings Sauces','sauce'),(599,1673,'Chicken Pizza Sauces','sauce'),(600,1673,'Pizza Selection','side_dish'),(601,1673,'Drinks 710ml','drink'),(602,1674,'Wings Sauces','sauce'),(603,1674,'Dessert Dipping Sauces','dip'),(604,1674,'Crust Type','crust'),(605,1674,'Pizza Sauces','sauce'),(606,1674,'Premium Toppings (Cheeses)','premium_toppings'),(607,1674,'Pizza Toppings','custom_ingredient'),(608,1674,'Extras for Pizza','extra'),(609,1674,'Bacon for Crack Sticks','custom_ingredient'),(610,1674,'Drinks','drink'),(611,1674,'Dips','dip'),(629,1663,'Extras for Hamburger','extra'),(630,1674,'Custom ING for Salads','custom_ingredient'),(631,1642,'Drinks for Combos','drink'),(632,1641,'Pork or Beef','custom_ingredient'),(633,1641,'Extra Sauce','sauce'),(634,1641,'Drinks (355 ml Can)','drink'),(635,1641,'Drinks (355 ml Can)','drink'),(636,1641,'Drinks (355 ml Can)','drink'),(637,1641,'Drinks (355 ml Can)','drink'),(647,1668,'Mikes Poutine Meat Selection','custom_ingredient'),(648,1668,'Chicken Souvlaki Skewers','side_dish'),(649,1670,'Walk In Special Pizza Toppings (no steak no chicken)','custom_ingredient');
/*!40000 ALTER TABLE `menu_v3_modifier_groups` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-30 11:52:05
