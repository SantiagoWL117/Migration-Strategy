# Handoff Message - New Session Context

**Date:** 2025-10-24
**Project:** MenuCA V3 Customer Frontend App
**Status:** MCP authenticated, ready to query database schema

---

## CRITICAL CONTEXT

### What We Just Accomplished
✅ **Supabase MCP is now authenticated and connected**
- Removed old unauthenticated MCP configuration
- Added new configuration with Personal Access Token
- Status: `✓ Connected` (verified with `claude mcp list`)

### The Problem We're Solving
The frontend app successfully connects to Supabase but we've been **GUESSING at table and column names** instead of using the MCP to inspect the actual database schema. This has caused multiple errors throughout development.

---

## IMMEDIATE TASK - TOP PRIORITY

**YOU MUST use the Supabase MCP tools to query the database schema.**

### Step 1: Verify MCP Tools Are Available
You should see tools like:
- `mcp__supabase__list_tables`
- `mcp__supabase__execute_sql`
- `mcp__supabase__list_projects`

If you DON'T see these tools, STOP and tell the user - we cannot proceed without them.

### Step 2: Query the Schema
Run these queries using the MCP:

**Query 1: Get all table names in menuca_v3 schema**
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'menuca_v3'
ORDER BY table_name;
```

**Query 2: Get menu-related tables specifically**
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'menuca_v3'
AND (
    table_name LIKE '%menu%'
    OR table_name LIKE '%dish%'
    OR table_name LIKE '%course%'
    OR table_name LIKE '%item%'
)
ORDER BY table_name;
```

**Query 3: Get columns for each menu table found**
```sql
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'menuca_v3'
AND table_name = 'TABLE_NAME_HERE'
ORDER BY ordinal_position;
```

### Step 3: Update Documentation
Update `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Frontend-build/DATABASE_SCHEMA_REFERENCE.md` with the ACTUAL table structures you discover.

### Step 4: Fix the Menu Page
Update `/Users/brianlapp/Documents/GitHub/Migration-Strategy/Frontend-build/customer-app/app/r/[slug]/page.tsx` with the correct table names and column names.

---

## PROJECT STRUCTURE

**Main Project Root:**
```
/Users/brianlapp/Documents/GitHub/Migration-Strategy/
```

**Frontend App (where we work):**
```
/Users/brianlapp/Documents/GitHub/Migration-Strategy/Frontend-build/customer-app/
```

**Key Files:**
- `Frontend-build/DATABASE_SCHEMA_REFERENCE.md` - Our schema documentation (UPDATE THIS)
- `Frontend-build/MISSING_DATABASE_COLUMNS_REPORT.md` - Lists missing columns in restaurants table
- `Frontend-build/customer-app/app/r/[slug]/page.tsx` - Restaurant menu page (NEEDS FIXING)
- `Frontend-build/customer-app/lib/supabase/client.ts` - Browser Supabase client
- `Frontend-build/customer-app/lib/supabase/server.ts` - Server Supabase client

---

## WHAT WE KNOW ABOUT THE DATABASE

### Supabase Connection
- **Project URL:** `https://nthpbtdjhhnwfxqsxbvy.supabase.co`
- **Schema:** `menuca_v3` (NOT public!)
- **Database is connected and working** ✅

### restaurants Table (31 columns - VERIFIED)
```
id, uuid, legacy_v1_id, legacy_v2_id
name, slug, timezone
status, activated_at, suspended_at, closed_at
online_ordering_enabled, online_ordering_disabled_at, online_ordering_disabled_reason
parent_restaurant_id, is_franchise_parent, franchise_brand_name
created_at, created_by, updated_at, updated_by, deleted_at, deleted_by
meta_title, meta_description, meta_keywords, og_image_url, search_keywords
is_featured, featured_priority, search_vector
```

### MISSING from restaurants table:
- `average_rating`, `review_count` (don't exist anywhere)
- `delivery_fee` (exists in `orders`, `restaurant_delivery_areas` tables)
- `minimum_order` (doesn't exist anywhere)
- `estimated_delivery_time` (exists in `orders` table)
- `image_url` (exists in `dishes` table)
- `description` (exists in `dishes`, `courses`, `ingredients` tables)
- `cuisine_type_id` (foreign key - `cuisine_types` table exists)

### restaurant_locations Table
- ⚠️ **Table exists but NO DATA**
- Missing: `latitude`, `longitude`
- This breaks distance calculations via `find_nearby_restaurants` RPC

### Menu Tables - UNKNOWN ❌
**THIS IS WHAT YOU NEED TO DISCOVER WITH THE MCP!**

We've been guessing names like:
- `menu_courses` (maybe?)
- `menu_items` (maybe?)
- `dishes` (exists, has `description` and `image_url`)
- `courses` (exists, has `description`)

**DO NOT ASSUME THESE ARE CORRECT!** Use the MCP to verify.

---

## KNOWN ISSUES & PATTERNS

### Schema Configuration
Both Supabase clients are configured with default schema:
```typescript
{
  db: { schema: 'menuca_v3' }
}
```

But RPC calls STILL need explicit `.schema('menuca_v3')`:
```typescript
await supabase
  .schema('menuca_v3')
  .rpc('find_nearby_restaurants', { ... })
```

### User's Critical Rules (NEVER VIOLATE)
1. **NEVER use placeholder/fake data** - show "N/A" or nothing instead
2. **NEVER hide features** - if data is missing, show indicators and fix the data flow
3. **ALWAYS check DATABASE_SCHEMA_REFERENCE.md before writing queries**
4. **ALWAYS use MCP to verify schema** - never guess table/column names
5. **DATABASE CONNECTION IS #1 PRIORITY** - nothing works without it

---

## WHAT THE FRONTEND IS WAITING FOR

The app is built and ready. We just need the correct table/column names for:

1. **Menu display** - What tables hold menu categories and items?
2. **Item details** - What columns exist (name, price, description, image, etc.)?
3. **Modifiers** - How are dish modifiers stored?
4. **Relationships** - How do menu items link to restaurants?

Once you discover the schema structure, update:
1. `DATABASE_SCHEMA_REFERENCE.md`
2. `/app/r/[slug]/page.tsx` queries
3. TypeScript interfaces if needed

---

## TODO LIST

- [x] Authenticate Supabase MCP
- [x] **Use MCP to query menuca_v3 schema structure**
- [x] Document all tables in DATABASE_SCHEMA_REFERENCE.md
- [x] Update restaurant menu page with verified table names
- [x] Fix menu display UX (show all dishes, not gated behind clicks)
- [x] Redesign menu to match industry standards (UberEats/DoorDash)
- [ ] Continue frontend development per MVP plan

---

## LATEST UPDATES (2025-10-24)

### ✅ Menu System Complete
- **Schema discovered** via MCP - courses, dishes, dish_prices, dish_modifiers, ingredients
- **RLS policies added** for public read access
- **Data audit completed** - 29 out of 277 restaurants have menu data (see RESTAURANT_DATA_AUDIT_2025_10_24.md)
- **Menu page redesigned** to industry standards (2-column grid, compact spacing)

### ✅ Menu Display UX Fixed
- Changed from single-category-at-a-time to show-all-dishes-at-once
- Categories now serve as jump navigation, not content gates
- 4x better space efficiency (8-12 dishes per viewport instead of 3)

### 🎯 Current Status
**Working restaurant URLs for testing:**
- `http://localhost:3001/r/pho-dau-bo-restaurant-kitchener-147` (186 dishes, 11 courses)
- `http://localhost:3001/r/lucky-star-chinese-food-8` (142 dishes, 19 courses)
- See RESTAURANT_DATA_AUDIT_2025_10_24.md for full list

---

## HOW TO VERIFY MCP IS WORKING

Run in terminal:
```bash
claude mcp list
```

Should show:
```
supabase: npx -y @supabase/mcp-server-supabase@latest --access-token sbp_... - ✓ Connected
```

If it shows "⚠ Needs authentication" - the MCP is NOT working and you cannot proceed.

---

## EMERGENCY CONTEXT

The user has been extremely frustrated because we kept making assumptions about the database schema instead of using the MCP to verify. Multiple sessions have been wasted on errors caused by guessing table names.

**Do NOT proceed with ANY database queries until you:**
1. Verify MCP tools are available to you
2. Query the actual schema structure
3. Update the documentation with facts, not guesses

If MCP tools are not available, STOP and tell the user immediately. Do not pivot to workarounds.

---

**Ready to proceed?**

1. Check if you have `mcp__supabase__*` tools available
2. If yes: Query the schema
3. If no: Tell the user and STOP
