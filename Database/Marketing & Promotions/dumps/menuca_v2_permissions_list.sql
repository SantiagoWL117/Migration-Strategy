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
-- Table structure for table `permissions_list`
--

DROP TABLE IF EXISTS `permissions_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions_list` (
  `id` int NOT NULL AUTO_INCREMENT,
  `description` varchar(255) DEFAULT NULL,
  `keywords` json DEFAULT NULL,
  `subnav_item` smallint unsigned DEFAULT NULL,
  `display_order` smallint DEFAULT NULL,
  `uri` json DEFAULT NULL,
  `type` varchar(25) DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions_list`
--

LOCK TABLES `permissions_list` WRITE;
/*!40000 ALTER TABLE `permissions_list` DISABLE KEYS */;
INSERT INTO `permissions_list` VALUES (1,'Add new restaurants','[\"restaurants_new\", \"restaurants_add\"]',12,10,'[\"restaurants/add\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(2,'Edit restaurants added by other users','[\"view_all_restaurants\"]',NULL,1,'[\"\"]','','y',0,NULL,1,'2025-02-14 08:32:48'),(6,'Manage users',NULL,11,11,'[\"users/groups\", \"users/groupedit/\\\\d+\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(7,'Login to all sites','[\"login_all\"]',NULL,3,'[\"\"]','','n',0,NULL,1,'2019-04-29 03:09:34'),(8,'Blacklist - add users',NULL,13,13,'[\"blacklist/show\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(10,'Access pending restaurants','[\"restaurants_pending\"]',2,9,'[\"restaurants/show/pending\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(11,'Manage aggregators',NULL,NULL,15,'[\"\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(12,'Manage orders - order details page','[\"manage_orders\"]',NULL,4,'[\"\"]','','y',0,NULL,1,'2025-02-14 08:32:48'),(13,'Dashboard vendors',NULL,28,3,'[\"welcome/vendors\"]','page','n',0,NULL,1,'2021-03-04 13:19:46'),(14,'Access active restaurants','[\"restaurants_active\"]',1,7,'[\"restaurants/show/active\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(15,'Access inactive restaurants','[\"restaurants_inactive\"]',3,8,'[\"restaurants/show/inactive\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(16,'Blacklist - list users',NULL,14,14,'[\"blacklist(?:/index)?\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(17,'Manage groups',NULL,10,12,'[\"users(?:/index)?\", \"users/useredit/\\\\d+\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(18,'Others - cities',NULL,6,18,'[\"others/cities(?:/\\\\d+)?\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(19,'Others - cuisine and tags',NULL,7,19,'[\"others/cuisine_and_tags\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(20,'Others - newsletter images',NULL,25,20,'[\"others/newsletter_images\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(21,'Others - francizes',NULL,26,21,'[\"franchises/index\"]','page','n',0,NULL,0,NULL),(22,'Dashboard home',NULL,29,1,'[\"welcome(?:/index)?\", \"welcome/(\\\\d+)-.+\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(23,'View orders - from dashboard index',NULL,NULL,5,'[\"display_orders/[^/]+/[^/]+(?:/[^/]+)?\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(24,'View search results - from order page',NULL,NULL,6,'[\"welcome/search/[^/]+\", \"welcome/search/order/\\\\d+\", \"welcome/search/custom/start:\\\\d{4}-\\\\d{2}-\\\\d{2}:stop:\\\\d{4}-\\\\d{2}-\\\\d{2}(?:/(\\\\d+)\\\\-.+)?\"]','page','y',0,NULL,1,'2025-02-14 08:32:48'),(25,'Info','[\"info\"]',NULL,1,'[\"info\"]','restaurant','y',1,'2019-04-28 00:24:52',1,'2025-02-14 08:32:48'),(26,'Schedule','[\"schedule\"]',NULL,2,'[\"schedule\"]','restaurant','y',1,'2019-04-28 00:25:53',1,'2025-02-14 08:32:48'),(27,'Delivery area','[\"delivery\"]',NULL,3,'[\"delivery\"]','restaurant','y',1,'2019-04-28 00:26:11',1,'2025-02-14 08:32:48'),(28,'Config','[\"configs\"]',NULL,4,'[\"configs\"]','restaurant','y',1,'2019-04-28 00:26:25',1,'2025-02-14 08:32:48'),(29,'Citations','[\"citations\"]',NULL,5,'[\"citations\"]','restaurant','y',1,'2019-04-28 00:26:39',1,'2025-02-14 08:32:48'),(30,'Banners','[\"banners\"]',NULL,6,'[\"banners\"]','restaurant','y',1,'2019-04-28 00:27:15',1,'2025-02-14 08:32:48'),(31,'Menu','[\"menu\"]',NULL,7,'[\"menu\", \"subnav=>[1=>[name:Global|page_url:global]|2=>[name:Restaurant|page_url:restaurant]\"]','restaurant','y',1,'2019-04-28 00:28:20',1,'2025-02-14 08:32:48'),(32,'Deals','[\"deals\"]',NULL,8,'[\"deals\"]','restaurant','y',1,'2019-04-28 00:28:56',1,'2025-02-14 08:32:48'),(33,'Images & About text','[\"images\"]',NULL,9,'[\"images\"]','restaurant','y',1,'2019-04-28 00:29:11',1,'2025-02-14 08:32:48'),(34,'Feedback','[\"feedback\"]',NULL,10,'[\"feedback\"]','restaurant','y',1,'2019-04-28 00:29:34',1,'2025-02-14 08:32:48'),(35,'Mail templates','[\"mail_templates\"]',NULL,11,'[\"mail_templates\"]','restaurant','y',1,'2019-04-28 00:30:06',1,'2025-02-14 08:32:48'),(36,'Charges','[\"charges\"]',NULL,12,'[\"charges\"]','restaurant','y',1,'2019-04-28 00:30:22',1,'2025-02-14 08:32:48'),(37,'Coupons','[\"coupons\"]',NULL,13,'[\"coupons\"]','restaurant','n',1,'2019-04-28 00:30:45',1,'2021-09-21 14:19:16'),(38,'Allow access to global menu','[\"global_menu\"]',NULL,2,'[\"\"]','','y',1,'2019-04-29 02:15:28',1,'2025-02-14 08:32:48'),(39,'Check referrer (try and prohibit url manipulation)','[\"check_referrer\"]',NULL,6,'[\"\"]','','y',1,'2019-04-29 09:20:41',1,'2025-02-14 08:32:48'),(40,'Landing page','[\"landing_page\"]',NULL,14,'[\"landing\"]','restaurant','y',1,'2019-05-01 02:59:27',1,'2025-02-14 08:32:48'),(41,'Search for order','[\"search_order\"]',NULL,7,'[\"\"]','','y',1,'2019-05-10 06:27:37',1,'2025-02-14 08:32:48'),(42,'Custom order search','[\"custom_search\"]',NULL,8,'[\"\"]','','y',1,'2019-05-10 09:59:35',1,'2025-02-14 08:32:48'),(43,'Allow search based on email','[\"email_search\"]',NULL,9,'[\"\"]','','y',1,'2019-05-10 12:02:07',1,'2025-02-14 08:32:48'),(44,'Show client list','[\"client_list\"]',NULL,10,'[\"\"]','','y',1,'2019-05-10 12:10:03',1,'2025-02-14 08:32:48'),(45,'Show printer info','[\"printer_info\"]',NULL,11,'[\"\"]','','y',1,'2019-05-13 08:35:02',1,'2025-02-14 08:32:48'),(46,'Restaurant Announcements','[\"restaurant_announcements\"]',NULL,12,'[\"\"]','','y',1,'2019-05-13 09:24:48',1,'2025-02-14 08:32:48'),(47,'Show vendor info (on restaurant info page)','[\"vendor_info\"]',NULL,13,'[\"\"]','','y',1,'2019-07-04 11:29:58',1,'2025-02-14 08:32:48'),(48,'Delete order / Change status','[\"delete_change_order\"]',NULL,5,'[\"\"]','','y',1,'2019-07-04 11:39:59',1,'2025-02-14 08:32:48'),(49,'Cancel requests',NULL,30,4,'[\"welcome/cancel_orders\"]','page','y',1,'2019-08-22 02:56:05',1,'2025-02-14 08:32:48'),(50,'Manage restaurant announcements','[\"restaurant_announcements\"]',NULL,14,NULL,'','n',1,'2019-08-22 03:15:22',NULL,NULL),(51,'Cancel order request','[\"cancel_order_request\"]',NULL,15,'[\"\"]','','y',1,'2019-08-22 03:16:01',1,'2025-02-14 08:32:48'),(52,'Disable dishes','[\"disable_dishes\"]',NULL,16,'[\"\"]','','y',1,'2019-08-22 03:38:19',1,'2025-02-14 08:32:48'),(53,'Issue statements',NULL,31,2,'[\"accounting/statements\"]','page','y',1,'2019-10-31 05:36:21',1,'2025-02-14 08:32:48'),(54,'Show create statements','[\"issue_statements\"]',NULL,17,'[\"\"]','','y',1,'2019-10-31 05:38:35',1,'2025-02-14 08:32:48'),(55,'Others - mail templates',NULL,32,22,'[\"others/mail_templates\"]','page','y',1,'2020-10-27 14:57:47',1,'2025-02-14 08:32:48'),(56,'View site users',NULL,33,5,'[\"welcome/list_users(?:/\\\\d+)?\"]','page','y',1,'2020-12-29 11:04:31',1,'2025-02-14 08:32:48'),(57,'View restaurant statements','[\"statements\"]',NULL,18,'[\"\"]','','y',1,'2021-02-24 12:24:59',1,'2025-02-14 08:32:48'),(58,'Vendor reports interface',NULL,34,6,'[\"accounting/vendor_reports_interface\"]','page','y',1,'2021-03-03 10:18:41',1,'2025-02-14 08:32:48'),(59,'Split settings','[\"vendor_split\"]',NULL,15,'[\"vendor_split\"]','restaurant','y',1,'2021-03-04 13:02:12',1,'2025-02-14 08:32:48'),(60,'Commissions','[\"commissions\"]',35,1,'[\"\"]','page','y',1,'2021-09-21 13:39:20',1,'2025-02-14 08:32:48'),(61,'Tablets page',NULL,36,7,'[\"tablets/index\"]','page','y',1,'2021-12-01 12:12:14',1,'2025-02-14 08:32:48'),(62,'Landing page setup',NULL,37,8,'[\"landings/index\"]','page','y',1,'2023-03-30 08:47:20',1,'2025-02-14 08:32:48'),(63,'Reports page',NULL,NULL,23,'[\"reports(?:/.+)?\"]','page','y',1,'2024-08-14 15:39:10',1,'2025-02-14 08:32:48'),(64,'AI Settings',NULL,38,24,'[\"ai/index\"]','page','y',1,'2025-02-11 03:10:00',1,'2025-02-14 08:32:48'),(65,'Show AI context',NULL,NULL,26,'[\"ai/showContextFor/(\\\\d+)(?:/(\\\\d+)-.+)?\"]','page','y',1,'2025-02-14 08:33:03',NULL,NULL),(66,'Image assignement','[\"image-assignment\"]',NULL,16,'[\"image_assignment\"]','restaurant','y',1,'2025-02-18 13:47:49',NULL,NULL);
/*!40000 ALTER TABLE `permissions_list` ENABLE KEYS */;
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
