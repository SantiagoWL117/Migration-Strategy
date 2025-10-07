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
-- Table structure for table `delivery_info`
--

DROP TABLE IF EXISTS `delivery_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_info` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `sendToDelivery` enum('y','n') DEFAULT 'n',
  `disable_until` datetime DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `commission` decimal(5,2) DEFAULT NULL,
  `rpd` decimal(5,2) DEFAULT '0.00' COMMENT 'restaurant pays difference',
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_info`
--

LOCK TABLES `delivery_info` WRITE;
/*!40000 ALTER TABLE `delivery_info` DISABLE KEYS */;
INSERT INTO `delivery_info` VALUES (6,114,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',0.00,0.00),(7,138,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','Don’t show up more than 25 minutes before the food needs to be at the door. ',12.00,0.00),(8,198,'n',NULL,'toyourhomedeliveries@outlook.com,mattmenuottawa2@gmail.com','',NULL,NULL),(9,203,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(11,377,'n',NULL,'toyourhomedeliveries@outlook.com,mattmenuottawa@gmail.com','',NULL,NULL),(12,378,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',NULL,NULL),(13,416,'n',NULL,'toyourhomedeliveries@outlook.com','',NULL,NULL),(14,451,'n',NULL,'toyourhomedeliveries@outlook.com','',NULL,NULL),(15,453,'n',NULL,'toyourhomedeliveries@outlook.com','',NULL,NULL),(17,615,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa@gmail.com','',NULL,NULL),(18,652,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',NULL,NULL),(19,748,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa@gmail.com','',NULL,NULL),(20,749,'n',NULL,'menuottawa@geodispatch.ca,mattmenuottawa@gmail.com,matt@pmrd.net,marc@deliverydirect.ca','',NULL,NULL),(21,761,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa@gmail.com','',NULL,NULL),(22,774,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa@gmail.com','',NULL,NULL),(23,798,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa@gmail.com','',NULL,NULL),(26,828,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa@gmail.com','',NULL,NULL),(27,829,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa@gmail.com','',NULL,NULL),(28,843,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',NULL,NULL),(29,851,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(32,880,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',NULL,NULL),(34,885,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',0.00,NULL),(36,888,'n',NULL,'deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',0.00,NULL),(37,892,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(39,897,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',NULL,NULL),(41,906,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',NULL,NULL),(42,911,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','Don’t show up more than 25 minutes before the food needs to be at the door. ',0.00,NULL),(44,919,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(45,922,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',0.00,NULL),(46,928,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(47,929,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',0.00,NULL),(48,931,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(133,137,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(135,819,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',12.00,0.00),(137,450,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',0.00,NULL),(138,938,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',12.00,0.00),(139,946,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',12.00,0.00),(140,945,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',12.00,0.00),(141,136,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',12.00,0.00),(143,760,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',12.00,0.00),(147,750,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',0.00,NULL),(153,966,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com','',10.00,0.00),(154,969,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(155,970,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(156,967,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(193,255,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(196,362,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(197,140,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',12.00,1.00),(211,956,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(218,995,'y',NULL,'mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(226,996,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(234,1002,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',12.00,0.00),(235,1000,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(236,1008,'y',NULL,'mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',12.00,0.00),(237,1010,'y',NULL,'mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(238,1009,'y',NULL,'mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(239,218,'y',NULL,'mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(240,1038,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(241,708,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(244,1051,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(245,219,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(246,980,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(247,334,'n',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(248,1085,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(249,1090,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00),(250,1094,'y',NULL,'Deliveryzonecanada@gmail.com,mattmenuottawa2@gmail.com,restozonedispatch@gmail.com','',15.00,0.00);
/*!40000 ALTER TABLE `delivery_info` ENABLE KEYS */;
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
