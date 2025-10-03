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
-- Dumping data for table `callcenter_users`
--

LOCK TABLES `callcenter_users` WRITE;
/*!40000 ALTER TABLE `callcenter_users` DISABLE KEYS */;
INSERT INTO `callcenter_users` VALUES (1,'stefan','dragos','stefan@menu.ca','$2y$10$uJGfHBS6sXolFITYAIfNbuCZDL.YG4NiVeuDI.mxRfZZwjithUcEG','2016-08-18 15:18:10','y',1),(4,'matthieu','blake','mattmenuottawa@gmail.com','$2y$10$IX.wAthm0dmSCQ8qKDLfKOrNlVluki2zBbjkxQWRuvslSIu8XldwO','2016-08-18 19:17:23','y',1),(6,'fname','lname','stefan1@menu.ca','$2y$10$Z7ZMsNiZglJA7W.xr6Im5e/3GiWHjuoiWXjDFRvT2y05rqv1KPiki','2016-08-18 19:45:40','n',0),(7,'Asaad','Alfares','asaadalfares@1for1pizza.com','$2y$10$GbKDZumZOI6GqzSkMR4PoexmiKTiuJ6vjdtRWxUa1J85kLIKT0IUe','2016-08-19 14:11:05','y',1),(8,'chris','Bouziotas','chris@menu.ca','$2y$10$1C0h24RTyJoBFjs2MtOU/u6uHo.uWrNGrtQI1QhsVC42qgV/hQ55K','2016-08-19 14:35:32','y',1),(9,'alexandra','nicolae','alexandra@menu.ca','$2y$10$8YFnJFy63I01/CQxA/ePzOdfdXMgGYtakKr2xMoY30/S18LaXeqDG','2017-09-29 15:49:35','y',0),(10,'Wandy','Simeon','wandy.simeon@hotmail.com','$2y$10$fvVaZxUWox917sdX/D.TyO5RDrlCmzoBU8G3a5xi/zOkGEBGWWky.','2018-01-18 21:31:51','n',0),(11,'Michael','Gordon','Michael_s_gordon@outlook.com','$2y$10$hkdcK18ihIE5hH9EmdtmNeOJbnCVPt03p9Mp0bz6HGek6BJ5Nx3n2','2018-01-18 22:55:04','n',0),(12,'Vero','Jean','vero_jean11@hotmail.com','$2y$10$IEy63Fc7h6gVNEPtrwpEseJ6z/uokBd1aTJcvV7AOIa8mjy0SA2BC','2018-01-18 22:56:08','n',0),(13,'Joseph','Souliere','josephsouliere@outlook.com','$2y$10$zlAafSg8Zv8CxeBeGR1imO9PMPYUbvSZntlcERPYbLsld.kDov3hO','2018-01-18 23:01:13','y',0),(14,'Mary-Eve','Gustave','mary2_g@hotmail.com','$2y$10$w3AIgK/e0.UaLcdoQvZ1V.F5Qj6jrNSo2RHVG9sTAa.nDvh9xtlpq','2018-01-18 23:02:04','y',0),(15,'Jacques','Larabie','jacques.larabie@gmail.com','$2y$10$uI7H/Vmk5WGJhB/EZzFQKOgFP/2kIxJNrsWbRp5K5hvHJgBhl.dne','2018-01-18 23:02:42','y',0),(16,'Alexandria','Van Den','alexandriavdh@gmail.com','$2y$10$TW.18w0cPLwfxorJsgO3F.REe6Dh10eMfgO8.sAyt6gqY3bAI6ctG','2018-01-18 23:03:11','n',0),(17,'Mouhamed','Diyouf','mdiou071@uottawa.ca','$2y$10$23s4S3rh3lWS3RZ/ftLgH.XF4sZljqvvpDTtuC9RTDMTVdei2y4QW','2018-01-18 23:14:31','y',0),(18,'Christine','Larabie`','christinelarabie@hotmail.com','$2y$10$U7fBdbrFoOe1Rt2BLCGe2uvN52ut4vgOHoFgySHN1dSgXpsWF19mS','2018-01-18 23:14:55','n',0),(19,'Aras','Tahir','arastahir@1for1pizza.com','$2y$10$J1AaPt3sI.7fsqvMVWQ.Ru5O0ImFUC.whz1RV3lCbHwJCxf7SX0Va','2018-01-18 23:15:27','y',0),(20,'Patrice','Pare','patrice_pare@hotmail.com','$2y$10$xwAl3gp0ewgl8/GNmAEmjufjZkiJeh8W4AwOdxAnrfQDzOLw/ZuLe','2018-01-18 23:16:07','n',0),(21,'Nadezhda','Colova','nadia.colova@gmail.com','$2y$10$PsYduwY2.HVsqM63eblj6u/VVS02MyBQvQxId40QFu8IP7qboesb6','2018-03-29 00:33:14','n',0),(22,'Nicole','Leduc','nicoleleduc1@aol.com','$2y$10$yrb4s6lxwsCfCiRKOJwFcuQrwtMyI9arBcbu0Mu5HCg9CJ4ITIIDa','2018-06-06 22:28:08','n',0),(23,'martin','boisvert','beermanplus@hotmail.com','$2y$10$vv.QkeXA13L/rsocJUOMWOQUih.eBqJgPlPObb71rUCWo9ddwm2b.','2018-08-09 17:21:28','n',0),(24,'Tristan','Legros','tolegros90@gmail.com','$2y$10$eZuWmUt.qQPSZguiAd31W.FgatSO9xOj6m25gGCzQ3/z4W2Y2bzq6','2018-08-24 00:40:05','n',0),(25,'Valery','jacques','vjacques09@gmail.com','$2y$10$cR9vsK8mpVRJfR.fAzTwUeMUanQsJZ/mcnw/GCGfhta/1yGLCTq12','2018-08-29 19:04:35','n',0),(26,'Valery','Jacques','vjacques06@gmail.com','$2y$10$nDy9IjDKa0HbCBmhye8zKuJeEl3hRZnC.nBT7pXfQy0aVrBXxmIs6','2018-08-29 19:06:13','n',0),(27,'Nadia','Alioui','nadiaalioui36@gmail.com','$2y$10$b34BBGzyWjN4qjfD3NJYvudT2gmQfXLEexR2JsZd.G0tzb9fJBPe.','2018-09-26 21:54:15','n',0),(28,'Megan','Robertson','ann-meg28@hotmail.com','$2y$10$tUdX7ulbdvZkA.X79UCUa.hs5O7x8KS4DNL2pA0BSWS23/PLpcHQO','2018-09-27 19:05:23','y',0),(29,'Adam','Norton','acn.adamnorton@gmail.com','$2y$10$..4OONuoQXSBq2xfKojDcOqejbqD5iJ//W2yNUAAbeiQ0LUR3pSt6','2018-10-05 21:26:54','n',0),(30,'David','La Rose','larosedavid1@gmail.com','$2y$10$6f8mVM9tqqmTi8raa4rfr.SuJPBcCalQmqaGhRGHyzjNRDMYhooUC','2019-01-10 23:34:24','n',0),(31,'Jessica','Omicil','jessica.omicil@gmail.com','$2y$10$AY6IfSK7Od55f6ZKHpouquF0alz5MPUYyxXxparxoV/NyBc4Mah3u','2019-02-23 01:43:51','n',0),(32,'Mathieu','Lemieux','mattlemieux61@gmail.com','$2y$10$AFbw7/DKMMf401ZWUKvfiOvmV6XMrEHiLDArjk.ASqpplFhxztvxK','2019-02-28 00:52:57','y',0),(33,'Marjorie','Toussaint','marjorietoussaint@hotmail.com','$2y$10$cVB1AzU5JP3hWi.FyVaUYOSqrQrieE1X8xeunDHF./bypqJoyooX2','2019-04-25 15:51:39','n',0),(34,'Yvonne','Couvillon','yvonne.couvillon@gmail.com','$2y$10$gymPGRDiMHH5pVy4zSmbwe5muPxbfup6u50Ndf6f12IWY5dTRUX62','2019-05-09 23:01:22','n',0),(35,'Kawter','Benmessoud','kawter-ben@hotmail.com','$2y$10$SdkDo/SQL/.CU/pVLhK96e4RJJWj0PxdtdrpSoA9J3pKWG.z/tkgW','2019-06-06 21:39:04','n',0),(36,'Yedidia','Pierre-Louis','y.e.pieerelouis@gmail.com','$2y$10$f2wpxUN.MXPwST9KcTOjN.jy//lnMc3g0Yo/9HSC3dFvhE6AX4DTy','2019-06-06 21:41:17','y',0),(37,'Kawter','Benmessoud','kawter_ben@hotmail.com','$2y$10$4Ris3HMDzwpoFV3I9pC11.W01MkjBXpFWCUI82kCJWta3I/2gE6VS','2019-06-06 23:17:29','n',0),(38,'Louise','Charbonneau','lmc.charbonneau@gmail.com','$2y$10$I30YgXjpKaiysdTBsLfGEeWW2IW1yX2HP2jiAEFRgMRPjy53XaFyO','2019-09-19 20:32:07','y',0),(39,'Francios','Sauve','francios.sauve@gmail.com','$2y$10$NG74QUrsQ0y6BYFIH14R8uan.ug5NL6ZJUB8gOTPFujEcIXdExN4.','2019-11-23 01:44:53','n',0),(40,'Francois','Sauve','francois.sauve@gmail.com','$2y$10$Ar99atwoizNb4g5NuVKyLe.PTDTkPhoyDPVI4UP3bx4hMw.wjQOVm','2019-11-23 02:06:11','y',0);
/*!40000 ALTER TABLE `callcenter_users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-03 12:18:55
