CREATE DATABASE  IF NOT EXISTS `menuca_v1` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `menuca_v1`;
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
-- Table structure for table `account_creation_attempts`
--

DROP TABLE IF EXISTS `account_creation_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_creation_attempts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `server` text,
  `post` text,
  `page` varchar(125) NOT NULL,
  `time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14077 DEFAULT CHARSET=latin1 COMMENT='store failed attempts to create account - sendgrid mail issue';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `addresses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `search_address` varchar(125) NOT NULL,
  `latitude` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `longitude` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `returned_address` varchar(255) NOT NULL,
  `city` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `ft` (`search_address`,`returned_address`)
) ENGINE=MyISAM AUTO_INCREMENT=2450 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_users`
--

DROP TABLE IF EXISTS `admin_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lastPassChange` datetime DEFAULT NULL,
  `fname` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `email` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `user_type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `restaurant` int NOT NULL,
  `lastlogin` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `activeUser` enum('1','0') NOT NULL DEFAULT '1',
  `loginCount` int unsigned NOT NULL DEFAULT '0',
  `permissions` blob NOT NULL,
  `apikey` varchar(40) DEFAULT NULL,
  `allowApiAccess` enum('Y','N') DEFAULT 'N',
  `rank` smallint DEFAULT NULL,
  `vendor` smallint DEFAULT NULL,
  `showClients` enum('y','n') DEFAULT 'y',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api`
--

DROP TABLE IF EXISTS `api`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api` (
  `id` int NOT NULL AUTO_INCREMENT,
  `key` varchar(125) DEFAULT NULL,
  `access_to` varchar(125) DEFAULT NULL,
  `last_used` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `autoresponders`
--

DROP TABLE IF EXISTS `autoresponders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `autoresponders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `instantSend` enum('1','0') DEFAULT '0',
  `date` int DEFAULT NULL,
  `type_time` varchar(15) DEFAULT NULL COMMENT 'can be hour or day',
  `subject` varchar(255) DEFAULT NULL,
  `from` varchar(255) DEFAULT NULL,
  `message` text,
  `createdBy` int DEFAULT NULL,
  `isActive` enum('y','n') DEFAULT 'y',
  `isSent` enum('y','n') DEFAULT 'n',
  `lang` char(2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `avs_orders`
--

DROP TABLE IF EXISTS `avs_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `avs_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `orderId` int DEFAULT NULL,
  `retries` int DEFAULT NULL,
  `answer` blob,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17865 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `banners`
--

DROP TABLE IF EXISTS `banners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `banners` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant` int unsigned NOT NULL,
  `banner` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `delete` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'n',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=598 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci COMMENT='these are the images that show on first page';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blacklist`
--

DROP TABLE IF EXISTS `blacklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blacklist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `value` varchar(125) DEFAULT NULL,
  `type` enum('mail','address','ip','phone') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `value_type` (`value`,`type`),
  FULLTEXT KEY `value` (`value`)
) ENGINE=MyISAM AUTO_INCREMENT=1504 DEFAULT CHARSET=latin1 COMMENT='blacklisted addresses, emails, ips';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bottommenu`
--

DROP TABLE IF EXISTS `bottommenu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bottommenu` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lang` char(2) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bottompages`
--

DROP TABLE IF EXISTS `bottompages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bottompages` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `parentId` int unsigned NOT NULL DEFAULT '0',
  `pageName` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `pageText` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `pageLink` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `pageTitle` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lang` char(2) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ca`
--

DROP TABLE IF EXISTS `ca`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ca` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `zip` char(6) DEFAULT NULL,
  `city` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `state_full` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `state` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `latitude` float NOT NULL,
  `longitude` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `by_zip` (`zip`)
) ENGINE=InnoDB AUTO_INCREMENT=917358 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `callcenter_blacklist`
--

DROP TABLE IF EXISTS `callcenter_blacklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `callcenter_blacklist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `value` varchar(125) DEFAULT NULL,
  `type` enum('mail','address','ip','phone') NOT NULL,
  `reason` text,
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `value_type` (`value`,`type`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COMMENT='blacklisted addresses, emails, ips';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `callcenter_incidents`
--

DROP TABLE IF EXISTS `callcenter_incidents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `callcenter_incidents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `title` varchar(255) NOT NULL,
  `content` text,
  `phone` varchar(10) NOT NULL,
  `address` int NOT NULL,
  `restaurant` bigint DEFAULT '0',
  `order` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `callcenter_users`
--

DROP TABLE IF EXISTS `callcenter_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `callcenter_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fname` varchar(25) NOT NULL,
  `lname` varchar(25) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `last_login` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_active` enum('y','n') DEFAULT 'y',
  `rank` smallint DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `citation_listings`
--

DROP TABLE IF EXISTS `citation_listings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `citation_listings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` smallint DEFAULT NULL,
  `c_name` smallint DEFAULT NULL,
  `creation_date` date DEFAULT NULL,
  `listing_link` varchar(125) DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique` (`restaurant`,`c_name`)
) ENGINE=InnoDB AUTO_INCREMENT=49521 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `citations`
--

DROP TABLE IF EXISTS `citations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `citations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int DEFAULT NULL,
  `reg_email` varchar(45) DEFAULT NULL,
  `reg_password` varchar(45) DEFAULT NULL,
  `employees_no` smallint DEFAULT NULL COMMENT 'number of employees',
  `reservations` enum('y','n') DEFAULT NULL,
  `waiter` enum('y','n') DEFAULT NULL,
  `wheelchair` enum('y','n') DEFAULT NULL,
  `outdoor` enum('y','n') DEFAULT NULL,
  `alcohol` enum('1','2','3') DEFAULT NULL,
  `parking` blob,
  `wifi` enum('y','n') DEFAULT NULL,
  `catering` enum('y','n') DEFAULT NULL,
  `price_range` enum('1','2','3','4','0') DEFAULT NULL,
  `payment` blob,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant` (`restaurant`)
) ENGINE=InnoDB AUTO_INCREMENT=4782 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cities`
--

DROP TABLE IF EXISTS `cities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cities` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `displayName` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `county` int unsigned NOT NULL DEFAULT '0',
  `country` int unsigned NOT NULL DEFAULT '0',
  `lat` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lng` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `timezone` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=118 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `combo_groups`
--

DROP TABLE IF EXISTS `combo_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `combo_groups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `dish` blob,
  `options` blob,
  `group` blob,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `lang` char(2) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=62720 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `combos`
--

DROP TABLE IF EXISTS `combos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `combos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `dish` int unsigned NOT NULL DEFAULT '0',
  `group` int unsigned NOT NULL DEFAULT '0',
  `order` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `dish_fk` (`dish`),
  KEY `group_fk` (`group`),
  CONSTRAINT `dish_fk` FOREIGN KEY (`dish`) REFERENCES `menu` (`id`) ON DELETE CASCADE,
  CONSTRAINT `group_fk` FOREIGN KEY (`group`) REFERENCES `combo_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=112125 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `counties`
--

DROP TABLE IF EXISTS `counties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `counties` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `country` int unsigned NOT NULL DEFAULT '0',
  `short_name` varchar(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lang` char(2) NOT NULL DEFAULT 'en',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `countries` (
  `country_id` int NOT NULL AUTO_INCREMENT,
  `country_code` char(3) DEFAULT NULL,
  `country_name` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `country_continent` varchar(4) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`country_id`)
) ENGINE=InnoDB AUTO_INCREMENT=223 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coupon_extempts`
--

DROP TABLE IF EXISTS `coupon_extempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon_extempts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_coupon` int DEFAULT NULL,
  `id_course` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=749 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coupon_images`
--

DROP TABLE IF EXISTS `coupon_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `image_0` varchar(45) DEFAULT NULL,
  `image_1` varchar(45) DEFAULT NULL,
  `image_2` varchar(45) DEFAULT NULL,
  `lang` char(2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coupons`
--

DROP TABLE IF EXISTS `coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupons` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `start` int unsigned NOT NULL DEFAULT '0',
  `stop` int unsigned NOT NULL DEFAULT '0',
  `reduceType` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `product` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `ammount` float NOT NULL DEFAULT '0',
  `couponType` enum('r','g') NOT NULL DEFAULT 'r',
  `redeem` float NOT NULL DEFAULT '0',
  `active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `itemCount` int unsigned NOT NULL DEFAULT '0',
  `lang` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `for_reorder` enum('1','0') DEFAULT '0' COMMENT 'used to determine which coupons are sent in mail, from autoresponders',
  `one_time_only` enum('y','n') DEFAULT 'n',
  `used` enum('y','n') DEFAULT 'n',
  `addToMail` enum('y','n') DEFAULT 'n',
  `mailText` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1283 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `desc` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `xthPromo` enum('n','y') DEFAULT 'n',
  `xthItem` int NOT NULL,
  `remove` float NOT NULL,
  `removeFrom` enum('b','t') DEFAULT 'b',
  `timePeriod` int NOT NULL DEFAULT '0',
  `ciHeader` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `lang` char(2) NOT NULL DEFAULT '',
  `order` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant`),
  KEY `lang` (`lang`)
) ENGINE=InnoDB AUTO_INCREMENT=16001 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `css_posted`
--

DROP TABLE IF EXISTS `css_posted`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `css_posted` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int DEFAULT NULL,
  `css` blob,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_UNIQUE` (`restaurant`)
) ENGINE=InnoDB AUTO_INCREMENT=9013 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cuisine`
--

DROP TABLE IF EXISTS `cuisine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cuisine` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deals`
--

DROP TABLE IF EXISTS `deals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int NOT NULL DEFAULT '0',
  `name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `type` varchar(35) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `removeValue` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `ammountSpent` int NOT NULL,
  `dealPrice` float NOT NULL,
  `orderTimes` int NOT NULL,
  `active_days` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `active_dates` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `items` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `mealNo` int unsigned NOT NULL DEFAULT '0',
  `position` char(1) DEFAULT NULL,
  `order` int NOT NULL,
  `lang` enum('en','fr') NOT NULL DEFAULT 'en',
  `image` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `display` int unsigned NOT NULL,
  `showOnThankyou` enum('0','1') NOT NULL DEFAULT '0',
  `isGlobal` enum('0','1') NOT NULL DEFAULT '0',
  `active` enum('y','n') NOT NULL DEFAULT 'y',
  `exceptions` blob NOT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant`),
  KEY `lang` (`lang`)
) ENGINE=InnoDB AUTO_INCREMENT=265 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deals_taken`
--

DROP TABLE IF EXISTS `deals_taken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deals_taken` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `userId` int unsigned NOT NULL,
  `dealId` int unsigned NOT NULL,
  `date` int unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_disable`
--

DROP TABLE IF EXISTS `delivery_disable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_disable` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` smallint DEFAULT NULL,
  `start` timestamp NULL DEFAULT NULL,
  `stop` timestamp NULL DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` tinyint DEFAULT NULL,
  `removed_by` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1792 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `delivery_orders`
--

DROP TABLE IF EXISTS `delivery_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `data` blob,
  `deliveryTime` datetime DEFAULT NULL,
  `prep_time` decimal(5,2) NOT NULL,
  `mail_content` blob NOT NULL,
  `sendTo` varchar(255) NOT NULL,
  `replyTo` varchar(255) NOT NULL,
  `sent` enum('y','n') DEFAULT 'n',
  `when` datetime DEFAULT NULL,
  `order_id` int DEFAULT NULL,
  `resto` varchar(125) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1513 DEFAULT CHARSET=latin1 COMMENT='orders that will be sent to delivery api';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_schedule`
--

DROP TABLE IF EXISTS `delivery_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_schedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `day` char(3) DEFAULT NULL,
  `start` time DEFAULT NULL,
  `stop` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_day` (`restaurant_id`,`day`)
) ENGINE=InnoDB AUTO_INCREMENT=1310 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `distance_fees`
--

DROP TABLE IF EXISTS `distance_fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `distance_fees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `distance` tinyint DEFAULT NULL,
  `driver_earning` decimal(5,2) DEFAULT NULL,
  `restaurant_pays` decimal(5,2) DEFAULT NULL,
  `vendor_pays` decimal(5,2) DEFAULT NULL,
  `delivery_fee` varchar(125) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_distance` (`restaurant_id`,`distance`)
) ENGINE=InnoDB AUTO_INCREMENT=687 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `donations`
--

DROP TABLE IF EXISTS `donations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `donations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `value` decimal(5,2) DEFAULT '2.00',
  `added_at` datetime DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'n',
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='donations table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `emails`
--

DROP TABLE IF EXISTS `emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emails` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `zip` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `extra_delivery_fees`
--

DROP TABLE IF EXISTS `extra_delivery_fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `extra_delivery_fees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `extra_fee` decimal(5,2) DEFAULT NULL,
  `available_from` int DEFAULT NULL,
  `available_until` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=660 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fav_restos`
--

DROP TABLE IF EXISTS `fav_restos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fav_restos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `userId` int unsigned NOT NULL,
  `restaurantId` int unsigned NOT NULL,
  `address_id` int unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `flyercontest`
--

DROP TABLE IF EXISTS `flyercontest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flyercontest` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(6) DEFAULT NULL,
  `fname` varchar(125) DEFAULT NULL,
  `lname` varchar(125) DEFAULT NULL,
  `email` varchar(125) DEFAULT NULL,
  `zip` varchar(7) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code_UNIQUE` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=1729 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `geodispatch_reports`
--

DROP TABLE IF EXISTS `geodispatch_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `geodispatch_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `issued` date NOT NULL,
  `number` int unsigned NOT NULL,
  `period` varchar(255) NOT NULL,
  `file` varchar(255) DEFAULT NULL,
  `type` enum('t','r') DEFAULT NULL COMMENT 'Tip or Report',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=656 DEFAULT CHARSET=latin1 COMMENT='save reports issued for geodispatch';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `geodispatch_retries`
--

DROP TABLE IF EXISTS `geodispatch_retries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `geodispatch_retries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `client` text,
  `restaurant` text,
  `order` text,
  `retries` tinyint DEFAULT NULL,
  `last_answer` text,
  `last_attempt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `mail_sent` enum('y','n') DEFAULT 'n',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COMMENT='if an order failes to be sent do geodispatch, put it here';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ingredient_groups`
--

DROP TABLE IF EXISTS `ingredient_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredient_groups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `type` char(2) NOT NULL DEFAULT '',
  `course` smallint unsigned NOT NULL DEFAULT '0',
  `dish` smallint NOT NULL DEFAULT '0',
  `item` blob,
  `price` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `lang` char(2) NOT NULL DEFAULT '',
  `useInCombo` enum('Y','N') NOT NULL DEFAULT 'N',
  `isGlobal` enum('Y','N') NOT NULL DEFAULT 'N',
  PRIMARY KEY (`id`),
  KEY `course_FK` (`course`)
) ENGINE=InnoDB AUTO_INCREMENT=13627 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ingredients`
--

DROP TABLE IF EXISTS `ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredients` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `availableFor` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `price` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lang` char(2) NOT NULL DEFAULT '',
  `type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `order` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant`),
  KEY `lang` (`lang`),
  KEY `type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=59950 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `issued_statements`
--

DROP TABLE IF EXISTS `issued_statements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `issued_statements` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `statementNo` int unsigned NOT NULL,
  `restaurant` int unsigned NOT NULL,
  `issued` date NOT NULL,
  `file` varchar(125) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `by_restaurant` (`restaurant`)
) ENGINE=InnoDB AUTO_INCREMENT=190723 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `logintoken`
--

DROP TABLE IF EXISTS `logintoken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logintoken` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` int DEFAULT NULL,
  `token` varchar(40) DEFAULT NULL,
  `expire` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `course` int unsigned NOT NULL DEFAULT '0',
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `sku` varchar(50) DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `ingredients` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `price` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `order` int unsigned NOT NULL DEFAULT '0',
  `quantity` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `hasCustomisation` enum('N','Y') NOT NULL DEFAULT 'N',
  `ciHeader` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `minci` smallint NOT NULL DEFAULT '0',
  `maxci` smallint DEFAULT '0',
  `freeci` smallint NOT NULL DEFAULT '0',
  `displayOrderCI` smallint NOT NULL DEFAULT '2',
  `hasSideDish` enum('N','Y') NOT NULL DEFAULT 'N',
  `sideDishHeader` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `minsd` smallint NOT NULL DEFAULT '0',
  `maxsd` smallint NOT NULL DEFAULT '0',
  `freeSD` smallint NOT NULL DEFAULT '0',
  `displayOrderSD` smallint NOT NULL DEFAULT '5',
  `hasDrinks` enum('N','Y') NOT NULL DEFAULT 'N',
  `drinksHeader` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `mindrink` varchar(25) NOT NULL DEFAULT '0',
  `maxdrink` varchar(25) NOT NULL DEFAULT '0',
  `freeDrink` varchar(25) NOT NULL DEFAULT '0',
  `displayOrderDrink` smallint NOT NULL DEFAULT '6',
  `hasExtras` enum('N','Y') NOT NULL DEFAULT 'N',
  `extraHeader` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `minextras` smallint NOT NULL DEFAULT '0',
  `maxextras` smallint NOT NULL DEFAULT '0',
  `freeExtra` smallint NOT NULL DEFAULT '0',
  `displayOrderExtras` smallint NOT NULL DEFAULT '7',
  `isSideDish` enum('N','Y') NOT NULL DEFAULT 'N',
  `showSDInMenu` enum('N','Y') DEFAULT 'N',
  `isDrink` enum('N','Y') NOT NULL DEFAULT 'N',
  `hasBread` enum('Y','N') DEFAULT 'N',
  `breadHeader` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `displayOrderBread` smallint NOT NULL DEFAULT '1',
  `hasDressing` enum('Y','N') DEFAULT 'N',
  `dressingHeader` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `mindressing` smallint NOT NULL DEFAULT '0',
  `maxdressing` smallint NOT NULL DEFAULT '0',
  `freeDressing` smallint NOT NULL DEFAULT '0',
  `displayOrderDressing` smallint NOT NULL DEFAULT '3',
  `hasSauce` enum('Y','N') DEFAULT 'N',
  `sauceHeader` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `minsauce` smallint NOT NULL DEFAULT '0',
  `maxsauce` smallint NOT NULL DEFAULT '0',
  `freeSauce` smallint NOT NULL DEFAULT '0',
  `displayOrderSauce` smallint NOT NULL DEFAULT '4',
  `hasCookMethod` enum('Y','N') DEFAULT 'N',
  `cmHeader` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `mincm` int NOT NULL,
  `maxcm` int NOT NULL DEFAULT '1',
  `freecm` int NOT NULL,
  `displayOrderCM` int NOT NULL,
  `isCombo` enum('Y','N') DEFAULT 'N',
  `useSteps` enum('Y','N') DEFAULT 'Y',
  `mincombo` smallint NOT NULL DEFAULT '0',
  `maxcombo` smallint NOT NULL DEFAULT '0',
  `displayOrderCombo` smallint NOT NULL DEFAULT '8',
  `menuType` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `image` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lang` char(2) NOT NULL DEFAULT '',
  `showInMenu` enum('Y','N') DEFAULT 'N',
  `showPizzaIcons` enum('Y','N') DEFAULT 'N',
  `hideOnDays` blob NOT NULL COMMENT 'empty for always show',
  `checkoutItems` enum('Y','N') NOT NULL DEFAULT 'N',
  `upsell` enum('y','n') DEFAULT 'n',
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant`),
  KEY `course` (`course`),
  KEY `sku` (`sku`)
) ENGINE=InnoDB AUTO_INCREMENT=141282 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `menuothers`
--

DROP TABLE IF EXISTS `menuothers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menuothers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int NOT NULL DEFAULT '0',
  `dishId` int NOT NULL DEFAULT '0',
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `type` char(2) DEFAULT NULL,
  `groupId` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant`),
  KEY `dishId` (`dishId`),
  KEY `type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=328167 DEFAULT CHARSET=latin1 COMMENT='store side dish, drink, extra info';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `neighbourhood`
--

DROP TABLE IF EXISTS `neighbourhood`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `neighbourhood` (
  `id` int NOT NULL AUTO_INCREMENT,
  `city` int DEFAULT NULL,
  `zip` varchar(6) DEFAULT NULL,
  `name` varchar(45) DEFAULT NULL,
  `area` blob,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `open_statements`
--

DROP TABLE IF EXISTS `open_statements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `open_statements` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(125) DEFAULT '0',
  `file` varchar(125) DEFAULT '0',
  `userip` varchar(15) DEFAULT '0',
  `date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=170604 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user` int unsigned NOT NULL,
  `restaurant` int unsigned NOT NULL,
  `orderId` int NOT NULL,
  `order` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `open` enum('1','0') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `time` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `orderid` (`orderId`)
) ENGINE=InnoDB AUTO_INCREMENT=3686498 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `over_hundred`
--

DROP TABLE IF EXISTS `over_hundred`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `over_hundred` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `notice_sent` enum('y','n') DEFAULT 'n',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COMMENT='over $100 orders';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pass_reset`
--

DROP TABLE IF EXISTS `pass_reset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pass_reset` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `code` varchar(36) DEFAULT NULL,
  `expire` int DEFAULT NULL,
  `used_at` int NOT NULL,
  `deleted` enum('y','n') NOT NULL DEFAULT 'n',
  PRIMARY KEY (`id`),
  KEY `userid_idx` (`id`,`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=391997 DEFAULT CHARSET=latin1 COMMENT='keep temp password reset links';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pings`
--

DROP TABLE IF EXISTS `pings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant` int unsigned NOT NULL,
  `date` int unsigned NOT NULL,
  `mailSentOn` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant`)
) ENGINE=InnoDB AUTO_INCREMENT=758 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quebec_delivery_retries`
--

DROP TABLE IF EXISTS `quebec_delivery_retries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quebec_delivery_retries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `data` text,
  `mailContent` text,
  `mailTo` varchar(255) DEFAULT NULL,
  `replyTo` varchar(255) DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `tz` varchar(125) DEFAULT NULL,
  `sent` enum('y','n') DEFAULT 'n',
  `retries` tinyint unsigned DEFAULT '0',
  `success_on` datetime DEFAULT NULL,
  `order_id` int DEFAULT NULL,
  `resto` varchar(125) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `redirects`
--

DROP TABLE IF EXISTS `redirects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `redirects` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant` int unsigned NOT NULL,
  `from` varchar(125) NOT NULL,
  `to` varchar(125) NOT NULL,
  `domain` varchar(125) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_admins`
--

DROP TABLE IF EXISTS `restaurant_admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_user_id` int unsigned DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `fname` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `email` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `user_type` enum('r','g') DEFAULT NULL COMMENT '''Restaurant, Global''',
  `restaurant` int NOT NULL,
  `lastlogin` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `activeUser` enum('1','0') NOT NULL DEFAULT '1',
  `loginCount` int unsigned NOT NULL DEFAULT '0',
  `allowed_restaurants` blob NOT NULL,
  `showAllStats` enum('y','n') NOT NULL DEFAULT 'n',
  `fb_token` varchar(255) NOT NULL,
  `showOrderManagement` enum('y','n') NOT NULL DEFAULT 'n',
  `sendStatement` enum('y','n') NOT NULL DEFAULT 'n',
  `sendStatementTo` varchar(125) NOT NULL,
  `allowAr` enum('y','n') NOT NULL DEFAULT 'n',
  `showClients` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1075 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_areas`
--

DROP TABLE IF EXISTS `restaurant_areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_areas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `area_id` int DEFAULT NULL COMMENT 'neighbourhood id',
  PRIMARY KEY (`id`),
  KEY `area_id` (`area_id`),
  KEY `by_restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1169 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_charges`
--

DROP TABLE IF EXISTS `restaurant_charges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_charges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int DEFAULT NULL,
  `name` varchar(125) DEFAULT NULL,
  `desc` text,
  `repeat` enum('y','n') DEFAULT NULL,
  `repeatInterval` varchar(15) DEFAULT NULL,
  `repeatOn` int DEFAULT NULL,
  `active` enum('y','n') DEFAULT NULL,
  `value` float DEFAULT '0',
  `type` varchar(15) DEFAULT NULL,
  `taxable` enum('y','n') DEFAULT NULL,
  `addedby` int DEFAULT '0',
  `addedon` int DEFAULT NULL,
  `repeatUntil` int DEFAULT NULL,
  `lastUsed` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7460 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_contacts`
--

DROP TABLE IF EXISTS `restaurant_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_contacts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant` int unsigned NOT NULL,
  `contact` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `title` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `phone` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `email` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1018 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_delivery_areas`
--

DROP TABLE IF EXISTS `restaurant_delivery_areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_delivery_areas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `area_number` int DEFAULT NULL,
  `area_name` varchar(255) DEFAULT NULL,
  `delivery_fee` text,
  `coords` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_area` (`restaurant_id`,`area_number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_domains`
--

DROP TABLE IF EXISTS `restaurant_domains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_domains` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant` int unsigned NOT NULL,
  `domain` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  PRIMARY KEY (`id`),
  KEY `domain` (`domain`(10))
) ENGINE=InnoDB AUTO_INCREMENT=51988 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_feedback`
--

DROP TABLE IF EXISTS `restaurant_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_feedback` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant` int unsigned NOT NULL,
  `nicety` text NOT NULL,
  `badty` text NOT NULL,
  `sampleReview` text NOT NULL,
  `google` varchar(255) NOT NULL,
  `urbanspoon` varchar(255) NOT NULL,
  `tripadvisor` varchar(255) NOT NULL,
  `restaurantica` varchar(255) NOT NULL,
  `sendmailto` varchar(255) NOT NULL DEFAULT 'stefan@menu.ca',
  `followup` enum('y','n') NOT NULL DEFAULT 'n',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=856 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_fees`
--

DROP TABLE IF EXISTS `restaurant_fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_fees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int DEFAULT '0',
  `cc_percent` float DEFAULT '2.5',
  `cc_fixed` float DEFAULT '0.15',
  `interac_percent` float DEFAULT '1.75',
  `interac_fixed` float DEFAULT '0.15',
  `start_on` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=868 DEFAULT CHARSET=latin1 COMMENT='stores the credit card and interac fees applied to orders';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_fees_stripe`
--

DROP TABLE IF EXISTS `restaurant_fees_stripe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_fees_stripe` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `cc_percent` decimal(4,2) DEFAULT '2.50',
  `cc_fixed` decimal(4,2) DEFAULT '0.30',
  `amex_percent` decimal(4,2) DEFAULT '3.50',
  `amex_fixed` decimal(4,2) DEFAULT '0.30',
  `start_on` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=598 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_locations`
--

DROP TABLE IF EXISTS `restaurant_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_locations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) NOT NULL,
  `street` varchar(125) NOT NULL,
  `city` varchar(125) NOT NULL,
  `province` int unsigned NOT NULL,
  `zip` varchar(7) NOT NULL,
  `latitude` float NOT NULL,
  `longitude` float NOT NULL,
  `francize` int unsigned NOT NULL,
  `phone` varchar(15) NOT NULL,
  `menuURL` text NOT NULL,
  `domain` varchar(255) NOT NULL,
  `isOnline` enum('Y','N') NOT NULL DEFAULT 'N',
  PRIMARY KEY (`id`),
  KEY `FK_restaurant_locations_1` (`city`),
  KEY `FK_restaurant_locations_2` (`province`),
  CONSTRAINT `FK_restaurant_locations_2` FOREIGN KEY (`province`) REFERENCES `counties` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=latin1 COMMENT='used for the 20 restos james asked ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_notes`
--

DROP TABLE IF EXISTS `restaurant_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_notes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int NOT NULL,
  `content` text NOT NULL,
  `updated` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resto` (`restaurant`)
) ENGINE=InnoDB AUTO_INCREMENT=214 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_photos`
--

DROP TABLE IF EXISTS `restaurant_photos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_photos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `comment` varchar(255) NOT NULL,
  `delete` enum('y','n') NOT NULL DEFAULT 'n',
  `restaurant` int NOT NULL DEFAULT '0',
  `update` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`id`),
  KEY `FK_restaurant_photos_1` (`restaurant`),
  CONSTRAINT `FK_restaurant_photos_1` FOREIGN KEY (`restaurant`) REFERENCES `restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=662 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_schedule`
--

DROP TABLE IF EXISTS `restaurant_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_schedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int NOT NULL,
  `day` smallint NOT NULL,
  `start` time DEFAULT NULL,
  `stop` time DEFAULT NULL,
  `interval` smallint NOT NULL,
  `type` enum('d','p','ds','ps') NOT NULL COMMENT '''Delivery, Pickup, DeliverySpecial, PickupSpecial''',
  `date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant`),
  KEY `day` (`day`),
  KEY `type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=416526 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_thresholds`
--

DROP TABLE IF EXISTS `restaurant_thresholds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_thresholds` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int DEFAULT NULL,
  `ammount` float DEFAULT NULL,
  `time` int DEFAULT NULL,
  `type` enum('p','d') DEFAULT NULL,
  `message_en` varchar(255) DEFAULT NULL,
  `message_fr` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=latin1 COMMENT='add time when order greater then value';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurant_votes`
--

DROP TABLE IF EXISTS `restaurant_votes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurant_votes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int NOT NULL,
  `up` enum('y','n') DEFAULT NULL,
  `down` enum('y','n') DEFAULT NULL,
  `ip` varchar(15) NOT NULL,
  `comment` text NOT NULL,
  `date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants`
--

DROP TABLE IF EXISTS `restaurants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `addedBy` int NOT NULL,
  `addedon` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `address` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `city` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `province` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `cuisine` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `delivery_schedule` blob,
  `restaurant_schedule` blob,
  `specialSchedule` blob,
  `phone` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `mainEmail` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `about_en` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `about_fr` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `country` int NOT NULL DEFAULT '0',
  `delivery_time` int unsigned NOT NULL DEFAULT '0',
  `takeout_time` int DEFAULT NULL,
  `link` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `zip` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `pickup` enum('1','0') NOT NULL DEFAULT '0',
  `delivery` enum('1','0') NOT NULL DEFAULT '0',
  `takeout` enum('1','0') DEFAULT '1',
  `fee` blob,
  `min_order` varchar(125) NOT NULL DEFAULT '0',
  `active` enum('Y','N') NOT NULL DEFAULT 'N',
  `pending` enum('y','n') DEFAULT 'n',
  `lang` char(2) NOT NULL DEFAULT '',
  `latitude` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `longitude` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `deliveryRadius` float NOT NULL DEFAULT '0',
  `multipleDeliveryArea` enum('Y','N') DEFAULT 'N',
  `deliveryArea` blob,
  `tags` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `theme` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `favicon` varchar(25) DEFAULT NULL,
  `htmlTitle` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `printerUser` varchar(45) NOT NULL DEFAULT 'demo',
  `printerPassword` varchar(45) NOT NULL DEFAULT '123456',
  `domain` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `mainDomain` varchar(125) NOT NULL,
  `mobileDomain` varchar(255) NOT NULL,
  `isLocationFor` int unsigned NOT NULL,
  `allowAddressLabels` enum('n','y') NOT NULL DEFAULT 'n',
  `alloGiftCard` enum('n','y') NOT NULL DEFAULT 'n',
  `enableConvenienceFee` enum('n','y') NOT NULL DEFAULT 'n',
  `convenienceFee` float NOT NULL,
  `enableServiceFee` enum('n','y') DEFAULT 'n',
  `serviceFee` float NOT NULL,
  `menu` blob,
  `landingImageType` enum('round','square') NOT NULL DEFAULT 'round',
  `warnBeforeClose` int unsigned NOT NULL DEFAULT '0',
  `enableTipDriver` enum('n','y') NOT NULL DEFAULT 'y',
  `enableTipDriverTakeout` enum('y','n') DEFAULT 'n',
  `tipDriverFee` int unsigned NOT NULL,
  `tipDriverPlacement` enum('m','c') DEFAULT 'c' COMMENT 'm show in menu, c show on checkout',
  `timePeriod` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `updateLogo` enum('0','1') NOT NULL DEFAULT '0',
  `updateBg` enum('0','1') NOT NULL DEFAULT '0',
  `updateImages` enum('0','1') DEFAULT NULL,
  `facebookurl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `twitterurl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `instagramurl` varchar(255) NOT NULL,
  `snapchaturl` varchar(255) NOT NULL,
  `printer_serial` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `sim_serial` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `activation_date` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `metaTags` blob,
  `frenchMetaTags` blob,
  `customMetaTags` blob,
  `googleAnalytics` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `googleAnalyticsV2` varchar(45) DEFAULT NULL,
  `pddiscount` enum('y','n') NOT NULL DEFAULT 'n' COMMENT 'if resto has pickup discount',
  `pdremove` float NOT NULL COMMENT 'remove this %',
  `pdbuy` float NOT NULL COMMENT 'when that much was spent',
  `firstPageBanners` enum('y','n') NOT NULL DEFAULT 'n',
  `bannerPlacement` enum('t','c','b') NOT NULL DEFAULT 't',
  `pageTitle` blob,
  `frenchPageTitle` blob,
  `isClone` enum('n','y') NOT NULL DEFAULT 'n',
  `sitemap` blob NOT NULL,
  `gprsStart` varchar(5) NOT NULL,
  `gprsStop` varchar(5) NOT NULL,
  `footerTags` blob NOT NULL,
  `homeTopText` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'Please make your selection',
  `homeFooterText` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `showMenuAs` enum('i','t') NOT NULL DEFAULT 'i' COMMENT 'show menu as Image or Text',
  `navTexts` blob NOT NULL,
  `customCss` text NOT NULL,
  `mobileCustomCss` text,
  `takeReservations` enum('y','n') NOT NULL,
  `waiterService` enum('y','n') NOT NULL,
  `wheelchairAccessible` enum('y','n') NOT NULL,
  `outdoorSeating` enum('y','n') NOT NULL,
  `wifi` enum('y','n') NOT NULL,
  `alcohoolParking` blob NOT NULL,
  `dogsAllowed` enum('y','n') NOT NULL,
  `googleplusurl` varchar(125) NOT NULL,
  `linkedinurl` varchar(125) NOT NULL,
  `yelp` varchar(255) NOT NULL,
  `urbanspoon` varchar(255) NOT NULL,
  `tripadvisor` varchar(255) NOT NULL,
  `foursquare` varchar(125) NOT NULL,
  `registrationEmail` varchar(125) NOT NULL,
  `preferredUsername` varchar(125) NOT NULL,
  `commission` float NOT NULL,
  `commission_from` enum('g','n') NOT NULL DEFAULT 'n',
  `enable_commission` enum('y','n') NOT NULL DEFAULT 'y',
  `contractFee` float NOT NULL,
  `checkPing` enum('y','n') DEFAULT 'y',
  `alertsMail` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'support@menu.ca',
  `showPhoneInHeader` enum('y','n') NOT NULL DEFAULT 'y',
  `showPdfMenu` blob NOT NULL,
  `homeTexts` blob NOT NULL COMMENT 'eventualy will replace the homeFooterText and homeTopText ',
  `defaultLang` char(2) NOT NULL DEFAULT 'EN',
  `showFeedback` enum('Y','N') NOT NULL DEFAULT 'N',
  `fb_token` varchar(255) DEFAULT NULL,
  `bilingual` enum('y','n') DEFAULT 'n',
  `comingSoon` enum('y','n') NOT NULL DEFAULT 'n',
  `vacation` enum('y','n') NOT NULL DEFAULT 'n',
  `vacationStart` date DEFAULT NULL,
  `vacationStop` date DEFAULT NULL,
  `suspendOrdering` enum('y','n') NOT NULL DEFAULT 'n',
  `suspend_operation` tinyint unsigned NOT NULL DEFAULT '0',
  `suspended_at` int DEFAULT NULL,
  `openScheduleAboutPage` blob NOT NULL,
  `deliverScheduleAboutPage` blob NOT NULL,
  `paymentOptions` blob NOT NULL,
  `gateway` enum('salt','stripe') DEFAULT 'stripe',
  `overrideAutoSuspend` enum('y','n') DEFAULT 'y' COMMENT 'y-do not allow script, n-allow script to suspend ordering',
  `restaurantMap` int NOT NULL DEFAULT '0',
  `apikey` varchar(40) NOT NULL,
  `deliverToArea` varchar(125) DEFAULT NULL COMMENT 'neighbourhoods that the restaurant''s delivery area overlaps with',
  `mobiletitle` blob,
  `assignedTo` smallint DEFAULT NULL,
  `vendor` smallint DEFAULT NULL,
  `sendCouponLink` enum('y','n') DEFAULT 'n',
  `couponLink` varchar(125) DEFAULT NULL,
  `sendSurvey` enum('n','y') DEFAULT 'n',
  `sendToDelivery` enum('y','n') DEFAULT 'n',
  `sendToDailyDelivery` enum('Y','N') DEFAULT 'N' COMMENT 'send info about the order to daily delivery company',
  `sendToGeodispatch` enum('Y','N') DEFAULT 'N',
  `geodispatch_username` varchar(125) DEFAULT NULL,
  `geodispatch_password` varchar(125) DEFAULT NULL,
  `geodispatch_api_key` varchar(125) NOT NULL,
  `sendToDelivery_email` varchar(125) NOT NULL,
  `surveyUrl` varchar(125) NOT NULL,
  `notes` text NOT NULL,
  `mlid` smallint NOT NULL DEFAULT '0' COMMENT 'group id from ymlp',
  `mlid_vegan` int DEFAULT NULL,
  `show_in_callcenter` enum('y','n') DEFAULT 'n',
  `showSurveyOnCheckout` enum('y','n') DEFAULT 'n',
  `mobile_survey` text,
  `desktop_survey` text,
  `bad_weather` enum('y','n') DEFAULT 'n',
  `bad_weather_start` date DEFAULT NULL,
  `bad_weather_stop` date DEFAULT NULL,
  `deliveryServiceAccounting` enum('y','n') DEFAULT 'n',
  `deliveryCostCharged` char(1) DEFAULT NULL,
  `vendorCommissionExtra` float DEFAULT NULL,
  `vendorIncludePickup` enum('y','n') DEFAULT 'n',
  `first_order_popup` enum('y','n') DEFAULT 'n' COMMENT 'enable/disable first order coupon on home page',
  `show_discount_coupon_for` enum('new','all') DEFAULT NULL,
  `restaurant_delivery_charge` decimal(5,2) DEFAULT NULL COMMENT 'how much restaurant is paying for delivery with delivery company',
  `tookan_delivery` enum('y','n') DEFAULT 'n',
  `tookan_tags` varchar(125) DEFAULT NULL,
  `tookan_restaurant_email` varchar(125) DEFAULT NULL,
  `tookan_delivery_as_pickup` enum('y','n') DEFAULT 'n',
  `weDeliver` enum('y','n') DEFAULT 'n',
  `weDeliver_driver_notes` text,
  `weDeliverEmail` varchar(125) DEFAULT NULL,
  `deliveryServiceExtra` decimal(5,2) DEFAULT '0.00',
  `use_delivery_areas` enum('y','n') DEFAULT 'y' COMMENT 'delivery areas or new delivery system based on distance - just ofr fees',
  `delivery_restaurant_id` int DEFAULT NULL,
  `max_delivery_distance` tinyint DEFAULT NULL,
  `disable_delivery_until` datetime DEFAULT NULL COMMENT 'disable delivery until selected time - from delivery company',
  `twilio_call` enum('y','n') DEFAULT 'n',
  PRIMARY KEY (`id`),
  KEY `zip` (`zip`(3)),
  KEY `map_to` (`restaurantMap`),
  KEY `mobile_domain` (`mobileDomain`(10)),
  KEY `province` (`province`),
  KEY `locationfor` (`isLocationFor`),
  KEY `active` (`active`),
  KEY `city` (`city`)
) ENGINE=InnoDB AUTO_INCREMENT=1095 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sent_contact_forms`
--

DROP TABLE IF EXISTS `sent_contact_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sent_contact_forms` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `userid` int unsigned NOT NULL,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `email` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `message` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `insertTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `viewed` enum('N','Y') NOT NULL DEFAULT 'N',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sent_restaurant_feedbacks`
--

DROP TABLE IF EXISTS `sent_restaurant_feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sent_restaurant_feedbacks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant` int unsigned NOT NULL,
  `name` varchar(125) NOT NULL,
  `experience` int unsigned NOT NULL,
  `story` text NOT NULL,
  `email` varchar(125) NOT NULL,
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `spam_reporters`
--

DROP TABLE IF EXISTS `spam_reporters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `spam_reporters` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `time` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `by_email` (`email`(10))
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sqlmapfile`
--

DROP TABLE IF EXISTS `sqlmapfile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sqlmapfile` (
  `data` longtext
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `statement_carry_values`
--

DROP TABLE IF EXISTS `statement_carry_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `statement_carry_values` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `commission` float DEFAULT NULL,
  `restaurant` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `date_restaurant` (`date`,`restaurant`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=160411 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `statement_info`
--

DROP TABLE IF EXISTS `statement_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `statement_info` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `restaurant` int DEFAULT NULL,
  `statement` int DEFAULT NULL,
  `net_paid` float DEFAULT NULL,
  `cash` float DEFAULT NULL,
  `card` float DEFAULT NULL,
  `bank_fees` float DEFAULT NULL,
  `commission` float DEFAULT NULL,
  `charges` float DEFAULT NULL,
  `taxes` float DEFAULT NULL,
  `transactionFee` decimal(6,2) DEFAULT NULL,
  `deliveryServiceFee` decimal(6,2) NOT NULL,
  `deliveryServiceTips` decimal(6,2) NOT NULL,
  `delivery_fee_and_tips` decimal(6,2) NOT NULL,
  `deliveryComission` decimal(6,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=161101 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `statement_invoices`
--

DROP TABLE IF EXISTS `statement_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `statement_invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant` int NOT NULL,
  `name` varchar(125) NOT NULL,
  `paid` enum('y','n') NOT NULL DEFAULT 'n',
  `date` date NOT NULL,
  `date_paid` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `resto_date` (`restaurant`,`date`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `statement_payments`
--

DROP TABLE IF EXISTS `statement_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `statement_payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `restaurant` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `date_resto` (`date`,`restaurant`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_payment_clients`
--

DROP TABLE IF EXISTS `stripe_payment_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stripe_payment_clients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `stripe_id` varchar(125) DEFAULT NULL,
  `stripe_info` blob,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=267162 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_payments`
--

DROP TABLE IF EXISTS `stripe_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stripe_payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT '0',
  `charge_id` varchar(125) NOT NULL,
  `answer` blob COMMENT 'stripe answer',
  `status` enum('y','n') DEFAULT NULL COMMENT 'success or fail',
  `type` enum('payment','refund','void') DEFAULT 'payment' COMMENT 'is it payment, refund or void',
  `class` varchar(125) DEFAULT NULL COMMENT 'if error, where does the error comes from',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb3 COMMENT='store payment info here';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stripe_payments_intents`
--

DROP TABLE IF EXISTS `stripe_payments_intents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stripe_payments_intents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `amount` int DEFAULT NULL,
  `intent_id` varchar(125) DEFAULT NULL,
  `intent` text NOT NULL,
  `client` varchar(125) DEFAULT NULL,
  `captured` enum('y','n') DEFAULT NULL,
  `last_4` varchar(4) DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `modified_at` datetime DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `by_order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1010136 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tablet_orders`
--

DROP TABLE IF EXISTS `tablet_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tablet_orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant` int unsigned NOT NULL,
  `order` int unsigned NOT NULL,
  `order_data` text NOT NULL,
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '0 - no action, 1 - accepted, 2 - rejected, 3 - done.',
  `reject_reason` tinytext NOT NULL,
  `time_created` int unsigned NOT NULL DEFAULT '0',
  `time_modified` int unsigned NOT NULL DEFAULT '0',
  `time_accepted` int unsigned NOT NULL DEFAULT '0',
  `time_ack` int unsigned NOT NULL DEFAULT '0',
  `time_rejected` int unsigned NOT NULL DEFAULT '0',
  `time_done` int unsigned NOT NULL DEFAULT '0',
  `deleted` tinyint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `by_resto_order` (`restaurant`,`order`)
) ENGINE=InnoDB AUTO_INCREMENT=1721485 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tablets`
--

DROP TABLE IF EXISTS `tablets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tablets` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `designator` tinytext NOT NULL,
  `key` varbinary(20) NOT NULL,
  `restaurant` int unsigned NOT NULL DEFAULT '0',
  `printing` tinyint unsigned NOT NULL DEFAULT '0',
  `config_edit` tinyint unsigned NOT NULL DEFAULT '0',
  `v2` tinyint unsigned NOT NULL DEFAULT '0',
  `fw_ver` tinyint unsigned NOT NULL DEFAULT '0',
  `sw_ver` tinyint unsigned NOT NULL DEFAULT '0',
  `desynced` tinyint unsigned NOT NULL DEFAULT '0',
  `last_boot` int unsigned NOT NULL DEFAULT '0',
  `last_check` int unsigned NOT NULL DEFAULT '0',
  `created_at` int unsigned NOT NULL DEFAULT '0',
  `modified_at` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `by_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=895 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tags` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `temp_password`
--

DROP TABLE IF EXISTS `temp_password`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temp_password` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `validation_code` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `validated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27185 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `templates`
--

DROP TABLE IF EXISTS `templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `lang` char(2) NOT NULL DEFAULT 'en',
  `type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `restaurant` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `by_restaurant` (`restaurant`)
) ENGINE=InnoDB AUTO_INCREMENT=6935 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testimonials`
--

DROP TABLE IF EXISTS `testimonials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testimonials` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `food` int unsigned NOT NULL DEFAULT '0',
  `money` int unsigned NOT NULL DEFAULT '0',
  `speed` int unsigned NOT NULL DEFAULT '0',
  `testimonial` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `time_added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `approved` enum('1','0') NOT NULL DEFAULT '0',
  `restaurant` tinyint unsigned NOT NULL DEFAULT '0',
  `addedBy` int unsigned NOT NULL DEFAULT '0',
  `viewed` enum('Y','N') DEFAULT 'N',
  `lang` enum('en','fr') NOT NULL DEFAULT 'en',
  `ip` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `theme_elements`
--

DROP TABLE IF EXISTS `theme_elements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `theme_elements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `theme_id` int DEFAULT NULL,
  `element` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `element_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `element_class` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `element_src` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `element_style` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `element_type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `element_href` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `theme_style`
--

DROP TABLE IF EXISTS `theme_style`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `theme_style` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'css,atttribute',
  `element` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `attribute` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `value` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `template_id` int NOT NULL COMMENT '-1 or resto id',
  `resto_id` int NOT NULL COMMENT '0 or resto id',
  PRIMARY KEY (`id`),
  KEY `attribute` (`attribute`)
) ENGINE=InnoDB AUTO_INCREMENT=1154 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `theme_templates`
--

DROP TABLE IF EXISTS `theme_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `theme_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `theme_id` int NOT NULL COMMENT '->themes->id',
  `owener` int NOT NULL COMMENT 'restaurant_admins->id',
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `type` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL COMMENT 'e.g pizza, pho',
  `description` tinytext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `css_link` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `theme_id` (`theme_id`),
  KEY `owener` (`owener`),
  KEY `css_link` (`css_link`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `themes`
--

DROP TABLE IF EXISTS `themes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `themes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `type` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `time_period`
--

DROP TABLE IF EXISTS `time_period`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `time_period` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `period_name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `period_start` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `period_stop` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tokens`
--

DROP TABLE IF EXISTS `tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `processedTime` varchar(15) DEFAULT NULL,
  `token` varchar(36) DEFAULT NULL,
  `card` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=67213 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tookan_fees`
--

DROP TABLE IF EXISTS `tookan_fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tookan_fees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `area` tinyint NOT NULL,
  `driver_earnings` decimal(5,2) NOT NULL,
  `restaurant` decimal(5,2) NOT NULL DEFAULT '0.00',
  `vendor` decimal(5,2) NOT NULL DEFAULT '0.00',
  `total_fare` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_restaurant_area` (`restaurant_id`,`area`)
) ENGINE=InnoDB AUTO_INCREMENT=868 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `twilio_calls`
--

DROP TABLE IF EXISTS `twilio_calls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `twilio_calls` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `last_call` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `us`
--

DROP TABLE IF EXISTS `us`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `us` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `zip` int DEFAULT NULL,
  `city` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `state_full` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `state` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `by_zip` (`zip`)
) ENGINE=InnoDB AUTO_INCREMENT=79949 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_auth_codes`
--

DROP TABLE IF EXISTS `user_auth_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_auth_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `table` varchar(30) DEFAULT NULL,
  `code` varchar(16) DEFAULT NULL,
  `used` enum('y','n') DEFAULT 'n',
  `created_at` datetime DEFAULT NULL,
  `used_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=725 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_coupons`
--

DROP TABLE IF EXISTS `user_coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_coupons` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `owner` int unsigned NOT NULL DEFAULT '0',
  `dateAdded` int unsigned NOT NULL DEFAULT '0',
  `used` enum('Y','N') NOT NULL DEFAULT 'N',
  `dateUsed` int unsigned NOT NULL DEFAULT '0',
  `coupon` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_orders`
--

DROP TABLE IF EXISTS `user_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `restaurant` int unsigned NOT NULL,
  `order` blob,
  `tmpOrder` blob,
  `buyType` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `totalWithTaxes` float NOT NULL,
  `paidWithCredit` float NOT NULL DEFAULT '0',
  `datePlaced` int unsigned NOT NULL COMMENT 'when order was registered',
  `placeOn` blob,
  `status` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `used_address` blob,
  `used_address_id` int NOT NULL,
  `used_address_area` tinyint DEFAULT '0',
  `reason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `deliveryTime` int unsigned NOT NULL COMMENT 'chosed delivery time',
  `acceptedFor` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `comments` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `couponCode` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `deductAmount` float NOT NULL,
  `couponProduct` varchar(255) DEFAULT NULL,
  `paymentMethod` int unsigned NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `ext` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `dealUsed` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `dealContent` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `dealItem` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `isGlobalDeal` enum('0','1') NOT NULL,
  `totalWithoutTaxes` float NOT NULL,
  `taxes` blob,
  `orderFile` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `driverTip` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `otherDiscounts` float NOT NULL,
  `deliverFee` float unsigned NOT NULL,
  `geodispatch_restofee` float DEFAULT '0',
  `convenienceFee` float NOT NULL,
  `serviceFee` float NOT NULL,
  `paymentStatus` enum('N','Y') NOT NULL DEFAULT 'N',
  `paymentInfo` blob,
  `refundInfo` blob,
  `isVoid` enum('N','Y') NOT NULL DEFAULT 'N',
  `isRefund` enum('N','Y') NOT NULL DEFAULT 'N',
  `refunded_at` datetime DEFAULT NULL,
  `midnight` int NOT NULL COMMENT 'used in accounting only',
  `totalItems` blob NOT NULL,
  `addHistory` blob NOT NULL,
  `queryString` varchar(255) DEFAULT NULL COMMENT 'printer answer',
  `userip` varchar(15) NOT NULL,
  `forwardedfor` varchar(15) DEFAULT NULL,
  `placedFrom` char(1) NOT NULL,
  `stringOrder` text,
  `from_callcenter` enum('y','n') DEFAULT 'n',
  `callcenter_user` int NOT NULL,
  `tookan_total_fare` decimal(5,2) DEFAULT '0.00',
  `tookan_driver_earnings` decimal(5,2) DEFAULT '0.00',
  `distance` int DEFAULT NULL COMMENT 'distance from restaurant to client',
  PRIMARY KEY (`id`),
  KEY `status` (`status`(6)),
  KEY `dateplaced` (`datePlaced`),
  KEY `midnight` (`midnight`),
  KEY `user_id` (`user_id`),
  KEY `restaurant` (`restaurant`) USING BTREE,
  KEY `used_address_id` (`used_address_id`),
  KEY `from_callcenter` (`from_callcenter`),
  KEY `couponCode` (`couponCode`)
) ENGINE=InnoDB AUTO_INCREMENT=3774478 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_insert` BEFORE INSERT ON `user_orders` FOR EACH ROW BEGIN
	if NEW.restaurant = 910 then
		if new.paymentMethod = 1 or new.paymentMethod = 4 or new.paymentMethod = 904 or new.paymentMethod = 905 then
			set NEW.`status` = 'Accepted';
        end if; 
    end if;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_update` BEFORE UPDATE ON `user_orders` FOR EACH ROW BEGIN
	if old.restaurant = 910 then
		if (new.paymentMethod = 2 or new.paymentMethod = 3) and new.`status`='pending' then
			set NEW.`status` = 'Accepted';
        end if;
    end if;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `user_orders_count`
--

DROP TABLE IF EXISTS `user_orders_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_orders_count` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `restaurant_id` int unsigned NOT NULL,
  `cnt` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `resto_uid` (`user_id`,`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3221391 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isActive` enum('y','n') DEFAULT 'y',
  `fname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `passwordChangedOn` datetime DEFAULT CURRENT_TIMESTAMP,
  `language` char(2) NOT NULL DEFAULT 'en',
  `newsletter` enum('0','1') DEFAULT '0',
  `vegan_newsletter` enum('1','0') DEFAULT '0',
  `isEmailConfirmed` enum('0','1') NOT NULL DEFAULT '1',
  `lastLogin` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `loginCount` int unsigned NOT NULL DEFAULT '0',
  `autologinCode` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `restaurant` int unsigned DEFAULT NULL,
  `globalUser` enum('n','y') NOT NULL DEFAULT 'n',
  `createdFrom` enum('d','m') DEFAULT NULL,
  `creationip` varchar(15) DEFAULT NULL,
  `forwardedfor` varchar(15) DEFAULT NULL,
  `firstMailFeedback` enum('n','y') NOT NULL DEFAULT 'n',
  `unsub` tinyint(1) DEFAULT NULL,
  `sent` int DEFAULT '0',
  `opens` int DEFAULT '0',
  `clicks` int DEFAULT '0',
  `total_opens` int NOT NULL DEFAULT '0',
  `total_clicks` int NOT NULL DEFAULT '0',
  `last_send` int NOT NULL DEFAULT '0',
  `last_click` int NOT NULL DEFAULT '0',
  `last_open` int NOT NULL DEFAULT '0',
  `creditValue` float DEFAULT NULL,
  `creditStartOn` int DEFAULT NULL,
  `fbid` bigint unsigned DEFAULT NULL,
  `storageToken` varchar(45) DEFAULT NULL,
  `fsi` varchar(32) DEFAULT NULL COMMENT 'fraud_session_id',
  PRIMARY KEY (`id`),
  KEY `email` (`email`(15))
) ENGINE=InnoDB AUTO_INCREMENT=1366081 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_delivery_addresses`
--

DROP TABLE IF EXISTS `users_delivery_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_delivery_addresses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `userid` int unsigned NOT NULL,
  `street` varchar(255) NOT NULL,
  `streetNo` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `apartment` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `buzzer` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `city` varchar(125) NOT NULL,
  `province` int unsigned NOT NULL,
  `zip` varchar(7) NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `ext` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `latitude` float NOT NULL,
  `longitude` float NOT NULL,
  `label` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `comment` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `userid` (`userid`),
  KEY `phone` (`phone`),
  FULLTEXT KEY `ft` (`street`,`city`,`zip`)
) ENGINE=MyISAM AUTO_INCREMENT=1446223 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_users`
--

DROP TABLE IF EXISTS `vendor_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `fname` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `lname` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `password` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `email` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `trelloAddress` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `company` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `activeUser` enum('1','0') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendors`
--

DROP TABLE IF EXISTS `vendors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendors` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `restaurants` blob NOT NULL,
  `orderFee` float NOT NULL,
  `address` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `phone` blob NOT NULL,
  `logo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `website` blob NOT NULL,
  `contacts` blob NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendors_payableto`
--

DROP TABLE IF EXISTS `vendors_payableto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendors_payableto` (
  `id` int NOT NULL AUTO_INCREMENT,
  `payableto` blob,
  `vendor` smallint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1681 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendors_reports`
--

DROP TABLE IF EXISTS `vendors_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendors_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vendor_id` int DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `start` int DEFAULT NULL,
  `stop` int DEFAULT NULL,
  `generated` int DEFAULT NULL,
  `type` char(5) NOT NULL COMMENT 'stat or inv',
  `number` smallint NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=44870 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendors_restaurants`
--

DROP TABLE IF EXISTS `vendors_restaurants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendors_restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vendor_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40054 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'menuca_v1'
--

--
-- Dumping routines for database 'menuca_v1'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-18 10:12:16
