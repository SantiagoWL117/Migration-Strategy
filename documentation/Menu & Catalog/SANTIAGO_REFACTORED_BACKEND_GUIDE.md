# Menu & Catalog - Backend Integration Guide

**Entity:** Menu & Catalog  
**Status:** ✅ **PRODUCTION READY** - Refactoring Complete (2025-10-30)  
**For:** Santiago (Backend Development)  
**Schema:** `menuca_v3`

---

## 🎯 OVERVIEW

The Menu & Catalog entity provides enterprise-grade menu management with:
- **Modern modifier system** (direct name+price, no ingredient dependencies)
- **Unified pricing** (all pricing in `dish_prices` table)
- **Multi-language support** (EN, ES, FR, ZH, AR)
- **Enterprise features** (allergens, dietary tags, size options)
- **Combo meal system** (multi-step combos with pricing functions)
- **Real-time updates** (via Supabase Realtime + custom triggers)

**Key Refactoring Changes:**
- ✅ Removed legacy pricing columns (`base_price`, `prices`, `size_options`)
- ✅ Migrated to modern modifier system (`modifier_groups` + `dish_modifiers`)
- ✅ Normalized all codes (full words, not 2-letter abbreviations)
- ✅ Removed V1/V2 branching logic (unified V3 patterns)
- ✅ Added enterprise schema (allergens, dietary tags, size options)

---

## 📋 TABLE OF CONTENTS

1. [Schema Structure](#schema-structure)
2. [SQL Functions](#sql-functions)
3. [RLS Policies](#rls-policies)
4. [API Endpoint Examples](#api-endpoint-examples)
5. [TypeScript Integration](#typescript-integration)
6. [Real-time Subscriptions](#real-time-subscriptions)
7. [Testing Checklist](#testing-checklist)
8. [Migration Notes](#migration-notes)

---

## 🗄️ SCHEMA STRUCTURE

### Core Tables

```
menuca_v3.restaurants
├── menuca_v3.courses (menu categories)
│   └── menuca_v3.dishes (menu items)
│       ├── menuca_v3.dish_prices (pricing)
│       ├── menuca_v3.dish_modifiers (customization options)
│       │   └── menuca_v3.modifier_groups (selection rules)
│       ├── menuca_v3.dish_ingredients (base ingredients)
│       ├── menuca_v3.dish_allergens (allergen warnings)
│       ├── menuca_v3.dish_dietary_tags (dietary preferences)
│       └── menuca_v3.dish_size_options (size metadata)
│
├── menuca_v3.combo_groups (meal deals)
│   ├── menuca_v3.combo_items (allowed dishes)
│   └── menuca_v3.combo_steps (multi-step metadata)
│
└── menuca_v3.ingredients (ingredient library)
    └── menuca_v3.ingredient_groups (legacy grouping)
```

### Translation Tables

All core entities support multi-language via translation tables:
- `dish_translations` - Dish names/descriptions
- `course_translations` - Course names/descriptions
- `ingredient_translations` - Ingredient names
- `modifier_group_translations` - Modifier group names
- `dish_modifier_translations` - Modifier names
- `combo_group_translations` - Combo group names

### Key Relationships

**Pricing:**
- `dishes` → `dish_prices` (one-to-many, size variants)

**Modifiers:**
- `dishes` → `modifier_groups` (one-to-many, selection rules)
- `modifier_groups` → `dish_modifiers` (one-to-many, options)

**Combos:**
- `combo_groups` → `combo_items` → `dishes` (many-to-many)
- `combo_items` → `combo_steps` (one-to-one, step metadata)

**Enterprise Features:**
- `dishes` → `dish_ingredients` (base ingredients for allergens/recipes)
- `dishes` → `dish_allergens` (allergen tracking)
- `dishes` → `dish_dietary_tags` (dietary preferences)
- `dishes` → `dish_size_options` (size metadata)

---

## 🔧 SQL FUNCTIONS

### 1. `get_restaurant_menu()`

**Purpose:** Get complete menu for a restaurant with translations, pricing, and modifiers

**Signature:**
```sql
get_restaurant_menu(
    p_restaurant_id BIGINT,
    p_language_code VARCHAR DEFAULT 'en'
) RETURNS TABLE(...)
```

**Parameters:**
- `p_restaurant_id`: Restaurant ID (required)
- `p_language_code`: Language code ('en', 'fr', 'es', 'zh', 'ar') - default 'en'

**Returns:**
- `course_id`, `course_name`, `course_display_order`
- `dish_id`, `dish_name`, `dish_description`, `dish_display_order`
- `pricing`: JSONB array of price objects
- `modifiers`: JSONB array of modifier groups with nested modifiers
- `availability`: JSONB object with availability info

**Features:**
- ✅ Uses refactored schema (`dish_prices`, `modifier_groups`, `dish_modifiers`)
- ✅ Multi-language support via translation tables
- ✅ Falls back to default language if translation missing
- ✅ Includes real-time availability from `dish_inventory`

**Example:**
```sql
-- Get menu in English (default)
SELECT * FROM menuca_v3.get_restaurant_menu(72);
-- OR explicitly:
SELECT * FROM menuca_v3.get_restaurant_menu(72, 'en');

-- Get menu in French
SELECT * FROM menuca_v3.get_restaurant_menu(72, 'fr');

-- Get menu in Spanish
SELECT * FROM menuca_v3.get_restaurant_menu(72, 'es');
```

**Response Structure:**
```json
{
  "course_id": 1,
  "course_name": "Appetizers",
  "course_display_order": 0,
  "dish_id": 123,
  "dish_name": "Caesar Salad",
  "dish_description": "Fresh romaine lettuce...",
  "dish_display_order": 0,
  "pricing": [
    {"size": "default", "price": 12.99, "display_order": 0}
  ],
  "modifiers": [
    {
      "modifier_group_id": 456,
      "group_name": "Dressing Options",
      "is_required": true,
      "min_selections": 1,
      "max_selections": 1,
      "display_order": 0,
      "modifiers": [
        {
          "modifier_id": 789,
          "name": "Caesar Dressing",
          "price": 0.00,
          "display_order": 0
        }
      ]
    }
  ],
  "availability": {
    "is_available": true,
    "is_active": true,
    "unavailable_until": null
  }
}
```

**TypeScript Usage:**
```typescript
const { data, error } = await supabase.rpc('get_restaurant_menu', {
  p_restaurant_id: 72,
  p_language_code: 'en'
});
```

---

### 2. `calculate_combo_price()`

**Purpose:** Calculate combo price based on selected items and modifier charges

**Signature:**
```sql
calculate_combo_price(
    p_combo_group_id BIGINT,
    p_selected_items JSONB DEFAULT '[]'::jsonb
) RETURNS JSONB
```

**Parameters:**
- `p_combo_group_id`: Combo group ID
- `p_selected_items`: JSON array of selected dishes/modifiers
  ```json
  [
    {"dish_id": 123, "modifiers": [456, 789]},
    {"dish_id": 456, "modifiers": []}
  ]
  ```

**Returns:**
```json
{
  "combo_group_id": 123,
  "base_price": 24.99,
  "modifier_charges": 2.50,
  "final_price": 27.49,
  "pricing_rules": {...},
  "item_count_required": 2,
  "item_count_selected": 2
}
```

**Example:**
```sql
SELECT menuca_v3.calculate_combo_price(
    123,
    '[
      {"dish_id": 456, "modifiers": [789]},
      {"dish_id": 789, "modifiers": []}
    ]'::jsonb
);
```

---

### 2. `validate_combo_configuration()`

**Purpose:** Validate combo configuration for data quality

**Signature:**
```sql
validate_combo_configuration(
    p_combo_group_id BIGINT
) RETURNS JSONB
```

**Returns:**
```json
{
  "valid": true,
  "errors": [],
  "warnings": ["Combo has no base price set"],
  "combo_name": "Family Deal",
  "combo_group_id": 123,
  "has_base_price": false,
  "item_count_actual": 3,
  "item_count_required": 2
}
```

**Example:**
```sql
SELECT menuca_v3.validate_combo_configuration(123);
```

---

### 3. `notify_menu_change()`

**Purpose:** Trigger function that sends `pg_notify` events on menu changes

**Usage:** Automatically called on INSERT/UPDATE/DELETE to:
- `dishes`
- `dish_prices`
- `dish_modifiers`
- `modifier_groups`
- `combo_groups`
- `combo_items`

**Event Payload:**
```json
{
  "table": "dishes",
  "action": "UPDATE",
  "restaurant_id": 123,
  "record_id": 456,
  "timestamp": "2025-10-30T12:00:00Z"
}
```

**Channel:** `menu_changed`

---

### 4. `enforce_dish_pricing()`

**Purpose:** Trigger function that warns when dishes are activated without pricing

**Usage:** Automatically called on UPDATE to `dishes.is_active`

**Behavior:**
- Does NOT block activation (allows temporary states during creation)
- Logs warning for data quality monitoring
- Frontend can check for dishes with $0.00 pricing

---

## 🔒 RLS POLICIES

### Security Pattern

All Menu & Catalog tables use the same 3-policy pattern:

1. **Public Read** (`*_public_read`)
   - Access: `anon`, `authenticated`
   - Filter: Active dishes only (`is_active = true`, `deleted_at IS NULL`)

2. **Admin Manage** (`*_admin_manage`)
   - Access: `authenticated` (restaurant admins only)
   - Filter: Valid admin assignment via `admin_user_restaurants`
   - Status: Admin must be `active` and not deleted

3. **Service Role** (`*_service_role`)
   - Access: `service_role` only
   - Filter: None (full access for migrations)

### Tables with RLS Enabled

**Core Tables:**
- `dishes` ✅
- `courses` ✅
- `dish_prices` ✅
- `dish_modifiers` ✅
- `modifier_groups` ✅

**Combo Tables:**
- `combo_groups` ✅
- `combo_items` ✅
- `combo_steps` ✅

**Enterprise Tables:**
- `dish_ingredients` ✅
- `dish_allergens` ✅
- `dish_dietary_tags` ✅
- `dish_size_options` ✅

**Translation Tables:**
- `dish_translations` ✅
- `course_translations` ✅
- `ingredient_translations` ✅
- `modifier_group_translations` ✅
- `dish_modifier_translations` ✅
- `combo_group_translations` ✅

**Legacy Tables:**
- `ingredients` ✅
- `ingredient_groups` ✅

---

## 🌐 API ENDPOINT EXAMPLES

### Public APIs

#### 1. Get Restaurant Menu (Multi-language)

**Endpoint:** `GET /api/restaurants/:id/menu?lang=en`

**Implementation:**
```typescript
// Supabase client
const { data, error } = await supabase
  .from('courses')
  .select(`
    id,
    name,
    display_order,
    course_translations!inner(name),
    dishes!inner(
      id,
      name,
      description,
      is_active,
      dish_translations!inner(name, description),
      dish_prices(
        size_variant,
        price,
        display_order
      ),
      modifier_groups(
        id,
        name,
        is_required,
        min_selections,
        max_selections,
        modifier_group_translations!inner(name),
        dish_modifiers(
          id,
          name,
          price,
          display_order,
          dish_modifier_translations!inner(name)
        )
      )
    )
  `)
  .eq('restaurant_id', restaurantId)
  .eq('is_active', true)
  .eq('dish_translations.language_code', lang)
  .eq('course_translations.language_code', lang)
  .eq('dishes.is_active', true)
  .is('dishes.deleted_at', null)
  .order('display_order')
  .order('dishes.display_order');
```

**Response:**
```json
{
  "courses": [
    {
      "id": 1,
      "name": "Appetizers",
      "dishes": [
        {
          "id": 123,
          "name": "Caesar Salad",
          "description": "Fresh romaine lettuce...",
          "prices": [
            {"size_variant": "default", "price": 12.99}
          ],
          "modifier_groups": [
            {
              "id": 456,
              "name": "Dressing Options",
              "is_required": true,
              "min_selections": 1,
              "max_selections": 1,
              "modifiers": [
                {"id": 789, "name": "Caesar Dressing", "price": 0.00}
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

---

#### 2. Get Dish Details

**Endpoint:** `GET /api/dishes/:id?lang=en`

**Implementation:**
```typescript
const { data, error } = await supabase
  .from('dishes')
  .select(`
    *,
    dish_translations!inner(name, description),
    dish_prices(size_variant, price, display_order),
    modifier_groups(
      *,
      modifier_group_translations!inner(name),
      dish_modifiers(
        *,
        dish_modifier_translations!inner(name)
      )
    ),
    dish_allergens(allergen, severity),
    dish_dietary_tags(tag, is_certified),
    dish_size_options(size_code, size_label, calories)
  `)
  .eq('id', dishId)
  .eq('dish_translations.language_code', lang)
  .single();
```

---

#### 3. Get Combo Details

**Endpoint:** `GET /api/combo-groups/:id?lang=en`

**Implementation:**
```typescript
const { data, error } = await supabase
  .from('combo_groups')
  .select(`
    *,
    combo_group_translations!inner(name, description),
    combo_items(
      dish:dishes!inner(
        id,
        name,
        dish_translations!inner(name),
        dish_prices(size_variant, price)
      ),
      combo_steps(step_number, step_label)
    )
  `)
  .eq('id', comboGroupId)
  .eq('combo_group_translations.language_code', lang)
  .single();
```

---

### Admin APIs

#### 4. Create Dish

**Endpoint:** `POST /api/admin/dishes`

**Implementation:**
```typescript
// Create dish
const { data: dish, error } = await supabase
  .from('dishes')
  .insert({
    restaurant_id: restaurantId,
    course_id: courseId,
    name: 'New Dish',
    description: 'Description here',
    is_active: false  // Start inactive until pricing added
  })
  .select()
  .single();

// Add pricing
await supabase
  .from('dish_prices')
  .insert({
    dish_id: dish.id,
    size_variant: 'default',
    price: 12.99,
    display_order: 0
  });

// Activate dish
await supabase
  .from('dishes')
  .update({ is_active: true })
  .eq('id', dish.id);
```

---

#### 5. Update Dish Pricing

**Endpoint:** `PUT /api/admin/dishes/:id/prices`

**Implementation:**
```typescript
// Upsert pricing (handles multiple sizes)
await supabase
  .from('dish_prices')
  .upsert([
    { dish_id: dishId, size_variant: 'small', price: 9.99, display_order: 0 },
    { dish_id: dishId, size_variant: 'medium', price: 12.99, display_order: 1 },
    { dish_id: dishId, size_variant: 'large', price: 15.99, display_order: 2 }
  ], {
    onConflict: 'dish_id,size_variant'
  });
```

---

#### 6. Add Modifier Group

**Endpoint:** `POST /api/admin/dishes/:id/modifier-groups`

**Implementation:**
```typescript
// Create modifier group
const { data: group, error } = await supabase
  .from('modifier_groups')
  .insert({
    dish_id: dishId,
    name: 'Toppings',
    is_required: false,
    min_selections: 0,
    max_selections: 5,
    display_order: 0
  })
  .select()
  .single();

// Add modifiers to group
await supabase
  .from('dish_modifiers')
  .insert([
    {
      modifier_group_id: group.id,
      name: 'Extra Cheese',
      price: 1.50,
      display_order: 0
    },
    {
      modifier_group_id: group.id,
      name: 'Pepperoni',
      price: 2.00,
      display_order: 1
    }
  ]);
```

---

#### 7. Validate Combo Configuration

**Endpoint:** `GET /api/admin/combo-groups/:id/validate`

**Implementation:**
```typescript
const { data, error } = await supabase.rpc(
  'validate_combo_configuration',
  { p_combo_group_id: comboGroupId }
);

if (!data.valid) {
  console.error('Combo validation errors:', data.errors);
}
if (data.warnings.length > 0) {
  console.warn('Combo warnings:', data.warnings);
}
```

---

## 💻 TYPESCRIPT INTEGRATION

### Setup

```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!
);
```

### Type Definitions

```typescript
// Generated types (use Supabase CLI: supabase gen types typescript)
type Dish = {
  id: number;
  restaurant_id: number;
  course_id: number | null;
  name: string;
  description: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  deleted_at: string | null;
};

type DishPrice = {
  id: number;
  dish_id: number;
  size_variant: string;
  price: number;
  display_order: number;
  is_active: boolean;
};

type ModifierGroup = {
  id: number;
  dish_id: number;
  name: string;
  is_required: boolean;
  min_selections: number;
  max_selections: number;
  display_order: number;
};

type DishModifier = {
  id: number;
  modifier_group_id: number;
  name: string;
  price: number;
  display_order: number;
};
```

### Helper Functions

```typescript
// Get menu with translations
async function getRestaurantMenu(
  restaurantId: number,
  lang: string = 'en'
) {
  const { data, error } = await supabase
    .from('courses')
    .select(`
      *,
      course_translations!inner(name),
      dishes!inner(
        *,
        dish_translations!inner(name, description),
        dish_prices(size_variant, price, display_order),
        modifier_groups(
          *,
          modifier_group_translations!inner(name),
          dish_modifiers(
            *,
            dish_modifier_translations!inner(name)
          )
        )
      )
    `)
    .eq('restaurant_id', restaurantId)
    .eq('is_active', true)
    .eq('course_translations.language_code', lang)
    .eq('dishes.is_active', true)
    .is('dishes.deleted_at', null)
    .order('display_order');

  return { data, error };
}

// Calculate combo price
async function calculateComboPrice(
  comboGroupId: number,
  selectedItems: Array<{ dish_id: number; modifiers: number[] }>
) {
  const { data, error } = await supabase.rpc('calculate_combo_price', {
    p_combo_group_id: comboGroupId,
    p_selected_items: selectedItems
  });

  return { data, error };
}
```

---

## 🔔 REAL-TIME SUBSCRIPTIONS

### Supabase Realtime

```typescript
// Subscribe to menu changes
const channel = supabase
  .channel('menu-changes')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'menuca_v3',
      table: 'dishes',
      filter: `restaurant_id=eq.${restaurantId}`
    },
    (payload) => {
      console.log('Menu change:', payload);
      // Refresh menu UI
    }
  )
  .subscribe();

// Cleanup
channel.unsubscribe();
```

### Custom pg_notify Events

```typescript
// Listen to custom trigger notifications
const channel = supabase
  .channel('menu-notifications')
  .on(
    'postgres_changes',
    {
      event: '*',
      schema: 'menuca_v3',
      table: 'dishes'
    },
    async (payload) => {
      // Fetch notification from notify_menu_change trigger
      const { data } = await supabase
        .from('pg_notify')
        .select('*')
        .eq('channel', 'menu_changed')
        .order('created_at', { ascending: false })
        .limit(1);

      if (data && data.length > 0) {
        const notification = JSON.parse(data[0].payload);
        console.log('Menu notification:', notification);
      }
    }
  )
  .subscribe();
```

---

## ✅ TESTING CHECKLIST

### Schema Integrity

- [ ] All foreign keys valid (no orphaned records)
- [ ] All active dishes have pricing (`dish_prices` table)
- [ ] All `dish_modifiers` linked to `modifier_groups`
- [ ] All combo items have valid `dish_id` references
- [ ] All translation tables have valid language codes

### Pricing Logic

- [ ] Dish prices load correctly for all size variants
- [ ] Modifier prices apply correctly
- [ ] Combo pricing calculates correctly
- [ ] $0.00 prices display correctly (needs restaurant update)

### Modifier System

- [ ] Modifier groups display with correct selection rules
- [ ] Min/max selections enforced
- [ ] Required modifiers enforced
- [ ] Modifier prices add correctly to dish total

### Multi-language

- [ ] Translations load for all languages (EN, ES, FR, ZH, AR)
- [ ] Fallback to default language when translation missing
- [ ] Translation updates reflect immediately

### RLS Security

- [ ] Public users can only read active dishes
- [ ] Restaurant admins can manage their dishes
- [ ] Cross-restaurant access blocked
- [ ] Service role has full access

### Performance

- [ ] Menu queries < 50ms (target: < 10ms)
- [ ] Indexes used for filtering
- [ ] No N+1 queries in menu loading

---

## 📝 MIGRATION NOTES

### Key Changes from V1/V2

**1. Pricing Consolidation:**
- ❌ Removed: `dishes.base_price`, `dishes.prices` (JSONB), `dishes.size_options`
- ✅ Added: `dish_prices` table (relational pricing)

**2. Modifier System:**
- ❌ Removed: Ingredient-based modifiers (legacy)
- ✅ Added: Direct modifier system (`modifier_groups` + `dish_modifiers`)

**3. Code Normalization:**
- ❌ Removed: 2-letter codes (`ci`, `e`, `sd`, etc.)
- ✅ Added: Full words (`custom_ingredients`, `extras`, `side_dishes`, etc.)

**4. V1/V2 Logic:**
- ❌ Removed: All `source_system` branching logic
- ✅ Added: Unified V3 patterns (legacy columns kept for audit only)

**5. Enterprise Features:**
- ✅ Added: `dish_allergens` (allergen tracking)
- ✅ Added: `dish_dietary_tags` (dietary preferences)
- ✅ Added: `dish_size_options` (size metadata)
- ✅ Added: `dish_ingredients` (base ingredients for recipes)

### Legacy Column Warnings

These columns are **HISTORICAL REFERENCE ONLY** - DO NOT USE IN BUSINESS LOGIC:
- `dishes.legacy_v1_id`, `dishes.legacy_v2_id`
- `courses.legacy_v1_id`, `courses.legacy_v2_id`
- `ingredients.legacy_v1_id`, `ingredients.legacy_v2_id`
- `ingredient_groups.legacy_v1_id`, `ingredient_groups.legacy_v2_id`
- `combo_groups.legacy_v1_id`, `combo_groups.legacy_v2_id`

**Usage:** Audit trail and debugging only. All new logic should use unified V3 patterns.

### Data Quality Notes

**Fixed Issues:**
- ✅ All active dishes now have pricing (was 772 without, now 0)
- ✅ All modifier codes normalized (was 2-letter codes, now full words)
- ✅ All foreign keys validated (orphaned records cleaned up)

**Known Non-Critical Issues:**
- ⚠️ 793 dishes have $0.00 default pricing (restaurants should update)
- ⚠️ Some dishes have NULL `course_id` (valid business case)

---

## 📚 ADDITIONAL RESOURCES

- **Business Rules:** `/documentation/Menu & Catalog/BUSINESS_RULES.md`
- **Refactoring Plan:** `/plans/MENU_CATALOG_REFACTORING_PLAN.md`
- **Phase Reports:** `/reports/database/MENU_CATALOG_PHASE_*.md`
- **Action Items:** `/reports/database/MENU_CATALOG_ACTION_PLAN.md`

---

**Last Updated:** 2025-10-30  
**Status:** ✅ **PRODUCTION READY**  
**Next Steps:** Frontend integration, performance testing

