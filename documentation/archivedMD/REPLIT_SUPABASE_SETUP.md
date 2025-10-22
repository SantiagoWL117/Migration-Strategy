# 🚀 Replit + Supabase Setup Guide
## Building the Menu.ca Frontend with Perfect Database Context

---

## 🎯 **TLDR: Best Approach**

1. ✅ **Generate TypeScript types from Supabase** (for autocomplete + type safety)
2. ✅ **Create a Database Schema Reference Doc** (for AI understanding)
3. ✅ **Use Mermaid diagrams** (for visual relationships)
4. ✅ **Write Feature Specs** (for business logic)

---

## 📋 **STEP 1: Generate TypeScript Types from Supabase**

### **✅ DONE! Types Already Generated!**

I've already created a comprehensive TypeScript types file for you:

📄 **`types/supabase-database.ts`**

This file includes:
- ✅ All 74 tables from `menuca_v3` schema
- ✅ Full ENUM types (restaurant_status, service_type, etc.)
- ✅ Insert/Update/Row types for each table
- ✅ Helper types (Restaurant, Dish, Order, User, etc.)
- ✅ ENUM constants for easy access

**You can use it immediately!** Just copy `types/supabase-database.ts` to your Replit project.

### **Option A: Via Supabase CLI (Alternative)**

If you want to regenerate types in the future:

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF

# Generate types for menuca_v3 schema
supabase gen types typescript --project-id YOUR_PROJECT_ID --schema menuca_v3 > types/database.ts
```

### **Option B: Use the Pre-Generated File**

The file at `types/supabase-database.ts` is **ready to use** and includes all your tables!

### **What This Gives You:**

```typescript
// Autocomplete + Type Safety for ALL tables!
import { Database, Restaurant, Dish, Order } from './types/supabase-database'

// Use the helper types
const restaurant: Restaurant = {
  id: 1,
  name: "Joe's Pizza",
  status: "active", // Autocomplete! Only valid statuses allowed
  // ... all other fields
}

// Supabase client with types
import { createClient } from '@supabase/supabase-js'

const supabase = createClient<Database>(SUPABASE_URL, SUPABASE_ANON_KEY)

// Now you get autocomplete for ALL tables and columns!
const { data: restaurants } = await supabase
  .from('restaurants') // Autocomplete!
  .select('id, name, status, restaurant_locations(*)')
  .eq('status', 'active') // Autocomplete for status values!

// Use ENUMs
import { RestaurantStatus, OrderStatus } from './types/supabase-database'

const activeRestaurants = await supabase
  .from('restaurants')
  .select('*')
  .eq('status', RestaurantStatus.ACTIVE) // Type-safe!
```

---

## 📋 **STEP 2: Create Database Context Document**

Create a `database-context.md` file for Replit Agent to understand the schema:

### **Template:**

```markdown
# Menu.ca Database Schema (menuca_v3)

## 🏢 Core Business Entities

### 1️⃣ Restaurant Management
- **restaurants** - Restaurant records (74 active restaurants)
  - Primary key: `id`
  - Status: ENUM ('pending', 'active', 'suspended', 'inactive', 'closed')
  - Relationships:
    - → restaurant_locations (1:many)
    - → restaurant_admins (via admin_user_restaurants)
    - → dishes (1:many)
    - → orders (1:many)

- **restaurant_locations** - Physical locations with geospatial data
  - Primary key: `id`
  - Foreign keys: `restaurant_id`, `city_id`
  - Features: PostGIS geometry for proximity search
  - Indexes: GIST index on `geom` column for fast radius queries

- **restaurant_domains** - Custom domains for each restaurant
  - Primary key: `id`
  - Foreign keys: `restaurant_id`
  - Types: 'main', 'other', 'mobile'

### 2️⃣ Menu & Catalog
- **dishes** - Menu items
  - Primary key: `id`
  - Foreign keys: `restaurant_id`, `course_id`
  - Features: 
    - Full-text search via `search_vector` (GIN index)
    - Size-based pricing via `dish_sizes` table
    - Allergen info, nutritional info
  - Relationships:
    - → dish_modifiers (1:many)
    - → combo_items (many:many)

- **courses** - Menu sections (Appetizers, Entrees, etc.)
  - Primary key: `id`
  - Features: `display_order` for sorting

- **ingredients** - Toppings and modifiers
  - Primary key: `id`
  - Foreign keys: `restaurant_id`, `ingredient_group_id`
  - Types: 'topping', 'modifier', 'side'
  - Size-based pricing: → ingredient_sizes

- **ingredient_groups** - Modifier groups
  - Primary key: `id`
  - Foreign keys: `restaurant_id`
  - Business Rules:
    - `min_selection` - Minimum required selections
    - `max_selection` - Maximum allowed selections
    - `free_quantity` - Number of free selections
    - `allow_duplicates` - Can customer select same item multiple times?
  - Example: "Choose 2 toppings (first 2 free, extra $1.50 each)"

- **combo_groups** - Meal deal definitions
  - Primary key: `id`
  - Foreign keys: `restaurant_id`
  - Relationships: → combo_items (1:many)
  - Status: `is_active`, `is_available`

### 3️⃣ Orders & Checkout
- **orders** - Order records (PARTITIONED by `created_at`)
  - Primary key: `(id, created_at)` - Composite PK for partitioning
  - Foreign keys: `restaurant_id`, `user_id`
  - Status: ENUM ('pending', 'confirmed', 'preparing', 'ready', 'out_for_delivery', 'delivered', 'cancelled')
  - Features:
    - Monthly partitions for scalability
    - UUID for public-facing IDs
  - Note: When querying, always include `created_at` for partition pruning

- **order_items** - Items in an order (PARTITIONED by `created_at`)
  - Primary key: `(id, created_at)`
  - Foreign keys: `(order_id, created_at)`, `dish_id`
  - Features: JSONB `customizations` for modifiers

### 4️⃣ Users & Access
- **users** - Customer accounts
  - Primary key: `id`
  - Features: `display_name`, MFA support

- **admin_users** - Platform-level admins
  - Primary key: `id`
  - Scope: Can manage multiple restaurants
  - Features: MFA support (mfa_enabled, mfa_secret, mfa_backup_codes)
  - Security: Row Level Security (RLS) enabled

- **admin_user_restaurants** - Admin-to-Restaurant junction
  - Primary key: `id`
  - Foreign keys: `admin_user_id`, `restaurant_id`
  - Role: 'owner', 'admin', 'staff'

### 5️⃣ Delivery Operations
- **delivery_areas** - Service coverage zones
  - Primary key: `id`
  - Foreign keys: `restaurant_location_id`, `city_id`

- **user_delivery_addresses** - Saved customer addresses
  - Primary key: `id`
  - Foreign keys: `user_id`, `city_id`, `province_id`
  - Constraint: Only ONE `is_default = true` per user (unique index)

### 6️⃣ Marketing & Promotions
- **promotional_deals** - Discounts and offers
  - Primary key: `id`
  - Foreign keys: `restaurant_id`
  - Types: `amount_type` ENUM ('percent', 'fixed')

- **promotional_coupons** - Promo codes
  - Primary key: `id`
  - Features: 
    - `usage_limit` - Total uses allowed
    - `per_user_limit` - Uses per customer
  - Fraud Prevention: → coupon_usage_log (tracks all uses)

- **coupon_usage_log** - Coupon redemption tracking
  - Primary key: `id`
  - Foreign keys: `coupon_id`, `user_id`, `(order_id, order_created_at)`
  - Constraint: UNIQUE (coupon_id, user_id, order_id) - Prevents duplicate uses

### 7️⃣ Service Configuration
- **restaurant_schedules** - Operating hours
  - Primary key: `id`
  - Foreign keys: `restaurant_location_id`
  - Features: `day_of_week`, `open_time`, `close_time`

- **restaurant_delivery_config** - Delivery settings
  - Primary key: `id`
  - Foreign keys: `restaurant_id`
  - Features: Minimum order, delivery radius, fees

### 8️⃣ Location & Geography
- **provinces** - States/provinces
  - Primary key: `id`
  - Features: `short_name` (e.g., "ON", "QC")

- **cities** - City reference
  - Primary key: `id`
  - Foreign keys: `province_id`
  - Features: Lat/lng coordinates, timezone

### 9️⃣ Infrastructure
- **audit_log** - Change tracking (PARTITIONED by `changed_at`)
  - Primary key: `(id, changed_at)`
  - Features: JSONB `old_data` and `new_data`
  - Retention: 90 days (auto-cleanup via pg_cron)

- **rate_limits** - API rate limiting
  - Primary key: `id`
  - Features: Tracks requests per IP/endpoint

- **email_queue** - Email sending queue
  - Primary key: `id`
  - Status: 'pending', 'sent', 'failed'

- **failed_jobs** - Job failure tracking
  - Primary key: `id`
  - Features: Retry count, error messages

---

## 🔗 **Key Relationships (For AI Understanding)**

```
restaurants (1) ←→ (many) restaurant_locations
restaurants (1) ←→ (many) dishes
restaurants (1) ←→ (many) orders
restaurants (1) ←→ (many) admin_user_restaurants ←→ (many) admin_users

dishes (1) ←→ (many) dish_modifiers ←→ (1) ingredient_groups ←→ (many) ingredients
dishes (1) ←→ (many) order_items ←→ (1) orders ←→ (1) users

combo_groups (1) ←→ (many) combo_items ←→ (1) dishes
promotional_coupons (1) ←→ (many) coupon_usage_log ←→ (1) orders

cities (1) ←→ (many) restaurant_locations
cities (1) ←→ (many) user_delivery_addresses
cities (many) ←→ (1) provinces
```

---

## ⚡ **Performance Notes (For AI)**

1. **Orders are PARTITIONED by month** - Always include `created_at` in WHERE clauses
2. **Full-text search on dishes** - Use `search_vector` column, not LIKE queries
3. **PostGIS for locations** - Use `ST_DWithin()` for proximity, not lat/lng math
4. **Composite indexes exist** - Use `(restaurant_id, course_id, display_order)` for menu queries

---

## 🚨 **Business Rules (Critical!)**

### **Ingredient Groups (Modifiers):**
- `min_selection` = minimum required (e.g., "Must choose 2 toppings")
- `max_selection` = maximum allowed (e.g., "Max 5 toppings")
- `free_quantity` = number of free items (e.g., "First 2 free, extra $1.50 each")
- `allow_duplicates` = can customer pick same item multiple times?

**Example:** Pizza toppings:
- min_selection = 0 (optional)
- max_selection = 5 (max 5 toppings)
- free_quantity = 2 (first 2 free)
- allow_duplicates = true (can have double pepperoni)

### **Coupon Fraud Prevention:**
- `promotional_coupons.usage_limit` = total uses allowed (NULL = unlimited)
- `promotional_coupons.per_user_limit` = max per user (NULL = unlimited)
- `coupon_usage_log` = tracks every redemption
- UNIQUE constraint prevents duplicate application to same order

### **User Delivery Addresses:**
- Only ONE `is_default = true` per user (enforced by unique index)
- Must reference valid `city_id` and `province_id`

---

## 📊 **Data Stats (As of October 2025)**

| Table | Row Count | Status |
|-------|-----------|--------|
| restaurants | 74 | ✅ Migrated |
| restaurant_locations | 82 | ✅ Migrated |
| dishes | 5,130 | ✅ Migrated |
| ingredients | 800+ | ✅ Migrated |
| combo_groups | 634 functional | ✅ 99.77% success |
| combo_items | 16,356 | ✅ Migrated |
| users | TBD | 🔄 In Progress |
| orders | 0 | 🆕 New table (partitioned) |

---

## 🎨 **Visual Diagrams Available**

Located in: `Database/Mermaid_Diagrams/`

1. **restaurant_management.mmd** - Restaurant entity relationships
2. **menu_catalog.mmd** - Menu, dishes, modifiers, combos
3. **orders_checkout.mmd** - Order flow
4. **users_access.mmd** - User roles and permissions
5. **delivery_operations.mmd** - Delivery areas and addresses
6. **marketing_promotions.mmd** - Deals, coupons, usage tracking
7. **service_schedules.mmd** - Hours, delivery config
8. **location_geography.mmd** - Provinces, cities
9. **accounting_reporting.mmd** - Commissions, reports

---

## 🔧 **Supabase Connection in Replit**

### **1. Environment Variables:**

```bash
# Create .env file in Replit
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### **2. Install Supabase Client:**

```bash
npm install @supabase/supabase-js
```

### **3. Initialize Client:**

```typescript
import { createClient } from '@supabase/supabase-js'
import { Database } from './types/database'

export const supabase = createClient<Database>(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!
)
```

### **4. Example Query:**

```typescript
// Get active restaurants with locations
const { data: restaurants, error } = await supabase
  .from('restaurants')
  .select(`
    id,
    name,
    status,
    restaurant_locations (
      id,
      address,
      city:cities (
        id,
        name,
        province:provinces (
          name,
          short_name
        )
      )
    )
  `)
  .eq('status', 'active')
  .order('name')

// Get menu for a restaurant with full-text search
const { data: dishes } = await supabase
  .from('dishes')
  .select(`
    id,
    name,
    description,
    course:courses (
      name,
      display_order
    ),
    dish_sizes (
      size_name,
      price
    )
  `)
  .eq('restaurant_id', restaurantId)
  .eq('is_active', true)
  .textSearch('search_vector', 'pizza') // Full-text search!
  .order('course_id, display_order')
```

---

## 🎯 **Feature Specifications to Provide to AI**

Along with the schema, tell Replit AI **what the app needs to do**:

### **Example Feature Spec:**

```markdown
## Feature: Restaurant Menu Display

**User Story:** As a customer, I want to browse a restaurant's menu organized by courses (Appetizers, Entrees, Desserts) with photos, descriptions, and pricing.

**Requirements:**
1. Fetch dishes for a specific restaurant
2. Group dishes by course (courses.display_order)
3. Sort dishes within each course by display_order
4. Show dish name, description, allergen info
5. Display size-based pricing (dish_sizes table)
6. Show "Out of Stock" for dishes with is_active = false
7. Support full-text search across dish names/descriptions

**Database Tables:**
- restaurants
- dishes
- courses
- dish_sizes

**Relationships:**
- restaurant (1) ←→ (many) dishes
- dish (1) ←→ (many) dish_sizes
- dish (many) ←→ (1) course
```

---

## 🚀 **Recommended Replit Setup Workflow**

### **Step 1: Project Setup**
```bash
# In Replit shell
npm init -y
npm install @supabase/supabase-js next react react-dom
npm install -D typescript @types/react @types/node
```

### **Step 2: Add Files to Replit**
1. `types/database.ts` - Supabase generated types
2. `docs/database-context.md` - This document
3. `docs/mermaid/` - Copy all `.mmd` files from GitHub
4. `.env` - Supabase credentials

### **Step 3: Prompt Replit Agent**

```
I'm building the Menu.ca food ordering platform frontend using Next.js + Supabase.

📋 Context Files:
- types/database.ts - Full database types
- docs/database-context.md - Schema documentation
- docs/mermaid/*.mmd - Visual entity diagrams

🎯 First Feature: Restaurant Menu Display

Build a restaurant menu page that:
1. Accepts restaurant_id as URL param
2. Fetches dishes grouped by courses
3. Shows size-based pricing from dish_sizes table
4. Displays allergen info and nutritional info
5. Marks out-of-stock items (is_active = false)
6. Includes full-text search using search_vector

Use Supabase client with TypeScript types for all queries.
Follow the database relationships shown in menu_catalog.mmd.
```

---

## 💡 **Pro Tips**

1. **Schema in `menuca_v3`, not `public`:**
   - Always query `supabase.from('restaurants')` - Supabase knows it's in `menuca_v3`
   - Don't prefix with schema name in queries

2. **Partitioned tables require `created_at`:**
   ```typescript
   // ✅ Good - includes partition key
   .from('orders')
   .select('*')
   .eq('restaurant_id', 123)
   .gte('created_at', '2025-10-01') // Partition key!
   
   // ❌ Bad - full table scan across all partitions
   .from('orders')
   .select('*')
   .eq('restaurant_id', 123)
   ```

3. **Use PostGIS for proximity:**
   ```typescript
   // Find restaurants within 5km of user
   .rpc('find_nearby_restaurants', {
     user_lat: 45.4215,
     user_lng: -75.6972,
     radius_km: 5
   })
   ```

4. **Respect business rules:**
   - Check `ingredient_groups.min_selection` before submitting order
   - Validate coupon with `promotional_coupons.usage_limit`
   - Enforce ONE default address per user

---

## ✅ **Checklist: Files to Share with Replit Agent**

- [ ] `types/database.ts` - Generated TypeScript types
- [ ] `docs/database-context.md` - This document
- [ ] `docs/mermaid/*.mmd` - Visual diagrams (all 9 files)
- [ ] `docs/features/` - Feature specifications (you create these)
- [ ] `.env` - Supabase URL and anon key

---

## 🎉 **You're Ready!**

With this setup, Replit Agent will:
- ✅ Understand your database schema completely
- ✅ Get autocomplete for all tables/columns
- ✅ Respect relationships and constraints
- ✅ Follow business rules (min/max selections, coupon limits, etc.)
- ✅ Use optimized queries (full-text search, PostGIS, partitions)
- ✅ Build features that align with your database design

---

**Last Updated:** October 15, 2025  
**Database Version:** menuca_v3 (100+ tables → 74 tables, optimized)  
**Migration Status:** 91.3% complete (21/23 items done)  

