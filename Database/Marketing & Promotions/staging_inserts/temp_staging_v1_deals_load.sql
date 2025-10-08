-- Load menuca_v1_deals.sql into staging.v1_deals
-- Generated from MySQL dump

INSERT INTO staging.v1_deals VALUES
(19,79,'15% Off Your First Order','ONLINE EXCLUSIVE','percent','15',0,0,0,'a:7:{i:0
ON CONFLICT (id) DO NOTHING;

-- Verification
SELECT COUNT(*) as row_count FROM staging.v1_deals;
