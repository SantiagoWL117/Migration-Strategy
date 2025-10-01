# Menu & Catalog Entity

**Status:** ⏳ NOT STARTED - BLOCKED  
**Priority:** MEDIUM  
**Blocked By:** Restaurant Management (needs restaurants table)  
**Developer:** Available for assignment

---

## 📊 Entity Overview

**Purpose:** Complete menu structure including courses, dishes, combos, ingredients, customizations, and pricing

**Scope:** All menu items, food catalog, ingredient groups, combo meals, and dish customizations

**Dependencies:** Restaurant Management (needs `restaurants` table) 🔄 IN PROGRESS

**Blocks:** Orders & Checkout (needs menu items for order items)

---

## 📋 Tables Identified - Verification Complete ✅

### V1 Tables (MySQL - menuca_v1) - 7 tables

**Core Menu Structure:**
1. `courses` - Menu categories/sections (~16,001 rows)
2. `menu` - Individual dishes/items (~141,282 rows)
3. `menuothers` - Side dishes, drinks, extras for items (~328,167 rows)

**Combos:**
4. `combo_groups` - Combo meal definitions (~62,720 rows)
5. `combos` - Combo items linking (~112,125 rows)

**Ingredients/Customizations:**
6. `ingredient_groups` - Ingredient group definitions (~13,627 rows)
7. `ingredients` - Individual ingredients (~59,950 rows)

### V2 Tables (MySQL - menuca_v2) - 13 tables

**Core Menu Structure:**
1. `restaurants_courses` - Course categories per restaurant
2. `restaurants_dishes` - Individual menu items per restaurant
3. `restaurants_dishes_customization` - Dish customization options

**Combos:**
4. `restaurants_combo_groups` - Combo meal groups
5. `restaurants_combo_groups_items` - Items within combo groups

**Ingredients/Customizations:**
6. `restaurants_ingredients` - Restaurant-specific ingredients
7. `restaurants_ingredient_groups` - Ingredient group definitions
8. `restaurants_ingredient_groups_items` - Items in ingredient groups
9. `custom_ingredients` - Custom ingredient definitions

**Global Templates:**
10. `global_courses` - Template/standard course definitions
11. `global_dishes` - Template/standard dish definitions
12. `global_ingredients` - Template/standard ingredient definitions
13. `global_restaurant_types` - Restaurant type templates

**Reference Only (V2):**
- `courses` - Legacy global course reference
- `menu` - Legacy global menu reference

---

## 🔍 Additional Tables Analyzed

**NOT Menu & Catalog Entity:**
- ✅ `tags` (V1) - Restaurant tags, belongs to Restaurant Management
- ✅ `restaurants_tags` (V2) - Restaurant tag junction, belongs to Restaurant Management
- ✅ `extra_delivery_fees` (V1) - Delivery fees, belongs to Delivery Operations
- ✅ `order_sub_items_combo` (V2) - Order data, belongs to Orders & Checkout

---

## 🎯 Key Data Model Insights

### V1 Structure
- **Denormalized:** Single `menu` table with many customization flags
- **Blob storage:** Many fields stored as serialized data
- **Shared ingredients:** Global ingredient system across restaurants
- **Combo complexity:** Combos reference dishes via FK relationships

### V2 Structure
- **Normalized:** Separate tables for dishes, customizations, ingredients
- **Restaurant-scoped:** Each restaurant has own courses, dishes, ingredients
- **Global templates:** Reusable templates for common items (global_*)
- **Better typing:** More structured customization options

### V3 Target (to be defined in menuca_v3 schema)
- Needs canonical course → dish → customization hierarchy
- Should support both restaurant-specific and global menu items
- Must handle pricing variations (size, time period, etc.)
- Need efficient lookup for order processing

---

## 📁 Files to Create

### Step 1: Mapping Document
- `menu-catalog-mapping.md` - Complete field mapping from V1/V2 to V3

### Step 2: Migration Plans (per table group)
1. `courses_migration_plan.md` - Course categories migration
2. `dishes_migration_plan.md` - Menu items migration
3. `combos_migration_plan.md` - Combo meals migration
4. `ingredients_migration_plan.md` - Ingredients and groups migration
5. `customizations_migration_plan.md` - Dish customization options

---

## 🔗 Dependencies

**Required (Blocked):**
- 🔄 Restaurant Management (`restaurants` table) - IN PROGRESS

**Blocks (Waiting on this entity):**
- ⏳ Orders & Checkout (needs menu items and pricing)

---

## ⚠️ Migration Challenges

### Data Quality Issues
1. **Blob serialization:** V1 stores many options as PHP serialized blobs
2. **Pricing complexity:** Multiple price formats (JSON, comma-separated)
3. **Multilingual data:** French/English content in separate fields/rows
4. **Global vs Restaurant:** Need to decide which items go to V3 global templates

### Technical Challenges
1. **Customization mapping:** V1 has 8+ customization types in single table
2. **Combo complexity:** Multi-level combo structure with steps
3. **Ingredient availability:** "availableFor" field contains blob data
4. **Order preservation:** `order` field determines display sequence

---

## 📝 Notes for Future Planning

- Menu & Catalog is one of the largest entities by row count (~750K+ rows in V1)
- Heavy use of blob fields will require careful deserialization
- Consider batching migration by restaurant to manage memory
- May need intermediate transform tables due to complexity
- Order processing performance depends heavily on this entity's structure

---

**Status:** Waiting for Restaurant Management entity to complete before starting analysis.

**Next Step:** Once restaurants table is migrated, create detailed mapping document.
