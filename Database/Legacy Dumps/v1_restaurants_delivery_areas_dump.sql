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
-- Table structure for table `santiago_restaurants_delivery_areas`
--

DROP TABLE IF EXISTS `santiago_restaurants_delivery_areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `santiago_restaurants_delivery_areas` (
  `id` int NOT NULL DEFAULT '0',
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `address` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `fee` blob
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `santiago_restaurants_delivery_areas`
--

LOCK TABLES `santiago_restaurants_delivery_areas` WRITE;
/*!40000 ALTER TABLE `santiago_restaurants_delivery_areas` DISABLE KEYS */;
INSERT INTO `santiago_restaurants_delivery_areas` VALUES (89,'Imilio\'s Pizzeria','110 Bearbrook Rd',_binary '0'),(199,'Season\'s Pizza','725 Somerset Street West',_binary '0'),(203,'Champa Thai Cuisine','193 King Edward Ave',_binary 'a:10:{i:0;s:4:\"3.00\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(225,'Restaurant Le Choix','139, rue Principale',_binary 'a:10:{i:0;s:1:\"3\";i:1;s:1:\"4\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(231,'Papa Pizza Des Flandres','22, rue des Flandres',_binary 'a:10:{i:0;s:1:\"3\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(238,'Mano City Pizza','5511 Manotick Main St',_binary 'a:10:{i:0;s:0:\"\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(346,'Papa Pizza Maloney','253, boul Maloney',_binary 'a:10:{i:0;s:4:\"3.50\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(364,'La Famiglia on the Danforth','2318 Danforth Ave',_binary 'a:10:{i:0;s:1:\"5\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(387,'Orchid Sushi','445 Laurier Ave W',_binary '3'),(511,'Sushi Express Chambly','886 ch de Chambly',_binary 'a:10:{i:0;s:1:\"2\";i:1;s:1:\"3\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(694,'Ting\'s Kitchen','3-701 Eagleson Rd',_binary 'a:10:{i:0;s:4:\"2.99\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(789,'Milano','2529 Baseline',_binary 'a:10:{i:0;s:4:\"2.50\";i:1;s:4:\"2.50\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(805,'Crispy\'s','1433 Woodrofe',_binary 'a:10:{i:0;s:4:\"2.99\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(807,'Milano','81 Madawaska Street',_binary 'a:10:{i:0;s:4:\"1.99\";i:1;s:4:\"4.99\";i:2;s:4:\"6.99\";i:3;s:4:\"9.99\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(818,'Sushi Fleury','2481 Fleury Est',_binary 'a:10:{i:0;s:3:\"2.5\";i:1;s:3:\"3.5\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(824,'Milano','1589 Main St',_binary 'a:10:{i:0;s:4:\"2.50\";i:1;s:4:\"5.00\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(856,'Asia Garden Ottawa','886 Dynes Road',_binary 'a:10:{i:0;s:4:\"3.50\";i:1;s:4:\"3.50\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(863,'Joes Family Pizzeria','284 Pembroke St W',_binary 'a:10:{i:0;s:4:\"4.99\";i:1;s:4:\"6.99\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(865,'Digby\'s Restaurant','300 Earl Grey Dr',_binary 'a:10:{i:0;s:4:\"1.50\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(874,'JC Royal Thai Cuisine','100 Jamieson Pkwy, Unit 11',_binary 'a:10:{i:0;s:9:\"5<40,0>40\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(889,'Milano','54 Wilson St W',_binary 'a:10:{i:0;s:1:\"0\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(913,'Milano','643 Boulevard Saint-René O',_binary 'a:10:{i:0;s:4:\"2.99\";i:1;s:4:\"3.99\";i:2;s:4:\"4.99\";i:3;s:4:\"3.99\";i:4;s:4:\"4.99\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(914,'Oka\'s Hull','1030 Boulevard Saint-Joseph',_binary 'a:10:{i:0;s:4:\"2.00\";i:1;s:4:\"3.00\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(937,'Milano','147 Main Street Unit 3',_binary 'a:10:{i:0;s:4:\"0.00\";i:1;s:4:\"5.00\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(953,'PizzaRama','253, boul Maloney',_binary 'a:10:{i:0;s:4:\"3.00\";i:1;s:4:\"3.00\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(964,'Pizza Joanna','229 Boulevard Saint-René Ouest',_binary 'a:10:{i:0;s:4:\"2.50\";i:1;s:4:\"4.00\";i:2;s:4:\"5.00\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(968,'Friendly Restaurant and Pizzeria','1756 Laurier St',_binary 'a:10:{i:0;s:4:\"3.00\";i:1;s:4:\"6.50\";i:2;s:4:\"8.50\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(973,'Amicci Pizza','2 Boulevard Louise-Campagna',_binary 'a:10:{i:0;s:4:\"2.50\";i:1;s:4:\"3.00\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(1042,'Kabylie Pizza','355 Bd Gréber',_binary 'a:10:{i:0;s:4:\"4.00\";i:1;s:4:\"4.50\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(1045,'Nachos Loco Gatineau','643 Boulevard Saint-René O',_binary 'a:10:{i:0;s:4:\"2.99\";i:1;s:4:\"3.99\";i:2;s:4:\"4.99\";i:3;s:4:\"3.99\";i:4;s:4:\"4.99\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(1046,'Poutinerie Québecurds Gatineau','643 Boulevard Saint-René O',_binary 'a:10:{i:0;s:4:\"2.99\";i:1;s:4:\"3.99\";i:2;s:4:\"4.99\";i:3;s:4:\"3.99\";i:4;s:4:\"4.99\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(1050,'Crispy\'s Bank Street','2446 Bank Street',_binary 'a:10:{i:0;s:4:\"2.99\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(1060,'Dépanneur Généreux','428 Rue Généreux',_binary 'a:10:{i:0;s:4:\"4.99\";i:1;s:1:\"7\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(1062,'Milano','2609 Laurier St',_binary 'a:10:{i:0;s:4:\"2.99\";i:1;s:4:\"6.00\";i:2;s:4:\"7.00\";i:3;s:4:\"9.00\";i:4;s:2:\"13\";i:5;s:2:\"16\";i:6;s:2:\"28\";i:7;s:2:\"32\";i:8;s:2:\"40\";i:9;s:0:\"\";}'),(1063,'Milano','6594 4th Line Rd',_binary 'a:10:{i:0;s:4:\"2.99\";i:1;s:4:\"5.99\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(1064,'Vieux Hull Pizza','574, boul Saint-Joseph',_binary '0'),(1066,'Papa Burger Maloney','253 Boul Maloney E',_binary 'a:10:{i:0;s:4:\"3.00\";i:1;s:0:\"\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(1080,'All Out Burger','951 Notre-Dame St',_binary 'a:10:{i:0;s:4:\"2.50\";i:1;s:4:\"5.00\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(1092,'Mykonos Greek Grill','6594 Fourth Line Rd',_binary 'a:10:{i:0;s:4:\"2.99\";i:1;s:4:\"5.99\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}'),(1093,'Mykonos Greek Grill','2600 County Rd 43',_binary 'a:10:{i:0;s:4:\"2.99\";i:1;s:4:\"5.99\";i:2;s:0:\"\";i:3;s:0:\"\";i:4;s:0:\"\";i:5;s:0:\"\";i:6;s:0:\"\";i:7;s:0:\"\";i:8;s:0:\"\";i:9;s:0:\"\";}');
/*!40000 ALTER TABLE `santiago_restaurants_delivery_areas` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-03  9:35:37
