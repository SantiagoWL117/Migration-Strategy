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
-- Table structure for table `nav_subitems`
--

DROP TABLE IF EXISTS `nav_subitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nav_subitems` (
  `id` int NOT NULL AUTO_INCREMENT,
  `parent_id` int DEFAULT NULL,
  `permission_required` tinyint DEFAULT NULL,
  `name` varchar(125) DEFAULT NULL,
  `url` varchar(125) DEFAULT '/',
  `display_order` smallint DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nav_subitems`
--

LOCK TABLES `nav_subitems` WRITE;
/*!40000 ALTER TABLE `nav_subitems` DISABLE KEYS */;
INSERT INTO `nav_subitems` VALUES (1,1,10,'Active','restaurants/show/active',2,'y'),(2,1,10,'Pending','restaurants/show/pending',3,'y'),(3,1,10,'Inactive','restaurants/show/inactive',4,'y'),(6,3,0,'Cities','others/cities',1,'y'),(7,3,0,'Cuisine and tags','others/cuisine_and_tags',2,'y'),(8,3,0,'Clone a restaurant','others/clone',3,'y'),(10,4,6,'Groups','users/groups',1,'y'),(11,4,6,'Users','users/index',2,'y'),(12,1,1,'Add restaurant','restaurants/add',1,'y'),(13,5,8,'Add entry','blacklist/index',1,'y'),(14,5,8,'Show entries','blacklist/show',2,'y'),(15,5,8,'Reports','blacklist/reports',3,'n'),(16,9,0,'This month','sales/this_month',4,'y'),(17,9,0,'Today','my/sales/today',1,'y'),(18,9,0,'Yesterday','my/sales/yesterday',2,'y'),(19,9,0,'This week','my/sales/this_week',3,'y'),(20,9,0,'Last month','my/sales/last_month',5,'y'),(21,9,0,'Custom','my/sales/custom',6,'y'),(22,0,0,'Set holidays','restaurants/holidays',1,'y'),(23,0,0,'Set delivery area','restaurants/delivery_area',2,'y'),(24,0,0,'Menu','restaurants/menu',3,'y'),(25,3,0,'Newsletter images','others/newsletter_images',4,'y'),(26,3,0,'Franchises','franchises/index',5,'y'),(27,14,11,'Menu.ca','aggregators/1',1,'y'),(28,13,0,'Vendors','welcome/vendors',2,'y'),(29,13,0,'Dashboard','welcome/index',1,'y'),(30,13,0,'Cancel requests','welcome/cancel_requests',3,'y'),(31,13,0,'Statements','accounting/statements',4,'y'),(32,3,0,'Email templates','others/email_templates',4,'y'),(33,13,0,'List users','welcome/list_users',5,'y'),(34,13,0,'Vendor reports','accounting/vendor_reports_interface',6,'y'),(35,23,0,'Commissions','accounting/commissions',7,'y'),(36,13,0,'Tablets','tablets/index',7,'y'),(37,13,0,'Main landing page setup','landings/index',8,'y'),(38,24,0,'Settings','ai/index',1,'y'),(39,24,0,'Page builder','ai/page_builder',2,'y');
/*!40000 ALTER TABLE `nav_subitems` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-07 14:53:37
