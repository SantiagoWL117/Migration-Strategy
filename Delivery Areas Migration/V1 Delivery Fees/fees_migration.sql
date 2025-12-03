-- ============================================================================
-- V1 Delivery Fees Migration
-- Generated: 2025-12-03 09:54:03
-- ============================================================================
--
-- Total Restaurants with Fee Data: 36
--
-- Source: V1 fee BLOB column (deserialized)
-- Target: menuca_v3.restaurant_delivery_areas.delivery_fee
-- ============================================================================

BEGIN;

-- Restaurant: Champa Thai Cuisine (V1 ID: 203, V3 ID: 87)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.00
WHERE restaurant_id = 87
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $3.00

-- Restaurant: Restaurant Le Choix (V1 ID: 225, V3 ID: 106)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.00
WHERE restaurant_id = 106
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $3.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.00
WHERE restaurant_id = 106
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $4.00

-- Restaurant: Papa Pizza Des Flandres (V1 ID: 231, V3 ID: 1012)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.00
WHERE restaurant_id = 1012
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $3.00

-- Restaurant: Papa Pizza Maloney (V1 ID: 346, V3 ID: 1013)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.50
WHERE restaurant_id = 1013
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $3.50

-- Restaurant: La Famiglia on the Danforth (V1 ID: 364, V3 ID: 984)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 5.00
WHERE restaurant_id = 984
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $5.00

-- Restaurant: Orchid Sushi (V1 ID: 387, V3 ID: 245)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.00
WHERE restaurant_id = 245
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $3.00

-- Restaurant: Sushi Express Chambly (V1 ID: 511, V3 ID: 1017)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.00
WHERE restaurant_id = 1017
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.00
WHERE restaurant_id = 1017
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $3.00

-- Restaurant: Ting's Kitchen (V1 ID: 694, V3 ID: 941)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.99
WHERE restaurant_id = 941
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.99

-- Restaurant: Milano (V1 ID: 789, V3 ID: 569)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.50
WHERE restaurant_id = 569
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.50
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.50
WHERE restaurant_id = 569
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $2.50

-- Restaurant: Crispy's (V1 ID: 805, V3 ID: 584)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.99
WHERE restaurant_id = 584
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.99

-- Restaurant: Milano (V1 ID: 807, V3 ID: 586)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 1.99
WHERE restaurant_id = 586
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $1.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.99
WHERE restaurant_id = 586
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $4.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 6.99
WHERE restaurant_id = 586
  AND area_number = 3
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 3: $6.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 9.99
WHERE restaurant_id = 586
  AND area_number = 4
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 4: $9.99

-- Restaurant: Sushi Fleury (V1 ID: 818, V3 ID: 596)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.50
WHERE restaurant_id = 596
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.50
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.50
WHERE restaurant_id = 596
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $3.50

-- Restaurant: Milano (V1 ID: 824, V3 ID: 601)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.50
WHERE restaurant_id = 601
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.50
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 5.00
WHERE restaurant_id = 601
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $5.00

-- Restaurant: Asia Garden Ottawa (V1 ID: 856, V3 ID: 630)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.50
WHERE restaurant_id = 630
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $3.50
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.50
WHERE restaurant_id = 630
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $3.50

-- Restaurant: Joes Family Pizzeria (V1 ID: 863, V3 ID: 636)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.99
WHERE restaurant_id = 636
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $4.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 6.99
WHERE restaurant_id = 636
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $6.99

-- Restaurant: Digby's Restaurant (V1 ID: 865, V3 ID: 638)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 1.50
WHERE restaurant_id = 638
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $1.50

-- Restaurant: JC Royal Thai Cuisine (V1 ID: 874, V3 ID: 646)
-- Skipping Area 1: invalid fee value '5<40,0>40'

-- Restaurant: Milano (V1 ID: 889, V3 ID: 660)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 0.00
WHERE restaurant_id = 660
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $0.00

-- Restaurant: Milano (V1 ID: 913, V3 ID: 680)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.99
WHERE restaurant_id = 680
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.99
WHERE restaurant_id = 680
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $3.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.99
WHERE restaurant_id = 680
  AND area_number = 3
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 3: $4.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.99
WHERE restaurant_id = 680
  AND area_number = 4
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 4: $3.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.99
WHERE restaurant_id = 680
  AND area_number = 5
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 5: $4.99

-- Restaurant: Oka's Hull (V1 ID: 914, V3 ID: 681)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.00
WHERE restaurant_id = 681
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.00
WHERE restaurant_id = 681
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $3.00

-- Restaurant: Milano (V1 ID: 937, V3 ID: 701)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 0.00
WHERE restaurant_id = 701
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $0.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 5.00
WHERE restaurant_id = 701
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $5.00

-- Restaurant: PizzaRama (V1 ID: 953, V3 ID: 716)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.00
WHERE restaurant_id = 716
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $3.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.00
WHERE restaurant_id = 716
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $3.00

-- Restaurant: Pizza Joanna (V1 ID: 964, V3 ID: 726)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.50
WHERE restaurant_id = 726
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.50
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.00
WHERE restaurant_id = 726
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $4.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 5.00
WHERE restaurant_id = 726
  AND area_number = 3
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 3: $5.00

-- Restaurant: Friendly Restaurant and Pizzeria (V1 ID: 968, V3 ID: 730)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.00
WHERE restaurant_id = 730
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $3.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 6.50
WHERE restaurant_id = 730
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $6.50
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 8.50
WHERE restaurant_id = 730
  AND area_number = 3
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 3: $8.50

-- Restaurant: Amicci Pizza (V1 ID: 973, V3 ID: 735)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.50
WHERE restaurant_id = 735
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.50
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.00
WHERE restaurant_id = 735
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $3.00

-- Restaurant: Kabylie Pizza (V1 ID: 1042, V3 ID: 798)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.00
WHERE restaurant_id = 798
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $4.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.50
WHERE restaurant_id = 798
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $4.50

-- Restaurant: Nachos Loco Gatineau (V1 ID: 1045, V3 ID: 801)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.99
WHERE restaurant_id = 801
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.99
WHERE restaurant_id = 801
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $3.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.99
WHERE restaurant_id = 801
  AND area_number = 3
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 3: $4.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.99
WHERE restaurant_id = 801
  AND area_number = 4
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 4: $3.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.99
WHERE restaurant_id = 801
  AND area_number = 5
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 5: $4.99

-- Restaurant: Poutinerie Québecurds Gatineau (V1 ID: 1046, V3 ID: 1015)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.99
WHERE restaurant_id = 1015
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.99
WHERE restaurant_id = 1015
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $3.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.99
WHERE restaurant_id = 1015
  AND area_number = 3
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 3: $4.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.99
WHERE restaurant_id = 1015
  AND area_number = 4
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 4: $3.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.99
WHERE restaurant_id = 1015
  AND area_number = 5
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 5: $4.99

-- Restaurant: Crispy's Bank Street (V1 ID: 1050, V3 ID: 806)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.99
WHERE restaurant_id = 806
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.99

-- Restaurant: Dépanneur Généreux (V1 ID: 1060, V3 ID: 816)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 4.99
WHERE restaurant_id = 816
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $4.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 7.00
WHERE restaurant_id = 816
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $7.00

-- Restaurant: Milano (V1 ID: 1062, V3 ID: 818)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.99
WHERE restaurant_id = 818
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 6.00
WHERE restaurant_id = 818
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $6.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 7.00
WHERE restaurant_id = 818
  AND area_number = 3
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 3: $7.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 9.00
WHERE restaurant_id = 818
  AND area_number = 4
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 4: $9.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 13.00
WHERE restaurant_id = 818
  AND area_number = 5
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 5: $13.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 16.00
WHERE restaurant_id = 818
  AND area_number = 6
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 6: $16.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 28.00
WHERE restaurant_id = 818
  AND area_number = 7
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 7: $28.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 32.00
WHERE restaurant_id = 818
  AND area_number = 8
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 8: $32.00
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 40.00
WHERE restaurant_id = 818
  AND area_number = 9
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 9: $40.00

-- Restaurant: Milano (V1 ID: 1063, V3 ID: 819)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.99
WHERE restaurant_id = 819
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 5.99
WHERE restaurant_id = 819
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $5.99

-- Restaurant: Papa Burger Maloney (V1 ID: 1066, V3 ID: 822)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 3.00
WHERE restaurant_id = 822
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $3.00

-- Restaurant: All Out Burger (V1 ID: 1080, V3 ID: 833)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.50
WHERE restaurant_id = 833
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.50
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 5.00
WHERE restaurant_id = 833
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $5.00

-- Restaurant: Mykonos Greek Grill (V1 ID: 1092, V3 ID: 845)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.99
WHERE restaurant_id = 845
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 5.99
WHERE restaurant_id = 845
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $5.99

-- Restaurant: Mykonos Greek Grill (V1 ID: 1093, V3 ID: 846)
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 2.99
WHERE restaurant_id = 846
  AND area_number = 1
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 1: $2.99
UPDATE menuca_v3.restaurant_delivery_areas
SET delivery_fee = 5.99
WHERE restaurant_id = 846
  AND area_number = 2
  AND (delivery_fee IS NULL OR delivery_fee = 0);
-- Area 2: $5.99

COMMIT;

-- ============================================================================
-- MIGRATION COMPLETE
-- Total UPDATE statements: 79
-- ============================================================================