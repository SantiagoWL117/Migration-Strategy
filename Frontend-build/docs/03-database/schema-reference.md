# Database Schema Reference - menuca_v3
**CRITICAL: CHECK THIS FILE BEFORE WRITING ANY DATABASE QUERIES**
**Last Updated:** 2025-10-24

## ⚠️ RULES
1. **ALWAYS** check this file before writing Supabase queries
2. **NEVER** assume table or column names
3. **UPDATE** this file when discovering new schema details
4. **ASK USER** to run queries if schema is unclear

---

## Known Table Structure

### 🍽️ RESTAURANTS
**Table:** `menuca_v3.restaurants`

**Known Columns (31 total):**
```
✅ id (INTEGER)
✅ uuid (UUID)
✅ legacy_v1_id (INTEGER)
✅ legacy_v2_id (INTEGER)
✅ name (VARCHAR)
✅ slug (VARCHAR) - Used for URLs
✅ status (VARCHAR) - Values: 'active', etc.
✅ activated_at (TIMESTAMP)
✅ suspended_at (TIMESTAMP)
✅ closed_at (TIMESTAMP)
✅ created_at (TIMESTAMP)
✅ created_by (INTEGER)
✅ updated_at (TIMESTAMP)
✅ updated_by (INTEGER)
✅ timezone (VARCHAR)
✅ deleted_at (TIMESTAMP)
✅ deleted_by (INTEGER)
✅ parent_restaurant_id (INTEGER)
✅ is_franchise_parent (BOOLEAN)
✅ franchise_brand_name (VARCHAR)
✅ online_ordering_enabled (BOOLEAN)
✅ online_ordering_disabled_at (TIMESTAMP)
✅ online_ordering_disabled_reason (TEXT)
✅ meta_title (VARCHAR)
✅ meta_description (TEXT)
✅ meta_keywords (TEXT)
✅ og_image_url (TEXT) - Currently NULL for all restaurants
✅ search_keywords (TEXT)
✅ is_featured (BOOLEAN)
✅ featured_priority (INTEGER)
✅ search_vector (TSVECTOR)
```

**❌ MISSING Columns (Need to be added):**
- `average_rating`
- `review_count`
- `delivery_fee`
- `minimum_order`
- `estimated_delivery_time`
- `image_url`
- `description`
- `cuisine_type_id`

---

### 📍 LOCATIONS
**Table:** `menuca_v3.restaurant_locations`
**Status:** ⚠️ Table exists but NO DATA populated
**Used For:** Distance calculations via `find_nearby_restaurants` RPC

**Expected Columns:**
- `restaurant_id` (FK to restaurants)
- `street_address`
- `city_id`
- `latitude` - ❌ NOT POPULATED
- `longitude` - ❌ NOT POPULATED

---

### 🍕 MENU SYSTEM
**Status:** ✅ VERIFIED VIA MCP - 2025-10-24

#### COURSES (Menu Categories)
**Table:** `menuca_v3.courses`

**Columns (17 total):**
```
✅ id (BIGINT) - Primary key
✅ uuid (UUID) - Unique identifier
✅ restaurant_id (BIGINT) - FK to restaurants
✅ name (VARCHAR) - Category name (e.g., "Appetizers", "Entrees")
✅ description (TEXT) - Category description
✅ display_order (INTEGER) - Sort order (default: 0)
✅ is_active (BOOLEAN) - Visibility toggle (default: true)
✅ source_system (VARCHAR) - Migration tracking
✅ source_id (BIGINT) - Original system ID
✅ legacy_v1_id (INTEGER) - V1 migration ID
✅ legacy_v2_id (INTEGER) - V2 migration ID
✅ notes (TEXT) - Internal notes
✅ created_at (TIMESTAMP) - Record creation
✅ updated_at (TIMESTAMP) - Last modification
✅ tenant_id (UUID) - Multi-tenancy support
✅ deleted_at (TIMESTAMP) - Soft delete
✅ deleted_by (BIGINT) - User who deleted
```

**Relationships:**
- `courses.restaurant_id` → `restaurants.id`
- `dishes.course_id` → `courses.id`

---

#### DISHES (Menu Items)
**Table:** `menuca_v3.dishes`

**Columns (32 total):**
```
✅ id (BIGINT) - Primary key
✅ uuid (UUID) - Unique identifier
✅ restaurant_id (BIGINT) - FK to restaurants
✅ course_id (BIGINT) - FK to courses (can be NULL)
✅ name (VARCHAR) - Dish name
✅ description (TEXT) - Dish description
✅ ingredients (TEXT) - Ingredient list as text
✅ sku (VARCHAR) - Stock keeping unit
✅ base_price (NUMERIC) - Default price
✅ prices (JSONB) - Complex pricing structure
✅ size_options (JSONB) - Size variants
✅ display_order (INTEGER) - Sort order (default: 0)
✅ image_url (VARCHAR) - Dish photo URL
✅ is_combo (BOOLEAN) - Combo meal flag (default: false)
✅ has_customization (BOOLEAN) - Modifiers available (default: false)
✅ quantity (VARCHAR) - Serving size info
✅ is_upsell (BOOLEAN) - Upsell item flag (default: false)
✅ is_active (BOOLEAN) - Visibility toggle (default: true)
✅ source_system (VARCHAR) - Migration tracking
✅ source_id (BIGINT) - Original system ID
✅ legacy_v1_id (INTEGER) - V1 migration ID
✅ legacy_v2_id (INTEGER) - V2 migration ID
✅ notes (TEXT) - Internal notes
✅ created_at (TIMESTAMP) - Record creation
✅ updated_at (TIMESTAMP) - Last modification
✅ unavailable_until_at (TIMESTAMP) - Temporary unavailability
✅ search_vector (TSVECTOR) - Full-text search
✅ allergen_info (JSONB) - Allergen data
✅ nutritional_info (JSONB) - Nutrition facts
✅ deleted_at (TIMESTAMP) - Soft delete
✅ deleted_by (BIGINT) - User who deleted
✅ tenant_id (UUID) - Multi-tenancy support
```

**Relationships:**
- `dishes.restaurant_id` → `restaurants.id`
- `dishes.course_id` → `courses.id` (optional)
- `dish_prices.dish_id` → `dishes.id`
- `dish_modifiers.dish_id` → `dishes.id`

---

#### DISH PRICES (Size Variants)
**Table:** `menuca_v3.dish_prices`

**Columns (10 total):**
```
✅ id (BIGINT) - Primary key
✅ dish_id (BIGINT) - FK to dishes
✅ size_variant (VARCHAR) - Size name (e.g., "Small", "Large")
✅ price (NUMERIC) - Price for this size
✅ display_order (INTEGER) - Sort order (default: 0)
✅ is_active (BOOLEAN) - Available for ordering (default: true)
✅ created_at (TIMESTAMP) - Record creation
✅ updated_at (TIMESTAMP) - Last modification
✅ deleted_at (TIMESTAMP) - Soft delete
✅ deleted_by (BIGINT) - User who deleted
```

**Relationships:**
- `dish_prices.dish_id` → `dishes.id`

---

#### DISH MODIFIERS (Customizations)
**Table:** `menuca_v3.dish_modifiers`

**Columns (22 total):**
```
✅ id (BIGINT) - Primary key
✅ uuid (UUID) - Unique identifier
✅ restaurant_id (BIGINT) - FK to restaurants
✅ dish_id (BIGINT) - FK to dishes
✅ ingredient_id (BIGINT) - FK to ingredients
✅ ingredient_group_id (BIGINT) - FK to ingredient_groups (optional)
✅ modifier_group_id (BIGINT) - FK to modifier_groups (optional)
✅ legacy_v1_menuothers_id (INTEGER) - V1 migration ID
✅ modifier_type (VARCHAR) - Type classification
✅ is_included (BOOLEAN) - Included in base price (default: false)
✅ is_default (BOOLEAN) - Selected by default (default: false)
✅ display_order (INTEGER) - Sort order
✅ name (VARCHAR) - Override ingredient name
✅ price (NUMERIC) - Additional cost
✅ source_system (VARCHAR) - Migration tracking
✅ source_id (BIGINT) - Original system ID
✅ notes (TEXT) - Internal notes
✅ created_at (TIMESTAMP) - Record creation
✅ updated_at (TIMESTAMP) - Last modification
✅ tenant_id (UUID) - Multi-tenancy support
✅ deleted_at (TIMESTAMP) - Soft delete
✅ deleted_by (BIGINT) - User who deleted
```

**Relationships:**
- `dish_modifiers.restaurant_id` → `restaurants.id`
- `dish_modifiers.dish_id` → `dishes.id`
- `dish_modifiers.ingredient_id` → `ingredients.id`
- `dish_modifiers.ingredient_group_id` → `ingredient_groups.id`
- `dish_modifiers.modifier_group_id` → `modifier_groups.id`

---

#### INGREDIENTS (Modifier Options)
**Table:** `menuca_v3.ingredients`

**Columns (21 total):**
```
✅ id (BIGINT) - Primary key
✅ uuid (UUID) - Unique identifier
✅ restaurant_id (BIGINT) - FK to restaurants
✅ name (VARCHAR) - Ingredient name (e.g., "Extra Cheese")
✅ description (TEXT) - Ingredient details
✅ base_price (NUMERIC) - Default additional cost
✅ price_by_size (JSONB) - Size-based pricing
✅ ingredient_type (VARCHAR) - Classification
✅ display_order (INTEGER) - Sort order (default: 0)
✅ is_global (BOOLEAN) - Available across menu (default: false)
✅ is_active (BOOLEAN) - Available for selection (default: true)
✅ source_system (VARCHAR) - Migration tracking
✅ source_id (BIGINT) - Original system ID
✅ legacy_v1_id (INTEGER) - V1 migration ID
✅ legacy_v2_id (INTEGER) - V2 migration ID
✅ notes (TEXT) - Internal notes
✅ created_at (TIMESTAMP) - Record creation
✅ updated_at (TIMESTAMP) - Last modification
✅ tenant_id (UUID) - Multi-tenancy support
✅ deleted_at (TIMESTAMP) - Soft delete
✅ deleted_by (BIGINT) - User who deleted
```

**Relationships:**
- `ingredients.restaurant_id` → `restaurants.id`
- `dish_modifiers.ingredient_id` → `ingredients.id`

---

#### INGREDIENT GROUPS (Modifier Categories)
**Table:** `menuca_v3.ingredient_groups`

**Columns (23 total):**
```
✅ id (BIGINT) - Primary key
✅ uuid (UUID) - Unique identifier
✅ restaurant_id (BIGINT) - FK to restaurants
✅ name (VARCHAR) - Group name (e.g., "Toppings", "Sauces")
✅ group_type (VARCHAR) - Classification
✅ applies_to_course (BIGINT) - FK to courses (optional)
✅ applies_to_dish (BIGINT) - FK to dishes (optional)
✅ display_order (INTEGER) - Sort order (default: 0)
✅ min_selection (INTEGER) - Minimum required (default: 0)
✅ max_selection (INTEGER) - Maximum allowed (can be NULL)
✅ free_quantity (INTEGER) - Number of free selections (default: 0)
✅ allow_duplicates (BOOLEAN) - Allow same item multiple times (default: true)
✅ is_active (BOOLEAN) - Available for selection (default: true)
✅ source_system (VARCHAR) - Migration tracking
✅ source_id (BIGINT) - Original system ID
✅ legacy_v1_id (INTEGER) - V1 migration ID
✅ legacy_v2_id (INTEGER) - V2 migration ID
✅ notes (TEXT) - Internal notes
✅ created_at (TIMESTAMP) - Record creation
✅ updated_at (TIMESTAMP) - Last modification
✅ tenant_id (UUID) - Multi-tenancy support
✅ deleted_at (TIMESTAMP) - Soft delete
✅ deleted_by (BIGINT) - User who deleted
```

**Relationships:**
- `ingredient_groups.restaurant_id` → `restaurants.id`
- `ingredient_groups.applies_to_course` → `courses.id`
- `ingredient_groups.applies_to_dish` → `dishes.id`
- `dish_modifiers.ingredient_group_id` → `ingredient_groups.id`

---

### 🏷️ CUISINE TYPES
**Table:** `menuca_v3.cuisine_types`
**Status:** ✅ Exists
**Columns:**
- `id`
- `description`

**Issue:** No FK relationship to `restaurants` table yet

---

## 🔴 CRITICAL ISSUES

### Issue 1: Missing Customer-Facing Data
The `restaurants` table lacks columns needed for frontend display:
- Ratings, reviews, pricing, delivery times, images, descriptions

**Solution:** Run ALTER TABLE commands from `MISSING_DATABASE_COLUMNS_REPORT.md`

### Issue 2: Location Data Not Populated
`restaurant_locations` table exists but has no lat/long data.

**Solution:** Geocode addresses and populate coordinates

### ✅ Issue 3: Menu Structure Unknown - RESOLVED
**Status:** VERIFIED VIA MCP on 2025-10-24

Menu structure is now fully documented:
- `courses` - Menu categories
- `dishes` - Menu items
- `dish_prices` - Size variants and pricing
- `dish_modifiers` - Customization options
- `ingredients` - Individual modifier items
- `ingredient_groups` - Modifier categories with rules

---

## 📋 BEFORE WRITING ANY QUERY CHECKLIST

- [ ] Checked this file for table name
- [ ] Checked this file for column names
- [ ] Verified schema is `menuca_v3`
- [ ] Added `.schema('menuca_v3')` to query (for RPC calls)
- [ ] Logged query results to verify data structure
- [ ] Updated this file if discovered new schema info

---

## 🔄 UPDATE LOG

**2025-10-24 - MAJOR UPDATE (MCP Verification):**
- ✅ Documented `restaurants` table (31 columns)
- ✅ Documented `courses` table (17 columns)
- ✅ Documented `dishes` table (32 columns)
- ✅ Documented `dish_prices` table (10 columns)
- ✅ Documented `dish_modifiers` table (22 columns)
- ✅ Documented `ingredients` table (21 columns)
- ✅ Documented `ingredient_groups` table (23 columns)
- ✅ Verified all table/column names via Supabase MCP
- ✅ Mapped all relationships between menu tables
- ⚠️ Still missing: customer-facing restaurant columns
- ⚠️ Still missing: location lat/long data
