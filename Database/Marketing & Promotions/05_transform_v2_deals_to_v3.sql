-- Marketing & Promotions: Transform V2 Deals to V3 Staging
-- Phase 4: Data Transformation
-- Source: staging.v2_restaurants_deals (37 rows with native JSON)
-- Target: staging.promotional_deals
-- Date: 2025-10-08

-- =============================================================================
-- TRANSFORMATION: V2 Restaurants_Deals → V3 Promotional Deals
-- =============================================================================

INSERT INTO staging.promotional_deals (
  restaurant_id,
  type,
  is_repeatable,
  name,
  description,
  
  -- Schedule (V2 has native JSON!)
  active_days,
  date_start,
  date_stop,
  time_start,
  time_stop,
  specific_dates,
  
  -- Deal Configuration
  deal_type,
  discount_percent,
  discount_amount,
  minimum_purchase,
  order_count_required,
  
  -- Item Selection (V2 has native JSON!)
  included_items,
  required_items,
  required_item_count,
  free_item_count,
  exempted_courses,
  
  -- Availability
  availability_types,
  
  -- Display & Marketing
  image_url,
  promo_code,
  is_customizable,
  is_split_deal,
  first_order_only,
  
  -- Email Marketing
  send_in_email,
  email_body_html,
  
  -- Status
  is_enabled,
  
  -- V2 Legacy Field
  v2_deal_id,
  
  -- Audit
  created_by,
  created_at,
  disabled_by,
  disabled_at
)
SELECT 
  -- FK Resolution: V2 restaurant_id → V3 restaurant ID
  COALESCE(
    (SELECT r.id 
     FROM menuca_v3.restaurants r 
     WHERE r.legacy_v2_id = v2.restaurant_id),
    v2.restaurant_id  -- Fallback
  ) as restaurant_id,
  
  -- Type
  CASE 
    WHEN v2.type = 'r' THEN 'restaurant'
    WHEN v2.type = 'a' THEN 'aggregator'
    ELSE 'restaurant'
  END as type,
  
  -- Repeatable
  CASE 
    WHEN v2.repeatable = 'y' THEN TRUE
    ELSE FALSE
  END as is_repeatable,
  
  -- Basic Info
  COALESCE(v2.name, 'Unnamed Deal') as name,
  v2.description,
  
  -- Schedule: V2 already has JSON! Just cast to JSONB
  v2.days::jsonb as active_days,
  v2.date_start,
  v2.date_stop,
  v2.time_start,
  v2.time_stop,
  v2.dates::jsonb as specific_dates,
  
  -- Deal Configuration
  COALESCE(v2.deal_type, 'percentTotal') as deal_type,
  
  -- Discount Percent (V2 stores as 'remove')
  CASE 
    WHEN v2.remove IS NOT NULL AND v2.remove > 0 
    THEN v2.remove::numeric(5,2)
    ELSE NULL
  END as discount_percent,
  
  -- Discount Amount
  CASE 
    WHEN v2.amount IS NOT NULL AND v2.amount > 0 
    THEN v2.amount::numeric(8,2)
    ELSE NULL
  END as discount_amount,
  
  -- Minimum Purchase (V2 doesn't have this, NULL)
  NULL as minimum_purchase,
  
  -- Order Count Required
  CASE 
    WHEN v2.times IS NOT NULL AND v2.times > 0 
    THEN v2.times
    ELSE NULL
  END as order_count_required,
  
  -- Item Selection: V2 has native JSON!
  v2.item::jsonb as included_items,
  v2.item_buy::jsonb as required_items,
  
  CASE 
    WHEN v2.item_count_buy IS NOT NULL AND v2.item_count_buy > 0 
    THEN v2.item_count_buy
    ELSE NULL
  END as required_item_count,
  
  CASE 
    WHEN v2.item_count IS NOT NULL AND v2.item_count > 0 
    THEN v2.item_count
    ELSE NULL
  END as free_item_count,
  
  -- Exempted Courses (note: V2 has typo "extempted")
  v2.extempted_courses::jsonb as exempted_courses,
  
  -- Availability: Map JSON array to JSONB
  -- V2: ["t", "d"] → V3: ["takeout", "delivery"]
  CASE 
    WHEN v2.available IS NOT NULL THEN
      (
        SELECT jsonb_agg(
          CASE 
            WHEN value::text = '"t"' THEN 'takeout'
            WHEN value::text = '"d"' THEN 'delivery'
            ELSE value::text
          END
        )
        FROM jsonb_array_elements(v2.available::jsonb)
      )
    ELSE NULL
  END as availability_types,
  
  -- Display & Marketing
  v2.image as image_url,
  v2.promo_code,
  
  CASE 
    WHEN v2.customize = 'y' THEN TRUE
    ELSE FALSE
  END as is_customizable,
  
  CASE 
    WHEN v2.split_deal = 'y' THEN TRUE
    ELSE FALSE
  END as is_split_deal,
  
  CASE 
    WHEN v2.first_order = 'y' THEN TRUE
    ELSE FALSE
  END as first_order_only,
  
  -- Email Marketing
  CASE 
    WHEN v2."mailcoupon" = 'y' THEN TRUE
    ELSE FALSE
  END as send_in_email,
  
  v2."mailbody" as email_body_html,
  
  -- Status
  CASE 
    WHEN v2.enabled = 'y' THEN TRUE
    ELSE FALSE
  END as is_enabled,
  
  -- V2 Legacy Field
  v2.id as v2_deal_id,
  
  -- Audit (V2 has audit fields!)
  v2.added_by as created_by,
  v2.added_at as created_at,
  v2.disabled_by,
  v2.disabled_at

FROM staging.v2_restaurants_deals v2

WHERE v2.name IS NOT NULL OR v2.description IS NOT NULL;

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Count of transformed V2 deals
SELECT 
  'V2 Deals Transformation' as step,
  (SELECT COUNT(*) FROM staging.v2_restaurants_deals) as source_count,
  (SELECT COUNT(*) FROM staging.promotional_deals WHERE v2_deal_id IS NOT NULL) as target_count,
  ROUND(
    (SELECT COUNT(*) FROM staging.promotional_deals WHERE v2_deal_id IS NOT NULL) * 100.0 / 
    NULLIF((SELECT COUNT(*) FROM staging.v2_restaurants_deals), 0),
    2
  ) as percent_migrated;

-- Sample of V2 transformed deals
SELECT 
  id,
  restaurant_id,
  name,
  type,
  deal_type,
  active_days,
  exempted_courses,
  included_items,
  availability_types,
  promo_code,
  v2_deal_id
FROM staging.promotional_deals
WHERE v2_deal_id IS NOT NULL
ORDER BY v2_deal_id
LIMIT 10;

-- Combined V1 + V2 totals
SELECT 
  'Combined V1+V2 Deals' as summary,
  COUNT(CASE WHEN v1_deal_id IS NOT NULL THEN 1 END) as v1_count,
  COUNT(CASE WHEN v2_deal_id IS NOT NULL THEN 1 END) as v2_count,
  COUNT(*) as total_deals
FROM staging.promotional_deals;

