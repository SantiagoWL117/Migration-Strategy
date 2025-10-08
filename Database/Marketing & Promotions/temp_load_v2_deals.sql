-- Temporarily extract just first 5 rows as a test
-- Then we'll load the full dataset

-- Test load (5 rows)
INSERT INTO staging.v2_restaurants_deals VALUES
(1,1,'r','n','deal 1','deal 1 desc','["wed", "fri", "sun"]','2017-05-01','2017-05-07','11:00:00','15:15:00','1',1,2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n','["2017-06-21,2017-06-19"]',NULL,'["t"]','y','n','n',NULL,'y',1,'2017-05-01 13:19:09',NULL,NULL),
(3,1,'r','n','deal 2','deal 2 desc','["tue", "thu", "sat", "sun"]','2017-05-07','2017-05-31','13:00:00','17:00:00','6',1,2,0,NULL,NULL,NULL,3,NULL,'','n','["2017-05-05", "2017-05-06", "2017-05-08"]','["102", "126", "127"]','["t", "d"]','y','n','n',NULL,'y',1,'2017-05-01 13:29:05',NULL,NULL),
(5,1,'r','n','deal 3','deal 3 desc','["mon"]',NULL,NULL,NULL,NULL,'5',0,0,0,'["230|4", "125", "126", "122|s", "122|l", "117|m", "117|xl"]',NULL,NULL,NULL,NULL,'','n','[""]',NULL,NULL,'n','n','n',NULL,'y',1,'2017-05-01 13:37:37',NULL,NULL),
(6,1593,'r','n','stefan','123','["mon"]','2017-05-01','2017-05-08',NULL,NULL,'1',2,1,0,NULL,NULL,NULL,NULL,NULL,'','n','[""]',NULL,NULL,'n','n','n',NULL,'n',1,'2017-05-08 17:12:40',NULL,NULL),
(7,1,'r','n','_key_','asdf','["tue", "wed"]',NULL,NULL,NULL,NULL,'7',NULL,0,NULL,'["208"]','["125"]',2,2,NULL,NULL,'n','["2017-06-08"]',NULL,'["t"]','n','n','n',NULL,'y',1,'2017-05-10 13:47:00',NULL,NULL)
ON CONFLICT (id) DO NOTHING;

SELECT COUNT(*) as loaded_count FROM staging.v2_restaurants_deals;
