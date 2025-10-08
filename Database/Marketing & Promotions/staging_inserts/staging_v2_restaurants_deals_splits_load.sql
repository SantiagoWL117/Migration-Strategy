-- Load menuca_v2_restaurants_deals_splits.sql into staging.v2_restaurants_deals_splits
-- Generated from MySQL dump

INSERT INTO staging.v2_restaurants_deals_splits VALUES
(2,3,'[{"from": "-1", "value": "13"}, {"from": "r", "value": "77"}, {"from": "v - 38", "value": "10"}, {"from": "r", "value": "1"}, {"from": "-1", "value": ""}, {"from": "-1", "value": ""}, {"from": "-1", "value": ""}, {"from": "-1", "value": ""}]','y',1,'2017-05-03 17:42:23',1,'2017-06-09 12:41:11',NULL,NULL)
ON CONFLICT (id) DO NOTHING;

-- Verification
SELECT COUNT(*) as row_count FROM staging.v2_restaurants_deals_splits;
