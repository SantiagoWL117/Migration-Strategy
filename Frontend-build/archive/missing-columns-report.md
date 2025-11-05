# Missing Database Columns Report - UPDATED
**Date:** 2025-10-24
**Updated:** After DB query analysis
**Issue:** Frontend app cannot display restaurant data - some fields exist in other tables, others are completely missing

## Problem Summary
The `menuca_v3.restaurants` table only has 31 basic metadata columns but is **MISSING all customer-facing operational data**. The frontend successfully connects to the database and fetches restaurants, but cannot display ratings, pricing, delivery info, or images because these columns don't exist in the schema.

## Current Schema (What EXISTS - 31 columns)
```
✅ id, uuid, legacy_v1_id, legacy_v2_id
✅ name, slug, timezone
✅ status, activated_at, suspended_at, closed_at
✅ online_ordering_enabled, online_ordering_disabled_at, online_ordering_disabled_reason
✅ parent_restaurant_id, is_franchise_parent, franchise_brand_name
✅ created_at, created_by, updated_at, updated_by, deleted_at, deleted_by
✅ meta_title, meta_description, meta_keywords, og_image_url, search_keywords
✅ is_featured, featured_priority, search_vector
```

## Missing/Misplaced Data Analysis

### ✅ EXISTS in other tables (needs JOIN or migration)
| Field | Current Location | Frontend Needs It In | Solution |
|-------|-----------------|---------------------|----------|
| `description` | `dishes`, `courses` tables | `restaurants` table | Add `description` column to `restaurants` |
| `image_url` | `dishes` table | `restaurants` table | Add `image_url` or use `og_image_url` |
| `delivery_fee` | `orders`, `restaurant_delivery_areas` | `restaurants` table | Add default `delivery_fee` to `restaurants` |
| `estimated_delivery_time` | `orders` table | `restaurants` table | Add default `estimated_delivery_time` to `restaurants` |

### 🔴 DOES NOT EXIST ANYWHERE (must be created)
| Field Name | Type | Purpose | Frontend Impact |
|-----------|------|---------|-----------------|
| `average_rating` | DECIMAL(3,2) | Restaurant rating (1.0-5.0) | Cards show "No rating" |
| `review_count` | INTEGER | Number of reviews | Cannot display social proof |
| `minimum_order` | DECIMAL(6,2) | Minimum order amount | Cards show "No min" |
| `cuisine_type_id` | INTEGER FK | Link to `cuisine_types` table | Cannot filter by cuisine |

### ⚠️ EXISTS but needs proper relation
| Field | Status | Action Needed |
|-------|--------|---------------|
| `cuisine_types` table | ✅ Exists | Add FK `cuisine_type_id` to `restaurants` table to link them |

### 📍 Location Data (Separate Table Issue)
The `restaurant_locations` table exists but has NO data:
- `find_nearby_restaurants` RPC returns 0 results
- Frontend cannot calculate distances
- Geolocation feature is non-functional

## Frontend Status
✅ **Working:**
- Database connection (Supabase client configured correctly)
- Schema access (`menuca_v3` schema properly set)
- Query execution (fetching 20 restaurants successfully)
- Null handling (shows "N/A" indicators, not fake data)

❌ **Not Working (Due to Missing Data):**
- Restaurant ratings display
- Delivery fee/minimum order display
- Distance calculations (location data missing)
- Restaurant images
- Search/filtering by cuisine

## Action Required - REVISED

### Phase 1: Add Missing Columns (CRITICAL)
```sql
ALTER TABLE menuca_v3.restaurants
ADD COLUMN average_rating DECIMAL(3,2) DEFAULT NULL,
ADD COLUMN review_count INTEGER DEFAULT 0,
ADD COLUMN delivery_fee DECIMAL(5,2) DEFAULT NULL,
ADD COLUMN minimum_order DECIMAL(6,2) DEFAULT NULL,
ADD COLUMN estimated_delivery_time VARCHAR(50) DEFAULT NULL,
ADD COLUMN image_url TEXT DEFAULT NULL,
ADD COLUMN description TEXT DEFAULT NULL,
ADD COLUMN cuisine_type_id INTEGER REFERENCES menuca_v3.cuisine_types(id);
```

### Phase 2: Create Indexes
```sql
CREATE INDEX idx_restaurants_cuisine_type ON menuca_v3.restaurants(cuisine_type_id);
CREATE INDEX idx_restaurants_rating ON menuca_v3.restaurants(average_rating);
```

### Phase 3: Migrate/Populate Data
1. **For `description` and `image_url`**: Copy from V1/V2 restaurant tables if they exist
2. **For `delivery_fee` and `minimum_order`**: Set reasonable defaults or migrate from old config tables
3. **For `estimated_delivery_time`**: Set default like "30-45 min" or calculate from historical order data
4. **For `cuisine_type_id`**: Map restaurants to existing `cuisine_types` table
5. **For ratings**: If you have reviews, calculate and populate; otherwise leave NULL

### Phase 4: Location Data (SEPARATE ISSUE)
Populate `menuca_v3.restaurant_locations` table with:
- `latitude` and `longitude` for each restaurant
- This enables the `find_nearby_restaurants` RPC function to work

## Testing Verification
Once columns are added and populated, verify:
```bash
# Check if columns exist and have data
SELECT
  name,
  average_rating,
  review_count,
  delivery_fee,
  minimum_order,
  cuisine_type,
  image_url IS NOT NULL as has_image
FROM menuca_v3.restaurants
LIMIT 5;
```

Expected: All fields should have values, not NULL.

---
**Frontend is ready and waiting for data!** Once these columns exist with real data, everything will display automatically.
