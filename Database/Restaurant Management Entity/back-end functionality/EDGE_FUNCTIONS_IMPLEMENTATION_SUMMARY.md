# Edge Functions Implementation Summary

**Date:** 2025-10-17
**Purpose:** Document the implementation of hybrid SQL + Edge Function architecture for Restaurant Management Entity
**Platform:** ✅ **Supabase Edge Functions (Deno Runtime)**
**Status:** ✅ **Franchise Backend Complete** | ⏳ **Categorization In Progress**

---

## Overview

This document tracks the implementation of Edge Function wrappers for the Restaurant Management Entity backend. The hybrid approach maintains atomic SQL functions for database operations while adding **Supabase Edge Functions** for authentication, authorization, audit logging, and application-level concerns.

**All Edge Functions are deployed to Supabase and use Deno runtime with JSR imports.**

---

## Infrastructure

### Database Tables

#### `admin_action_logs` - Admin Action Audit Trail
**Status:** ✅ **Created**

```sql
CREATE TABLE menuca_v3.admin_action_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  action VARCHAR(255) NOT NULL,
  resource_type VARCHAR(100) NOT NULL,
  resource_id BIGINT,
  metadata JSONB DEFAULT '{}',
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Purpose:** Tracks explicit admin actions via API (separate from automatic `audit_log` triggers).

**Indexes:**
- `idx_admin_action_logs_user_id` - Query by admin user
- `idx_admin_action_logs_action` - Query by action type
- `idx_admin_action_logs_resource` - Query by resource
- `idx_admin_action_logs_created_at` - Time-based queries

---

### Shared Utilities Structure

**Platform:** Supabase Edge Functions use self-contained functions (inline utilities per function)

#### Core Utilities (Inlined in Each Function)
- **CORS Headers** - CORS configuration for API access
- **Authentication** - JWT verification via Supabase Auth
- **Response Helpers** - `badRequest()`, `successResponse()`, `internalError()`, `created()`
- **Validation** - Required field validation and sanitization
- **Audit Logging** - `logAdminAction()` writes to `admin_action_logs`

#### TypeScript Types
- `CreateFranchiseParentRequest` - Create franchise parent params
- `ConvertRequest` - Single/batch franchise conversion params
- `CascadeMenuRequest` - Menu cascading params

---

## 🏢 Franchise / Chain Hierarchy

**Status:** ✅ **Complete** (SQL + Edge Functions)

### Architecture Overview

**Hybrid Approach:**
- **SQL Functions:** Core business logic, data validation, atomic transactions
- **Edge Functions:** Authentication, authorization, audit logging, cache management, notifications

**SQL Functions Implemented:** 9 functions
**Edge Functions Implemented:** 3 functions

---

### Edge Function 1: Create Franchise Parent

**Endpoint:** `POST /functions/v1/create-franchise-parent`

**SQL Function:** `menuca_v3.create_franchise_parent()`

**Edge Function:** `supabase/functions/create-franchise-parent/index.ts`

**Deployment Status:** ✅ **Deployed to Supabase** (Version 1, Active)

**Purpose:** Create a new franchise parent/brand with multiple locations.

**Features:**
- ✅ Authentication required (Bearer token)
- ✅ Authorization: `franchise.create` permission
- ✅ Input validation (name, brand_name, city_id, province_id)
- ✅ SQL function call (atomic transaction)
- ✅ Admin action logging
- ✅ Cache invalidation
- ✅ Slack notification
- ✅ REST-compliant response

**Request Example:**
```bash
curl -X POST \
  https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/create-franchise-parent \
  -H "Authorization: Bearer <supabase_anon_key>" \
  -H "Content-Type: application/json" \
  -d

{
  "name": "Milano Pizza - Corporate",
  "franchise_brand_name": "Milano Pizza",
  "city_id": 245,
  "province_id": 9,
  "timezone": "America/Toronto",
  "created_by": 42
}
```

**Response Example (201 Created):**
```json
{
  "success": true,
  "data": {
    "parent_id": 1005,
    "brand_name": "Milano Pizza",
    "name": "Milano Pizza - Corporate",
    "status": "active"
  },
  "message": "Franchise parent created successfully"
}
```

**SQL Function Called:**
```sql
CREATE OR REPLACE FUNCTION menuca_v3.create_franchise_parent(
  p_name VARCHAR,
  p_franchise_brand_name VARCHAR,
  p_city_id INTEGER,
  p_province_id INTEGER,
  p_timezone VARCHAR DEFAULT 'America/Toronto',
  p_created_by BIGINT DEFAULT NULL
)
RETURNS TABLE (
  parent_id BIGINT,
  brand_name VARCHAR,
  name VARCHAR,
  status public.restaurant_status
)
```

**Validation:**
- Brand name uniqueness
- Valid city_id and province_id
- Name length (2-255 characters)
- Timezone format (IANA)

**Post-Creation Actions (Async):**
1. Log to `admin_action_logs`
2. Invalidate caches: `franchises`, `franchises:list`, `restaurants:franchises`
3. Send Slack notification

---

### Edge Function 2: Convert Restaurant to Franchise

**Endpoint:** `POST /functions/v1/convert-restaurant-to-franchise`

**SQL Functions:** 
- `menuca_v3.convert_to_franchise()` - Single conversion
- `menuca_v3.batch_link_franchise_children()` - Bulk conversion

**Edge Function:** `supabase/functions/convert-restaurant-to-franchise/index.ts`

**Deployment Status:** ✅ **Deployed to Supabase** (Version 1, Active)

**Purpose:** Convert independent restaurant to franchise location OR bulk-link multiple restaurants.

**Features:**
- ✅ Authentication required (Bearer token)
- ✅ Authorization: `franchise.update` permission
- ✅ Smart detection: single vs batch conversion
- ✅ Input validation (restaurant_id, parent_id, child arrays)
- ✅ SQL function calls (atomic transactions)
- ✅ Admin action logging
- ✅ Cache invalidation (per-restaurant + franchise)
- ✅ Slack notification
- ✅ REST-compliant response

**Single Conversion Request:**
```bash
curl -X POST \
  https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/convert-restaurant-to-franchise \
  -H "Authorization: Bearer <supabase_anon_key>" \
  -H "Content-Type: application/json" \
  -d

{
  "restaurant_id": 561,
  "parent_restaurant_id": 1005,
  "updated_by": 42
}
```

**Single Conversion Response:**
```json
{
  "success": true,
  "data": {
    "restaurant_id": 561,
    "restaurant_name": "Milano Pizza - Downtown",
    "parent_restaurant_id": 1005,
    "parent_brand_name": "Milano Pizza"
  },
  "message": "Restaurant converted to franchise successfully"
}
```

**Batch Conversion Request:**
```bash
curl -X POST \
  https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/convert-restaurant-to-franchise \
  -H "Authorization: Bearer <supabase_anon_key>" \
  -H "Content-Type: application/json" \
  -d

{
  "parent_restaurant_id": 1005,
  "child_restaurant_ids": [561, 562, 563, 564],
  "updated_by": 42
}
```

**Batch Conversion Response:**
```json
{
  "success": true,
  "data": {
    "parent_restaurant_id": 1005,
    "parent_brand_name": "Milano Pizza",
    "linked_count": 4,
    "child_restaurants": [
      { "id": 561, "name": "Milano Pizza - Downtown" },
      { "id": 562, "name": "Milano Pizza - Uptown" },
      { "id": 563, "name": "Milano Pizza - West" },
      { "id": 564, "name": "Milano Pizza - East" }
    ]
  },
  "message": "Successfully linked 4 restaurants to franchise"
}
```

**SQL Functions Called:**

**Single:**
```sql
CREATE OR REPLACE FUNCTION menuca_v3.convert_to_franchise(
  p_restaurant_id BIGINT,
  p_parent_restaurant_id BIGINT,
  p_updated_by BIGINT DEFAULT NULL
)
RETURNS TABLE (
  restaurant_id BIGINT,
  restaurant_name VARCHAR,
  parent_restaurant_id BIGINT,
  parent_brand_name VARCHAR
)
```

**Batch:**
```sql
CREATE OR REPLACE FUNCTION menuca_v3.batch_link_franchise_children(
  p_parent_restaurant_id BIGINT,
  p_child_restaurant_ids BIGINT[],
  p_updated_by BIGINT DEFAULT NULL
)
RETURNS TABLE (
  parent_restaurant_id BIGINT,
  parent_brand_name VARCHAR,
  linked_count INTEGER,
  child_restaurants JSONB
)
```

**Validation:**
- Parent restaurant must be franchise parent (`is_franchise_parent = true`)
- Child restaurants must exist and not already be franchise children
- All IDs must be positive integers

**Post-Conversion Actions (Async):**
1. Log to `admin_action_logs` with action `franchise.convert` or `franchise.batch_link`
2. Invalidate caches: specific restaurant(s) + franchise list
3. Send Slack notification with conversion details

---

### Edge Function 3: Cascade Menu Items

**Endpoint:** `POST /functions/v1/cascade-franchise-menu`

**SQL Functions:**
- `menuca_v3.cascade_dish_to_children()` - Cascade single dish+
- `menuca_v3.cascade_pricing_to_children()` - Cascade pricing only
- `menuca_v3.sync_menu_from_parent()` - Full menu sync

**Edge Function:** `supabase/functions/cascade-franchise-menu/index.ts`

**Deployment Status:** ✅ **Deployed to Supabase** (Version 1, Active)

**Purpose:** Synchronize menu items and pricing from parent to franchise locations.

**Features:**
- ✅ Authentication required (Bearer token)
- ✅ Authorization: `franchise.menu_cascade` permission
- ✅ Smart operation detection (single dish, pricing, or full sync)
- ✅ Input validation (parent_id, optional dish_id, child arrays)
- ✅ SQL function calls (atomic transactions)
- ✅ Admin action logging
- ✅ Cache invalidation (menu caches)
- ✅ Slack notification
- ✅ REST-compliant response

**Operation 1: Cascade Single Dish**

**Request:**
```json
POST /api/admin/franchises/cascade-menu
Authorization: Bearer <token>

{
  "parent_restaurant_id": 1005,
  "dish_id": 12345,
  "include_pricing": true,
  "child_restaurant_ids": [561, 562]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "parent_restaurant_id": 1005,
    "dish_id": 12345,
    "dish_name": "Margherita Pizza",
    "children_updated": 2,
    "include_pricing": true
  },
  "message": "Dish cascaded to 2 franchise locations"
}
```

**SQL Function:**
```sql
CREATE OR REPLACE FUNCTION menuca_v3.cascade_dish_to_children(
  p_parent_restaurant_id BIGINT,
  p_dish_id BIGINT,
  p_child_restaurant_ids BIGINT[] DEFAULT NULL,
  p_include_pricing BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
  dish_name VARCHAR,
  children_updated INTEGER
)
```

---

**Operation 2: Cascade Pricing Only**

**Request:**
```json
POST /api/admin/franchises/cascade-menu
Authorization: Bearer <token>

{
  "parent_restaurant_id": 1005,
  "include_pricing": true
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "parent_restaurant_id": 1005,
    "children_updated": 4,
    "dishes_updated": 87
  },
  "message": "Pricing cascaded to 4 franchise locations"
}
```

**SQL Function:**
```sql
CREATE OR REPLACE FUNCTION menuca_v3.cascade_pricing_to_children(
  p_parent_restaurant_id BIGINT,
  p_child_restaurant_ids BIGINT[] DEFAULT NULL
)
RETURNS TABLE (
  children_updated INTEGER,
  dishes_updated INTEGER
)
```

---

**Operation 3: Full Menu Sync**

**Request:**
```json
POST /api/admin/franchises/cascade-menu
Authorization: Bearer <token>

{
  "parent_restaurant_id": 1005
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "parent_restaurant_id": 1005,
    "children_updated": 4,
    "dishes_synced": 87
  },
  "message": "Menu synced to 4 franchise locations"
}
```

**SQL Function:**
```sql
CREATE OR REPLACE FUNCTION menuca_v3.sync_menu_from_parent(
  p_parent_restaurant_id BIGINT,
  p_child_restaurant_ids BIGINT[] DEFAULT NULL
)
RETURNS TABLE (
  children_updated INTEGER,
  dishes_synced INTEGER
)
```

**Validation:**
- Parent restaurant must exist and be franchise parent
- Dish ID must exist and belong to parent (for single dish cascade)
- Child restaurant IDs must be valid franchise children

**Post-Operation Actions (Async):**
1. Log to `admin_action_logs` with action `franchise.cascade_dish`, `franchise.cascade_pricing`, or `franchise.sync_menu`
2. Invalidate menu caches for parent and all affected children
3. Send Slack notification with operation details

---

### Franchise SQL Functions Summary

**Status:** ✅ **All 9 Complete**

| Function | Purpose | Edge Wrapper |
|----------|---------|--------------|
| `create_franchise_parent()` | Create parent brand | ✅ create-parent.ts |
| `convert_to_franchise()` | Link single child | ✅ convert-restaurant.ts |
| `batch_link_franchise_children()` | Link multiple children | ✅ convert-restaurant.ts |
| `bulk_update_franchise_feature()` | Toggle features | ❌ SQL Only |
| `cascade_dish_to_children()` | Copy single dish | ✅ cascade-menu.ts |
| `cascade_pricing_to_children()` | Sync pricing | ✅ cascade-menu.ts |
| `sync_menu_from_parent()` | Full menu sync | ✅ cascade-menu.ts |
| `get_franchise_analytics()` | Performance data | ❌ SQL Only |
| `compare_franchise_locations()` | Location comparison | ❌ SQL Only |
| `get_franchise_menu_coverage()` | Menu coverage % | ❌ SQL Only |
| `find_nearest_franchise_location()` | PostGIS routing | ❌ SQL Only |

**Note:** Read-only analytics and routing functions don't need Edge wrappers - they can be called directly or via a simple public API endpoint.

---

## 🍽️ Restaurant Categorization (Cuisines & Tags)

**Status:** ⏳ **In Progress** (SQL Complete, Edge Functions Partial)

### Edge Function 1: Create Restaurant with Cuisine

**Endpoint:** `POST /api/admin/restaurants/create-with-cuisine`

**SQL Function:** `menuca_v3.create_restaurant_with_cuisine()`

**Edge Function:** `netlify/functions/admin/restaurants/create-with-cuisine.ts`

**Status:** ✅ **Complete**

**Features:**
- ✅ Authentication required (Bearer token)
- ✅ Authorization: `restaurant.create` permission
- ✅ Input validation (name, status, timezone, cuisine)
- ✅ SQL function call (atomic transaction)
- ✅ Admin action logging
- ✅ Cache invalidation
- ✅ Slack notification
- ✅ REST-compliant response

**Request Example:**
```json
POST /api/admin/restaurants/create-with-cuisine
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "New Restaurant",
  "status": "pending",
  "timezone": "America/Toronto",
  "cuisine_slug": "italian",
  "created_by": 1
}
```

**Response Example (201 Created):**
```json
{
  "success": true,
  "data": {
    "restaurant_id": 1001,
    "name": "New Restaurant",
    "cuisine": "Italian",
    "status": "pending",
    "timezone": "America/Toronto"
  },
  "message": "Restaurant created successfully"
}
```

---

### Remaining Categorization Edge Functions

**Status:** ⏳ **Templates Ready, Not Implemented**

1. **Add Cuisine to Restaurant** - `POST /api/admin/restaurants/add-cuisine`
2. **Create Cuisine Type** - `POST /api/admin/cuisines/create`
3. **Create Restaurant Tag** - `POST /api/admin/tags/create`
4. **Add Tag to Restaurant** - `POST /api/admin/restaurants/add-tag`

---

## 📋 Implementation Pattern

All Edge Functions follow this standard pattern:

```typescript
export default async (req: Request): Promise<Response> => {
  // 1. Handle CORS preflight
  if (req.method === 'OPTIONS') return handleOptions();

  // 2. Check HTTP method
  if (req.method !== 'POST') return badRequest('Method not allowed');

  try {
    // 3. Authentication & Authorization
    const user = await requirePermission(req, 'permission.name');

    // 4. Parse request body
    const body = await req.json();

    // 5. Input validation
    const validation = validateRequired(body, ['field1', 'field2']);
    if (!validation.valid) return badRequest(validation.error);

    // 6. Initialize Supabase client
    const supabase = createAdminClient();

    // 7. Call SQL function (atomic operation)
    const { data, error } = await supabase.rpc('sql_function_name', {
      p_param1: body.param1,
      p_param2: body.param2,
    });

    if (error) throw error;
    if (!data[0]?.success) return badRequest(data[0]?.message);

    // 8. Post-processing (async, don't block response)
    Promise.all([
      logAdminAction(supabase, user.id, 'action.name', 'resource', data[0].id),
      invalidateCache(['cache-key']),
      sendNotification('slack', 'message', metadata),
    ]).catch(console.error);

    // 9. Return success response
    return created(data[0], 'Action completed successfully');

  } catch (error) {
    console.error('Error:', error);
    return internalError('Internal server error');
  }
};
```

---

## 📂 File Structure

```
netlify/functions/
├── shared/
│   ├── types.ts                    ✅ Complete (incl. franchise types)
│   ├── auth.ts                     ✅ Complete
│   ├── response.ts                 ✅ Complete
│   ├── validation.ts               ✅ Complete
│   └── supabase.ts                 ✅ Complete (admin_action_logs)
├── admin/
│   ├── franchises/                 ✅ NEW
│   │   ├── create-parent.ts        ✅ Complete
│   │   ├── convert-restaurant.ts   ✅ Complete
│   │   └── cascade-menu.ts         ✅ Complete
│   ├── restaurants/
│   │   ├── create-with-cuisine.ts  ✅ Complete
│   │   ├── add-cuisine.ts          ⏳ Template ready
│   │   └── add-tag.ts              ⏳ Template ready
│   ├── cuisines/
│   │   └── create.ts               ⏳ Template ready
│   ├── tags/
│   │   └── create.ts               ⏳ Template ready
│   └── domains/
│       └── verify-single.ts        ✅ Complete (existing)
├── cron/
│   └── verify-domains.ts           ✅ Complete (existing)
└── public/
    └── [future public endpoints]
```

---

## 🔧 Environment Variables Required

Add to `.env` or Netlify environment variables:

```bash
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Optional: External services
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/xxx
REDIS_URL=redis://localhost:6379
CDN_PURGE_API_KEY=xxx
CRON_SECRET=xxx

# Node environment
NODE_ENV=development
```

---

## 🔒 Security Model

### 1. **Authentication**
- ✅ All admin endpoints require Bearer token
- ✅ Tokens verified with Supabase `auth.getUser()`
- ✅ Expired tokens rejected (401)

### 2. **Authorization**
- ✅ Role-based permissions (`admin`, `super_admin`, `restaurant_owner`)
- ✅ Permission checks before SQL execution
- ✅ Resource ownership validation (where applicable)

### 3. **Input Validation**
- ✅ All inputs sanitized (`sanitizeString()`)
- ✅ Required fields checked (`validateRequired()`)
- ✅ Data types validated (integers, emails, slugs)
- ✅ SQL injection prevention (using RPC, not raw SQL)

### 4. **Audit Logging**
- ✅ All admin actions logged to `admin_action_logs`
- ✅ Includes: user_id, action, resource_type, resource_id, metadata, timestamp
- ✅ Separate from automatic `audit_log` (trigger-based)

### 5. **Rate Limiting** 
- ⏳ TODO: Implement per-user rate limiting
- ⏳ TODO: Implement per-IP rate limiting
- ⏳ TODO: Implement endpoint-specific limits

### 6. **CORS**
- ✅ CORS headers configured
- ✅ Preflight requests handled (`OPTIONS`)
- ⚠️ Currently allows all origins (`*` - tighten in production)

---

## 🚀 Deployment

### Netlify Configuration (`netlify.toml`)

```toml
[build]
  functions = "netlify/functions"

[functions]
  node_bundler = "esbuild"

[[redirects]]
  from = "/api/admin/*"
  to = "/.netlify/functions/admin/:splat"
  status = 200

[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/public/:splat"
  status = 200
```

### Deploy Commands

```bash
# Install dependencies
npm install @supabase/supabase-js

# Deploy to Netlify
netlify deploy --prod

# Or use Git integration (automatic deployment)
git push origin main
```

---

## ✅ Completion Status

### Franchise / Chain Hierarchy
- ✅ SQL Functions (9/9 complete)
- ✅ Edge Functions (3/3 complete)
- ✅ Shared utilities updated
- ✅ Database tables created
- ✅ Documentation complete

### Restaurant Categorization
- ✅ SQL Functions (complete)
- ⏳ Edge Functions (1/5 complete)
- ⏳ Remaining: 4 Edge Functions

---

## 📝 Next Steps

### Immediate
1. ✅ Franchise Edge Functions implemented
2. ⏳ Complete remaining categorization Edge Functions
3. ⏳ Add unit tests for Edge Functions
4. ⏳ Add integration tests

### Short-term
1. ⏳ Implement rate limiting
2. ⏳ Add error tracking (Sentry)
3. ⏳ Add performance monitoring
4. ⏳ Tighten CORS policy
5. ⏳ Add request logging

### Long-term
1. ⏳ Add GraphQL support
2. ⏳ Add webhook system
3. ⏳ Add real-time WebSocket updates
4. ⏳ Add API versioning
5. ⏳ Add OpenAPI/Swagger documentation

---

## 🚀 Deployment Summary

### Supabase Edge Functions (Deno Runtime)

**Deployment Date:** October 17, 2025  
**Platform:** Supabase (Project: nthpbtdjhhnwfxqsxbvy)  
**Runtime:** Deno + JSR imports

| Function | Slug | Status | Version | Endpoint |
|----------|------|--------|---------|----------|
| Create Franchise Parent | `create-franchise-parent` | ✅ Active | v1 | `/functions/v1/create-franchise-parent` |
| Convert to Franchise | `convert-restaurant-to-franchise` | ✅ Active | v1 | `/functions/v1/convert-restaurant-to-franchise` |
| Cascade Menu | `cascade-franchise-menu` | ✅ Active | v1 | `/functions/v1/cascade-franchise-menu` |

### File Structure

```
supabase/functions/
├── _shared/                         # Shared utilities (for reference)
│   ├── types.ts                     # TypeScript types
│   ├── cors.ts                      # CORS configuration
│   ├── response.ts                  # Response helpers
│   ├── validation.ts                # Input validation
│   ├── auth.ts                      # Authentication
│   └── supabase.ts                  # Supabase client utilities
│
├── create-franchise-parent/         # ✅ Deployed
│   └── index.ts                     # Self-contained function
│
├── convert-restaurant-to-franchise/ # ✅ Deployed
│   └── index.ts                     # Self-contained function
│
└── cascade-franchise-menu/          # ✅ Deployed
    └── index.ts                     # Self-contained function
```

**Note:** Supabase Edge Functions don't support shared imports outside the function directory, so each function is self-contained with inlined utilities.

### SQL Functions (Database)

All 9 SQL functions are already deployed in `menuca_v3` schema:
- `create_franchise_parent()`
- `convert_to_franchise()`
- `batch_link_franchise_children()`
- `cascade_dish_to_children()`
- `cascade_pricing_to_children()`
- `sync_menu_from_parent()`
- `get_franchise_analytics()`
- `compare_franchise_locations()`
- `get_franchise_menu_coverage()`

### Audit Logging

The `admin_action_logs` table is created in `menuca_v3` schema with proper indexes for tracking all admin actions.

---

**Maintained By:** Santiago
**Last Updated:** 2025-10-17  
**Status:** Franchise Backend Complete ✅ | All Functions Deployed to Supabase 🚀

