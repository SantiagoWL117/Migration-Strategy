-- Translate English coupon descriptions to French
-- Date: 2026-01-27

-- 1. "$15 off on all online orders of minimum $25"
UPDATE menuca_v3.promotional_coupons
SET description_fr = '15$ de rabais sur toutes les commandes en ligne de 25$ minimum'
WHERE description_en = '$15 off on all online orders of minimum $25' AND description_fr IS NULL;

-- 2. "$30 off one time only. Valid till the end of the year."
UPDATE menuca_v3.promotional_coupons
SET description_fr = '30$ de rabais, utilisation unique. Valide jusqu''à la fin de l''année.'
WHERE description_en = '$30 off one time only. Valid till the end of the year.' AND description_fr IS NULL;

-- 3. "$30 off one time only. Valid till the end of the year.\r\n" (with newline)
UPDATE menuca_v3.promotional_coupons
SET description_fr = '30$ de rabais, utilisation unique. Valide jusqu''à la fin de l''année.'
WHERE description_en LIKE '$30 off one time only. Valid till the end of the year.%' AND description_fr IS NULL;

-- 4. "$5 off if you spend $40 or more"
UPDATE menuca_v3.promotional_coupons
SET description_fr = '5$ de rabais si vous dépensez 40$ ou plus'
WHERE description_en = '$5 off if you spend $40 or more' AND description_fr IS NULL;

-- 5. "$5 off if you spend 30$ or more"
UPDATE menuca_v3.promotional_coupons
SET description_fr = '5$ de rabais si vous dépensez 30$ ou plus'
WHERE description_en = '$5 off if you spend 30$ or more' AND description_fr IS NULL;

-- 6. "$5 off when you spend $25 or more"
UPDATE menuca_v3.promotional_coupons
SET description_fr = '5$ de rabais lorsque vous dépensez 25$ ou plus'
WHERE description_en = '$5 off when you spend $25 or more' AND description_fr IS NULL;

-- 7. "$5 Off with promo code"
UPDATE menuca_v3.promotional_coupons
SET description_fr = '5$ de rabais avec code promo'
WHERE description_en = '$5 Off with promo code' AND description_fr IS NULL;

-- 8. "15% off apologies for being late"
UPDATE menuca_v3.promotional_coupons
SET description_fr = '15% de rabais - excuses pour le retard'
WHERE description_en = '15% off apologies for being late' AND description_fr IS NULL;

-- 9. "20% off with promo code"
UPDATE menuca_v3.promotional_coupons
SET description_fr = '20% de rabais avec code promo'
WHERE description_en = '20% off with promo code' AND description_fr IS NULL;

-- 10. "customer appreciation bucks - one time use only - good as cash on the entire menu"
UPDATE menuca_v3.promotional_coupons
SET description_fr = 'Bons de remerciement client - utilisation unique - valable comme argent comptant sur tout le menu'
WHERE description_en = 'customer appreciation bucks - one time use only - good as cash on the entire menu' AND description_fr IS NULL;

-- Verify results
SELECT description_en, description_fr 
FROM menuca_v3.promotional_coupons 
WHERE description_en IS NOT NULL AND description_fr IS NOT NULL
GROUP BY description_en, description_fr
ORDER BY description_en;
