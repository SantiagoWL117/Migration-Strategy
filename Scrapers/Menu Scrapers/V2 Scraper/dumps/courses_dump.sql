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
-- Table structure for table `menu_v3_restaurants_courses`
--

DROP TABLE IF EXISTS `menu_v3_restaurants_courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_v3_restaurants_courses` (
  `id` int NOT NULL,
  `restaurant_v2_id` int DEFAULT NULL,
  `name` varchar(125) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_v3_restaurants_courses`
--

LOCK TABLES `menu_v3_restaurants_courses` WRITE;
/*!40000 ALTER TABLE `menu_v3_restaurants_courses` DISABLE KEYS */;
INSERT INTO `menu_v3_restaurants_courses` VALUES (598,1171,'Thai Food'),(599,1171,'Vegetarian'),(600,1171,'Fried Rice'),(601,1171,'Steamed Rice'),(602,1171,'Vermicelli'),(603,1171,'Beef Rice Noodle Soup'),(604,1171,'Stir Fried Rice Noodle'),(605,1171,'Clear & Egg Noodle'),(606,1171,'Appetizers'),(871,1285,'Latest'),(872,1285,'Chef\'s Specialties'),(873,1285,'Nigiri / Sashimi'),(874,1285,'Hosomakis'),(875,1285,'Maki Rice Paper'),(876,1285,'Assorted Plates'),(877,1285,'Futomakis'),(878,1285,'Makis'),(879,1285,'Spring Makis'),(880,1285,'Tartar Makis'),(881,1285,'Salads'),(882,1285,'Miso Soup'),(883,1285,'Sushi Desserts'),(884,1285,'Pokebols'),(885,1285,'Extras'),(886,1285,'Drinks'),(925,1171,'Side Orders (Extra Small)'),(926,1171,'Beverages'),(948,1637,'Subs'),(949,1637,'Chicken Bites Deals'),(950,1637,'Platters, Burgers & Sandwiches'),(951,1637,'Wraps'),(952,1637,'Appetizers'),(953,1637,'Poutine'),(954,1637,'Salads'),(955,1637,'Southern Fried Chicken'),(956,1637,'Wings Deals'),(957,1637,'Pizza'),(958,1637,'Desserts'),(959,1637,'Drinks'),(960,1637,'2 For 1 Pizza Deal'),(961,1637,'Pizza and Wings Deal'),(962,1637,'Specials'),(974,1639,'Appetizers'),(975,1639,'Canadian Food'),(976,1639,'Big Salads'),(977,1639,'Chicken Wings'),(978,1639,'Submarines'),(979,1639,'Donairs'),(980,1639,'Pasta'),(981,1639,'Pizzas'),(982,1639,'Desserts'),(983,1639,'Drinks'),(984,1639,'Specials'),(985,1639,'Twin Pizzas'),(1020,1641,'CHEF\'S SPECIAL - THAI STYLE STREET FOOD'),(1021,1641,'Lunch- Appetizers'),(1022,1641,'Lunch- Soups'),(1023,1641,'Lunch- Rice and Noodle Dishes'),(1024,1641,'Lunch- Curries'),(1025,1641,'Lunch- Stir Fried Dishes'),(1026,1641,'Lunch- Combos'),(1027,1641,'Dinner- Appetizers'),(1028,1641,'Dinner- Soups'),(1029,1641,'Dinner- Noodle Dishes'),(1030,1641,'Dinner- Rice Dishes'),(1031,1641,'Dinner- Salads'),(1032,1641,'Dinner- Curries'),(1033,1641,'Dinner- Stir Fried Dishes'),(1034,1641,'Dinner- Seafood'),(1035,1641,'Dinner- Combos'),(1036,1641,'Extras'),(1037,1641,'Drinks'),(1038,1642,'Entrées'),(1039,1642,'Végétarienne'),(1040,1642,'Non-Végétarienne'),(1041,1642,'Tandoori'),(1042,1642,'Extras'),(1043,1642,'Desserts'),(1044,1642,'Boissons'),(1045,1642,'Biryani'),(1062,1654,'Finger Food'),(1063,1654,'Subs'),(1064,1654,'Sandwiches and Side Items'),(1065,1654,'Pastas'),(1066,1654,'Salads'),(1067,1654,'Pizza'),(1068,1654,'Calzones'),(1069,1654,'Desserts'),(1070,1654,'Drinks'),(1071,1654,'Create Your Own Pizza'),(1100,1657,'Soups and Appetizers'),(1101,1657,'Curry Specialities'),(1102,1657,'Vegetables (Main Dish)'),(1103,1657,'Vegetables (Side Dish)'),(1104,1657,'Tandoori Specialty'),(1105,1657,'Bombay Specialty'),(1106,1657,'Biryanis'),(1107,1657,'Rice'),(1108,1657,'Indian Breads'),(1109,1657,'Sundried and Others'),(1110,1657,'Combos'),(1111,1657,'Soupes et Entrées'),(1112,1657,'Spécialités Cari'),(1113,1657,'Légumes (plats principaux)'),(1114,1657,'Légumes (à-côtés)'),(1115,1657,'Spécialités Tandoori'),(1116,1657,'Spécialités Bombay'),(1117,1657,'Biryanis'),(1118,1657,'Riz'),(1119,1657,'Pains Indiens'),(1120,1657,'Séché au soleil et autres'),(1121,1657,'Combos'),(1122,1658,'Shawarmas'),(1123,1658,'Shawarmas Formats Familiaux'),(1124,1658,'Salades'),(1125,1658,'Les à Cotés'),(1130,1658,'Breuvages'),(1137,1660,'Shawarmas'),(1138,1660,'Shawarmas Formats Familiaux'),(1139,1660,'Les Pizzas Classiques'),(1140,1660,'Les Pizzas Spécialités'),(1141,1660,'Salades'),(1142,1660,'Les Nachos'),(1143,1660,'Club Sandwich'),(1144,1660,'Les à Cotés'),(1146,1660,'Desserts'),(1147,1660,'Breuvages'),(1148,1660,'Spéciaux'),(1149,1661,'Shawarmas'),(1150,1661,'Shawarmas Formats Familiaux'),(1151,1661,'Les Pizzas Classiques'),(1152,1661,'Les Pizzas Spécialités'),(1153,1661,'Salades'),(1154,1661,'Les Nachos'),(1155,1661,'Club Sandwich'),(1156,1661,'Sous-Marins'),(1157,1661,'Les à Cotés'),(1158,1661,'Desserts'),(1159,1661,'Breuvages'),(1160,1662,'Shawarmas'),(1161,1662,'Shawarmas Formats Familiaux'),(1162,1662,'Salades'),(1163,1662,'Les à Cotés'),(1164,1662,'Desserts'),(1165,1662,'Breuvages'),(1166,1663,'Les Pizzas Classiques'),(1167,1663,'Les Pizzas Spécialités'),(1168,1663,'Les Nachos'),(1169,1663,'Club Sandwich'),(1170,1663,'Sous-Marins'),(1171,1663,'Les à Cotés'),(1172,1663,'Desserts'),(1173,1663,'Breuvages'),(1174,1664,'Les Pizzas Classiques'),(1175,1664,'Les Pizzas Spécialités'),(1176,1664,'Les Nachos'),(1177,1664,'Club sandwich'),(1178,1664,'Sous-Marins'),(1179,1664,'Les à Cotés'),(1180,1664,'Desserts'),(1181,1664,'Breuvages'),(1183,1663,'Spéciaux'),(1184,1661,'Spéciaux'),(1185,1664,'Spéciaux'),(1213,1668,'Greek Dinners'),(1214,1668,'Appetizers'),(1215,1668,'Burgers & Classics'),(1216,1668,'Meal Salads'),(1217,1668,'Greek Dips'),(1218,1668,'Pitas'),(1219,1668,'Kids'),(1220,1668,'Sides & Extras'),(1221,1668,'Desserts'),(1222,1668,'Drinks'),(1223,1668,'Family Combos'),(1224,1668,'Deal Of The Day'),(1227,1285,'Nouveautés'),(1228,1285,'Spécialités du Chef'),(1229,1285,'Nigiri - Sashimi'),(1230,1285,'Hosomakis'),(1231,1285,'Maki Feuille de Riz'),(1232,1285,'Soupes'),(1233,1285,'Salades'),(1234,1285,'Sushi Desserts'),(1235,1285,'Futomakis'),(1236,1285,'Makis'),(1237,1285,'Maki de Printemps'),(1238,1285,'Maki de Tartare'),(1239,1285,'Assietes Assorties'),(1240,1285,'Pokebols'),(1241,1285,'Breuvages'),(1254,1670,'Appetizers'),(1255,1670,'Salads'),(1256,1670,'Poutine'),(1257,1670,'Donairs'),(1258,1670,'Seafood'),(1259,1670,'Italian Dishes'),(1260,1670,'Platters'),(1261,1670,'Subs'),(1262,1670,'Pizza'),(1263,1671,'Pizza'),(1264,1671,'Appetizers'),(1265,1671,'Salads'),(1266,1671,'Platters'),(1267,1671,'Subs'),(1268,1671,'Poutine'),(1269,1671,'Kabab Platters'),(1270,1671,'Kabab Sandwiches on Charcoal'),(1271,1671,'Middle Eastern Pies'),(1272,1671,'Drinks'),(1273,1671,'Deals'),(1274,1670,'2 For 1 Pizza Deals'),(1275,1670,'Pizza Combo Deals'),(1276,1670,'Drinks'),(1277,1670,'2 For 1 Wings'),(1278,1673,'Pizza'),(1279,1673,'Subs'),(1280,1673,'Italian Food'),(1281,1673,'Canadian Food'),(1282,1673,'Salads'),(1283,1673,'Specials'),(1284,1673,'Drinks'),(1285,1673,'Mets Canadiens'),(1286,1673,'Mets Italiens'),(1287,1673,'Sous Marins'),(1288,1673,'Pizza'),(1289,1673,'Salades'),(1290,1673,'Boissons'),(1291,1673,'Spéciaux'),(1292,1637,'Daily Specials'),(1293,1674,'Appetizers'),(1294,1674,'Salads'),(1295,1674,'Kids Menu'),(1296,1674,'Desserts'),(1297,1674,'Drinks'),(1298,1674,'Specialty Pizza'),(1299,1674,'Gourmet Pizza'),(1300,1674,'Make Your Pizza'),(1301,1674,'Dipping Sauces'),(1302,1674,'Specials'),(1317,1663,'Pasta'),(1318,1661,'Mets Italiens'),(1319,1654,'Burgers'),(1320,1671,'Kebab Combos'),(1322,1642,'Combo'),(1323,1674,'Halal Menu'),(1325,1663,'Special des Series'),(1326,1661,'Special des Series'),(1327,1660,'Special des Series'),(1328,1664,'Special des Series'),(1340,1668,'Lunch Special'),(1341,1678,'Fries'),(1342,1678,'Burgers'),(1343,1678,'Drinks'),(1344,1678,'Sundae'),(1345,1678,'Icecream'),(1346,1678,'Milkshake'),(1347,1670,'Walk In');
/*!40000 ALTER TABLE `menu_v3_restaurants_courses` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-02 13:25:50
