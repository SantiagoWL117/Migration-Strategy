# MenuCA V3 Database Analysis Report

**Generated:** October 10, 2025  
**Database:** menuca_v3 (Supabase)  
**Total Tables:** 50  
**Total Records:** ~150,000+

---

## Table of Contents
1. [Schema Overview](#schema-overview)
2. [Pricing Data Analysis](#pricing-data-analysis)
3. [Modifier System Analysis](#modifier-system-analysis)
4. [Combo System Analysis](#combo-system-analysis)
5. [Data Quality Checks](#data-quality-checks)
6. [Key Findings & Recommendations](#key-findings--recommendations)

---

## Schema Overview

### Core Tables by Category

#### **Restaurant Management** (944 restaurants)
- `restaurants` - 944 rows
- `restaurant_locations` - 921 rows
- `restaurant_contacts` - 823 rows
- `restaurant_admin_users` - 439 rows
- `restaurant_schedules` - 1,002 rows
- `restaurant_domains` - 713 rows
- `restaurant_id_mapping` - 826 rows (legacy mapping)

#### **Geography**
- `provinces` - 13 rows (Canadian provinces)
- `cities` - 118 rows

#### **Service Configuration**
- `restaurant_special_schedules` - 50 rows
- `restaurant_service_configs` - 944 rows
- `restaurant_time_periods` - 6 rows

#### **Users & Access**
- `users` - 32,349 rows (customers)
- `admin_users` - 51 rows (platform admins)
- `admin_user_restaurants` - 91 rows
- **Empty tables:** `user_addresses`, `user_favorite_restaurants`, `password_reset_tokens`, `autologin_tokens`

#### **Delivery Configuration**
- `delivery_company_emails` - 9 rows
- `restaurant_delivery_companies` - 160 rows
- `restaurant_delivery_fees` - 210 rows
- `restaurant_partner_schedules` - 7 rows
- `restaurant_twilio_config` - 18 rows
- `restaurant_delivery_config` - 825 rows
- `restaurant_delivery_areas` - 47 rows (with PostGIS geometry)

#### **Marketing & Promotions**
- `marketing_tags` - 36 rows
- `promotional_deals` - 202 rows
- `promotional_coupons` - 581 rows
- `restaurant_tag_associations` - 29 rows

#### **Menu & Catalog** (Largest section)
- `courses` - 1,207 rows (menu categories)
- `dishes` - 10,585 rows (menu items)
- `ingredients` - 31,542 rows (modifiers/toppings)
- `ingredient_groups` - 9,169 rows
- `ingredient_group_items` - 37,684 rows
- `dish_modifiers` - 2,922 rows
- `combo_groups` - 8,234 rows
- `combo_items` - 63 rows ⚠️
- `combo_group_modifier_pricing` - 9,141 rows
- `combo_steps` - 0 rows (empty)

#### **Infrastructure**
- `devices` - 981 rows (tablets)

---

## Pricing Data Analysis

### Dishes Pricing

| Metric | Count | Percentage |
|--------|-------|------------|
| **Total Dishes** | 10,585 | 100% |
| **Dishes with `base_price`** | 10,553 | 99.7% |
| **Dishes with `prices` JSONB** | 5,130 | 48.5% |
| **Dishes with no pricing** | 32 | 0.3% |

#### Example Dishes (Simple Pricing)
```json
{
  "id": 28,
  "name": "Tuna Wrap",
  "base_price": "4.99",
  "prices": null,
  "size_options": null
}

{
  "id": 29,
  "name": "Chicken Avocado Wrap",
  "base_price": "4.99",
  "prices": null,
  "size_options": null
}

{
  "id": 30,
  "name": "Thai Pasta Salad",
  "base_price": "28.50",
  "prices": null,
  "size_options": null
}
```

**Observation:** Most dishes use simple `base_price` (single price), while ~48% have complex `prices` JSONB for multi-size pricing.

### Ingredients Pricing

| Metric | Count |
|--------|-------|
| **Total Ingredients** | 31,542 |
| **Ingredients with `price_by_size` JSONB** | 0 |

**Finding:** Ingredients don't use `price_by_size` directly. Pricing is handled through relationship tables.

---

## Modifier System Analysis

### Dish Modifiers Pricing Distribution

| Pricing Method | Count | Percentage |
|----------------|-------|------------|
| **Base Price Only** | 2,476 | 84.7% |
| **Price by Size (JSONB)** | 429 | 14.7% |
| **No Price** | 17 | 0.6% |
| **Total Modifiers** | 2,922 | 100% |

#### Example Modifier Pricing Structures

**Pizza Modifiers with Size-Based Pricing:**

```json
{
  "id": 1473,
  "dish_name": "Plain",
  "ingredient_name": "Mushrooms",
  "base_price": null,
  "price_by_size": {"S": 1, "M": 1.5, "L": 2},
  "modifier_type": "custom_ingredients"
}

{
  "id": 1476,
  "dish_name": "Combination Pizza",
  "ingredient_name": "Mushrooms",
  "base_price": null,
  "price_by_size": {"S": 1, "M": 1.5, "L": 2},
  "modifier_type": "custom_ingredients"
}

{
  "id": 1479,
  "dish_name": "Meat Lover Pizza",
  "ingredient_name": "Mushrooms",
  "base_price": null,
  "price_by_size": {"S": 1, "M": 1.5, "L": 2},
  "modifier_type": "custom_ingredients"
}
```

### Ingredient Group Items Pricing

| Pricing Method | Count | Percentage |
|----------------|-------|------------|
| **Base Price** | 23,656 | 62.8% |
| **Price by Size (JSONB)** | 14,028 | 37.2% |
| **Total Items** | 37,684 | 100% |

**Finding:** Ingredient group items use BOTH pricing methods extensively - 37% use complex JSONB pricing.

### Modifier Coverage

- **Dishes with Modifiers:** 1,836 out of 10,585 (17.3%)
- **Dish with Most Modifiers:** "Ultimate Shredded Pepperoni HIDE" (Restaurant 863) with **6 modifiers**

**Observation:** Most dishes are simple items without customization. Only ~17% have modifiers.

---

## Combo System Analysis

### 🚨 Critical Finding: Orphaned Combo Groups

| Metric | Count | Status |
|--------|-------|--------|
| **Total Combo Groups** | 8,234 | ⚠️ |
| **Total Combo Items** | 63 | ⚠️ |
| **Combo Groups WITH Items** | 16 | ✅ Only 0.2% |
| **Orphaned Combo Groups** | 8,218 | 🔴 99.8% have NO items |

### Why the Discrepancy?

The combo system appears to be migrated incorrectly. We have:
- 8,234 combo group **definitions** (metadata/rules)
- Only 63 actual item **associations** (what dishes are in combos)
- Only 16 groups actually have items linked

### Example Combo Groups with Items

```json
{
  "combo_group_id": 8075,
  "combo_name": "2 main dishes",
  "combo_price": null,
  "item_count": 3,
  "items": [
    {"dish_id": 322, "dish_name": "37.Yu Shang Eggplant in Spicy Sauce with Minced Pork", "quantity": 1},
    {"dish_id": 323, "dish_name": "38.Szechuan Beef", "quantity": 1},
    {"dish_id": 325, "dish_name": "41.General Tao's Chicken", "quantity": 1}
  ]
}
```

**Note:** Same 3 dishes appear in combos for "2 main dishes", "3 main dishes", "4 main dishes", etc.

### Combo Rules Data

| Field | Count with Data | Notes |
|-------|----------------|-------|
| **`combo_rules` JSONB** | 8,047 (97.7%) | ✅ Well populated |
| **`pricing_rules` JSONB** | 0 | ⚠️ Not used |

#### Example Combo Rules Structure

```json
{
  "id": 10295,
  "name": "2 chicken shawarma",
  "combo_rules": {
    "item_count": 2,
    "display_header": "First Shawarma;Second Shawarma",
    "modifier_rules": {
      "custom_ingredients": {
        "max": 0,
        "min": 1,
        "enabled": true,
        "display_order": 2,
        "free_quantity": 0,
        "display_header": "Custom Ingredients"
      }
    },
    "show_pizza_icons": false
  },
  "source_system": "v1",
  "is_active": true
}
```

**Finding:** Combo rules are well-structured but the junction table (`combo_items`) linking groups to actual dishes is almost empty.

---

## Data Quality Checks

### ✅ Referential Integrity (EXCELLENT)

| Check | Result | Status |
|-------|--------|--------|
| **Orphaned Dishes** (no restaurant_id) | 0 | ✅ Perfect |
| **Orphaned Ingredients** (no restaurant_id) | 0 | ✅ Perfect |
| **Orphaned Modifiers** (pointing to non-existent dishes) | 0 | ✅ Perfect |

### ⚠️ Business Data Issues

#### Restaurants with No Dishes

**Count:** 714 restaurants (75.6% of all restaurants!)

**Example Restaurants with No Menu:**

| ID | Name | Status | Created |
|----|------|--------|---------|
| 251 | Milano | suspended | 2025-09-24 |
| 106 | Restaurant Le Choix | suspended | 2025-09-24 |
| 285 | Thali | suspended | 2025-09-24 |
| 681 | Oka's Hull | active | 2018-11-05 |
| 120 | Piper's Pizzeria Bar & Grill (dropped) | suspended | 2025-09-24 |

**Analysis:**
- Most are **suspended** or **inactive** (expected)
- One active restaurant with no menu (ID: 681 "Oka's Hull") - needs investigation
- Many created on the same date (2025-09-24) suggesting bulk migration

#### Duplicate Dish Names

**Total Duplicate Groups:** 387 restaurant+dish name combinations with duplicates

**Top 10 Duplicates:**

| Restaurant ID | Dish Name | Duplicate Count |
|---------------|-----------|-----------------|
| 916 | "test" | 5 |
| 72 | "Chicken" | 4 |
| 72 | "Beef" | 4 |
| 895 | "Coors Light" | 4 |
| 895 | "Heineken" | 4 |
| 72 | "Shrimp" | 4 |
| 938 | "Rice" | 3 |
| 436 | "Falafel" | 3 |
| 523 | "Black Cod with Miso HIDE" | 3 |
| 433 | "Falafel" | 3 |

**Possible Causes:**
1. Different sizes stored as separate dishes (by design)
2. Test data ("test" dish name)
3. Migration artifacts creating duplicates
4. Legitimate variations (lunch vs dinner pricing)

---

## Key Findings & Recommendations

### 🎯 Critical Issues

#### 1. **Combo System Migration Failure** 🔴
- **Problem:** 8,218 combo groups (99.8%) have no dishes linked
- **Impact:** Combo meals are non-functional for most restaurants
- **Recommendation:** 
  - Investigate V1/V2 source data for `combos` junction table
  - Re-run migration for `combo_items` table
  - Verify `combo_groups.dish` BLOB parsing from V1

#### 2. **714 Restaurants Without Menus** ⚠️
- **Problem:** 75.6% of restaurants have no dishes
- **Impact:** Restaurants cannot take orders
- **Recommendation:**
  - Filter reports to only show restaurants WITH dishes
  - Mark restaurants without dishes as `incomplete` status
  - Investigate active restaurants with no menu (e.g., ID: 681)

#### 3. **387 Duplicate Dish Names** ⚠️
- **Problem:** Same dish name appears multiple times per restaurant
- **Impact:** Could confuse customers, cause ordering errors
- **Recommendation:**
  - Review if duplicates are intentional (sizes) or errors
  - Add `display_order` or `variation` field if needed
  - Consider unique constraint on (restaurant_id, name, size) after cleanup

### ✅ Strengths

1. **Excellent Referential Integrity** - No orphaned records
2. **Rich Pricing System** - Supports both simple and complex pricing
3. **Well-Structured Modifiers** - 37% use advanced JSONB pricing
4. **Good Data Population** - 99.7% of dishes have pricing
5. **Comprehensive Delivery System** - PostGIS geometry for delivery zones

### 📊 Data Distribution Health

| Category | Status | Notes |
|----------|--------|-------|
| **Restaurants** | ✅ Good | 944 records, well distributed |
| **Users** | ✅ Good | 32,349 customers migrated |
| **Dishes** | ✅ Good | 10,585 dishes, 99.7% priced |
| **Ingredients** | ✅ Good | 31,542 ingredients |
| **Modifiers** | ✅ Good | 2,922 modifiers, complex pricing works |
| **Combos** | 🔴 BROKEN | 99.8% orphaned combo groups |
| **User Addresses** | ⚠️ Empty | Migration pending? |
| **Orders** | ⚠️ Missing | Not in current schema |

### 🔧 Next Steps

#### Immediate (Week 1)
1. **Fix Combo System**
   - Re-migrate `combo_items` from V1 `combos` table
   - Parse V1 `combo_groups.dish` BLOB correctly
   - Verify all combo groups have at least 1 item

2. **Audit Active Restaurants Without Menus**
   - Create list of active restaurants with 0 dishes
   - Contact restaurants or mark as incomplete

#### Short Term (Month 1)
3. **Deduplicate Dish Names**
   - Analyze duplicate patterns
   - Merge or differentiate duplicates
   - Add business rules to prevent future duplicates

4. **Complete User Migration**
   - Migrate `user_addresses` from V2
   - Set up order history (if available)

#### Medium Term (Quarter 1)
5. **Performance Optimization**
   - Add indexes on JSONB fields if querying pricing
   - Consider materialized views for reporting
   - Archive suspended restaurants without dishes

6. **Data Validation Rules**
   - Add CHECK constraints for required JSONB fields
   - Implement application-level validation
   - Create monitoring for data quality metrics

---

## Appendix: Query Summary

**Total Queries Run:** 20+  
**Execution Date:** October 10, 2025  
**Database Version:** PostgreSQL (Supabase)  
**Schema:** menuca_v3

### Tool Used
- Supabase MCP (Model Context Protocol)
- Direct SQL execution via `execute_sql`
- Table introspection via `list_tables`

---

**Report Generated By:** Brian Lapp  
**Project:** MenuCA V1/V2 → V3 Migration  
**Status:** Phase 2 Complete, Combo System Requires Remediation

