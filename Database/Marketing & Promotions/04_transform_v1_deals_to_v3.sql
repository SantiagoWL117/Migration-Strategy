-- Marketing & Promotions: Transform V1 Deals to V3 Staging
-- Phase 4: Data Transformation
-- Source: staging.v1_deals (194 rows with deserialized JSONB)
-- Target: staging.promotional_deals
-- Date: 2025-10-08

-- =============================================================================
-- TRANSFORMATION: V1 Deals → V3 Promotional Deals
-- =============================================================================

INSERT INTO staging.promotional_deals (
  restaurant_id,
  type,
  is_repeatable,
  name,
  description,
  
  -- Schedule (using deserialized JSONB!)
  active_days,
  specific_dates,
  
  -- Deal Configuration
  deal_type,
  discount_percent,
  discount_amount,
  minimum_purchase,
  order_count_required,
  
  -- Item Selection (using deserialized JSONB!)
  included_items,
  exempted_courses,
  free_item_count,
  
  -- Display & Marketing
  image_url,
  display_order,
  show_on_thankyou,
  
  -- Status
  is_enabled,
  language_code,
  
  -- V1 Legacy Fields
  v1_deal_id,
  v1_meal_number,
  v1_position,
  v1_is_global,
  
  -- Audit
  created_at
)
SELECT 
  -- FK Resolution: V1 restaurant ID → V3 restaurant ID
  COALESCE(
    (SELECT r.id 
     FROM menuca_v3.restaurants r 
     WHERE r.legacy_v1_id = v1.restaurant),
    v1.restaurant  -- Fallback to original ID if mapping not found
  ) as restaurant_id,
  
  -- Type (V1 doesn't have this, default to 'restaurant')
  'restaurant' as type,
  
  -- Repeatable (V1 doesn't have this, default to FALSE)
  FALSE as is_repeatable,
  
  -- Basic Info
  COALESCE(v1.name, 'Unnamed Deal') as name,  -- Ensure NOT NULL
  v1.description,
  
  -- Schedule: Use the deserialized JSONB columns!
  v1.active_days_json as active_days,  -- ✅ Already JSONB from Phase 3!
  v1.active_dates_json as specific_dates,  -- ✅ Already JSONB from Phase 3!
  
  -- Deal Configuration
  CASE 
    WHEN v1.type IS NULL OR v1.type = '' THEN 'percentTotal'
    WHEN v1.type = 'percent' THEN 'percent'
    WHEN v1.type = 'percentTotal' THEN 'percentTotal'
    WHEN v1.type = 'value' THEN 'value'
    WHEN v1.type = 'freeItem' THEN 'freeItem'
    WHEN v1.type = 'timesOrder' THEN 'timesOrder'
    ELSE v1.type  -- Pass through any other types
  END as deal_type,
  
  -- Discount Percent (parse from removeValue if percent type)
  CASE 
    WHEN v1.type LIKE '%percent%' AND v1."removeValue" IS NOT NULL 
    THEN 
      CASE 
        WHEN v1."removeValue" ~ '^[0-9]+\.?[0-9]*$'  -- Check if numeric
        THEN v1."removeValue"::numeric(5,2)
        ELSE NULL
      END
    ELSE NULL
  END as discount_percent,
  
  -- Discount Amount (fixed price deals)
  CASE 
    WHEN v1."dealPrice" > 0 THEN v1."dealPrice"::numeric(8,2)
    ELSE NULL
  END as discount_amount,
  
  -- Minimum Purchase
  CASE 
    WHEN v1."ammountSpent" > 0 THEN v1."ammountSpent"::numeric(8,2)
    ELSE NULL
  END as minimum_purchase,
  
  -- Order Count Required (for "order X times" deals)
  CASE 
    WHEN v1."orderTimes" > 0 THEN v1."orderTimes"
    ELSE NULL
  END as order_count_required,
  
  -- Item Selection: Use the deserialized JSONB columns!
  v1.items_json as included_items,  -- ✅ Already JSONB from Phase 3!
  v1.exceptions_json as exempted_courses,  -- ✅ Already JSONB from Phase 3!
  
  -- Free Item Count (V1 mealNo field)
  CASE 
    WHEN v1."mealNo" > 0 THEN v1."mealNo"
    ELSE NULL
  END as free_item_count,
  
  -- Display & Marketing
  v1.image as image_url,
  COALESCE(v1."order", v1.display, 0) as display_order,
  
  -- Show on Thank You page
  CASE 
    WHEN v1."showOnThankyou" = '1' THEN TRUE
    ELSE FALSE
  END as show_on_thankyou,
  
  -- Status
  CASE 
    WHEN v1.active = 'y' THEN TRUE
    WHEN v1.active = 'n' THEN FALSE
    ELSE TRUE  -- Default to enabled
  END as is_enabled,
  
  -- Language
  COALESCE(v1.lang, 'en') as language_code,
  
  -- V1 Legacy Fields (preserve for reference)
  v1.id as v1_deal_id,
  CASE WHEN v1."mealNo" > 0 THEN v1."mealNo" ELSE NULL END as v1_meal_number,
  v1.position as v1_position,
  CASE 
    WHEN v1."isGlobal" = '1' THEN TRUE
    WHEN v1."isGlobal" = '0' THEN FALSE
    ELSE NULL
  END as v1_is_global,
  
  -- Audit
  NOW() as created_at

FROM staging.v1_deals v1

-- Only insert deals that have valid data
WHERE v1.name IS NOT NULL OR v1.description IS NOT NULL

-- Avoid duplicates if script is re-run
ON CONFLICT (v1_deal_id) WHERE v1_deal_id IS NOT NULL DO NOTHING;

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Count of transformed deals
SELECT 
  'V1 Deals Transformation' as migration_step,
  (SELECT COUNT(*) FROM staging.v1_deals) as source_count,
  (SELECT COUNT(*) FROM staging.promotional_deals WHERE v1_deal_id IS NOT NULL) as target_count,
  (SELECT COUNT(*) FROM staging.promotional_deals WHERE v1_deal_id IS NOT NULL) * 100.0 / 
    NULLIF((SELECT COUNT(*) FROM staging.v1_deals), 0) as percent_migrated;

-- Sample of transformed deals
SELECT 
  id,
  restaurant_id,
  name,
  deal_type,
  active_days,
  exempted_courses,
  included_items,
  specific_dates,
  v1_deal_id
FROM staging.promotional_deals
WHERE v1_deal_id IS NOT NULL
ORDER BY v1_deal_id
LIMIT 10;

-- Check for unmapped restaurants
SELECT 
  'Unmapped Restaurants' as issue_type,
  COUNT(DISTINCT v1.restaurant) as count,
  array_agg(DISTINCT v1.restaurant ORDER BY v1.restaurant) as v1_restaurant_ids
FROM staging.v1_deals v1
LEFT JOIN menuca_v3.restaurants r ON r.legacy_v1_id = v1.restaurant
WHERE r.id IS NULL;

