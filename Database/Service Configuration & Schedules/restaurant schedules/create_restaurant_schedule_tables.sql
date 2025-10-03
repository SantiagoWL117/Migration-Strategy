-- Legacy normalization tables for restaurant scheduling data
DROP TABLE IF EXISTS `restaurants_schedule_normalized`;
CREATE TABLE `restaurants_schedule_normalized` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `day_start` smallint NOT NULL,
  `time_start` time DEFAULT NULL,
  `day_stop` smallint NOT NULL,
  `time_stop` time DEFAULT NULL,
  `type` enum('d','t') DEFAULT NULL COMMENT 'd = delivery, t = takeout',
  `enabled` enum('y','n') DEFAULT 'y',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_restaurant_type` (`restaurant_id`,`type`),
  KEY `idx_enabled` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `restaurants_special_schedule`;
CREATE TABLE `restaurants_special_schedule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurant_id` int NOT NULL,
  `special_date` date NOT NULL,
  `time_start` time DEFAULT NULL,
  `time_stop` time DEFAULT NULL,
  `enabled` enum('y','n') DEFAULT 'y',
  `note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_restaurant_date` (`restaurant_id`,`special_date`),
  KEY `idx_enabled_special` (`enabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

