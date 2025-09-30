CREATE DATABASE  IF NOT EXISTS `menuca_v2` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `menuca_v2`;
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
-- Table structure for table `account_options`
--

DROP TABLE IF EXISTS `account_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `options` json DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='store the options to display the user account page';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `address_searches`
--

DROP TABLE IF EXISTS `address_searches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `address_searches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `place_id` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `lat` decimal(13,10) DEFAULT NULL,
  `lng` decimal(13,10) DEFAULT NULL,
  `street_number` int DEFAULT NULL,
  `route` varchar(125) DEFAULT NULL COMMENT 'street name, named route on google',
  `sublocality_level_1` varchar(125) DEFAULT NULL COMMENT 'division in city',
  `locality` varchar(125) DEFAULT NULL COMMENT 'city name',
  `postal_code_prefix` varchar(3) DEFAULT NULL,
  `postal_code` varchar(7) DEFAULT NULL,
  `administrative_area_level_1` varchar(3) DEFAULT NULL,
  `area` varchar(125) DEFAULT NULL,
  `formatted_address` varchar(255) DEFAULT NULL,
  `hash` varchar(125) GENERATED ALWAYS AS (md5(concat_ws(_latin1',',`street_number`,`route`))) VIRTUAL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `address_searches_place_id_uindex` (`place_id`),
  KEY `address_searches_area` (`area`(10))
) ENGINE=InnoDB AUTO_INCREMENT=25285 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_users`
--

DROP TABLE IF EXISTS `admin_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `preferred_language` tinyint DEFAULT '1',
  `fname` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `lname` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `email` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `password` varchar(125) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `group` int NOT NULL,
  `receive_statements` enum('y','n') DEFAULT 'n',
  `phone` varchar(20) DEFAULT NULL,
  `active` enum('y','n') DEFAULT 'y',
  `override_restaurants` enum('y','n') DEFAULT 'n',
  `settings` json DEFAULT NULL,
  `billing_info` text,
  `allow_login_to_sites` enum('y','n') DEFAULT 'n',
  `last_activity` datetime DEFAULT NULL,
  `created_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_users_actions`
--

DROP TABLE IF EXISTS `admin_users_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_users_actions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_user_id` int NOT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `action` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `posted_data` json DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `restaurant_id` int unsigned DEFAULT NULL,
  `group_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `blacklist_id` int unsigned DEFAULT NULL,
  `global_ingredient_id` int unsigned DEFAULT NULL,
  `restaurant_ingredient_id` int unsigned DEFAULT NULL,
  `course_id` int unsigned DEFAULT NULL,
  `order_id` int unsigned DEFAULT NULL,
  `table` varchar(125) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `level` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'info',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `restaurant_id` (`restaurant_id`) USING BTREE,
  KEY `admin_user_id` (`admin_user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_users_restaurants`
--

DROP TABLE IF EXISTS `admin_users_restaurants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_users_restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=432 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aggregators`
--

DROP TABLE IF EXISTS `aggregators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aggregators` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(125) DEFAULT NULL,
  `url` varchar(125) DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT NULL,
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aggregators_contact`
--

DROP TABLE IF EXISTS `aggregators_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aggregators_contact` (
  `id` int NOT NULL AUTO_INCREMENT,
  `aggregator_id` int DEFAULT NULL,
  `address` varchar(125) DEFAULT NULL,
  `phone` varchar(45) DEFAULT NULL,
  `customer_email` varchar(125) DEFAULT NULL,
  `menu_changes_email` varchar(125) DEFAULT NULL,
  `advertising_email` varchar(125) DEFAULT NULL,
  `social_media` json DEFAULT NULL,
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `aggregator_id_UNIQUE` (`aggregator_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COMMENT='contact info for aggregators';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ai_context`
--

DROP TABLE IF EXISTS `ai_context`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_context` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `body` text,
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blacklist`
--

DROP TABLE IF EXISTS `blacklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blacklist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(20) DEFAULT NULL,
  `hash` varchar(125) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `email` varchar(125) DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `t_u_r` (`type`,`item_id`,`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `browser_list`
--

DROP TABLE IF EXISTS `browser_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `browser_list` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `browser_info` json DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `browser_list_pk2` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=171264 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cancel_order_requests`
--

DROP TABLE IF EXISTS `cancel_order_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cancel_order_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `accepted` enum('n','y') DEFAULT 'n',
  `requested_by` int DEFAULT NULL,
  `requested_at` datetime DEFAULT NULL,
  `seen` enum('y','n') DEFAULT 'n',
  `seen_at` datetime DEFAULT NULL,
  `seen_by` int DEFAULT NULL,
  `accepted_by` int DEFAULT NULL,
  `accepted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_restaurant` (`order_id`,`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ci_sessions`
--

DROP TABLE IF EXISTS `ci_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ci_sessions` (
  `id` varchar(40) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `timestamp` int unsigned NOT NULL DEFAULT '0',
  `data` blob NOT NULL,
  KEY `ci_sessions_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cities`
--

DROP TABLE IF EXISTS `cities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cities` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `displayName` varchar(125) DEFAULT NULL,
  `province_id` smallint DEFAULT '0',
  `country` char(3) NOT NULL DEFAULT 'ca',
  `lat` decimal(13,10) DEFAULT NULL,
  `lng` decimal(13,10) DEFAULT NULL,
  `timezone` varchar(45) DEFAULT NULL,
  `language_id` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `province_id` (`province_id`)
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC;
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `cuisine`
--

DROP TABLE IF EXISTS `cuisine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cuisine` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_ingredients`
--

DROP TABLE IF EXISTS `custom_ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `custom_ingredients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `name` varchar(125) NOT NULL,
  `price` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `custom_ingredients_fk_1_idx` (`restaurant_id`),
  CONSTRAINT `custom_ingredients_fk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_company_retries`
--

DROP TABLE IF EXISTS `delivery_company_retries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_company_retries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `order_id` int DEFAULT NULL,
  `delivery_company` varchar(125) DEFAULT NULL,
  `delivery_time` datetime DEFAULT NULL,
  `prep_time` decimal(10,0) DEFAULT NULL,
  `sent` enum('y','n') DEFAULT 'n',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deliveryzone_retries`
--

DROP TABLE IF EXISTS `deliveryzone_retries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deliveryzone_retries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `data` json DEFAULT NULL,
  `mailContent` blob,
  `mailTo` varchar(255) DEFAULT NULL,
  `replyTo` varchar(255) DEFAULT NULL,
  `deliveryAt` datetime DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `tz` varchar(125) DEFAULT NULL,
  `sent` enum('y','n') DEFAULT 'n',
  `retries` tinyint unsigned DEFAULT '0',
  `success_on` datetime DEFAULT NULL,
  `order_id` int DEFAULT NULL,
  `resto` varchar(125) DEFAULT NULL,
  `preorder` enum('y','n') DEFAULT 'n',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `francizes`
--

DROP TABLE IF EXISTS `francizes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `francizes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `global_courses`
--

DROP TABLE IF EXISTS `global_courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `global_courses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant_type` int DEFAULT NULL,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `language_id` tinyint unsigned DEFAULT NULL,
  `enabled` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT 'y',
  `added_at` timestamp NULL DEFAULT NULL,
  `added_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_type` (`restaurant_type`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `global_dishes`
--

DROP TABLE IF EXISTS `global_dishes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `global_dishes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `course_id` int unsigned DEFAULT NULL,
  `name` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin,
  `enabled` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_course` (`name`,`course_id`),
  KEY `course_id` (`course_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `global_ingredients`
--

DROP TABLE IF EXISTS `global_ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `global_ingredients` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `language_id` tinyint NOT NULL DEFAULT '1',
  `restaurant_type` int unsigned DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lang` (`language_id`),
  KEY `type` (`type`),
  KEY `restaurant_type` (`restaurant_type`)
) ENGINE=InnoDB AUTO_INCREMENT=8299 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `global_restaurant_types`
--

DROP TABLE IF EXISTS `global_restaurant_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `global_restaurant_types` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `groups` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(125) DEFAULT NULL,
  `description` text,
  `allow_remove` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `groups_permissions`
--

DROP TABLE IF EXISTS `groups_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `groups_permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` char(3) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`,`group_id`),
  KEY `fk_permissions_admin_users_id_idx` (`group_id`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4939 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `landing_pages`
--

DROP TABLE IF EXISTS `landing_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `landing_pages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(125) DEFAULT NULL COMMENT 'internal name of the landing page',
  `domain` varchar(125) DEFAULT NULL COMMENT 'domain of the page',
  `logo` varchar(125) DEFAULT NULL,
  `background` varchar(125) DEFAULT NULL,
  `coords` json DEFAULT NULL,
  `settings` json DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='landing pages table - kinda like an aggregator';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `landing_pages_restaurants`
--

DROP TABLE IF EXISTS `landing_pages_restaurants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `landing_pages_restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `landing_page_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=254 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='restaurants that belong to a landing page';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `languages` (
  `id` tinyint NOT NULL AUTO_INCREMENT,
  `name` varchar(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `short_name` char(2) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `path` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COMMENT='all available languages here, use the id ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `login_attempts`
--

DROP TABLE IF EXISTS `login_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_attempts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(15) NOT NULL,
  `login` varchar(100) NOT NULL,
  `time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restraurant_id` int DEFAULT NULL,
  `course_id` int DEFAULT NULL,
  `name` varchar(125) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `image` varchar(40) DEFAULT NULL,
  `price` varchar(45) DEFAULT NULL COMMENT '1,2,3',
  `size` varchar(125) DEFAULT NULL COMMENT 's,m,l',
  PRIMARY KEY (`id`),
  KEY `menu_restaurant_id_fk1_idx` (`restraurant_id`),
  KEY `menu_course_id_fk2_idx` (`course_id`),
  CONSTRAINT `menu_course_id_fk2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`),
  CONSTRAINT `menu_restaurant_id_fk1` FOREIGN KEY (`restraurant_id`) REFERENCES `restaurants` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COMMENT='holds the menu items for a given course';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nav`
--

DROP TABLE IF EXISTS `nav`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nav` (
  `id` int NOT NULL AUTO_INCREMENT,
  `permission_required` json DEFAULT NULL,
  `groups_allowed` json DEFAULT NULL,
  `name` varchar(125) DEFAULT NULL,
  `url` varchar(125) DEFAULT '/',
  `available_for` int DEFAULT NULL,
  `display_order` smallint DEFAULT NULL,
  `class` varchar(125) NOT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`),
  KEY `available_for` (`available_for`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `order_details`
--

DROP TABLE IF EXISTS `order_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `user_id` int DEFAULT NULL COMMENT 'user id, if any',
  `user_ip` varchar(125) DEFAULT NULL,
  `total` decimal(6,2) DEFAULT NULL,
  `food_value` decimal(6,2) DEFAULT NULL,
  `taxes` json NOT NULL,
  `status` enum('pending','rejected','accepted','canceled') DEFAULT NULL COMMENT 'Pending / Accepted / Rejected / Canceled',
  `reason` varchar(255) DEFAULT NULL COMMENT 'taken from query string - not sure if we need it - might aswell parse query string',
  `added_on` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'date when order was saved to db',
  `ordered_for` datetime DEFAULT NULL COMMENT 'ordered for this time',
  `asap` enum('y','n') NOT NULL DEFAULT 'n',
  `updated_at` datetime DEFAULT NULL,
  `order_type` enum('t','d') NOT NULL DEFAULT 't' COMMENT 'takeout / delivery',
  `payment_method` smallint DEFAULT NULL,
  `device` char(1) NOT NULL DEFAULT 'd' COMMENT 'Mobile / Desktop',
  `queryString` varchar(255) DEFAULT NULL COMMENT 'printer answer ',
  `referal` varchar(45) DEFAULT NULL COMMENT 'where did the user came from - if present',
  `address_id` int DEFAULT NULL COMMENT 'the address id user used',
  `coupon` varchar(125) DEFAULT NULL COMMENT 'the id of the coupon used',
  `coupon_deduct` decimal(5,2) DEFAULT NULL,
  `coupon_product` varchar(125) DEFAULT NULL,
  `deal` int DEFAULT NULL COMMENT 'the id of the deal used',
  `deal_deduct` decimal(5,2) DEFAULT NULL,
  `deal_item` varchar(255) DEFAULT NULL,
  `driver_tip` decimal(5,2) DEFAULT NULL,
  `other_discounts` decimal(5,2) DEFAULT NULL,
  `delivery_fee` decimal(5,2) DEFAULT '0.00',
  `convenience_fee` decimal(5,2) DEFAULT NULL,
  `service_fee` decimal(5,2) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `payment_info` blob,
  `refund_info` blob,
  `is_void` enum('y','n') DEFAULT 'n',
  `is_refund` enum('y','n') DEFAULT 'n',
  `midnight` datetime DEFAULT NULL,
  `is_reorder` enum('y','n') DEFAULT 'n',
  `driver_earnings` decimal(5,2) DEFAULT NULL,
  `distance` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `coupon` (`coupon`),
  KEY `deal` (`deal`)
) ENGINE=InnoDB AUTO_INCREMENT=88608 DEFAULT CHARSET=utf8mb3 COMMENT='main order info';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_main_items`
--

DROP TABLE IF EXISTS `order_main_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_main_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `is_combo` enum('y','n') DEFAULT 'n',
  `item_id` smallint DEFAULT NULL COMMENT 'item id from menu',
  `item_size` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `hr_size` varchar(125) DEFAULT NULL,
  `base_price` decimal(5,2) DEFAULT NULL,
  `quantity` tinyint DEFAULT '1' COMMENT 'how many items of this type are added to the order',
  `special_instructions` varchar(255) DEFAULT NULL,
  `add_to_cart` enum('y','n') DEFAULT 'n' COMMENT 'if set to no, then don''t take in account this dish ... user changed his mind.',
  `added_on` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=141280 DEFAULT CHARSET=utf8mb3 COMMENT='main items that order has - for instance a pizza''s name';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_pdf`
--

DROP TABLE IF EXISTS `order_pdf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_pdf` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `order_id` int DEFAULT NULL,
  `file` varchar(125) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13474 DEFAULT CHARSET=utf8mb3 COMMENT='generated pdf files for orders';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_sub_items`
--

DROP TABLE IF EXISTS `order_sub_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_sub_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `main_item_id` int DEFAULT NULL COMMENT 'id of the item in orders_main_items',
  `item_id` int DEFAULT NULL COMMENT 'item id added in customisation',
  `item_count` smallint DEFAULT '0',
  `hash` varchar(15) DEFAULT NULL,
  `price` decimal(5,2) DEFAULT NULL,
  `position` enum('l','r','a') CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT 'a',
  `display_order` smallint DEFAULT NULL,
  `added_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `header` varchar(125) DEFAULT NULL,
  `type` varchar(45) DEFAULT NULL COMMENT 'item type - extra, ci, etc',
  `input_type` varchar(20) DEFAULT NULL,
  `combo_index` tinyint DEFAULT NULL,
  `group_index` tinyint DEFAULT NULL,
  `group_id` int DEFAULT NULL,
  `dish` varchar(10) DEFAULT NULL,
  `dish_size` tinyint unsigned DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`),
  KEY `hash` (`hash`)
) ENGINE=InnoDB AUTO_INCREMENT=87470 DEFAULT CHARSET=utf8mb3 COMMENT='ingredients for say a pizza';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_sub_items_combo`
--

DROP TABLE IF EXISTS `order_sub_items_combo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_sub_items_combo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `main_item_id` int DEFAULT NULL COMMENT 'the item that the customization is being done for - need it like that so we don''t alter code too much',
  `item_id` int DEFAULT NULL COMMENT 'dish id',
  `item_count` tinyint unsigned DEFAULT NULL,
  `hash` varchar(15) DEFAULT NULL,
  `price` decimal(5,2) DEFAULT NULL,
  `display_order` tinyint unsigned DEFAULT NULL,
  `added_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `header` varchar(125) DEFAULT NULL,
  `type` varchar(45) DEFAULT NULL COMMENT 'item type - extra, ci, etc',
  `input_type` varchar(25) DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4191 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_clients`
--

DROP TABLE IF EXISTS `payment_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_clients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `stripe_id` varchar(125) DEFAULT NULL,
  `stripe_info` json DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int DEFAULT '0',
  `answer` json DEFAULT NULL COMMENT 'stripe answer',
  `status` enum('y','n') DEFAULT NULL COMMENT 'success or fail',
  `type` enum('payment','refund','void') DEFAULT 'payment' COMMENT 'is it payment, refund or void',
  `class` varchar(125) DEFAULT NULL COMMENT 'if error, where does the error comes from',
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb3 COMMENT='store payment info here';
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `phinxlog`
--

DROP TABLE IF EXISTS `phinxlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phinxlog` (
  `version` bigint NOT NULL,
  `migration_name` varchar(100) DEFAULT NULL,
  `start_time` timestamp NULL DEFAULT NULL,
  `end_time` timestamp NULL DEFAULT NULL,
  `breakpoint` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `provinces`
--

DROP TABLE IF EXISTS `provinces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `provinces` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `name` varchar(125) NOT NULL,
  `short_name` char(3) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `language_id` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reset_codes`
--

DROP TABLE IF EXISTS `reset_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reset_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(15) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `request_ip` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reset_codes_code_index` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=3631 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='table containing reset codes for password recovery';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants`
--

DROP TABLE IF EXISTS `restaurants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `v1_id` int DEFAULT NULL COMMENT 'id from v1 db',
  `restaurant_owner_id` int NOT NULL,
  `francize_id` int NOT NULL COMMENT 'if restaurant belongs to a francize, fill this',
  `added_by` int NOT NULL COMMENT 'who added the restaurant',
  `added_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'time restaurant was added in db',
  `vendor_id` int DEFAULT NULL,
  `printer_id` int DEFAULT NULL,
  `suspend_operation` enum('1','0') DEFAULT '0' COMMENT 'weather restaurant had disabled getting orders from app or not - do not touch',
  `suspended_at` int unsigned DEFAULT NULL COMMENT 'indicates when the restaurant has suspended operation - do not touch',
  `name` varchar(125) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `address` varchar(125) DEFAULT NULL,
  `zip` varchar(10) DEFAULT NULL,
  `city_id` int DEFAULT NULL,
  `province_id` int DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(125) DEFAULT NULL,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  `active` enum('y','n') DEFAULT 'n',
  `pending` enum('y','n') DEFAULT 'y',
  `coming_soon` enum('y','n') DEFAULT 'n' COMMENT 'if present it will show some sort of coming soon page',
  `vacation` enum('y','n') DEFAULT 'n',
  `vacation_start` date DEFAULT NULL,
  `vacation_stop` date DEFAULT NULL,
  `suspend_ordering` enum('y','n') DEFAULT 'n',
  `suspend_ordering_start` timestamp NULL DEFAULT NULL,
  `suspend_ordering_stop` timestamp NULL DEFAULT NULL,
  `restaurant_type_id` int DEFAULT NULL COMMENT 'restaurant type - pizza, chineze, etc - get id from global_restaurant_types',
  `slug` varchar(125) NOT NULL,
  `price_range` smallint DEFAULT '1',
  `app_or_printer` enum('app','printer') DEFAULT 'app' COMMENT 'restaurant uses app or printer',
  `contract_fee` varchar(10) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `vendor_id` (`vendor_id`),
  KEY `active` (`active`),
  KEY `pending` (`pending`),
  KEY `slug` (`slug`(10))
) ENGINE=InnoDB AUTO_INCREMENT=1679 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_about`
--

DROP TABLE IF EXISTS `restaurants_about`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_about` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `text` json DEFAULT NULL,
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurants_about_restaurant_id_uindex` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=186 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_accounting_fees`
--

DROP TABLE IF EXISTS `restaurants_accounting_fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_accounting_fees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `cc_percent` decimal(4,2) DEFAULT NULL,
  `cc_fixed` decimal(4,2) DEFAULT NULL,
  `interac_percent` decimal(4,2) DEFAULT NULL,
  `interac_fixed` decimal(4,2) DEFAULT NULL,
  `amex_percent` decimal(4,2) DEFAULT '3.50',
  `amex_fixed` decimal(4,2) DEFAULT '0.30',
  `start_on` date DEFAULT NULL,
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=latin1 COMMENT='null added_by means was added by system when restaurant was created';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_announcements`
--

DROP TABLE IF EXISTS `restaurants_announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_announcements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `start` datetime DEFAULT NULL,
  `stop` datetime DEFAULT NULL,
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` datetime DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_charges`
--

DROP TABLE IF EXISTS `restaurants_charges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_charges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `value` float DEFAULT NULL,
  `is_taxable` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT 'y',
  `remove_from_report` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT 'n',
  `type` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `charge` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `repeat` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT 'n',
  `apply_on` date DEFAULT NULL,
  `repeatInterval` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `start` date DEFAULT NULL,
  `stop` date DEFAULT NULL,
  `last_used` datetime DEFAULT NULL,
  `desc` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin,
  `enabled` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'y',
  `added_by` tinyint unsigned DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` tinyint unsigned DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_citations`
--

DROP TABLE IF EXISTS `restaurants_citations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_citations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
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
  UNIQUE KEY `restaurant` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=154 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_citations_listings`
--

DROP TABLE IF EXISTS `restaurants_citations_listings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_citations_listings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `c_name` smallint DEFAULT NULL,
  `creation_date` date DEFAULT NULL,
  `listing_link` varchar(125) DEFAULT NULL,
  `notes` text,
  `enabled` enum('y','n') DEFAULT 'n',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=399 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_combo_groups`
--

DROP TABLE IF EXISTS `restaurants_combo_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_combo_groups` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `language_id` tinyint DEFAULT '1',
  `group_name` varchar(125) DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT NULL,
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=262 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_combo_groups_items`
--

DROP TABLE IF EXISTS `restaurants_combo_groups_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_combo_groups_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_id` int DEFAULT NULL,
  `item_count` tinyint DEFAULT NULL,
  `dish_title` json DEFAULT NULL,
  `has` json DEFAULT NULL,
  `header` json DEFAULT NULL,
  `min` json DEFAULT NULL,
  `max` json DEFAULT NULL,
  `free` json DEFAULT NULL,
  `do` json DEFAULT NULL COMMENT 'display order',
  `use` json DEFAULT NULL COMMENT 'use only these item types in combo',
  `use_price` json DEFAULT NULL,
  `dish_count` tinyint DEFAULT '1',
  `dishes` json DEFAULT NULL COMMENT 'dishes to choose from, if any',
  `pizza_icons` json DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `added_by` smallint DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `disabled_by` smallint DEFAULT NULL,
  `disabled_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `table_name_id_uindex` (`id`),
  KEY `group_id_fk` (`group_id`),
  CONSTRAINT `group_id_fk` FOREIGN KEY (`group_id`) REFERENCES `restaurants_combo_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=252 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_configs`
--

DROP TABLE IF EXISTS `restaurants_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_configs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `allow_preorders` enum('y','n') DEFAULT 'n',
  `preorders_unit` enum('h') DEFAULT 'h',
  `preorders_time_frame` int DEFAULT NULL,
  `bilingual` enum('y','n') DEFAULT 'n',
  `default_language` tinyint DEFAULT '1' COMMENT 'default language id',
  `takeout` enum('y','n') DEFAULT 'n',
  `takeout_discount` enum('y','n') DEFAULT 'n',
  `takeout_discount_selffire` enum('y','n') DEFAULT 'n',
  `takeout_remove_food_value` float DEFAULT NULL COMMENT 'min food value to apply discount',
  `takeout_remove_type` enum('v','p') DEFAULT NULL COMMENT 'remove type from takeout - value or percent',
  `takeout_remove` float DEFAULT NULL COMMENT 'remove these percents when food value is greater than takeout_remove_value',
  `takeout_remove_value` float DEFAULT NULL,
  `takeout_remove_percent` float DEFAULT NULL,
  `takeout_time` int DEFAULT NULL,
  `delivery` enum('y','n') DEFAULT 'n',
  `min_delivery` float DEFAULT '0',
  `delivery_time` int DEFAULT NULL,
  `alerts_mail` varchar(255) DEFAULT NULL,
  `check_pings` enum('y','n') DEFAULT 'n',
  `suspend_when_no_ping` enum('y','n') DEFAULT 'n',
  `favicon` varchar(125) DEFAULT NULL,
  `showInCallcenter` enum('y','n') DEFAULT 'n',
  `sendEmailToDeliveryCompany` enum('y','n') DEFAULT 'n',
  `deliveryCompanyEmail` varchar(125) DEFAULT NULL,
  `showFeedbackLink` enum('y','n') DEFAULT 'n',
  `google_analytics_code` varchar(50) DEFAULT NULL,
  `custom_meta` blob,
  `takeout_tip` enum('y','n') DEFAULT 'n',
  `scheduleSettings` json NOT NULL,
  `template` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=182 DEFAULT CHARSET=latin1 COMMENT='restaurant configuration options';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_contacts`
--

DROP TABLE IF EXISTS `restaurants_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_contacts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `name` varchar(125) DEFAULT NULL,
  `email` varchar(125) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `message` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb3 COMMENT='restaurant contact forms are saved here';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_courses`
--

DROP TABLE IF EXISTS `restaurants_courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_courses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `language_id` tinyint DEFAULT '1',
  `global_course_id` int DEFAULT NULL,
  `name` varchar(125) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT NULL,
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin,
  `display_order` tinyint DEFAULT NULL,
  `available_for` json DEFAULT NULL,
  `time_period` int DEFAULT NULL,
  `enabled` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1348 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_cuisine`
--

DROP TABLE IF EXISTS `restaurants_cuisine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_cuisine` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` smallint unsigned DEFAULT NULL,
  `cuisine_id` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3749 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_deals`
--

DROP TABLE IF EXISTS `restaurants_deals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_deals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `type` enum('r','a') DEFAULT NULL COMMENT 'r - restaurant, a - aggregator',
  `repeatable` enum('y','n') DEFAULT 'n' COMMENT 'can deal be taken multiple times',
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `days` json DEFAULT NULL,
  `date_start` date DEFAULT NULL,
  `date_stop` date DEFAULT NULL,
  `time_start` time DEFAULT NULL,
  `time_stop` time DEFAULT NULL,
  `deal_type` varchar(25) DEFAULT NULL,
  `remove` float DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `times` tinyint DEFAULT NULL,
  `item` json DEFAULT NULL,
  `item_buy` json DEFAULT NULL COMMENT 'items to buy to qualify for the deal',
  `item_count_buy` tinyint DEFAULT NULL COMMENT 'how many items are needed to buy in order to qualify for deal',
  `item_count` tinyint DEFAULT NULL,
  `image` varchar(45) DEFAULT NULL,
  `promo_code` varchar(125) DEFAULT NULL,
  `customize` enum('y','n') DEFAULT 'n',
  `dates` json DEFAULT NULL,
  `extempted_courses` json DEFAULT NULL,
  `available` json DEFAULT NULL COMMENT 'when deal is available - takeout, delivery',
  `split_deal` enum('y','n') DEFAULT 'n',
  `first_order` enum('y','n') DEFAULT 'n' COMMENT 'coupon / deal available on first order only',
  `mailCoupon` enum('y','n') DEFAULT 'n' COMMENT 'send this coupon to accept order email',
  `mailBody` text,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_deals_splits`
--

DROP TABLE IF EXISTS `restaurants_deals_splits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_deals_splits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `deal_id` int DEFAULT NULL,
  `content` json DEFAULT NULL COMMENT 'contains array with split information',
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `deal_id` (`deal_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_delivery_areas`
--

DROP TABLE IF EXISTS `restaurants_delivery_areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_delivery_areas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `area_number` int DEFAULT NULL,
  `area_name` varchar(255) DEFAULT NULL,
  `delivery_fee` text,
  `min_order_value` float(4,2) DEFAULT NULL,
  `is_complex` enum('y','n') DEFAULT 'n',
  `coords` text,
  `geometry` geometry DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_area` (`restaurant_id`,`area_number`)
) ENGINE=MyISAM AUTO_INCREMENT=640 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_delivery_fees`
--

DROP TABLE IF EXISTS `restaurants_delivery_fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_delivery_fees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `distance` tinyint DEFAULT NULL,
  `driver_earning` decimal(5,2) DEFAULT NULL,
  `restaurant_pays` decimal(5,2) DEFAULT NULL,
  `vendor_pays` decimal(5,2) DEFAULT NULL,
  `delivery_fee` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `distance` (`distance`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_delivery_info`
--

DROP TABLE IF EXISTS `restaurants_delivery_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_delivery_info` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `area_or_distances` enum('area','distance') NOT NULL DEFAULT 'area' COMMENT 'use delivery areas or distances to determine if address can be used for delivery',
  `company` varchar(125) DEFAULT NULL,
  `company_restaurant_id` int DEFAULT NULL COMMENT 'if restaurant has a certain id, given by delivery company\n',
  `can_suspend_delivery` enum('y','n') DEFAULT 'y' COMMENT 'can delivery de suspended by delivery company',
  `suspend_delivery_until` datetime DEFAULT NULL,
  `delivery_suspended` enum('y','n') DEFAULT 'n',
  `email_delivery_company` enum('y','n') DEFAULT 'n',
  `email_address` varchar(255) DEFAULT NULL,
  `other_data` json DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'n',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_delivery_schedule`
--

DROP TABLE IF EXISTS `restaurants_delivery_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_delivery_schedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `day` char(3) DEFAULT NULL,
  `start` time DEFAULT NULL,
  `stop` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_day` (`restaurant_id`,`day`)
) ENGINE=InnoDB AUTO_INCREMENT=232 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_disable_delivery`
--

DROP TABLE IF EXISTS `restaurants_disable_delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_disable_delivery` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `start` datetime DEFAULT NULL,
  `stop` datetime DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb3;
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

--
-- Table structure for table `restaurants_domain`
--

DROP TABLE IF EXISTS `restaurants_domain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_domain` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `domain` varchar(125) DEFAULT NULL,
  `type` enum('main','other','mobile') DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=210 DEFAULT CHARSET=latin1 COMMENT='this is where the domains a restaurant belongs to go (eg pizzalime)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_feedback`
--

DROP TABLE IF EXISTS `restaurants_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_feedback` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant_id` int unsigned NOT NULL,
  `nicety` text NOT NULL,
  `badty` text NOT NULL,
  `sampleReview` text NOT NULL,
  `google` varchar(255) NOT NULL,
  `urbanspoon` varchar(255) NOT NULL,
  `tripadvisor` varchar(255) NOT NULL,
  `restaurantica` varchar(255) NOT NULL,
  `sendmailto` varchar(255) NOT NULL DEFAULT 'stefan@menu.ca',
  `followup` enum('y','n') NOT NULL DEFAULT 'n',
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_fees`
--

DROP TABLE IF EXISTS `restaurants_fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_fees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `convenienceFee` enum('y','n') DEFAULT 'n',
  `convenienceFeeValue` decimal(4,2) DEFAULT '0.00',
  `serviceFee` enum('y','n') DEFAULT 'n',
  `serviceFeeValue` decimal(4,2) DEFAULT '0.00',
  `commission` enum('y','n') DEFAULT 'n',
  `commissionValue` decimal(4,2) DEFAULT '0.00',
  `commissionFrom` enum('g','n') DEFAULT NULL,
  `pay_at_door_fee` enum('y','n') DEFAULT 'n',
  `pay_at_door_fee_value` decimal(4,0) DEFAULT '0',
  `pay_at_door_fee_apply_to` varchar(255) DEFAULT NULL,
  `delivery_service_accounting` enum('y','n') DEFAULT 'n',
  `vendor_commission_extra` decimal(4,2) DEFAULT '0.00',
  `contractFee` decimal(4,0) DEFAULT '0',
  `contract_fee_type` enum('fixed','percent') DEFAULT 'percent',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=148 DEFAULT CHARSET=latin1 COMMENT='fees to be applied to order or accounting';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_ingredient_groups`
--

DROP TABLE IF EXISTS `restaurants_ingredient_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_ingredient_groups` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `language_id` tinyint DEFAULT '1',
  `group_name` varchar(125) DEFAULT NULL,
  `group_type` varchar(45) DEFAULT NULL,
  `items` blob,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=650 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_ingredient_groups_items`
--

DROP TABLE IF EXISTS `restaurants_ingredient_groups_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_ingredient_groups_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_id` int DEFAULT NULL,
  `item_hash` varchar(10) NOT NULL,
  `price` varchar(125) DEFAULT NULL,
  `price_j` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `group_id` FOREIGN KEY (`group_id`) REFERENCES `restaurants_ingredient_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4108 DEFAULT CHARSET=utf8mb3 COMMENT='put ids for items belonging to a group';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_ingredients`
--

DROP TABLE IF EXISTS `restaurants_ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_ingredients` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `hash` varchar(10) DEFAULT NULL,
  `restaurant_id` int unsigned DEFAULT NULL,
  `global_ingredient_id` int unsigned DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `language_id` tinyint NOT NULL DEFAULT '1',
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` smallint unsigned DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  `unavailable_until` timestamp NULL DEFAULT NULL,
  `unavailabled_by` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lang` (`language_id`),
  KEY `type` (`type`),
  KEY `restaurant_type` (`restaurant_id`),
  KEY `hash` (`hash`)
) ENGINE=InnoDB AUTO_INCREMENT=4041 DEFAULT CHARSET=latin1 COMMENT='	`unavailable_until` TIMESTAMP NULL DEFAULT NULL,\r\n	`unavailabled_by` SMALLINT(5) UNSIGNED NULL DEFAULT NULL,';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_landing`
--

DROP TABLE IF EXISTS `restaurants_landing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_landing` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `options` json DEFAULT NULL,
  `headerContent` json DEFAULT NULL,
  `footerContent` json DEFAULT NULL,
  `template` tinyint unsigned DEFAULT '1',
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=395 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_mail_templates`
--

DROP TABLE IF EXISTS `restaurants_mail_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_mail_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `language_id` int DEFAULT NULL,
  `password_recover` text,
  `registration_confirmation` text,
  `order_mail` text,
  `feedback_followup_mail` text,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=315 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_messages`
--

DROP TABLE IF EXISTS `restaurants_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `language_id` int DEFAULT NULL,
  `message` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin,
  `available_from` date DEFAULT NULL,
  `available_until` date DEFAULT NULL,
  `enabled` enum('y','n') CHARACTER SET utf8mb3 COLLATE utf8mb3_bin DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` datetime DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_owner_info`
--

DROP TABLE IF EXISTS `restaurants_owner_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_owner_info` (
  `id` int NOT NULL,
  `restaurant_id` int NOT NULL,
  `fname` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `lname` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `email` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `password` varchar(40) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `send_statement` enum('y','n') DEFAULT 'n',
  `last_login` timestamp NULL DEFAULT NULL,
  `login_count` smallint DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_payment_options`
--

DROP TABLE IF EXISTS `restaurants_payment_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_payment_options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `payment_option_id` int DEFAULT NULL,
  `language_id` smallint DEFAULT NULL,
  `overwrite_default` varchar(125) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=64119 DEFAULT CHARSET=latin1 COMMENT='store what payment methods restaurant offers\n1-cash, 2-cc, 3-interac, 4-credit or debit at door, 904-credit at door, 905-debit at door';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_printers`
--

DROP TABLE IF EXISTS `restaurants_printers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_printers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `printer_serial` varchar(125) DEFAULT NULL,
  `sim_serial` varchar(125) DEFAULT NULL,
  `activation_date` date DEFAULT NULL,
  `map_to_restaurant` varchar(255) DEFAULT NULL,
  `gprs_start` time DEFAULT NULL,
  `gprs_stop` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=155 DEFAULT CHARSET=latin1 COMMENT='put information about printer here';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_reviews`
--

DROP TABLE IF EXISTS `restaurants_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `temperature` decimal(2,1) DEFAULT '1.0',
  `delivery_time` decimal(2,1) DEFAULT NULL,
  `food_quality` decimal(2,1) DEFAULT NULL,
  `value_cost` decimal(2,1) DEFAULT NULL,
  `service` decimal(2,1) DEFAULT NULL,
  `overall` decimal(2,1) NOT NULL,
  `content` varchar(255) DEFAULT NULL,
  `added_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `approved` enum('y','n') DEFAULT 'n',
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_schedule`
--

DROP TABLE IF EXISTS `restaurants_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_schedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT '1',
  `day_start` smallint NOT NULL,
  `time_start` time DEFAULT NULL,
  `day_stop` smallint NOT NULL,
  `time_stop` time DEFAULT NULL,
  `type` enum('d','t') CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'Delivery, Takeout',
  `enabled` enum('y','n') CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT 'y',
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `enabled` (`enabled`)
) ENGINE=InnoDB AUTO_INCREMENT=2502 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_seo`
--

DROP TABLE IF EXISTS `restaurants_seo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_seo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `data` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurants_seo_unique` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_special_schedule`
--

DROP TABLE IF EXISTS `restaurants_special_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_special_schedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `date_start` timestamp NULL DEFAULT NULL,
  `date_stop` timestamp NULL DEFAULT NULL,
  `schedule_type` enum('c','o') DEFAULT 'c' COMMENT 'Closed / Open - default closed',
  `reason` enum('bad_weather','vacation','') DEFAULT '',
  `apply_to` enum('t','d') DEFAULT 't' COMMENT 'apply this schedule to Takeout or Delivery',
  `enabled` enum('y','n') CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=134 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_statements`
--

DROP TABLE IF EXISTS `restaurants_statements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_statements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` smallint unsigned NOT NULL,
  `statement_number` smallint unsigned NOT NULL DEFAULT '1',
  `start` date NOT NULL,
  `stop` date NOT NULL,
  `issued_on` date NOT NULL,
  `path_to_file` varchar(125) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_tags`
--

DROP TABLE IF EXISTS `restaurants_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_tags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` smallint unsigned DEFAULT NULL,
  `tag_id` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3782 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_takeout_radius`
--

DROP TABLE IF EXISTS `restaurants_takeout_radius`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_takeout_radius` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `radius` decimal(10,0) DEFAULT NULL,
  `action` varchar(45) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT NULL,
  `enable_check_area` enum('y','n') DEFAULT 'n' COMMENT 'weather to check delivery areas or not',
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `updated_by` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `restaurants_time_periods`
--

DROP TABLE IF EXISTS `restaurants_time_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants_time_periods` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `start` time DEFAULT NULL,
  `stop` time DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_users`
--

DROP TABLE IF EXISTS `site_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `active` enum('y','n') CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT 'y',
  `fname` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `lname` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `email` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `password` varchar(125) NOT NULL,
  `language_id` tinyint DEFAULT '1',
  `gender` varchar(6) DEFAULT NULL,
  `locale` varchar(6) DEFAULT NULL,
  `oauth_provider` varchar(125) DEFAULT NULL,
  `oauth_uid` varchar(125) DEFAULT NULL,
  `picture_url` varchar(255) DEFAULT NULL,
  `profile_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `newsletter` enum('y','n') CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT 'y',
  `sms` enum('y','n') DEFAULT 'n',
  `origin_restaurant` smallint NOT NULL,
  `last_login` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `origin_restaurant` (`origin_restaurant`)
) ENGINE=InnoDB AUTO_INCREMENT=9320 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_users_autologins`
--

DROP TABLE IF EXISTS `site_users_autologins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_users_autologins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_login` varchar(125) DEFAULT NULL,
  `selector` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `expire` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_login` (`user_login`)
) ENGINE=InnoDB AUTO_INCREMENT=1715 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_users_delivery_addresses`
--

DROP TABLE IF EXISTS `site_users_delivery_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_users_delivery_addresses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `active` enum('y','n') DEFAULT 'y',
  `place_id` varchar(255) DEFAULT NULL,
  `user_id` int NOT NULL COMMENT 'site_user_id',
  `lat` decimal(20,17) DEFAULT NULL,
  `lng` decimal(20,17) DEFAULT NULL,
  `street` varchar(125) DEFAULT NULL,
  `apartment` varchar(15) DEFAULT NULL,
  `zip` varchar(7) DEFAULT NULL,
  `ringer` varchar(45) DEFAULT NULL,
  `extension` varchar(6) DEFAULT NULL,
  `special_instructions` varchar(255) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL COMMENT 'locality',
  `province` varchar(50) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `missingData` enum('y','n') DEFAULT 'y' COMMENT 'defaults to yes, until user edits the missing info - zip, apartment, etc',
  PRIMARY KEY (`id`,`user_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13962 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_users_favorite_restaurants`
--

DROP TABLE IF EXISTS `site_users_favorite_restaurants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_users_favorite_restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `removed_at` datetime DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_restaurant` (`user_id`,`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `site_users_fb`
--

DROP TABLE IF EXISTS `site_users_fb`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_users_fb` (
  `id` int NOT NULL AUTO_INCREMENT,
  `oauth_provider` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `oauth_uid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `first_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `last_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `gender` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `locale` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `picture_url` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `profile_url` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
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
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `date_restaurant` (`date`,`restaurant`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1652 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `statements`
--

DROP TABLE IF EXISTS `statements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `statements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `statement_no` smallint unsigned DEFAULT NULL,
  `issued_at` datetime DEFAULT NULL,
  `file` varchar(125) DEFAULT NULL COMMENT 'statement file',
  `start` date DEFAULT NULL,
  `stop` date DEFAULT NULL,
  `cc` json DEFAULT NULL,
  `cash` json DEFAULT NULL,
  `interac` json DEFAULT NULL,
  `total_orders` json DEFAULT NULL,
  `all_info` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_start_stop` (`restaurant_id`,`start`,`stop`)
) ENGINE=InnoDB AUTO_INCREMENT=1904 DEFAULT CHARSET=utf8mb3;
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
) ENGINE=InnoDB AUTO_INCREMENT=5190 DEFAULT CHARSET=utf8mb3;
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
  `card_type` varchar(125) DEFAULT NULL,
  `intent_id` varchar(125) DEFAULT NULL,
  `intent` text NOT NULL,
  `client` varchar(125) DEFAULT NULL,
  `captured` enum('y','n') DEFAULT 'n',
  `is_refund` enum('y','n') DEFAULT 'n',
  `last_4` varchar(4) DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  `modified_at` datetime DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9271 DEFAULT CHARSET=latin1;
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
  `reject_reason` tinytext,
  `time_created` int unsigned NOT NULL DEFAULT '0',
  `time_modified` int unsigned NOT NULL DEFAULT '0',
  `time_accepted` int unsigned NOT NULL DEFAULT '0',
  `time_ack` int unsigned NOT NULL DEFAULT '0',
  `time_rejected` int unsigned NOT NULL DEFAULT '0',
  `time_done` int unsigned NOT NULL DEFAULT '0',
  `deleted` tinyint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `by_resto_order` (`restaurant`,`order`)
) ENGINE=InnoDB AUTO_INCREMENT=1545010 DEFAULT CHARSET=utf8mb3;
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
  `last_boot` int unsigned NOT NULL DEFAULT '0',
  `last_check` int NOT NULL DEFAULT '0',
  `fw_ver` tinyint unsigned NOT NULL DEFAULT '0',
  `sw_ver` tinyint unsigned NOT NULL DEFAULT '0',
  `desynced` tinyint unsigned NOT NULL DEFAULT '0',
  `created_at` int unsigned NOT NULL DEFAULT '0',
  `modified_at` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `by_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb3;
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
  `order` smallint unsigned DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `twilio`
--

DROP TABLE IF EXISTS `twilio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `twilio` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `enable_call` enum('y','n') DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_invoices`
--

DROP TABLE IF EXISTS `vendor_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vendor_id` int DEFAULT NULL,
  `file` varchar(125) DEFAULT NULL,
  `invoice_date` date DEFAULT NULL,
  `type` varchar(50) NOT NULL,
  `number` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_reports`
--

DROP TABLE IF EXISTS `vendor_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int DEFAULT NULL,
  `result` json DEFAULT NULL,
  `vendor_id` int DEFAULT NULL,
  `statement_no` tinyint unsigned DEFAULT '1',
  `start` date DEFAULT NULL,
  `stop` date DEFAULT NULL,
  `date_added` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=494 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='store vendor reports data';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_reports_numbers`
--

DROP TABLE IF EXISTS `vendor_reports_numbers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_reports_numbers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `statement_no` tinyint unsigned DEFAULT '1',
  `vendor_id` int DEFAULT NULL,
  `file` varchar(125) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_file` (`vendor_id`,`file`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='statement number is being stored here';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_sites`
--

DROP TABLE IF EXISTS `vendor_sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_sites` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vendor_id` int DEFAULT NULL,
  `active` enum('y','n') DEFAULT NULL,
  `site name` varchar(45) DEFAULT NULL,
  `site_address` varchar(45) DEFAULT NULL,
  `added_by` int DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT NULL,
  `disabled_by` int DEFAULT NULL,
  `disabled_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='like matt is with menuottawa';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_splits`
--

DROP TABLE IF EXISTS `vendor_splits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_splits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `template_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `restaurant_id` (`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendor_splits_templates`
--

DROP TABLE IF EXISTS `vendor_splits_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendor_splits_templates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(125) DEFAULT NULL,
  `commission_from` char(15) DEFAULT NULL,
  `menuottawa_share` decimal(5,2) DEFAULT NULL,
  `breakdown` text,
  `return_info` text,
  `file` varchar(125) DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `added_by` int DEFAULT NULL,
  `added_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vendors`
--

DROP TABLE IF EXISTS `vendors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `address` varchar(125) DEFAULT NULL,
  `phone` varchar(45) DEFAULT NULL,
  `logo` varchar(45) DEFAULT NULL,
  `website` varchar(45) DEFAULT NULL,
  `orders_fee` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-18 10:50:56
