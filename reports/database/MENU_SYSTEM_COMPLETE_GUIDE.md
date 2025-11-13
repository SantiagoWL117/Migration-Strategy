# Menu System Complete Guide

**Database:** menuca_v3 (Supabase PostgreSQL)  
**Project:** Menu.ca V3  
**Generated:** 2025-11-11  
**Status:** ✅ Connection Verified & Documented

---

## 📚 Documentation Index

This guide provides complete documentation for all tables related to courses, dishes, dish prices, modifiers, and modifier prices in the menuca_v3 database.

### Core Documentation Files

| Document | Purpose | Best For |
|----------|---------|----------|
| **[MENU_DATA_TABLES_STRUCTURE.md](MENU_DATA_TABLES_STRUCTURE.md)** | Complete technical reference | Understanding schema, relationships, RLS policies |
| **[MENU_TABLES_QUICK_REFERENCE.md](MENU_TABLES_QUICK_REFERENCE.md)** | Quick lookup guide | Common queries, field reference, use cases |
| **[MENU_TABLES_REAL_WORLD_EXAMPLES.md](MENU_TABLES_REAL_WORLD_EXAMPLES.md)** | Real data examples | Understanding how data flows in practice |

---

## 🗂️ Complete Table List

### Primary Menu Tables (6 Tables)

| # | Table Name | Records | Purpose |
|---|------------|---------|---------|
| 1 | `courses` | 2,309 active | Menu categories/sections (Appetizers, Main Courses, etc.) |
| 2 | `dishes` | 22,504 | Individual menu items (Pizza, Pasta, etc.) |
| 3 | `dish_prices` | 21,431 | Dish pricing with size variants |
| 4 | `modifier_groups` | 11,104 | Grouping logic for modifiers (Choose Size, Add Toppings) |
| 5 | `dish_modifiers` | 188,990 | Individual customization options (Extra Cheese, No Onions) |
| 6 | `dish_modifier_prices` | 327,436 | Modifier pricing by size variant |

### Translation Tables (4 Tables - Ready but Unused)

| # | Table Name | Records | Purpose |
|---|------------|---------|---------|
| 7 | `course_translations` | 0 | Multi-language course names |
| 8 | `dish_translations` | 0 | Multi-language dish details |
| 9 | `modifier_group_translations` | 0 | Multi-language group names |
| 10 | `dish_modifier_translations` | 0 | Multi-language modifier names |

### Advanced Features (1 Table - Future Use)

| # | Table Name | Records | Purpose |
|---|------------|---------|---------|
| 11 | `dish_size_options` | 0 | Advanced size config with nutrition data |

---

## 🏗️ System Architecture

### Data Hierarchy

```
Restaurant
  ↓
Courses (Menu Sections)
  ↓
Dishes (Menu Items)
  ↓
  ├─→ Dish Prices (Size-based pricing)
  └─→ Modifier Groups (Customization categories)
       ↓
       Dish Modifiers (Individual options)
         ↓
         Dish Modifier Prices (Option pricing by size)
```

### Key Relationships

```sql
-- Core relationships
restaurants (1) → (many) courses
courses (1) → (many) dishes
dishes (1) → (many) dish_prices
dishes (1) → (many) modifier_groups
modifier_groups (1) → (many) dish_modifiers
dish_modifiers (1) → (many) dish_modifier_prices

-- Cross-references
dish_modifiers → dishes (direct reference)
dish_modifier_prices → dishes (direct reference)
```

---

## 📊 Data Volume Analysis

### Overall Statistics
- **Total Courses:** 2,613 (2,309 active, 304 soft-deleted)
- **Total Dishes:** 22,504 (all active)
- **Total Prices:** 21,431 (all active)
- **Total Modifiers:** 188,990 (all active)
- **Total Modifier Prices:** 327,436 (all active)

### Sample Restaurant Breakdown

**Milano (ID: 349)** - Most complete dataset:
- 27 courses
- 196 dishes
- 439 dish prices (avg 2.2 per dish)
- 6,095 modifiers
- 11,225 modifier prices (avg 1.8 per modifier)

**Lemon Grass Restaurant (ID: 102)** - Smaller dataset:
- 12 courses
- 68 dishes
- 98 dish prices
- 2 modifiers
- 2 modifier prices

---

## 💰 Pricing Structure

### Dish Pricing (`dish_prices`)

**Single-size dish:**
```
dish_id: 100
size_variant: NULL
price: $14.99
```

**Multi-size dish:**
```
dish_id: 200
  → size_variant: "Small",  price: $12.99
  → size_variant: "Medium", price: $15.99
  → size_variant: "Large",  price: $18.99
```

### Modifier Pricing (`dish_modifier_prices`)

**Free modifier (preference):**
```
modifier_id: 300
  → size_variant: "Small",  price: $0.00
  → size_variant: "Medium", price: $0.00
  → size_variant: "Large",  price: $0.00
```

**Fixed-price modifier:**
```
modifier_id: 400 (e.g., "Bacon")
  → size_variant: "Small",  price: $0.99
  → size_variant: "Medium", price: $0.99
  → size_variant: "Large",  price: $0.99
```

**Size-scaled modifier:**
```
modifier_id: 500 (e.g., "Extra Cheese")
  → size_variant: "Small",  price: $1.50
  → size_variant: "Medium", price: $2.00
  → size_variant: "Large",  price: $2.50
```

---

## 🎯 Common Use Cases

### 1. Display Restaurant Menu
**Tables:** `courses` → `dishes` → `dish_prices`

```sql
SELECT 
    c.name as course,
    d.name as dish,
    d.description,
    dp.size_variant,
    dp.price
FROM menuca_v3.courses c
JOIN menuca_v3.dishes d ON c.id = d.course_id
JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id
WHERE c.restaurant_id = ?
    AND c.is_active = true
    AND c.deleted_at IS NULL
    AND d.is_active = true
    AND d.deleted_at IS NULL
    AND dp.is_active = true
    AND dp.deleted_at IS NULL
ORDER BY c.display_order, d.display_order, dp.display_order;
```

### 2. Display Dish Customization Options
**Tables:** `dishes` → `modifier_groups` → `dish_modifiers` → `dish_modifier_prices`

```sql
SELECT 
    mg.name as group_name,
    mg.is_required,
    mg.min_selections,
    mg.max_selections,
    dm.name as modifier_name,
    dmp.size_variant,
    dmp.price
FROM menuca_v3.modifier_groups mg
JOIN menuca_v3.dish_modifiers dm ON mg.id = dm.modifier_group_id
JOIN menuca_v3.dish_modifier_prices dmp ON dm.id = dmp.dish_modifier_id
WHERE mg.dish_id = ?
    AND dm.deleted_at IS NULL
    AND dmp.is_active = true
ORDER BY mg.display_order, dm.display_order;
```

### 3. Calculate Order Total
**Logic:**
```javascript
// Get base dish price
const baseDishPrice = dish_prices
    .where(size_variant === selectedSize)
    .price;

// Get modifier prices for selected size
const modifierTotal = selected_modifiers
    .map(mod => dish_modifier_prices
        .where(modifier_id === mod.id && size_variant === selectedSize)
        .price
    )
    .sum();

const orderTotal = baseDishPrice + modifierTotal;
```

---

## 🔒 Security & Access Control

### Row-Level Security (RLS) Summary

**All tables have RLS policies:**

1. **Public Read Access**
   - Anonymous and authenticated users
   - Can read active, non-deleted records
   - `WHERE is_active = true AND deleted_at IS NULL`

2. **Restaurant Admin Access**
   - Can CRUD records for their assigned restaurants
   - Verified via `admin_user_restaurants` join
   - Must be active admin with valid auth token

3. **Service Role Access**
   - Full unrestricted access
   - Bypasses all RLS policies
   - Backend operations only

### Testing Access Patterns

✅ **CORRECT - Test with Auth:**
```bash
# Create user and get JWT token
curl -X POST "https://PROJECT.supabase.co/auth/v1/signup" \
  -H "apikey: ANON_KEY" \
  -d '{"email": "test@example.com", "password": "pass123"}'

# Test function with JWT
curl -X POST "https://PROJECT.supabase.co/rest/v1/rpc/function_name" \
  -H "Authorization: Bearer USER_JWT_TOKEN" \
  -H "apikey: ANON_KEY"
```

❌ **WRONG - Using psql:**
```bash
# This bypasses RLS and auth.uid() returns NULL
psql "CONNECTION_STRING" -c "SELECT * FROM dishes;"
```

---

## 🚨 Important Rules & Best Practices

### 1. Soft Deletes
✅ **ALWAYS use soft deletes:**
```sql
UPDATE menuca_v3.dishes 
SET deleted_at = NOW(), 
    deleted_by = <admin_user_id>
WHERE id = 123;
```

❌ **NEVER use hard deletes:**
```sql
DELETE FROM menuca_v3.dishes WHERE id = 123;  -- DON'T DO THIS!
```

### 2. Querying Active Records
✅ **ALWAYS filter soft-deleted records:**
```sql
WHERE deleted_at IS NULL
  AND is_active = true
```

### 3. Size Variant Consistency
✅ **Ensure size variants match:**
```sql
-- If dish has these sizes:
dish_prices: ["Small", "Medium", "Large"]

-- Modifiers MUST have prices for the same sizes:
dish_modifier_prices: ["Small", "Medium", "Large"]
```

### 4. Real-Time Notifications
**Tables with real-time triggers:**
- `courses` → broadcasts menu changes
- `dishes` → broadcasts menu changes
- `dish_prices` → broadcasts price changes

Subscribe to changes:
```javascript
const subscription = supabase
    .channel('menu-changes')
    .on('postgres_changes', 
        { event: '*', schema: 'menuca_v3', table: 'dishes' },
        (payload) => console.log('Dish changed:', payload)
    )
    .subscribe();
```

---

## 🔧 Database Connection

### Supabase Project Details
- **Project Ref:** `nthpbtdjhhnwfxqsxbvy`
- **Host:** `db.nthpbtdjhhnwfxqsxbvy.supabase.co`
- **Database:** PostgreSQL 17.4
- **Schema:** `menuca_v3`

### Connection Methods

**1. Direct psql (Debugging Only):**
```bash
"C:\Program Files\PostgreSQL\17\bin\psql.exe" \
  "postgresql://postgres:PASSWORD@db.PROJECT.supabase.co:5432/postgres" \
  -c "SELECT COUNT(*) FROM menuca_v3.dishes;"
```

**2. Supabase REST API (Production Testing):**
```bash
curl -X POST "https://PROJECT.supabase.co/rest/v1/rpc/function_name" \
  -H "Authorization: Bearer JWT_TOKEN" \
  -H "apikey: ANON_KEY"
```

**3. Supabase CLI (Management):**
```bash
export SUPABASE_ACCESS_TOKEN="TOKEN"
supabase projects list
supabase functions list
```

**Full connection guide:** `.claude/Supabase Connection/SUPABASE-QUICKSTART-CONNECTION.md`

---

## 📈 Schema Evolution

### Current State (V3)
- ✅ Core menu system fully implemented
- ✅ Soft delete functionality active
- ✅ RLS policies configured
- ✅ Real-time triggers enabled
- ✅ Audit logging (dishes table)
- ⚠️ Translation system ready but unused
- ⚠️ `dish_size_options` table defined but unused

### Legacy System Tracking
All tables include migration tracking fields:
- `source_system` - 'v1' or 'v2'
- `source_id` - Original ID from legacy system
- `legacy_v1_id` / `legacy_v2_id` - Legacy identifiers

This enables:
- Data lineage tracking
- Duplicate detection
- Migration verification

### Future Enhancements

**Priority 1: Multi-Language Support**
- Populate translation tables
- Add French translations (Quebec market)
- Implement language switching in UI

**Priority 2: Nutritional Data**
- Utilize JSONB fields (`allergen_info`, `nutritional_info`)
- Import from external sources
- Build allergen filtering

**Priority 3: Advanced Size Options**
- Migrate from `dish_prices` to `dish_size_options`
- Add nutritional data per size
- Standardize size codes

---

## 🧪 Sample Queries

### Get menu statistics for a restaurant
```sql
SELECT 
    COUNT(DISTINCT c.id) as courses,
    COUNT(DISTINCT d.id) as dishes,
    COUNT(DISTINCT dp.id) as prices,
    COUNT(DISTINCT dm.id) as modifiers
FROM menuca_v3.courses c
LEFT JOIN menuca_v3.dishes d ON c.id = d.course_id
LEFT JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id
LEFT JOIN menuca_v3.dish_modifiers dm ON d.id = dm.dish_id
WHERE c.restaurant_id = 349
    AND c.deleted_at IS NULL
    AND d.deleted_at IS NULL
    AND dp.deleted_at IS NULL
    AND dm.deleted_at IS NULL;
```

### Find dishes with most modifiers
```sql
SELECT 
    d.name,
    COUNT(dm.id) as modifier_count
FROM menuca_v3.dishes d
JOIN menuca_v3.dish_modifiers dm ON d.id = dm.dish_id
WHERE d.restaurant_id = 349
    AND d.deleted_at IS NULL
    AND dm.deleted_at IS NULL
GROUP BY d.id, d.name
ORDER BY modifier_count DESC
LIMIT 10;
```

### Get dishes without pricing (data quality check)
```sql
SELECT d.id, d.name
FROM menuca_v3.dishes d
LEFT JOIN menuca_v3.dish_prices dp ON d.id = dp.dish_id
WHERE d.deleted_at IS NULL
    AND d.is_active = true
    AND dp.id IS NULL;
```

---

## 🎓 Learning Path

### For New Developers

1. **Start Here:** Read `MENU_TABLES_QUICK_REFERENCE.md`
2. **Understand Relationships:** Review architecture diagrams in this guide
3. **See Real Examples:** Study `MENU_TABLES_REAL_WORLD_EXAMPLES.md`
4. **Deep Dive:** Reference `MENU_DATA_TABLES_STRUCTURE.md` for details
5. **Connect & Test:** Follow `.claude/Supabase Connection/SUPABASE-QUICKSTART-CONNECTION.md`

### For Database Admins

1. **Schema Overview:** `MENU_DATA_TABLES_STRUCTURE.md` (full technical specs)
2. **Security Review:** RLS policies section in structure doc
3. **Data Integrity:** Soft delete patterns, foreign keys, constraints
4. **Migration Tracking:** Legacy system fields documentation

### For Frontend Developers

1. **Quick Reference:** `MENU_TABLES_QUICK_REFERENCE.md` (common queries)
2. **Real Examples:** `MENU_TABLES_REAL_WORLD_EXAMPLES.md` (actual data)
3. **API Testing:** Supabase connection guide for REST API usage
4. **Real-Time:** Real-time notifications section above

---

## 📞 Support & Resources

### Documentation Locations
- **This Guide:** `reports/database/MENU_SYSTEM_COMPLETE_GUIDE.md`
- **Technical Specs:** `reports/database/MENU_DATA_TABLES_STRUCTURE.md`
- **Quick Reference:** `reports/database/MENU_TABLES_QUICK_REFERENCE.md`
- **Real Examples:** `reports/database/MENU_TABLES_REAL_WORLD_EXAMPLES.md`
- **Connection Guide:** `.claude/Supabase Connection/SUPABASE-QUICKSTART-CONNECTION.md`

### Project Context
- **Project:** Menu.ca V3 Migration
- **Database:** menuca_v3 on Supabase
- **Owner:** Santiago
- **Status:** Active Development

---

## ✅ Verification Checklist

When working with the menu system, verify:

- [ ] Connection to Supabase established
- [ ] Querying `menuca_v3` schema
- [ ] Always filtering by `deleted_at IS NULL`
- [ ] Always checking `is_active = true` for public-facing queries
- [ ] Using proper authentication (JWT tokens, not raw psql)
- [ ] Testing with restaurant admin or service role for write operations
- [ ] Size variants match between `dish_prices` and `dish_modifier_prices`
- [ ] Modifier groups have proper `min_selections`/`max_selections` rules
- [ ] Soft deletes used instead of hard deletes
- [ ] Audit fields populated (`created_by`, `updated_by`, `deleted_by`)

---

## 🔄 Last Updated

**Date:** 2025-11-11  
**Generated By:** Claude (Cursor AI)  
**Database Version:** PostgreSQL 17.4 on Supabase  
**Schema Version:** menuca_v3 (current production)

---

*Complete documentation for Menu.ca V3 menu system tables*

