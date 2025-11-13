# Menu Data Tables Structure Report
**Database:** menuca_v3 (Supabase PostgreSQL)  
**Generated:** 2025-11-11  
**Purpose:** Complete reference for all tables storing courses, dishes, dish prices, modifiers, and modifier prices

---

## 📊 Executive Summary

The menu system uses **10 core tables** organized in a hierarchical structure:

```
Restaurants
    └── Courses (Menu Categories/Sections)
        └── Dishes (Menu Items)
            ├── Dish Prices (Size variants & pricing)
            ├── Dish Size Options (Advanced size configurations)
            ├── Modifier Groups (Grouping logic for modifiers)
            │   └── Dish Modifiers (Individual modifiers)
            │       └── Dish Modifier Prices (Modifier pricing by size)
            └── Translations (Multi-language support)
                ├── Course Translations
                ├── Dish Translations
                ├── Modifier Group Translations
                └── Dish Modifier Translations
```

### Data Volume (Current State)

| Table | Total Records | Active Records | Notes |
|-------|--------------|----------------|-------|
| **courses** | 2,613 | 2,309 | 304 soft-deleted |
| **dishes** | 22,504 | 22,504 | All active |
| **dish_prices** | 21,431 | 21,431 | All active |
| **dish_modifiers** | 188,990 | 188,990 | All active |
| **dish_modifier_prices** | 327,436 | 327,436 | All active |
| **modifier_groups** | 11,104 | 11,104 | All active |
| **dish_size_options** | 0 | 0 | Feature not yet used |
| **course_translations** | 0 | 0 | Translation system ready but unused |
| **dish_translations** | 0 | 0 | Translation system ready but unused |
| **dish_modifier_translations** | 0 | 0 | Translation system ready but unused |

---

## 🗂️ Table Details

### 1. COURSES (Menu Categories/Sections)

**Table:** `menuca_v3.courses`

**Purpose:** Menu categories that group dishes (e.g., "Appetizers", "Main Courses", "Desserts")

#### Schema
```sql
id                  BIGINT PRIMARY KEY
uuid                UUID UNIQUE NOT NULL
restaurant_id       BIGINT NOT NULL (FK → restaurants.id)
name                VARCHAR(255) NOT NULL
description         TEXT
display_order       INTEGER DEFAULT 0
is_active           BOOLEAN DEFAULT true
source_system       VARCHAR(10)           -- 'v1' or 'v2' (legacy system indicator)
source_id           BIGINT                -- ID from legacy system
legacy_v1_id        INTEGER               -- Original v1 ID
legacy_v2_id        INTEGER               -- Original v2 ID
notes               TEXT
created_at          TIMESTAMPTZ NOT NULL
updated_at          TIMESTAMPTZ
deleted_at          TIMESTAMPTZ          -- Soft delete timestamp
deleted_by          BIGINT               -- Admin who deleted
```

#### Key Indexes
- `idx_courses_restaurant` - Fast lookup by restaurant
- `idx_courses_restaurant_display` - Ordering courses within restaurant
- `idx_courses_active` - Filter active courses
- `idx_courses_legacy_v1/v2` - Legacy system migration tracking

#### Relationships
- **Parent:** `restaurants` (via `restaurant_id`)
- **Children:** 
  - `dishes` (via `course_id`)
  - `course_translations` (via `course_id`)

#### Row-Level Security (RLS)
- ✅ Public read access for active courses
- ✅ Restaurant admins can manage their courses
- ✅ Service role has full access

---

### 2. COURSE_TRANSLATIONS (Multi-Language Course Names)

**Table:** `menuca_v3.course_translations`

**Purpose:** Store course names and descriptions in multiple languages

#### Schema
```sql
id                  BIGINT PRIMARY KEY
uuid                UUID UNIQUE NOT NULL
course_id           BIGINT NOT NULL (FK → courses.id)
language_code       VARCHAR(5) NOT NULL  -- 'en', 'fr', 'es', 'zh', 'ar'
name                VARCHAR(500) NOT NULL
description         TEXT
created_at          TIMESTAMPTZ NOT NULL
updated_at          TIMESTAMPTZ
```

#### Key Constraints
- Unique constraint: `(course_id, language_code)` - One translation per language per course
- Language codes: English, French, Spanish, Chinese, Arabic

#### Current Status
- ⚠️ **Not yet in use** (0 records)
- ✅ Schema ready for multi-language support

---

### 3. DISHES (Menu Items)

**Table:** `menuca_v3.dishes`

**Purpose:** Individual menu items (e.g., "Margherita Pizza", "Caesar Salad")

#### Schema
```sql
id                      BIGINT PRIMARY KEY
uuid                    UUID UNIQUE NOT NULL
restaurant_id           BIGINT NOT NULL (FK → restaurants.id)
course_id               BIGINT (FK → courses.id)
name                    VARCHAR(255) NOT NULL
description             TEXT
ingredients             TEXT
sku                     VARCHAR(50)
display_order           INTEGER DEFAULT 0
image_url               VARCHAR(500)
is_combo                BOOLEAN DEFAULT false
has_customization       BOOLEAN DEFAULT false
quantity                VARCHAR(255)
is_upsell               BOOLEAN DEFAULT false
is_active               BOOLEAN DEFAULT true
source_system           VARCHAR(10)
source_id               BIGINT
legacy_v1_id            INTEGER
legacy_v2_id            INTEGER
notes                   TEXT
created_at              TIMESTAMPTZ NOT NULL
updated_at              TIMESTAMPTZ
unavailable_until_at    TIMESTAMPTZ           -- Temporary unavailability
search_vector           TSVECTOR (generated)  -- Full-text search
allergen_info           JSONB                 -- Allergen information
nutritional_info        JSONB                 -- Nutrition facts
deleted_at              TIMESTAMPTZ
deleted_by              BIGINT
```

#### Key Features
- **Full-Text Search:** `search_vector` enables fast text search on name + description
- **Allergen Tracking:** JSONB field for flexible allergen data
- **Nutritional Info:** JSONB field for nutritional facts
- **Combo Support:** `is_combo` flag for meal deals
- **Customization:** `has_customization` indicates if modifiers available

#### Key Indexes
- `idx_dishes_restaurant` - Fast lookup by restaurant
- `idx_dishes_course` - Group dishes by course
- `idx_dishes_restaurant_active_course` - Optimized for menu display
- `idx_dishes_search` - Full-text search index
- `idx_dishes_allergens` - GIN index on allergen_info
- `idx_dishes_nutrition` - GIN index on nutritional_info

#### Relationships
- **Parent:** 
  - `restaurants` (via `restaurant_id`)
  - `courses` (via `course_id`)
- **Children:** 
  - `dish_prices` (via `dish_id`)
  - `dish_size_options` (via `dish_id`)
  - `dish_modifiers` (via `dish_id`)
  - `modifier_groups` (via `dish_id`)
  - `dish_translations` (via `dish_id`)
  - `order_items` (via `dish_id`)

#### Triggers
- `check_dish_pricing` - Ensures at least one price exists
- `audit_dishes_changes` - Logs all changes to audit_log
- `notify_dishes_change` - Real-time notifications via Supabase Realtime

---

### 4. DISH_TRANSLATIONS (Multi-Language Dish Details)

**Table:** `menuca_v3.dish_translations`

**Purpose:** Store dish names, descriptions, and ingredients in multiple languages

#### Schema
```sql
id                  BIGINT PRIMARY KEY
uuid                UUID UNIQUE NOT NULL
dish_id             BIGINT NOT NULL (FK → dishes.id)
language_code       VARCHAR(5) NOT NULL
name                VARCHAR(500) NOT NULL
description         TEXT
ingredients         TEXT
created_at          TIMESTAMPTZ NOT NULL
updated_at          TIMESTAMPTZ
```

#### Current Status
- ⚠️ **Not yet in use** (0 records)
- ✅ Schema ready for multi-language support

---

### 5. DISH_PRICES (Basic Dish Pricing)

**Table:** `menuca_v3.dish_prices`

**Purpose:** Store prices for dishes, including size variants (e.g., "Small", "Large")

#### Schema
```sql
id                  BIGINT PRIMARY KEY
dish_id             BIGINT NOT NULL (FK → dishes.id)
size_variant        VARCHAR(50)           -- e.g., "Small", "Medium", "Large", null for single-size
price               NUMERIC(10,2) NOT NULL
display_order       INTEGER DEFAULT 0
is_active           BOOLEAN DEFAULT true
created_at          TIMESTAMPTZ
updated_at          TIMESTAMPTZ
deleted_at          TIMESTAMPTZ
deleted_by          BIGINT
```

#### Pricing Logic
- **Single-size dishes:** `size_variant = NULL`, one price record
- **Multi-size dishes:** Multiple records with different `size_variant` values
- `display_order` controls the order sizes appear in UI

#### Key Indexes
- `idx_dish_prices_dish_id` - Fast lookup of all prices for a dish
- `idx_dish_prices_lookup` - Optimized for menu display (dish_id + active + order)

#### Relationships
- **Parent:** `dishes` (via `dish_id`)

#### Usage Example
```sql
-- Pizza with 3 sizes
dish_id: 123, size_variant: "Small (10\")",  price: 12.99, display_order: 1
dish_id: 123, size_variant: "Medium (12\")", price: 15.99, display_order: 2
dish_id: 123, size_variant: "Large (14\")",  price: 18.99, display_order: 3

-- Single-size pasta
dish_id: 456, size_variant: NULL, price: 14.99, display_order: 1
```

---

### 6. DISH_SIZE_OPTIONS (Advanced Size Configuration)

**Table:** `menuca_v3.dish_size_options`

**Purpose:** Advanced size configuration with nutritional data (alternative to dish_prices)

#### Schema
```sql
id                  BIGINT PRIMARY KEY
uuid                UUID UNIQUE
dish_id             BIGINT NOT NULL (FK → dishes.id)
size_code           size_type NOT NULL    -- ENUM: small, medium, large, xlarge, etc.
size_label          VARCHAR(100) NOT NULL
price               NUMERIC(10,2) NOT NULL
calories            INTEGER
protein_grams       NUMERIC(10,2)
carbs_grams         NUMERIC(10,2)
fat_grams           NUMERIC(10,2)
is_default          BOOLEAN DEFAULT false
display_order       INTEGER DEFAULT 0
created_at          TIMESTAMPTZ
updated_at          TIMESTAMPTZ
created_by          BIGINT (FK → admin_users.id)
updated_by          BIGINT (FK → admin_users.id)
deleted_at          TIMESTAMPTZ
deleted_by          BIGINT (FK → admin_users.id)
```

#### Current Status
- ⚠️ **Not currently in use** (0 records)
- ✅ More advanced than `dish_prices` (includes nutrition)
- 🔄 May replace `dish_prices` in future version

#### Key Features
- Standardized size codes (ENUM type)
- Nutritional information per size
- Audit trail (created_by, updated_by, deleted_by)

---

### 7. MODIFIER_GROUPS (Modifier Organization)

**Table:** `menuca_v3.modifier_groups`

**Purpose:** Group and organize modifiers for dishes (e.g., "Choose Size", "Add Toppings", "Select Sauce")

#### Schema
```sql
id                  BIGINT PRIMARY KEY
dish_id             BIGINT NOT NULL (FK → dishes.id)
name                VARCHAR(100) NOT NULL
is_required         BOOLEAN DEFAULT false  -- Must customer select from this group?
min_selections      INTEGER DEFAULT 0      -- Minimum selections required
max_selections      INTEGER DEFAULT 1      -- Maximum selections allowed
display_order       INTEGER DEFAULT 0
parent_modifier_id  BIGINT                -- For nested/conditional modifiers
instructions        TEXT                  -- Instructions for customer
created_at          TIMESTAMPTZ NOT NULL
updated_at          TIMESTAMPTZ NOT NULL
```

#### Key Features
- **Selection Rules:** Min/max selections enforce business logic
- **Required Groups:** `is_required=true` forces customer selection
- **Nested Modifiers:** `parent_modifier_id` enables conditional modifiers
- **Display Control:** `display_order` manages UI presentation

#### Relationships
- **Parent:** `dishes` (via `dish_id`)
- **Children:** 
  - `dish_modifiers` (via `modifier_group_id`)
  - `modifier_group_translations` (via `modifier_group_id`)

#### Usage Examples
```sql
-- Required size selection (must pick exactly 1)
name: "Choose Size"
is_required: true
min_selections: 1
max_selections: 1

-- Optional extra toppings (pick up to 5)
name: "Add Extra Toppings"
is_required: false
min_selections: 0
max_selections: 5

-- Sauce selection with minimum (pick 1-3)
name: "Choose Your Sauces"
is_required: true
min_selections: 1
max_selections: 3
```

---

### 8. MODIFIER_GROUP_TRANSLATIONS

**Table:** `menuca_v3.modifier_group_translations`

**Purpose:** Multi-language support for modifier group names and instructions

#### Schema
```sql
id                  BIGINT PRIMARY KEY
modifier_group_id   BIGINT NOT NULL (FK → modifier_groups.id)
language_code       VARCHAR(5) NOT NULL
name                VARCHAR(500) NOT NULL
instructions        TEXT
created_at          TIMESTAMPTZ NOT NULL
updated_at          TIMESTAMPTZ
```

#### Current Status
- ⚠️ **Not yet in use** (0 records)
- ✅ Schema ready for multi-language support

---

### 9. DISH_MODIFIERS (Individual Modifiers)

**Table:** `menuca_v3.dish_modifiers`

**Purpose:** Individual modifier options (e.g., "Extra Cheese", "No Onions", "Gluten-Free Crust")

#### Schema
```sql
id                  BIGINT PRIMARY KEY
uuid                UUID UNIQUE NOT NULL
restaurant_id       BIGINT NOT NULL (FK → restaurants.id)
dish_id             BIGINT NOT NULL (FK → dishes.id)
modifier_group_id   BIGINT (FK → modifier_groups.id)
name                VARCHAR(100)
modifier_type       VARCHAR(50)           -- Category: 'extras', 'sauces', 'cooking_method', etc.
display_order       INTEGER
is_default          BOOLEAN DEFAULT false -- Pre-selected by default?
source_system       VARCHAR(10)
source_id           BIGINT
created_at          TIMESTAMPTZ NOT NULL
updated_at          TIMESTAMPTZ
deleted_at          TIMESTAMPTZ
deleted_by          BIGINT
```

#### Modifier Types (Validated by CHECK constraint)
- `custom_ingredients` - Ingredient additions/removals
- `extras` - Additional items (cheese, bacon, etc.)
- `side_dishes` - Side items included with dish
- `drinks` - Beverage options
- `sauces` - Sauce selections
- `bread` - Bread type options
- `dressing` - Salad dressing choices
- `cooking_method` - How item is prepared
- `other` - Miscellaneous

#### Key Features
- **Default Selections:** `is_default=true` pre-selects modifiers
- **Group Association:** Links to `modifier_groups` for organization
- **Type Classification:** Categorizes modifiers for filtering/display

#### Key Indexes
- `idx_dish_modifiers_dish` - Fast lookup by dish
- `idx_dish_modifiers_modifier_group` - Group modifier lookups
- `idx_dish_modifiers_restaurant` - Restaurant-wide modifier queries
- `idx_dish_modifiers_type` - Filter by modifier type
- `idx_dish_modifiers_group_id_active` - Active modifiers by group

#### Relationships
- **Parent:** 
  - `dishes` (via `dish_id`)
  - `restaurants` (via `restaurant_id`)
  - `modifier_groups` (via `modifier_group_id`)
- **Children:** 
  - `dish_modifier_prices` (via `dish_modifier_id`)
  - `dish_modifier_translations` (via `dish_modifier_id`)

---

### 10. DISH_MODIFIER_TRANSLATIONS

**Table:** `menuca_v3.dish_modifier_translations`

**Purpose:** Multi-language support for modifier names

#### Schema
```sql
id                  BIGINT PRIMARY KEY
dish_modifier_id    BIGINT NOT NULL (FK → dish_modifiers.id)
language_code       VARCHAR(5) NOT NULL
name                VARCHAR(500) NOT NULL
created_at          TIMESTAMPTZ NOT NULL
updated_at          TIMESTAMPTZ
```

#### Current Status
- ⚠️ **Not yet in use** (0 records)
- ✅ Schema ready for multi-language support

---

### 11. DISH_MODIFIER_PRICES (Modifier Pricing by Size)

**Table:** `menuca_v3.dish_modifier_prices`

**Purpose:** Store prices for modifiers, with support for different dish sizes

#### Schema
```sql
id                  BIGINT PRIMARY KEY
uuid                UUID UNIQUE NOT NULL
dish_modifier_id    BIGINT NOT NULL (FK → dish_modifiers.id)
dish_id             BIGINT NOT NULL (FK → dishes.id)
restaurant_id       BIGINT NOT NULL (FK → restaurants.id)
size_variant        VARCHAR(50)           -- Matches dish_prices.size_variant
price               NUMERIC(10,2) DEFAULT 0.00
display_order       INTEGER DEFAULT 1
is_active           BOOLEAN DEFAULT true
source_system       VARCHAR(20)
created_at          TIMESTAMPTZ NOT NULL
updated_at          TIMESTAMPTZ
deleted_at          TIMESTAMPTZ
deleted_by          BIGINT
```

#### Pricing Logic
- **Free modifiers:** `price = 0.00` (e.g., "No Onions")
- **Fixed-price modifiers:** Same price across all sizes (e.g., "+$2.00 Extra Cheese")
- **Size-based pricing:** Different prices per size (e.g., Small pizza toppings cheaper than Large)

#### Key Features
- **Size Matching:** `size_variant` matches `dish_prices.size_variant`
- **Validation:** Unique constraint on `(dish_modifier_id, size_variant)`
- **Non-negative prices:** CHECK constraint ensures `price >= 0`

#### Key Indexes
- `idx_dish_modifier_prices_modifier` - Lookup all prices for a modifier
- `idx_dish_modifier_prices_dish` - Lookup all modifier prices for a dish
- `idx_dish_modifier_prices_restaurant_active` - Restaurant-wide active prices
- `unique_modifier_price` - Ensures one price per modifier per size

#### Relationships
- **Parent:** 
  - `dish_modifiers` (via `dish_modifier_id`)
  - `dishes` (via `dish_id`)
  - `restaurants` (via `restaurant_id`)

#### Usage Example
```sql
-- Extra cheese pricing by pizza size
dish_id: 123 (Margherita Pizza)
dish_modifier_id: 789 (Extra Cheese)

size_variant: "Small (10\")",  price: 1.50
size_variant: "Medium (12\")", price: 2.00
size_variant: "Large (14\")",  price: 2.50

-- Free modifier (same for all sizes)
dish_id: 123
dish_modifier_id: 790 (No Onions)

size_variant: "Small (10\")",  price: 0.00
size_variant: "Medium (12\")", price: 0.00
size_variant: "Large (14\")",  price: 0.00
```

---

## 🔗 Relationship Diagram

```
┌─────────────────┐
│   restaurants   │
└────────┬────────┘
         │
         ├──────────────────────────────┐
         │                              │
    ┌────▼────────┐              ┌─────▼────────┐
    │   courses   │              │dish_modifiers│
    └────┬────────┘              └──────────────┘
         │                              (standalone restaurant modifiers)
    ┌────▼────────┐
    │   dishes    │
    └────┬────────┘
         │
         ├─────────────┬──────────────┬──────────────────┬──────────────────┐
         │             │              │                  │                  │
    ┌────▼──────┐ ┌───▼──────┐ ┌────▼───────────┐ ┌────▼────────────┐ ┌──▼───────────┐
    │dish_prices│ │dish_size_│ │modifier_groups │ │dish_translations│ │dish_allergens│
    └───────────┘ │  options │ └────┬───────────┘ └─────────────────┘ └──────────────┘
                  └──────────┘      │
                                    │
                              ┌─────▼──────────────┐
                              │  dish_modifiers    │
                              └─────┬──────────────┘
                                    │
                              ┌─────▼─────────────────┐
                              │dish_modifier_prices   │
                              └───────────────────────┘
```

---

## 🔍 Common Query Patterns

### Get Complete Menu for a Restaurant

```sql
-- Get all active courses with dishes and pricing
SELECT 
    c.id as course_id,
    c.name as course_name,
    c.display_order as course_order,
    d.id as dish_id,
    d.name as dish_name,
    d.description,
    d.image_url,
    dp.size_variant,
    dp.price
FROM menuca_v3.courses c
LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id
LEFT JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id
WHERE c.restaurant_id = 349
    AND c.is_active = true
    AND c.deleted_at IS NULL
    AND d.is_active = true
    AND d.deleted_at IS NULL
    AND dp.is_active = true
    AND dp.deleted_at IS NULL
ORDER BY c.display_order, d.display_order, dp.display_order;
```

### Get Dish with All Modifiers and Prices

```sql
-- Get complete dish details including modifier groups and pricing
SELECT 
    d.id as dish_id,
    d.name as dish_name,
    mg.id as modifier_group_id,
    mg.name as modifier_group_name,
    mg.is_required,
    mg.min_selections,
    mg.max_selections,
    dm.id as modifier_id,
    dm.name as modifier_name,
    dm.modifier_type,
    dm.is_default,
    dmp.size_variant,
    dmp.price as modifier_price
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.modifier_groups mg ON d.id = mg.dish_id
LEFT JOIN menuca_v3.dish_modifiers dm ON mg.id = dm.modifier_group_id
LEFT JOIN menuca_v3.dish_modifier_prices dmp ON dm.id = dmp.dish_modifier_id
WHERE d.id = 12345
    AND d.deleted_at IS NULL
    AND (dm.deleted_at IS NULL OR dm.id IS NULL)
    AND (dmp.deleted_at IS NULL OR dmp.id IS NULL)
ORDER BY mg.display_order, dm.display_order, dmp.display_order;
```

### Get Restaurant Menu Summary Statistics

```sql
-- Count courses, dishes, and modifiers per restaurant
SELECT 
    r.id as restaurant_id,
    r.name as restaurant_name,
    COUNT(DISTINCT c.id) as total_courses,
    COUNT(DISTINCT d.id) as total_dishes,
    COUNT(DISTINCT dm.id) as total_modifiers,
    COUNT(DISTINCT dp.id) as total_dish_prices,
    COUNT(DISTINCT dmp.id) as total_modifier_prices
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.courses c ON r.id = c.restaurant_id AND c.deleted_at IS NULL
LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id AND d.deleted_at IS NULL
LEFT JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id AND dp.deleted_at IS NULL
LEFT JOIN menuca_v3.dish_modifiers dm ON d.id = dm.dish_id AND dm.deleted_at IS NULL
LEFT JOIN menuca_v3.dish_modifier_prices dmp ON dm.id = dmp.dish_modifier_id AND dmp.deleted_at IS NULL
WHERE r.id = 349
GROUP BY r.id, r.name;
```

---

## 🚨 Important Notes

### Soft Deletes
All primary tables use soft deletes via `deleted_at` timestamp:
- ✅ Never use `DELETE FROM` - always use `UPDATE SET deleted_at = NOW()`
- ✅ Always filter by `deleted_at IS NULL` in queries
- ✅ Include `deleted_by` to track who deleted the record

### Row-Level Security (RLS)
All tables have RLS policies:
- **Public read:** Anonymous and authenticated users can read active records
- **Restaurant admin:** Can manage records for their assigned restaurants
- **Service role:** Full access (bypasses RLS)

### Real-Time Notifications
These tables have real-time triggers:
- `courses` → `notify_menu_change()`
- `dishes` → `notify_menu_change()`
- `dish_prices` → `notify_menu_change()`

Changes are broadcast via Supabase Realtime to connected clients.

### Data Integrity
- ✅ Foreign keys with `ON DELETE CASCADE` for child records
- ✅ Check constraints on prices (non-negative)
- ✅ Unique constraints on translations (one per language)
- ✅ Audit triggers on dishes table

### Legacy System Migration
Tables include fields for tracking legacy data:
- `source_system` - 'v1' or 'v2'
- `source_id` - ID from legacy system
- `legacy_v1_id` / `legacy_v2_id` - Original IDs

These enable:
- ✅ Data lineage tracking
- ✅ Duplicate detection
- ✅ Migration validation

---

## 📝 Future Enhancements

### Translation System
- **Current Status:** Schema exists but unused (0 records)
- **Next Steps:** 
  1. Populate English translations from main tables
  2. Add French translations for Quebec restaurants
  3. Implement UI language switching

### Dish Size Options
- **Current Status:** Not in use (0 records)
- **Consideration:** Replace `dish_prices` with `dish_size_options` for:
  - Standardized size codes (ENUM)
  - Nutritional information
  - Better audit trail

### Allergen & Nutrition
- **Current Status:** JSONB fields exist but underutilized
- **Next Steps:**
  1. Standardize allergen data format
  2. Import nutritional data from external sources
  3. Create UI for allergen filtering

---

## 🔐 Security Considerations

### Access Control Hierarchy
1. **Service Role:** Full access (backend operations only)
2. **Restaurant Admin:** CRUD on their restaurant's data only
3. **Authenticated Users:** Read-only on active records
4. **Anonymous Users:** Read-only on active records

### API Access Patterns
- ✅ Use Supabase REST API with JWT tokens (enforces RLS)
- ❌ Do NOT use direct psql for testing (bypasses RLS, auth.uid() is NULL)
- ✅ Use curl with proper Authorization headers for testing

### Data Protection
- Soft deletes preserve data integrity
- Audit logs track all changes (dishes table)
- deleted_by field tracks who deleted records

---

## 📧 Contact & Support

**Database Owner:** Santiago  
**Project:** Menu.ca V3 Migration  
**Documentation Location:** `reports/database/MENU_DATA_TABLES_STRUCTURE.md`

---

*Report generated by analyzing menuca_v3 schema on Supabase project `nthpbtdjhhnwfxqsxbvy`*

