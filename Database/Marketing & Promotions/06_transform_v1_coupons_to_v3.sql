-- Marketing & Promotions: Transform V1 Coupons to V3 Staging
-- Phase 4: Data Transformation
-- Source: staging.v1_coupons (582 rows)
-- Target: staging.promotional_coupons
-- Date: 2025-10-08

-- =============================================================================
-- TRANSFORMATION: V1 Coupons → V3 Promotional Coupons
-- =============================================================================

INSERT INTO staging.promotional_coupons (
  restaurant_id,
  name,
  description,
  code,
  
  -- Validity Period
  valid_from,
  valid_until,
  
  -- Discount Configuration
  discount_type,
  discount_amount,
  minimum_purchase,
  
  -- Usage Rules
  applies_to_specific_items,
  specific_item_ids,
  max_redemptions_per_customer,
  is_single_use,
  
  -- Email Marketing
  include_in_reorder_emails,
  include_in_marketing_emails,
  email_text,
  
  -- Status
  is_active,
  language_code,
  has_been_used,
  
  -- V1 Legacy
  v1_coupon_id,
  v1_coupon_type,
  v1_redeem_value,
  
  -- Audit
  created_at
)
SELECT 
  -- FK Resolution: V1 restaurant → V3 restaurant ID
  COALESCE(
    (SELECT r.id 
     FROM menuca_v3.restaurants r 
     WHERE r.legacy_v1_id = v1.restaurant),
    v1.restaurant  -- Fallback
  ) as restaurant_id,
  
  -- Basic Info
  COALESCE(v1.name, 'Unnamed Coupon') as name,
  v1.description,
  v1.code,
  
  -- Validity Period (V1 uses Unix timestamps)
  CASE 
    WHEN v1.start > 0 THEN to_timestamp(v1.start)::timestamptz
    ELSE NULL
  END as valid_from,
  
  CASE 
    WHEN v1.stop > 0 THEN to_timestamp(v1.stop)::timestamptz
    ELSE NULL
  END as valid_until,
  
  -- Discount Configuration
  CASE 
    WHEN v1.reducetype IS NULL OR v1.reducetype = '' THEN 'value'
    WHEN v1.reducetype = 'percent' THEN 'percent'
    WHEN v1.reducetype = 'value' THEN 'value'
    WHEN v1.reducetype = 'freeItem' THEN 'freeItem'
    ELSE v1.reducetype
  END as discount_type,
  
  -- Discount Amount
  CASE 
    WHEN v1.ammount > 0 THEN v1.ammount::numeric(8,2)
    ELSE NULL
  END as discount_amount,
  
  -- Minimum Purchase (V1 doesn't have this, NULL)
  NULL as minimum_purchase,
  
  -- Usage Rules
  -- V1 has 'product' field (text) - indicates if coupon applies to specific items
  CASE 
    WHEN v1.product IS NOT NULL AND v1.product != '' THEN TRUE
    ELSE FALSE
  END as applies_to_specific_items,
  
  -- Store product text as JSONB array (split by comma if multiple)
  CASE 
    WHEN v1.product IS NOT NULL AND v1.product != '' THEN
      jsonb_build_array(v1.product)  -- Simple approach: store as single-element array
    ELSE NULL
  END as specific_item_ids,
  
  -- Max Redemptions
  CASE 
    WHEN v1.itemcount > 0 THEN v1.itemcount
    ELSE NULL
  END as max_redemptions_per_customer,
  
  -- Is Single Use
  CASE 
    WHEN v1.one_time_only = 'y' THEN TRUE
    ELSE FALSE
  END as is_single_use,
  
  -- Email Marketing
  CASE 
    WHEN v1.for_reorder = '1' THEN TRUE
    ELSE FALSE
  END as include_in_reorder_emails,
  
  CASE 
    WHEN v1.addtomail = 'y' THEN TRUE
    ELSE FALSE
  END as include_in_marketing_emails,
  
  v1.mailtext as email_text,
  
  -- Status
  CASE 
    WHEN v1.active = 'Y' THEN TRUE
    WHEN v1.active = 'N' THEN FALSE
    ELSE TRUE  -- Default to active
  END as is_active,
  
  -- Language
  COALESCE(v1.lang, 'en') as language_code,
  
  -- Has Been Used
  CASE 
    WHEN v1.used = 'y' THEN TRUE
    ELSE FALSE
  END as has_been_used,
  
  -- V1 Legacy Fields
  v1.id as v1_coupon_id,
  
  CASE 
    WHEN v1.coupontype = 'r' THEN 'restaurant'
    WHEN v1.coupontype = 'g' THEN 'global'
    ELSE v1.coupontype
  END as v1_coupon_type,
  
  CASE 
    WHEN v1.redeem > 0 THEN v1.redeem
    ELSE NULL
  END as v1_redeem_value,
  
  -- Audit
  NOW() as created_at

FROM staging.v1_coupons v1

WHERE v1.code IS NOT NULL;  -- Only migrate coupons with codes

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Count of transformed coupons
SELECT 
  'V1 Coupons Transformation' as step,
  (SELECT COUNT(*) FROM staging.v1_coupons) as source_count,
  (SELECT COUNT(*) FROM staging.promotional_coupons WHERE v1_coupon_id IS NOT NULL) as target_count,
  ROUND(
    (SELECT COUNT(*) FROM staging.promotional_coupons WHERE v1_coupon_id IS NOT NULL) * 100.0 / 
    NULLIF((SELECT COUNT(*) FROM staging.v1_coupons), 0),
    2
  ) as percent_migrated;

-- Sample of transformed coupons
SELECT 
  id,
  restaurant_id,
  name,
  code,
  discount_type,
  discount_amount,
  is_active,
  v1_coupon_id
FROM staging.promotional_coupons
WHERE v1_coupon_id IS NOT NULL
ORDER BY v1_coupon_id
LIMIT 10;

-- Coupons by discount type
SELECT 
  discount_type,
  COUNT(*) as count,
  COUNT(CASE WHEN is_active THEN 1 END) as active_count
FROM staging.promotional_coupons
WHERE v1_coupon_id IS NOT NULL
GROUP BY discount_type
ORDER BY count DESC;

