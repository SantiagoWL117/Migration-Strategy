# Function Architecture Guide - SQL vs Edge Functions

**Project:** Menu.ca V3 Refactoring
**Date Created:** 2025-10-15
**Last Updated:** 2025-10-15
**Purpose:** Decision framework and implementation log for database functions vs Edge Functions

---

## Decision Framework

### When to Use SQL Functions (PostgreSQL/PL/pgSQL)

✅ **MUST use SQL for:**
1. **Database Triggers** - PostgreSQL requirement
2. **Complex Aggregations** - Pure data operations without business logic
3. **Data Validation** - Database-level constraints
4. **Performance-Critical Queries** - Runs close to data
5. **Reusable Helpers** - Called by other SQL functions/views

✅ **GOOD for SQL:**
- Simple CRUD operations
- Data lookups and joins
- Atomic transactions
- Type-safe operations (Supabase generates TypeScript types)
- Operations that don't require external APIs

### When to Use Edge Functions (Netlify Functions)

✅ **MUST use Edge Functions for:**
1. **Authentication/Authorization** - User permission checks
2. **External API Calls** - Third-party integrations
3. **Complex Business Logic** - Multi-step workflows
4. **Audit Logging** - Application-level tracking
5. **Notifications** - Email, Slack, webhooks
6. **Cache Management** - CDN/cache invalidation

✅ **GOOD for Edge Functions:**
- Admin-only operations
- File uploads/processing
- Payment processing
- Real-time features
- API rate limiting
- Complex error handling

### Hybrid Approach (SQL + Edge Wrapper)

🔄 **Best of both worlds:**
1. **SQL function** handles atomic database operations
2. **Edge function** wraps it with:
   - Authentication
   - Authorization
   - Input validation
   - Business rules
   - Audit logging
   - Notifications
   - Cache invalidation
   - REST-compliant responses

---

## Implementation Log

### Phase 1: Restaurant Categorization Functions

#### Function 1: `create_restaurant_with_cuisine()`

**Status:** 🔄 Hybrid Approach Implemented
**Priority:** Medium
**SQL Function:** ✅ Created (internal helper)
**Edge Function:** ✅ Created

**Decision Rationale:**
- **Why SQL?** Atomic transaction (restaurant + cuisine in single transaction)
- **Why Edge Wrapper?** Admin-only operation, needs auth, audit logging, geocoding

**SQL Function (Internal Helper):**
```sql
Location: menuca_v3.create_restaurant_with_cuisine()
Purpose: Atomic database operation for restaurant creation
Access: Internal only (called by Edge Function)
Returns: JSON with restaurant_id, success status
```

**Edge Function (Public API):**
```typescript
Location: netlify/functions/admin/restaurants/create-with-cuisine.ts
Method: POST
Auth: Required (Admin only)
Input Validation: ✅
Permission Check: ✅
Audit Log: ✅
Cache Invalidation: ✅
External APIs: Geocoding (optional)
Response: REST-compliant JSON
```

**Implementation Details:**
- Edge function validates input before calling SQL
- SQL function ensures atomic transaction
- Edge function logs admin action
- Edge function invalidates restaurant cache
- Can be extended with geocoding API calls

---

#### Function 2: `add_cuisine_to_restaurant()`

**Status:** 🔄 Hybrid Approach Implemented
**Priority:** Medium
**SQL Function:** ✅ Created (internal helper)
**Edge Function:** ✅ Created

**Decision Rationale:**
- **Why SQL?** Simple upsert, handles primary cuisine logic
- **Why Edge Wrapper?** Permission checks, real-time updates, cache invalidation

**SQL Function (Internal Helper):**
```sql
Location: menuca_v3.add_cuisine_to_restaurant()
Purpose: Add/update cuisine assignment with primary flag handling
Access: Internal only
Returns: Success status and cuisine name
```

**Edge Function (Public API):**
```typescript
Location: netlify/functions/admin/restaurants/add-cuisine.ts
Method: POST
Auth: Required (Admin or Restaurant Owner)
Input Validation: ✅
Permission Check: ✅ (Can modify this restaurant?)
Audit Log: ✅
Cache Invalidation: ✅
Real-time Update: WebSocket notification
Response: REST-compliant JSON
```

---

#### Function 3: `create_cuisine_type()`

**Status:** 🔄 Hybrid Approach Implemented
**Priority:** Low
**SQL Function:** ✅ Created (internal helper)
**Edge Function:** ✅ Created

**Decision Rationale:**
- **Why SQL?** Database-level validation (slug uniqueness)
- **Why Edge Wrapper?** Super admin only, needs approval workflow, cache invalidation

**SQL Function (Internal Helper):**
```sql
Location: menuca_v3.create_cuisine_type()
Purpose: Create new cuisine category with validation
Access: Internal only
Returns: Cuisine ID and status
```

**Edge Function (Public API):**
```typescript
Location: netlify/functions/admin/cuisines/create.ts
Method: POST
Auth: Required (Super Admin only)
Input Validation: ✅
Permission Check: ✅ (Super admin role)
Audit Log: ✅
Cache Invalidation: ✅ (Global cuisine cache)
Notification: Slack alert for new cuisine
Response: REST-compliant JSON
```

**Special Features:**
- Super admin role check
- Slug validation and auto-generation
- Global cache invalidation
- Team notification (new cuisine added)

---

#### Function 4: `create_restaurant_tag()`

**Status:** 🔄 Hybrid Approach Implemented
**Priority:** Low
**SQL Function:** ✅ Created (internal helper)
**Edge Function:** ✅ Created

**Decision Rationale:**
- **Why SQL?** Simple insert with constraints
- **Why Edge Wrapper?** Admin only, category validation, cache management

**SQL Function (Internal Helper):**
```sql
Location: menuca_v3.create_restaurant_tag()
Purpose: Create new restaurant tag with category validation
Access: Internal only
Returns: Tag ID and status
```

**Edge Function (Public API):**
```typescript
Location: netlify/functions/admin/tags/create.ts
Method: POST
Auth: Required (Admin only)
Input Validation: ✅
Permission Check: ✅
Audit Log: ✅
Cache Invalidation: ✅
Response: REST-compliant JSON
```

---

#### Function 5: `add_tag_to_restaurant()`

**Status:** 🔄 Hybrid Approach Implemented
**Priority:** Medium
**SQL Function:** ✅ Created (internal helper)
**Edge Function:** ✅ Created

**Decision Rationale:**
- **Why SQL?** Simple relationship insert
- **Why Edge Wrapper?** Permission checks, real-time updates

**SQL Function (Internal Helper):**
```sql
Location: menuca_v3.add_tag_to_restaurant()
Purpose: Assign tag to restaurant
Access: Internal only
Returns: Success status
```

**Edge Function (Public API):**
```typescript
Location: netlify/functions/admin/restaurants/add-tag.ts
Method: POST
Auth: Required (Admin or Restaurant Owner)
Input Validation: ✅
Permission Check: ✅
Audit Log: ✅
Cache Invalidation: ✅
Real-time Update: WebSocket notification
Response: REST-compliant JSON
```

---

### Pure SQL Functions (No Edge Wrapper Needed)

#### Function: `audit_restaurant_status_change()`

**Status:** ✅ SQL Trigger Only
**Type:** Database Trigger
**Priority:** CRITICAL

**Decision Rationale:**
- ✅ **MUST be SQL** - PostgreSQL triggers require PL/pgSQL
- ✅ Cannot be bypassed
- ✅ Guaranteed atomic execution
- ❌ Cannot be Edge Function

**Implementation:**
```sql
Location: menuca_v3.audit_restaurant_status_change()
Type: TRIGGER FUNCTION
Fires: AFTER UPDATE ON restaurants
Purpose: Audit trail for status changes
Access: Automatic (cannot be called directly)
```

---

#### Function: `get_restaurant_status_stats()`

**Status:** ✅ SQL Function Only
**Type:** Query Function
**Priority:** High

**Decision Rationale:**
- ✅ Pure data aggregation
- ✅ No business logic
- ✅ Performance-critical
- ✅ Reusable across services
- 🔄 Could have Edge wrapper for caching, but not necessary

**Implementation:**
```sql
Location: menuca_v3.get_restaurant_status_stats()
Type: QUERY FUNCTION
Purpose: Aggregate status statistics
Access: Public (via RLS)
Returns: Status metrics
```

**Notes:**
- Can be called directly from client (respects RLS)
- Edge wrapper optional for caching
- Currently no auth requirements (public stats)

---

#### Function: `get_restaurant_primary_contact()`

**Status:** ✅ SQL Function Only
**Type:** Query Function
**Priority:** High

**Decision Rationale:**
- ✅ Simple lookup
- ✅ Reusable in views/joins
- ✅ Fast database-level execution
- ✅ Type-safe (Supabase generates types)
- 🔄 Edge wrapper not needed (simple query)

**Implementation:**
```sql
Location: menuca_v3.get_restaurant_primary_contact()
Type: QUERY FUNCTION
Purpose: Get primary contact for restaurant
Access: Public (via RLS)
Returns: Contact record
```

---

## Edge Function Implementation Structure

### Standard Edge Function Template

```typescript
// netlify/functions/admin/[resource]/[action].ts

import { createClient } from '@supabase/supabase-js';
import { verify } from 'jsonwebtoken';

interface RequestBody {
  // Define expected input
}

interface SupabaseUser {
  id: string;
  role: string;
  email: string;
}

export default async (req: Request): Promise<Response> => {
  // 1. CORS headers
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    });
  }

  try {
    // 2. Authentication
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return jsonResponse({ error: 'Unauthorized' }, 401);
    }

    const token = authHeader.substring(7);
    const user = await verifyToken(token);

    // 3. Input validation
    const body: RequestBody = await req.json();
    const validation = validateInput(body);
    if (!validation.valid) {
      return jsonResponse({ error: validation.error }, 400);
    }

    // 4. Permission check
    if (!hasPermission(user, 'resource.action')) {
      return jsonResponse({ error: 'Forbidden' }, 403);
    }

    // 5. Initialize Supabase client
    const supabase = createClient(
      process.env.SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_KEY!
    );

    // 6. Call SQL function (atomic operation)
    const { data, error } = await supabase.rpc('sql_function_name', {
      p_param1: body.param1,
      p_param2: body.param2,
    });

    if (error) throw error;

    // 7. Post-processing
    await Promise.all([
      logAdminAction(user.id, 'resource.action', data),
      invalidateCache('resource-key'),
      sendNotification(user, 'action-completed', data),
    ]);

    // 8. Response
    return jsonResponse({
      success: true,
      data,
      message: 'Action completed successfully',
    }, 201);

  } catch (error) {
    console.error('Error:', error);
    return jsonResponse({
      error: 'Internal server error',
      message: error.message,
    }, 500);
  }
};

// Helper functions
function jsonResponse(data: any, status: number = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  });
}

async function verifyToken(token: string): Promise<SupabaseUser> {
  // Verify JWT and return user
  // Implementation depends on auth provider
}

function validateInput(body: any): { valid: boolean; error?: string } {
  // Validate input structure
  // Return validation result
}

function hasPermission(user: SupabaseUser, permission: string): boolean {
  // Check user permissions
  // Implementation depends on RBAC system
}

async function logAdminAction(userId: string, action: string, metadata: any): Promise<void> {
  // Log to audit table
}

async function invalidateCache(key: string): Promise<void> {
  // Invalidate CDN/cache
}

async function sendNotification(user: SupabaseUser, type: string, data: any): Promise<void> {
  // Send notification (Slack, email, etc.)
}
```

---

## Future Function Analysis Checklist

For each new function, evaluate:

### ✅ Checklist: SQL Function Only

- [ ] Is it a database trigger? → **SQL ONLY**
- [ ] Is it pure data aggregation with no business logic? → **SQL ONLY**
- [ ] Is it called by other SQL functions/views? → **SQL ONLY**
- [ ] Does it need to run in the same transaction as other operations? → **SQL ONLY**
- [ ] Is it performance-critical (< 50ms requirement)? → **SQL ONLY**
- [ ] Does it have no authentication requirements? → **SQL ONLY**

### 🔄 Checklist: Hybrid Approach

- [ ] Does it modify data? → **Consider Hybrid**
- [ ] Is it an admin-only operation? → **Hybrid**
- [ ] Does it need audit logging? → **Hybrid**
- [ ] Does it need permission checks beyond RLS? → **Hybrid**
- [ ] Does it need cache invalidation? → **Hybrid**
- [ ] Should it send notifications? → **Hybrid**
- [ ] Does it need to call external APIs? → **Hybrid**
- [ ] Is REST-compliant response needed? → **Hybrid**

### ⚡ Checklist: Edge Function Only

- [ ] Does it primarily call external APIs? → **Edge Only**
- [ ] Is it a file upload/processing operation? → **Edge Only**
- [ ] Does it need complex business logic orchestration? → **Edge Only**
- [ ] Is it a webhook endpoint? → **Edge Only**
- [ ] Does it need rate limiting? → **Edge Only**

---

## Implementation Progress

### ✅ Completed

| Function | Type | SQL | Edge | Status |
|----------|------|-----|------|--------|
| `audit_restaurant_status_change()` | Trigger | ✅ | ❌ | Complete |
| `get_restaurant_status_stats()` | Query | ✅ | ❌ | Complete |
| `get_restaurant_primary_contact()` | Query | ✅ | ❌ | Complete |
| `create_restaurant_with_cuisine()` | Mutation | ✅ | ✅ | Complete |
| `add_cuisine_to_restaurant()` | Mutation | ✅ | ✅ | Complete |
| `create_cuisine_type()` | Mutation | ✅ | ✅ | Complete |
| `create_restaurant_tag()` | Mutation | ✅ | ✅ | Complete |
| `add_tag_to_restaurant()` | Mutation | ✅ | ✅ | Complete |

### ✅ Completed - Task 3.2 (PostGIS Functions)

| Function | Type | Decision | Status |
|----------|------|----------|--------|
| `is_address_in_delivery_zone()` | Query | SQL Only | ✅ Implemented |
| `find_nearby_restaurants()` | Query | SQL Only | ✅ Implemented |
| `get_delivery_zone_area_sq_km()` | Query | SQL Only | ✅ Implemented |
| `get_restaurant_delivery_summary()` | Query | SQL Only | ✅ Implemented |

**Decision Rationale:**
- **Why SQL Only?** Geospatial queries are performance-critical (< 100ms target)
- PostGIS operations run efficiently at database level
- No business logic beyond data retrieval
- Can be called directly from client (respects RLS)
- No authentication requirements (public queries)
- Results cacheable at application level

---

### ✅ Completed - Task 3.3 (Restaurant Feature Flags)

| Function | Type | Decision | Status |
|----------|------|----------|--------|
| `has_feature()` | Query | SQL Only | ✅ Implemented |
| `get_feature_config()` | Query | SQL Only | ✅ Implemented |
| `get_enabled_features()` | Query | SQL Only | ✅ Implemented |
| `manage_feature_timestamps()` | Trigger | SQL Only | ✅ Implemented |
| `update_restaurant_features_timestamp()` | Trigger | SQL Only | ✅ Implemented |

**Decision Rationale:**
- **Why SQL Only?** 
  - Feature checks are ultra-fast, performance-critical lookups
  - Called frequently in order flow (need <10ms response)
  - No external dependencies or business logic
  - Timestamps managed automatically by triggers
  - Results highly cacheable at application level
  
**Future Edge Function Needs:**
- `toggle_feature()` - ADMIN operation, needs auth + audit
- `bulk_update_features()` - ADMIN operation, needs validation
- `feature_analytics()` - Could benefit from caching layer

---

### ✅ Completed - Task 4.1 (SEO Metadata & Full-Text Search)

| Function | Type | Decision | Status |
|----------|------|----------|--------|
| `search_restaurants()` | Query | SQL Only | ✅ Implemented |
| `get_restaurant_by_slug()` | Query | SQL Only | ✅ Implemented |
| `generate_restaurant_slug()` | Trigger | SQL Only | ✅ Implemented |

**Decision Rationale:**
- **Why SQL Only?**
  - Full-text search with tsvector/GIN index is ultra-fast (<50ms)
  - PostgreSQL's `ts_rank` provides excellent relevance scoring
  - No external dependencies or business logic
  - Slug lookups are simple key-value queries
  - Results cacheable at CDN/application level
  - Trigger-based slug generation is atomic

**Performance Achieved:**
- Full-text search: 49ms (target: <500ms) ✅
- Slug lookup: ~5ms ✅
- GIN index on search_vector: Automatic maintenance
- 100% restaurant coverage: All 959 restaurants have slugs/meta

**Future Edge Function Needs:**
- `update_restaurant_seo()` - ADMIN operation, needs auth + validation
- `mark_restaurant_featured()` - ADMIN operation, needs auth + audit
- `bulk_generate_meta()` - ADMIN operation with AI integration

---

### ✅ Completed - Task 4.2 (Onboarding Status Tracking)

| Function | Type | Decision | Status |
|----------|------|----------|--------|
| `get_onboarding_status()` | Query | SQL Only | ✅ Implemented |
| `get_onboarding_summary()` | Query | SQL Only | ✅ Implemented |
| `update_onboarding_timestamp()` | Trigger | SQL Only | ✅ Implemented |
| `check_onboarding_completion()` | Trigger | SQL Only | ✅ Implemented |

**Decision Rationale:**
- **Why SQL Only?**
  - Onboarding queries are simple data retrieval (<10ms)
  - Auto-calculated completion_percentage using GENERATED column
  - Triggers handle timestamp management automatically
  - No external dependencies or business logic
  - Results cacheable at application level

**Performance Achieved:**
- Status query: ~5ms ✅
- Summary query: ~5ms ✅
- Auto-completion trigger: Instant
- 959 restaurants initialized automatically

**Future Edge Function Needs:**
- `update_onboarding_step()` - ADMIN operation, needs auth + notifications
- `skip_onboarding_step()` - ADMIN operation, needs auth + reason
- `reset_onboarding()` - ADMIN operation, needs auth + confirmation

### ✅ Completed - Task 5.1 (SSL & DNS Domain Verification)

| Function | Type | Decision | Status |
|----------|------|----------|--------|
| `mark_domain_verified()` | Mutation | SQL Only | ✅ Implemented |
| `get_domain_verification_status()` | Query | SQL Only | ✅ Implemented |
| `verify_domains` (cron) | Automation | Edge Only | ✅ Implemented |
| `verify_single_domain` | Admin Action | Edge Only | ✅ Implemented |

**Decision Rationale:**
- **Why SQL for helpers?**
  - `mark_domain_verified()` - Atomic database update with validation
  - `get_domain_verification_status()` - Simple query with calculations
  - Both called by Edge Functions, not directly by clients

- **Why Edge Only for verification?**
  - **MUST be Edge Function** - Requires external API calls (SSL/DNS checks)
  - Node.js `https` and `dns` modules required
  - 10-second timeout per domain (too long for SQL function)
  - Slack/email alerts for expiring certificates
  - Rate limiting (500ms between requests)
  - Cron scheduling capability

**Implementation:**
```
netlify/functions/
├── cron/
│   └── verify-domains.ts       (Automated daily verification)
└── admin/
    └── domains/
        └── verify-single.ts    (On-demand verification)
```

**Features Implemented:**
- ✅ SSL certificate verification (expiration, issuer)
- ✅ DNS record validation (A, CNAME)
- ✅ Batch processing (100 domains/day)
- ✅ Rate limiting (500ms delay)
- ✅ Expiration alerts (Slack webhook)
- ✅ Error logging and graceful degradation
- ✅ Admin on-demand verification

**Performance:**
- Cron job: ~50 seconds for 100 domains
- Single verification: 2-5 seconds
- Full cycle: 711 domains in 8 days

**Monitoring Views:**
- `v_domains_needing_attention` - Priority-sorted issues
- `v_domain_verification_summary` - Overall statistics

---

### ⏳ Pending (From Plan)

| Function | Recommendation | Priority |
|----------|---------------|----------|
| `can_accept_orders()` | SQL Only | High |
| `validate_timezone()` | SQL Only | High |
| `validate_schedule_no_overlap()` | SQL Only | Critical |
| `enable_feature()` | Hybrid | Medium |
| `disable_feature()` | Hybrid | Medium |
| `complete_onboarding_step()` | Hybrid | Medium |

---

## Documentation Updates

### For Each New Function:

1. **Add to this log** with decision rationale
2. **Update API documentation** if Edge Function created
3. **Generate TypeScript types** from SQL functions
4. **Create test cases** for both SQL and Edge layers
5. **Update ERD** if new tables involved

### Edge Function Deployment

**Location:** `netlify/functions/admin/`

**Structure:**
```
netlify/functions/
├── admin/
│   ├── restaurants/
│   │   ├── create-with-cuisine.ts
│   │   ├── add-cuisine.ts
│   │   └── add-tag.ts
│   ├── cuisines/
│   │   └── create.ts
│   └── tags/
│       └── create.ts
├── public/
│   └── [future public endpoints]
└── shared/
    ├── auth.ts
    ├── validation.ts
    └── supabase.ts
```

---

## Benefits of Hybrid Approach

### For Development
✅ **Separation of Concerns** - Database logic vs application logic
✅ **Type Safety** - Supabase generates types from SQL functions
✅ **Testability** - Can test SQL and Edge layers independently
✅ **Maintainability** - Business logic changes don't require migrations

### For Production
✅ **Security** - Authentication/authorization in Edge layer
✅ **Auditability** - Complete audit trail of admin actions
✅ **Performance** - Database operations are atomic and fast
✅ **Scalability** - Edge functions scale independently
✅ **Flexibility** - Can add features (notifications, caching) without touching DB

### For Future
✅ **API Evolution** - Can version Edge Functions without DB changes
✅ **Integration** - Easy to add third-party APIs
✅ **Monitoring** - Better observability at Edge layer
✅ **Rate Limiting** - Protect database from abuse

---

## Next Steps

1. ✅ Create Edge Function implementations for 5 hybrid functions
2. ⏳ Update `restaurant-entity-refactor.plan.md` with hybrid approach notes
3. ⏳ Document API endpoints in OpenAPI/Swagger format
4. ⏳ Create shared utilities for Edge Functions (auth, validation)
5. ⏳ Set up automated testing for Edge Functions
6. ⏳ Configure deployment pipeline for Netlify Functions

---

**Last Updated:** 2025-10-15
**Next Review:** After Task 3.2 (PostGIS Delivery Zones)
**Maintained By:** Santiago

