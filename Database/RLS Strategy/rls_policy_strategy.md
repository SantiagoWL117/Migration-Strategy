# RLS Policy Strategy for MenuCA V3

**Date:** October 10, 2025  
**Author:** Brian Lapp  
**Status:** Implementation Ready  
**Target:** All 50 tables in menuca_v3 schema

---

## Executive Summary

This document defines the Row Level Security (RLS) policy strategy for MenuCA V3. RLS will enforce tenant isolation at the database level, ensuring restaurants can only access their own data while maintaining performance through indexed predicates.

---

## Policy Architecture

### 1. Tenant Isolation Model

**Primary Strategy:** Restaurant-based multi-tenancy
- Every row with `restaurant_id` FK is tenant-scoped
- RLS policies filter on `restaurant_id = current_restaurant_id`
- All filtered columns MUST have indexes (already created)

**Authentication Context:**
```sql
-- Set per-request in application layer
SET LOCAL app.current_restaurant_id = '123';
SET LOCAL app.user_role = 'restaurant_owner';
SET LOCAL app.user_id = 'uuid-here';
```

**Alternative (Supabase Native):**
```sql
-- Use Supabase JWT token
auth.jwt() ->> 'restaurant_id'
auth.jwt() ->> 'role'
auth.uid()
```

**Recommendation:** Use Supabase JWT method for easier integration with Supabase Auth.

---

## Policy Categories

### Category 1: Tenant-Scoped Tables (Restaurant Data)

**Tables:** 40 tables with `restaurant_id` FK

**Policy Pattern:**
```sql
-- Allow restaurant to see only their data
CREATE POLICY tenant_isolation_[table_name] ON menuca_v3.[table_name]
  FOR SELECT
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

-- Allow restaurant to modify only their data
CREATE POLICY tenant_write_[table_name] ON menuca_v3.[table_name]
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
  WITH CHECK (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);
```

**Affected Tables:**
- Restaurant Management: restaurants, restaurant_locations, restaurant_domains, restaurant_contacts, restaurant_admin_users, restaurant_schedules, restaurant_special_schedules, restaurant_service_configs, restaurant_time_periods
- Menu & Catalog: dishes, courses, ingredients, ingredient_groups, ingredient_group_items, dish_modifiers, combo_groups, combo_items, combo_group_modifier_pricing
- Delivery: restaurant_delivery_config, restaurant_delivery_areas, restaurant_delivery_companies, restaurant_delivery_fees, restaurant_partner_schedules, restaurant_twilio_config
- Marketing: promotional_deals, promotional_coupons, restaurant_tag_associations
- Infrastructure: devices

### Category 2: User-Scoped Tables (Customer Data)

**Tables:** 5 tables with user ownership

**Policy Pattern:**
```sql
-- Users can only see their own data
CREATE POLICY user_isolation_[table_name] ON menuca_v3.[table_name]
  FOR SELECT
  USING (user_id = auth.uid());

-- Users can only modify their own data
CREATE POLICY user_write_[table_name] ON menuca_v3.[table_name]
  FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
```

**Affected Tables:**
- users (self-access to profile)
- user_addresses
- user_favorite_restaurants
- password_reset_tokens
- autologin_tokens

### Category 3: Admin-Only Tables

**Tables:** Platform admin management

**Policy Pattern:**
```sql
-- Only admins can access
CREATE POLICY admin_only_[table_name] ON menuca_v3.[table_name]
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin');
```

**Affected Tables:**
- admin_users
- admin_user_restaurants

### Category 4: Public Read Tables (Reference Data)

**Tables:** Geographic and shared reference data

**Policy Pattern:**
```sql
-- Anyone can read, no one can write via RLS
CREATE POLICY public_read_[table_name] ON menuca_v3.[table_name]
  FOR SELECT
  USING (true);
```

**Affected Tables:**
- provinces
- cities
- delivery_company_emails
- marketing_tags

### Category 5: Hybrid Access Tables

**Special Cases:**

**promotional_deals / promotional_coupons:**
```sql
-- Restaurants can manage their own deals
CREATE POLICY tenant_manage_deals ON menuca_v3.promotional_deals
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

-- Public can view active deals
CREATE POLICY public_view_active_deals ON menuca_v3.promotional_deals
  FOR SELECT
  USING (is_enabled = true AND date_start <= CURRENT_DATE AND date_stop >= CURRENT_DATE);
```

**dishes / courses (Menu Data):**
```sql
-- Restaurant can manage their menu
CREATE POLICY tenant_manage_menu ON menuca_v3.dishes
  FOR ALL
  USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint);

-- Public can view active menu items
CREATE POLICY public_view_menu ON menuca_v3.dishes
  FOR SELECT
  USING (is_active = true);
```

---

## Performance Requirements

### Critical Rules for Performance

1. **Simple Equality Predicates Only**
   ```sql
   -- GOOD (uses index)
   USING (restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint)
   
   -- BAD (no index, slow)
   USING (restaurant_id IN (SELECT id FROM user_restaurants WHERE user_id = auth.uid()))
   ```

2. **All Filtered Columns MUST Be Indexed**
   - ✅ All `restaurant_id` columns indexed (via add_critical_indexes.sql)
   - ✅ All `user_id` columns indexed
   - ✅ `is_active`, `is_enabled` indexed where used

3. **Avoid OR Conditions**
   ```sql
   -- BAD (requires multiple index scans)
   USING (restaurant_id = X OR user_role = 'admin')
   
   -- GOOD (separate policies)
   CREATE POLICY tenant_access ... USING (restaurant_id = X);
   CREATE POLICY admin_access ... USING (user_role = 'admin');
   ```

4. **No Function Calls in Predicates**
   ```sql
   -- BAD (not sargable)
   USING (LOWER(email) = LOWER(auth.jwt() ->> 'email'))
   
   -- GOOD (direct comparison)
   USING (email = auth.jwt() ->> 'email')
   ```

### Performance Targets

- **RLS Overhead:** <10% vs no RLS
- **Query Plans:** Must show Index Scan, not Seq Scan
- **P95 Latency:** <100ms for menu queries with RLS

---

## Implementation Plan

### Phase 1: Enable RLS on All Tables
```sql
-- Enable RLS (doesn't enforce until policies exist)
ALTER TABLE menuca_v3.restaurants ENABLE ROW LEVEL SECURITY;
-- Repeat for all 50 tables
```

### Phase 2: Create Bypass for Service Role
```sql
-- Allow service role (backend) to bypass RLS
ALTER TABLE menuca_v3.restaurants FORCE ROW LEVEL SECURITY;
-- Service role in backend can use: SET ROLE service_role;
```

### Phase 3: Deploy Policies by Category
1. Deploy tenant-scoped policies first (40 tables)
2. Deploy user-scoped policies (5 tables)
3. Deploy admin policies (2 tables)
4. Deploy public read policies (4 tables)
5. Deploy hybrid policies (special cases)

### Phase 4: Test Each Category
```sql
-- Test as restaurant user
SET LOCAL app.current_restaurant_id = '123';
SELECT COUNT(*) FROM menuca_v3.dishes; -- Should only return restaurant 123's dishes

-- Test as regular user
SET ROLE authenticated;
SELECT * FROM menuca_v3.users WHERE id = auth.uid(); -- Should work

-- Test as anonymous
SET ROLE anon;
SELECT * FROM menuca_v3.dishes WHERE is_active = true; -- Should work
SELECT * FROM menuca_v3.restaurant_admin_users; -- Should return 0 rows
```

---

## Testing Strategy

### Functional Tests

**Test 1: Tenant Isolation**
```sql
-- User from restaurant 123 should only see their data
SET LOCAL app.current_restaurant_id = '123';
SELECT COUNT(*) FROM menuca_v3.dishes WHERE restaurant_id != 123;
-- Expected: 0 rows
```

**Test 2: Admin Full Access**
```sql
SET LOCAL app.user_role = 'admin';
SELECT COUNT(*) FROM menuca_v3.dishes;
-- Expected: 10,585 rows (all dishes)
```

**Test 3: Public Read**
```sql
SET ROLE anon;
SELECT COUNT(*) FROM menuca_v3.provinces;
-- Expected: 13 rows
```

**Test 4: Cross-Tenant Block**
```sql
SET LOCAL app.current_restaurant_id = '123';
INSERT INTO menuca_v3.dishes (restaurant_id, name, ...) VALUES (456, 'Hack', ...);
-- Expected: ERROR: new row violates row-level security policy
```

### Performance Tests

**Test 1: Query Plan Validation**
```sql
EXPLAIN ANALYZE
SELECT * FROM menuca_v3.dishes 
WHERE restaurant_id = (auth.jwt() ->> 'restaurant_id')::bigint;
-- Must show: Index Scan using idx_dishes_restaurant
-- Must NOT show: Seq Scan
```

**Test 2: RLS Overhead Measurement**
```bash
# Without RLS
ALTER TABLE menuca_v3.dishes DISABLE ROW LEVEL SECURITY;
\timing
SELECT COUNT(*) FROM menuca_v3.dishes WHERE restaurant_id = 123;
# Record time: X ms

# With RLS
ALTER TABLE menuca_v3.dishes ENABLE ROW LEVEL SECURITY;
SET LOCAL app.current_restaurant_id = '123';
\timing
SELECT COUNT(*) FROM menuca_v3.dishes;
# Record time: Y ms
# Overhead = ((Y - X) / X) * 100%
# Target: < 10%
```

**Test 3: Concurrent Load Test**
```bash
# Use pgbench or custom script
pgbench -c 50 -j 4 -T 60 -f menu_query.sql
# Record P50, P95, P99 latencies
```

---

## Monitoring & Maintenance

### Key Metrics to Track

1. **RLS Policy Hit Rate**
   ```sql
   SELECT * FROM pg_stat_user_tables 
   WHERE schemaname = 'menuca_v3';
   ```

2. **Slow Query Detection**
   ```sql
   SELECT query, mean_exec_time, calls 
   FROM pg_stat_statements 
   WHERE query LIKE '%menuca_v3%'
   ORDER BY mean_exec_time DESC 
   LIMIT 20;
   ```

3. **Index Usage**
   ```sql
   SELECT tablename, indexname, idx_scan, idx_tup_read
   FROM pg_stat_user_indexes
   WHERE schemaname = 'menuca_v3' AND idx_scan = 0;
   -- Any idx_scan = 0 means unused index
   ```

### Common Issues & Solutions

**Issue 1: Slow Queries After RLS**
- Check EXPLAIN ANALYZE for Seq Scans
- Verify indexes exist on filtered columns
- Simplify policy predicates

**Issue 2: RLS Blocking Valid Access**
- Check session context is set correctly
- Verify JWT token contains required claims
- Test policy logic with direct SQL

**Issue 3: Performance Degradation Over Time**
- Run VACUUM ANALYZE on tables
- REINDEX if index bloat > 30%
- Update table statistics

---

## Security Considerations

### Bypass Prevention

**Never expose service role credentials to frontend:**
```typescript
// BAD - Never do this
const client = createClient(url, SERVICE_ROLE_KEY); // Full access!

// GOOD - Use anon key + JWT
const client = createClient(url, ANON_KEY); // RLS enforced
```

### JWT Token Requirements

**Required Claims for Full Functionality:**
```json
{
  "sub": "user-uuid",
  "role": "authenticated",
  "restaurant_id": 123,
  "user_role": "restaurant_owner",
  "email": "user@example.com"
}
```

### Audit Logging

**Track RLS Policy Violations:**
```sql
-- Create audit log table
CREATE TABLE menuca_v3.rls_violations (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID,
  table_name TEXT,
  attempted_action TEXT,
  violation_time TIMESTAMPTZ DEFAULT NOW()
);

-- Log violations (requires trigger or application logic)
```

---

## Rollback Plan

### Disable RLS Quickly
```sql
-- Disable on all tables if issues arise
DO $$
DECLARE
  tbl RECORD;
BEGIN
  FOR tbl IN 
    SELECT tablename 
    FROM pg_tables 
    WHERE schemaname = 'menuca_v3'
  LOOP
    EXECUTE 'ALTER TABLE menuca_v3.' || tbl.tablename || ' DISABLE ROW LEVEL SECURITY';
  END LOOP;
END $$;
```

### Re-enable After Fix
```sql
-- Re-enable after fixing policy
ALTER TABLE menuca_v3.dishes ENABLE ROW LEVEL SECURITY;
```

---

## Future Enhancements

### Phase 2 (Month 2)
- Implement audit logging for policy violations
- Add rate limiting per tenant
- Create policy templates for new tables

### Phase 3 (Month 3)
- Implement data residency policies (GDPR compliance)
- Add time-based access restrictions
- Create automated policy testing suite

---

## References

- PostgreSQL RLS Documentation: https://www.postgresql.org/docs/current/ddl-rowsecurity.html
- Supabase RLS Guide: https://supabase.com/docs/guides/auth/row-level-security
- Performance Best Practices: /Database/Performance/add_critical_indexes.sql

---

**Status:** Ready for Implementation  
**Approval Required:** Santiago  
**Estimated Implementation Time:** 4 hours  
**Risk Level:** Medium (can rollback if issues)

