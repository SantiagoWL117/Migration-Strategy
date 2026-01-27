-- Fix English translations from French
-- Date: 2026-01-27

-- Fix name_en for ID 172
UPDATE menuca_v3.promotional_coupons
SET name_en = '$5 off Amicci'
WHERE id = 172;

-- Fix description_en for ID 172
UPDATE menuca_v3.promotional_coupons
SET description_en = '$5 off with purchase of $40 or more'
WHERE id = 172;

-- Fix description_en for ID 152
UPDATE menuca_v3.promotional_coupons
SET description_en = '20% off with promo code and order of $20 or more.'
WHERE id = 152;

-- Verify results
SELECT id, name_en, name_fr, description_en, description_fr 
FROM menuca_v3.promotional_coupons 
WHERE id IN (152, 159, 172);
