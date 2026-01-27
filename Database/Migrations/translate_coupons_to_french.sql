-- Translate English coupon names to French
-- Date: 2026-01-27

-- Pattern 1: "$X off" -> "X$ de rabais"
UPDATE menuca_v3.promotional_coupons
SET name_fr = regexp_replace(name_en, '\$(\d+) off', '\1$ de rabais', 'gi')
WHERE name_en ~* '\$\d+ off' AND name_fr = name_en;

-- Pattern 2: "$X OFF" (uppercase) -> "X$ DE RABAIS"
UPDATE menuca_v3.promotional_coupons
SET name_fr = regexp_replace(name_en, '\$(\d+) OFF', '\1$ DE RABAIS', 'g')
WHERE name_en ~ '\$\d+ OFF' AND name_fr = name_en;

-- Pattern 3: "X% off order online" -> "X% de rabais commande en ligne"
UPDATE menuca_v3.promotional_coupons
SET name_fr = regexp_replace(name_en, '(\d+)% off order online', '\1% de rabais commande en ligne', 'gi')
WHERE name_en ~* '\d+% off order online' AND name_fr LIKE '%order online%';

-- Pattern 4: "Flash Sale" -> "Vente flash"
UPDATE menuca_v3.promotional_coupons
SET name_fr = 'Vente flash'
WHERE name_en = 'Flash Sale';

-- Pattern 5: "Sorry" -> "Désolé"
UPDATE menuca_v3.promotional_coupons
SET name_fr = 'Désolé'
WHERE name_en = 'Sorry';

-- Verify results
SELECT name_en, name_fr FROM menuca_v3.promotional_coupons 
WHERE name_en IS NOT NULL AND name_en != name_fr
ORDER BY id LIMIT 20;
