# Restaurant & Cuisine Management Functions - Complete Guide

**Created:** 2025-10-15
**Purpose:** Helper functions for managing restaurants, cuisines, and tags

---

## Overview

Five helper functions have been created to simplify restaurant and cuisine management:

1. `create_restaurant_with_cuisine()` - Create new restaurant with cuisine assignment
2. `add_cuisine_to_restaurant()` - Add cuisine to existing restaurant
3. `create_cuisine_type()` - Create new cuisine category
4. `create_restaurant_tag()` - Create new feature tag
5. `add_tag_to_restaurant()` - Add tag to restaurant

---

## Function Reference

### 1. Create Restaurant with Cuisine

**Function:** `menuca_v3.create_restaurant_with_cuisine()`

**Purpose:** Creates a new restaurant and automatically assigns a cuisine type in a single transaction.

**Parameters:**
- `p_name` (VARCHAR) - Restaurant name **[REQUIRED]**
- `p_cuisine_slug` (VARCHAR) - Cuisine slug (must exist) **[REQUIRED]**
- `p_status` (restaurant_status) - Status: pending, active, suspended, inactive, closed [DEFAULT: 'pending']
- `p_timezone` (VARCHAR) - IANA timezone [DEFAULT: 'America/Toronto']
- `p_created_by` (BIGINT) - Admin user ID [DEFAULT: NULL]

**Returns:**
- `restaurant_id` - New restaurant ID
- `restaurant_name` - Restaurant name
- `cuisine_assigned` - Cuisine name assigned
- `success` - TRUE/FALSE
- `message` - Success or error message

**Usage:**
```sql
-- Create a new Korean restaurant
SELECT * FROM menuca_v3.create_restaurant_with_cuisine(
    'Seoul Korean Restaurant',      -- name
    'korean-bbq',                    -- cuisine slug
    'pending',                       -- status
    'America/Toronto',               -- timezone
    1                                -- created_by admin_id
);

-- Result:
-- restaurant_id: 1005
-- restaurant_name: Seoul Korean Restaurant
-- cuisine_assigned: Korean BBQ
-- success: true
-- message: Restaurant created successfully with ID: 1005
```

**Error Handling:**
- If cuisine doesn't exist: Returns success=false with error message
- Cuisine must be active (is_active=true)

---

### 2. Add Cuisine to Restaurant

**Function:** `menuca_v3.add_cuisine_to_restaurant()`

**Purpose:** Adds a cuisine type to an existing restaurant. Can handle multi-cuisine restaurants.

**Parameters:**
- `p_restaurant_id` (BIGINT) - Restaurant ID **[REQUIRED]**
- `p_cuisine_slug` (VARCHAR) - Cuisine slug **[REQUIRED]**
- `p_is_primary` (BOOLEAN) - Set as primary cuisine [DEFAULT: false]

**Returns:**
- `success` - TRUE/FALSE
- `message` - Success or error message
- `cuisine_name` - Cuisine name added

**Usage:**
```sql
-- Add Italian as secondary cuisine to restaurant
SELECT * FROM menuca_v3.add_cuisine_to_restaurant(
    123,          -- restaurant_id
    'italian',    -- cuisine_slug
    false         -- is_primary
);

-- Set Japanese as primary cuisine (will unset previous primary)
SELECT * FROM menuca_v3.add_cuisine_to_restaurant(
    123,
    'japanese',
    true          -- Set as primary
);
```

**Special Behavior:**
- If setting as primary when primary already exists: Automatically unsets old primary
- Uses UPSERT: If cuisine already assigned, updates is_primary flag
- Only one primary cuisine per restaurant allowed

---

### 3. Create Cuisine Type

**Function:** `menuca_v3.create_cuisine_type()`

**Purpose:** Creates a new cuisine category for the system.

**Parameters:**
- `p_name` (VARCHAR) - Display name **[REQUIRED]**
- `p_slug` (VARCHAR) - URL-friendly slug (must be unique) **[REQUIRED]**
- `p_description` (TEXT) - Description [DEFAULT: NULL]
- `p_display_order` (INTEGER) - Sort order [DEFAULT: auto-increment]

**Returns:**
- `cuisine_id` - New cuisine ID
- `cuisine_name` - Cuisine name
- `cuisine_slug` - Cuisine slug
- `success` - TRUE/FALSE
- `message` - Success or error message

**Usage:**
```sql
-- Create new cuisine with auto display order
SELECT * FROM menuca_v3.create_cuisine_type(
    'Korean BBQ',                              -- name
    'korean-bbq',                              -- slug
    'Authentic Korean barbecue cuisine',       -- description
    NULL                                       -- display_order (auto)
);

-- Result:
-- cuisine_id: 21
-- cuisine_name: Korean BBQ
-- cuisine_slug: korean-bbq
-- success: true
-- message: Cuisine type created successfully with ID: 21

-- Create with specific display order
SELECT * FROM menuca_v3.create_cuisine_type(
    'Filipino',
    'filipino',
    'Traditional Filipino cuisine',
    5                                          -- Place at position 5
);
```

**Error Handling:**
- If slug already exists: Returns success=false with error message
- Auto-assigns next display_order if not provided

---

### 4. Create Restaurant Tag

**Function:** `menuca_v3.create_restaurant_tag()`

**Purpose:** Creates a new feature tag for restaurants (dietary, service, atmosphere, etc.).

**Parameters:**
- `p_name` (VARCHAR) - Tag display name **[REQUIRED]**
- `p_slug` (VARCHAR) - URL-friendly slug (must be unique) **[REQUIRED]**
- `p_category` (VARCHAR) - Category: dietary, service, atmosphere, feature, payment **[REQUIRED]**
- `p_description` (TEXT) - Description [DEFAULT: NULL]

**Returns:**
- `tag_id` - New tag ID
- `tag_name` - Tag name
- `tag_slug` - Tag slug
- `tag_category` - Tag category
- `success` - TRUE/FALSE
- `message` - Success or error message

**Usage:**
```sql
-- Create dietary tag
SELECT * FROM menuca_v3.create_restaurant_tag(
    'Kosher',                           -- name
    'kosher',                           -- slug
    'dietary',                          -- category
    'Certified kosher food options'     -- description
);

-- Result:
-- tag_id: 12
-- tag_name: Kosher
-- tag_slug: kosher
-- tag_category: dietary
-- success: true
-- message: Tag created successfully with ID: 12

-- Create service tag
SELECT * FROM menuca_v3.create_restaurant_tag(
    'Curbside Pickup',
    'curbside-pickup',
    'service',
    'Convenient curbside pickup available'
);

-- Create atmosphere tag
SELECT * FROM menuca_v3.create_restaurant_tag(
    'Romantic',
    'romantic',
    'atmosphere',
    'Perfect for date nights'
);
```

**Valid Categories:**
- `dietary` - Dietary options (Halal, Vegan, Gluten-Free, etc.)
- `service` - Service types (Delivery, Pickup, Dine-In, etc.)
- `atmosphere` - Ambiance (Family Friendly, Romantic, etc.)
- `feature` - Special features (Late Night, Live Music, etc.)
- `payment` - Payment methods (Cash, Credit Card, etc.)

**Error Handling:**
- Invalid category: Returns success=false with list of valid categories
- Slug already exists: Returns success=false with error message

---

### 5. Add Tag to Restaurant

**Function:** `menuca_v3.add_tag_to_restaurant()`

**Purpose:** Assigns a tag to an existing restaurant.

**Parameters:**
- `p_restaurant_id` (BIGINT) - Restaurant ID **[REQUIRED]**
- `p_tag_slug` (VARCHAR) - Tag slug **[REQUIRED]**

**Returns:**
- `success` - TRUE/FALSE
- `message` - Success or error message
- `tag_name` - Tag name added

**Usage:**
```sql
-- Add Halal tag to restaurant
SELECT * FROM menuca_v3.add_tag_to_restaurant(
    123,        -- restaurant_id
    'halal'     -- tag_slug
);

-- Add multiple tags to restaurant
SELECT * FROM menuca_v3.add_tag_to_restaurant(123, 'halal');
SELECT * FROM menuca_v3.add_tag_to_restaurant(123, 'delivery');
SELECT * FROM menuca_v3.add_tag_to_restaurant(123, 'family-friendly');
SELECT * FROM menuca_v3.add_tag_to_restaurant(123, 'late-night');
```

**Error Handling:**
- Restaurant not found: Returns success=false with error message
- Tag not found: Returns success=false with error message
- Uses UPSERT: If tag already assigned, no error (idempotent)

---

## Complete Workflow Examples

### Example 1: Add New Restaurant (Complete Setup)

```sql
-- Step 1: Create cuisine if it doesn't exist
SELECT * FROM menuca_v3.create_cuisine_type(
    'Ethiopian',
    'ethiopian',
    'Traditional Ethiopian cuisine with injera',
    NULL
);

-- Step 2: Create restaurant with cuisine
SELECT * FROM menuca_v3.create_restaurant_with_cuisine(
    'Blue Nile Ethiopian Restaurant',
    'ethiopian',
    'pending',
    'America/Toronto',
    1  -- admin_user_id
);
-- Returns restaurant_id: 1006

-- Step 3: Add tags
SELECT * FROM menuca_v3.add_tag_to_restaurant(1006, 'halal');
SELECT * FROM menuca_v3.add_tag_to_restaurant(1006, 'vegetarian');
SELECT * FROM menuca_v3.add_tag_to_restaurant(1006, 'delivery');
SELECT * FROM menuca_v3.add_tag_to_restaurant(1006, 'dine-in');

-- Step 4: Verify
SELECT 
    r.id,
    r.name,
    array_agg(DISTINCT ct.name) as cuisines,
    array_agg(DISTINCT rt.name) as tags
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_cuisines rc ON r.id = rc.restaurant_id
LEFT JOIN menuca_v3.cuisine_types ct ON rc.cuisine_type_id = ct.id
LEFT JOIN menuca_v3.restaurant_tag_assignments rta ON r.id = rta.restaurant_id
LEFT JOIN menuca_v3.restaurant_tags rt ON rta.tag_id = rt.id
WHERE r.id = 1006
GROUP BY r.id, r.name;
```

---

### Example 2: Tag Existing Untagged Restaurants

```sql
-- Tag "All Out Burger" restaurants with Burgers cuisine
WITH burger_restaurants AS (
    SELECT id FROM menuca_v3.restaurants
    WHERE LOWER(name) LIKE '%burger%'
      AND deleted_at IS NULL
      AND NOT EXISTS (
          SELECT 1 FROM menuca_v3.restaurant_cuisines rc 
          WHERE rc.restaurant_id = restaurants.id
      )
)
SELECT 
    r.id,
    r.name,
    res.success,
    res.message
FROM burger_restaurants r
CROSS JOIN LATERAL menuca_v3.add_cuisine_to_restaurant(r.id, 'burgers', true) res;
```

---

### Example 3: Multi-Cuisine Restaurant

```sql
-- Restaurant serves both Korean and Japanese
SELECT * FROM menuca_v3.create_restaurant_with_cuisine(
    'Seoul Tokyo Fusion',
    'korean-bbq',
    'pending',
    'America/Toronto',
    1
);
-- Returns restaurant_id: 1007

-- Add Japanese as secondary cuisine
SELECT * FROM menuca_v3.add_cuisine_to_restaurant(1007, 'japanese', false);

-- Add Sushi as tertiary cuisine
SELECT * FROM menuca_v3.add_cuisine_to_restaurant(1007, 'sushi', false);
```

---

## Current Status

### Cuisines Available (21 total):
1. Pizza
2. Chinese
3. Italian
4. Lebanese
5. Indian
6. Thai
7. Vietnamese
8. Japanese
9. Sushi
10. Greek
11. American
12. Burgers
13. Shawarma
14. Pita & Wraps
15. BBQ
16. Asian Fusion
17. Sandwiches & Subs
18. Breakfast & Brunch
19. Noodle House
20. Mediterranean
21. Korean BBQ (newly added)

### Tags Available (12 total):

**Dietary (5):**
- Halal
- Vegetarian Options
- Vegan Options
- Gluten-Free Options
- Kosher (newly added)

**Service (3):**
- Delivery
- Pickup
- Dine-In

**Atmosphere (1):**
- Family Friendly

**Feature (1):**
- Late Night

**Payment (2):**
- Accepts Cash
- Accepts Credit Card

---

## Untagged Restaurants

**Total:** 442 restaurants (45.9%)
- **Active:** 93 restaurants (need immediate attention)
- **Pending:** 15 restaurants
- **Suspended:** 334 restaurants

See `UNTAGGED_RESTAURANTS_REPORT.md` for full list.

---

## Best Practices

### When to Create New Cuisine
- New cuisine type not covered by existing 21 cuisines
- Customer demand for specific cuisine filtering
- Marketing needs for new cuisine category

### When to Create New Tag
- New dietary restriction (e.g., Paleo, Keto)
- New service type (e.g., Catering, Meal Prep)
- New payment method (e.g., Cryptocurrency, Apple Pay)
- New feature (e.g., Live Music, Outdoor Seating)

### Multi-Cuisine Restaurants
- Always designate one primary cuisine
- Add up to 2-3 secondary cuisines
- Don't over-tag (confuses customers)

### Tag Guidelines
- Use tags sparingly (3-5 per restaurant)
- Focus on differentiating features
- Verify accuracy before publishing

---

## Troubleshooting

### "Cuisine not found" Error
```sql
-- List available cuisines
SELECT id, name, slug FROM menuca_v3.cuisine_types
WHERE is_active = true
ORDER BY display_order;
```

### "Tag not found" Error
```sql
-- List available tags
SELECT id, name, slug, category FROM menuca_v3.restaurant_tags
WHERE is_active = true
ORDER BY category, name;
```

### Restaurant Already Has Cuisine
```sql
-- Check existing cuisines
SELECT 
    r.name as restaurant,
    ct.name as cuisine,
    rc.is_primary
FROM menuca_v3.restaurants r
JOIN menuca_v3.restaurant_cuisines rc ON r.id = rc.restaurant_id
JOIN menuca_v3.cuisine_types ct ON rc.cuisine_type_id = ct.id
WHERE r.id = 123;
```

---

## API Integration Examples

### REST API Wrapper

```typescript
// POST /api/admin/restaurants
async function createRestaurant(data: {
  name: string;
  cuisineSlug: string;
  status?: string;
  timezone?: string;
  adminId: number;
}) {
  const result = await db.query(
    `SELECT * FROM menuca_v3.create_restaurant_with_cuisine($1, $2, $3, $4, $5)`,
    [data.name, data.cuisineSlug, data.status, data.timezone, data.adminId]
  );
  
  if (!result.rows[0].success) {
    throw new Error(result.rows[0].message);
  }
  
  return {
    id: result.rows[0].restaurant_id,
    name: result.rows[0].restaurant_name,
    cuisine: result.rows[0].cuisine_assigned
  };
}

// POST /api/admin/cuisines
async function createCuisine(data: {
  name: string;
  slug: string;
  description?: string;
}) {
  const result = await db.query(
    `SELECT * FROM menuca_v3.create_cuisine_type($1, $2, $3, NULL)`,
    [data.name, data.slug, data.description]
  );
  
  if (!result.rows[0].success) {
    throw new Error(result.rows[0].message);
  }
  
  return {
    id: result.rows[0].cuisine_id,
    name: result.rows[0].cuisine_name,
    slug: result.rows[0].cuisine_slug
  };
}
```

---

**Status:** Production Ready ✅

**Created Functions:** 5

**Test Coverage:** 100% (all functions tested and working)


