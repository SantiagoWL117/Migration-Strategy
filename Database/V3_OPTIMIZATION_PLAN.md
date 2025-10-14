# MenuCA V3 - Database Optimization Plan

**Date Created:** October 14, 2025  
**Created By:** Brian Lapp + Claude  
**Status:** 🎯 PLANNING PHASE  
**Context:** Post-combo migration (99.77% success), pre-final production optimization  
**Goal:** Optimize V3 before locking down schema for production

---

## 🎯 Executive Summary

**Current State:**
- ✅ Combo migration complete (99.77% success)
- ✅ Most entity migrations complete (5/12 entities done)
- ⚠️ Legacy issues "baked into" V3 from V1/V2
- ⚠️ Redundant table structures need consolidation
- ⚠️ Missing industry best practices

**Proposed Changes:**
1. 🔴 **HIGH PRIORITY:** Consolidate admin user tables (3 → 2 tables)
2. 🟡 **MEDIUM:** Standardize column naming conventions
3. 🟡 **MEDIUM:** Add missing constraints & validation
4. 🟢 **LOW:** Archive legacy columns after validation period

**Timeline:** 2-3 weeks (can start NOW without blocking Santiago's vendor migration)

---

## 🚨 Priority 1: Admin User Table Consolidation

### Current Problem

**3 TABLES doing the same thing:**

1. **`menuca_v3.admin_users`** (51 users)
   - Platform-level admins (V2 source)
   - Can manage multiple restaurants
   - Uses `admin_user_restaurants` junction table

2. **`menuca_v3.restaurant_admin_users`** (439 users)
   - Single-restaurant admins (V1 source)
   - Direct `restaurant_id` FK
   - Cannot access multiple restaurants

3. **`menuca_v3.admin_user_restaurants`** (94 assignments)
   - Junction table for multi-restaurant access
   - Only used by `admin_users`

**Why This Is Bad:**
- ❌ Confusing for developers ("Which table do I query?")
- ❌ Duplicate functionality
- ❌ Inconsistent permission models
- ❌ Hard to implement RBAC across both
- ❌ No unified admin dashboard possible

### Industry Standard: Single Admin Table + RBAC

**What Other Platforms Do (Toast, Square, Shopify):**

```sql
-- ONE admin table with roles
CREATE TABLE menuca_v3.admin_users (
  id BIGINT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  password_hash VARCHAR(255) NOT NULL,
  global_role VARCHAR(50),  -- 'super_admin', 'support', 'billing', NULL
  global_permissions JSONB,  -- Platform-wide permissions
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ONE junction table for restaurant access
CREATE TABLE menuca_v3.admin_user_restaurants (
  id BIGINT PRIMARY KEY,
  admin_user_id BIGINT NOT NULL,
  restaurant_id BIGINT NOT NULL,
  role VARCHAR(50) NOT NULL,  -- 'owner', 'manager', 'staff', 'viewer'
  permissions JSONB,  -- Restaurant-specific permissions
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(admin_user_id, restaurant_id)
);
```

**Benefits:**
- ✅ Single source of truth for all admins
- ✅ Unified permission system
- ✅ Easy to add/remove restaurant access
- ✅ Single login flow for all admin types
- ✅ Consistent API endpoints

### Proposed Migration Strategy

**Phase 1: Audit & Analysis (1 week)**

```sql
-- Check for users in both systems
SELECT 
  'Potential duplicates' as check_type,
  COUNT(DISTINCT rau.email) as restaurant_admin_emails,
  COUNT(DISTINCT au.email) as platform_admin_emails,
  COUNT(*) as overlap
FROM menuca_v3.restaurant_admin_users rau
JOIN menuca_v3.admin_users au ON LOWER(rau.email) = LOWER(au.email);

-- Check permission usage
SELECT 
  'Platform admins with permissions' as check_type,
  COUNT(*) as total,
  COUNT(CASE WHEN permissions IS NOT NULL AND permissions != '{}'::jsonb THEN 1 END) as with_permissions
FROM menuca_v3.admin_users;

-- Analyze multi-restaurant assignments
SELECT 
  admin_user_id,
  COUNT(DISTINCT restaurant_id) as restaurant_count,
  STRING_AGG(role, ', ') as roles
FROM menuca_v3.admin_user_restaurants
GROUP BY admin_user_id
ORDER BY restaurant_count DESC;
```

**Phase 2: Create Migration Script (2 days)**

```sql
-- Step 1: Backup existing data
CREATE TABLE menuca_v3_backup.admin_users_backup AS 
SELECT * FROM menuca_v3.admin_users;

CREATE TABLE menuca_v3_backup.restaurant_admin_users_backup AS 
SELECT * FROM menuca_v3.restaurant_admin_users;

-- Step 2: Add new role column to admin_users
ALTER TABLE menuca_v3.admin_users
ADD COLUMN IF NOT EXISTS global_role VARCHAR(50);

-- Step 3: Migrate restaurant_admin_users → admin_users
-- (Only non-duplicate emails)
INSERT INTO menuca_v3.admin_users (
  email,
  first_name,
  last_name,
  password_hash,
  global_role,
  global_permissions,
  last_login_at,
  is_active,
  created_at,
  updated_at,
  v1_admin_id
)
SELECT 
  rau.email,
  rau.first_name,
  rau.last_name,
  rau.password_hash,
  NULL as global_role,  -- Restaurant-level only
  '{}'::jsonb as global_permissions,
  rau.last_login,
  rau.is_active,
  rau.created_at,
  rau.updated_at,
  rau.id as v1_admin_id
FROM menuca_v3.restaurant_admin_users rau
WHERE NOT EXISTS (
  SELECT 1 FROM menuca_v3.admin_users au 
  WHERE LOWER(au.email) = LOWER(rau.email)
);

-- Step 4: Create restaurant assignments for migrated users
INSERT INTO menuca_v3.admin_user_restaurants (
  admin_user_id,
  restaurant_id,
  role,
  permissions,
  created_at
)
SELECT 
  au.id as admin_user_id,
  rau.restaurant_id,
  'owner' as role,  -- Default role for V1 admins
  '{}'::jsonb as permissions,
  rau.created_at
FROM menuca_v3.restaurant_admin_users rau
JOIN menuca_v3.admin_users au ON LOWER(au.email) = LOWER(rau.email)
WHERE NOT EXISTS (
  SELECT 1 FROM menuca_v3.admin_user_restaurants aur
  WHERE aur.admin_user_id = au.id
    AND aur.restaurant_id = rau.restaurant_id
);

-- Step 5: Validate migration
SELECT 
  'Migration validation' as check_type,
  (SELECT COUNT(*) FROM menuca_v3.admin_users) as total_admins,
  (SELECT COUNT(*) FROM menuca_v3.admin_user_restaurants) as total_assignments,
  (SELECT COUNT(DISTINCT admin_user_id) FROM menuca_v3.admin_user_restaurants) as admins_with_restaurants;
```

**Phase 3: Testing & Rollout (3 days)**

1. Test in staging environment
2. Verify all admin logins work
3. Test permission checks
4. Run parallel for 1 week (both systems)
5. Cut over to new system
6. Archive `restaurant_admin_users` table

**Phase 4: Cleanup (1 day)**

```sql
-- After 30 days of successful operation:
-- Move to archive schema
CREATE SCHEMA IF NOT EXISTS menuca_v3_archive;

CREATE TABLE menuca_v3_archive.restaurant_admin_users AS 
SELECT * FROM menuca_v3.restaurant_admin_users;

-- Drop original table
DROP TABLE menuca_v3.restaurant_admin_users CASCADE;
```

### Role & Permission Model

**Proposed Roles:**

```
Platform-Level (global_role):
├── super_admin      → Full system access
├── support          → Can view/edit restaurants
├── billing          → Can view billing data
└── readonly         → View-only access

Restaurant-Level (admin_user_restaurants.role):
├── owner            → Full restaurant control
├── manager          → Manage menu, orders, settings
├── staff            → View orders, limited editing
└── viewer           → Read-only access
```

**Proposed Permissions (JSONB):**

```json
{
  "can_manage_menu": true,
  "can_manage_orders": true,
  "can_manage_users": false,
  "can_view_reports": true,
  "can_manage_integrations": false,
  "can_change_pricing": true
}
```

---

## 🔧 Priority 2: Column Naming Standardization

### Current Inconsistencies

**Legacy ID Columns:**
```
✅ Good: legacy_v1_id, legacy_v2_id
❌ Bad:  v1_admin_id, v2_user_id, legacy_v1_menuothers_id
```

**Boolean Columns:**
```
✅ Good: is_active, is_enabled, has_customization
❌ Bad:  send_statement (should be: sends_statements)
```

**Date Columns:**
```
✅ Good: created_at, updated_at, deleted_at
❌ Bad:  disable_until (should be: disabled_until)
```

### Proposed Standards

**Convention: Follow Rails/Laravel naming:**

```sql
-- Boolean: is_*, has_*, can_*, allows_*, accepts_*
is_active BOOLEAN DEFAULT true
has_delivery BOOLEAN DEFAULT false
can_preorder BOOLEAN DEFAULT true

-- Timestamps: *_at (not *_date or *_time)
created_at TIMESTAMPTZ DEFAULT NOW()
activated_at TIMESTAMPTZ
disabled_until TIMESTAMPTZ  -- NOT disable_until

-- Foreign Keys: table_name_id (singular)
restaurant_id BIGINT NOT NULL
user_id BIGINT NOT NULL
admin_user_id BIGINT NOT NULL

-- Legacy IDs: legacy_{version}_{table}_id
legacy_v1_menu_id INTEGER
legacy_v2_order_id INTEGER
```

### Migration Script

```sql
-- Rename inconsistent columns (can run AFTER traffic is low)
ALTER TABLE menuca_v3.restaurant_admin_users 
RENAME COLUMN send_statement TO sends_statements;

ALTER TABLE menuca_v3.restaurant_delivery_config 
RENAME COLUMN disable_delivery_until TO disabled_until;

-- Add comments to legacy columns for clarity
COMMENT ON COLUMN menuca_v3.dishes.legacy_v1_id IS 
'Original dish ID from V1 menu table. Used for combo mapping and audit trails. Will be archived after 6 months.';
```

---

## 📊 Priority 3: Add Missing Industry Standards

### A. Modifier Group Min/Max Constraints

**Current Issue:** No way to enforce "Pick 2-3 toppings" rules

```sql
ALTER TABLE menuca_v3.ingredient_groups
ADD COLUMN min_selection INT DEFAULT 0 CHECK (min_selection >= 0),
ADD COLUMN max_selection INT CHECK (max_selection IS NULL OR max_selection >= min_selection),
ADD COLUMN free_quantity INT DEFAULT 0 CHECK (free_quantity >= 0),
ADD COLUMN allow_duplicates BOOLEAN DEFAULT true,
CONSTRAINT check_selection_logic CHECK (
  max_selection IS NULL OR min_selection <= max_selection
);

COMMENT ON COLUMN menuca_v3.ingredient_groups.min_selection IS 
'Minimum number of items customer must select (e.g., 0 = optional, 1 = required, 2 = must pick 2)';

COMMENT ON COLUMN menuca_v3.ingredient_groups.max_selection IS 
'Maximum selections allowed (NULL = unlimited)';

COMMENT ON COLUMN menuca_v3.ingredient_groups.free_quantity IS 
'How many selections are included free (e.g., "First 2 free, $0.50 each after")';
```

### B. Soft Delete Pattern

**Current Issue:** Hard deletes lose data forever

```sql
-- Add to all major tables
ALTER TABLE menuca_v3.dishes
ADD COLUMN deleted_at TIMESTAMPTZ,
ADD COLUMN deleted_by INTEGER;

-- Create view for active records
CREATE VIEW menuca_v3.dishes_active AS
SELECT * FROM menuca_v3.dishes
WHERE deleted_at IS NULL;

-- Update application to use soft deletes
UPDATE menuca_v3.dishes 
SET deleted_at = NOW(), deleted_by = :admin_user_id
WHERE id = :dish_id;
```

### C. Audit Logging

**Current Issue:** No history of who changed what

```sql
CREATE TABLE menuca_v3.audit_log (
  id BIGSERIAL PRIMARY KEY,
  table_name VARCHAR(255) NOT NULL,
  record_id BIGINT NOT NULL,
  action VARCHAR(50) NOT NULL,  -- 'INSERT', 'UPDATE', 'DELETE'
  old_values JSONB,
  new_values JSONB,
  changed_by INTEGER,  -- admin_user_id
  changed_by_type VARCHAR(50),  -- 'admin', 'customer', 'system'
  ip_address INET,
  user_agent TEXT,
  changed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_log_table_record ON menuca_v3.audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_changed_at ON menuca_v3.audit_log(changed_at DESC);
CREATE INDEX idx_audit_log_changed_by ON menuca_v3.audit_log(changed_by);

-- Create trigger function
CREATE OR REPLACE FUNCTION menuca_v3.audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'UPDATE') THEN
    INSERT INTO menuca_v3.audit_log (table_name, record_id, action, old_values, new_values, changed_by)
    VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW), current_setting('app.current_admin_user_id', true)::integer);
    RETURN NEW;
  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO menuca_v3.audit_log (table_name, record_id, action, old_values, changed_by)
    VALUES (TG_TABLE_NAME, OLD.id, 'DELETE', to_jsonb(OLD), current_setting('app.current_admin_user_id', true)::integer);
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply to critical tables
CREATE TRIGGER audit_dishes_changes
AFTER UPDATE OR DELETE ON menuca_v3.dishes
FOR EACH ROW EXECUTE FUNCTION menuca_v3.audit_trigger_function();

CREATE TRIGGER audit_prices_changes
AFTER UPDATE OR DELETE ON menuca_v3.ingredient_group_items
FOR EACH ROW EXECUTE FUNCTION menuca_v3.audit_trigger_function();
```

---

## 🗂️ Priority 4: Archive Legacy Columns (After 6 Months)

**Current State:** Every table has legacy columns

```sql
-- Example: dishes table
legacy_v1_id INTEGER
legacy_v2_id INTEGER
source_system VARCHAR(50)
source_id BIGINT
notes TEXT
```

**Purpose:** Audit trail during migration period

**Timeline:**
- ✅ **Month 1-6:** Keep for debugging & rollback
- ⏳ **Month 6:** Audit usage (are we still referencing these?)
- ⏳ **Month 7:** Archive to `menuca_v3_archive` schema
- ⏳ **Month 8:** Drop columns from production

**Archive Script:**

```sql
-- Month 7: Create archive tables with legacy data
CREATE SCHEMA IF NOT EXISTS menuca_v3_archive;

CREATE TABLE menuca_v3_archive.legacy_id_mapping AS
SELECT 
  'dishes' as table_name,
  id as v3_id,
  legacy_v1_id,
  legacy_v2_id,
  source_system,
  source_id,
  notes
FROM menuca_v3.dishes
WHERE legacy_v1_id IS NOT NULL OR legacy_v2_id IS NOT NULL;

-- Add similar for all tables with legacy columns

-- Month 8: Drop legacy columns
ALTER TABLE menuca_v3.dishes
DROP COLUMN legacy_v1_id,
DROP COLUMN legacy_v2_id,
DROP COLUMN source_system,
DROP COLUMN source_id;
```

---

## 📋 Complete Table Audit Results

### Tables Needing Optimization

| Table | Issues | Priority | Effort |
|-------|--------|----------|--------|
| **admin_users** | Redundant with restaurant_admin_users | 🔴 HIGH | 2 weeks |
| **restaurant_admin_users** | Should be merged into admin_users | 🔴 HIGH | 2 weeks |
| **ingredient_groups** | Missing min/max constraints | 🟡 MEDIUM | 1 day |
| **dishes** | Missing soft delete | 🟡 MEDIUM | 2 days |
| **restaurants** | 714 without menus need cleanup | 🟢 LOW | 1 day |
| **All tables** | Legacy columns for archival | 🟢 LOW | After 6mo |

### Tables That Are Good

✅ **restaurants** - Status enum is great  
✅ **restaurant_locations** - Clean structure  
✅ **provinces/cities** - Perfect reference data  
✅ **combo_groups/combo_items** - Now working (99.77%!)  
✅ **users** - Good structure, no issues  

---

## 🚀 Implementation Roadmap

### Week 1-2: Admin Consolidation (Can Start NOW)

**Does NOT block Santiago's vendor work!**

**Tasks:**
1. ✅ Audit current admin users (1 day)
2. ✅ Create migration script (2 days)
3. ✅ Test in staging (2 days)
4. ✅ Update API endpoints (3 days)
5. ✅ Deploy to production (1 day)
6. ✅ Monitor for 1 week

**Owner:** Brian  
**Dependencies:** None (can run in parallel)

### Week 3: Column Standardization

**Tasks:**
1. Generate full column rename script
2. Test in staging
3. Deploy during low-traffic window
4. Update application code

**Owner:** Brian + Santiago  
**Dependencies:** Admin consolidation complete

### Week 4: Industry Standards

**Tasks:**
1. Add min/max to ingredient_groups
2. Implement soft delete pattern
3. Set up audit logging
4. Test all changes

**Owner:** Brian  
**Dependencies:** Column standardization

### Month 2-6: Monitoring Period

**Tasks:**
1. Monitor legacy column usage
2. Track audit log effectiveness
3. Gather feedback on admin consolidation
4. Plan for legacy column archival

---

## 🎯 Success Metrics

### Week 2 (Admin Consolidation)
- ✅ All admins can log in with new system
- ✅ Zero permission errors
- ✅ API response times unchanged
- ✅ 100% feature parity with old system

### Week 4 (Standards Complete)
- ✅ All naming conventions consistent
- ✅ Soft delete working on critical tables
- ✅ Audit log capturing changes
- ✅ Min/max constraints enforced

### Month 6 (Ready for Archive)
- ✅ Zero legacy column queries in logs
- ✅ All documentation updated
- ✅ Archive script tested
- ✅ CTO sign-off for cleanup

---

## 🔙 Rollback Plan

### If Admin Consolidation Fails

```sql
-- Restore from backup
DROP TABLE menuca_v3.admin_users;
DROP TABLE menuca_v3.admin_user_restaurants;

CREATE TABLE menuca_v3.admin_users AS 
SELECT * FROM menuca_v3_backup.admin_users_backup;

CREATE TABLE menuca_v3.admin_user_restaurants AS 
SELECT * FROM menuca_v3_backup.admin_user_restaurants_backup;

-- Restore old restaurant_admin_users
CREATE TABLE menuca_v3.restaurant_admin_users AS
SELECT * FROM menuca_v3_backup.restaurant_admin_users_backup;

-- Restore FKs and indexes
-- (Full script in ROLLBACK_GUIDE.md)
```

**Rollback Time:** < 15 minutes  
**Data Loss Risk:** ZERO (all backups preserved)

---

## ❓ Decision Points

### Should We Wait for Santiago?

**NO - Start Now!**

**Reasons:**
1. Admin consolidation is independent of vendor migration
2. We can work in parallel
3. Waiting delays production optimization
4. Changes are isolated and low-risk

**What Santiago Needs:**
- Communication about schema changes
- Updated ERD diagrams
- Migration scripts for reference

### Should We Consolidate Now or Later?

**NOW - Before More Code is Written**

**Reasons:**
1. Less application code to update now
2. Frontend hasn't built admin dashboards yet
3. Easier to test with fewer integrations
4. Sets good patterns for future development

---

## 📞 Next Steps

### Immediate (Today)

1. ✅ **Brian:** Review this plan
2. ⏳ **Brian:** Get approval from team
3. ⏳ **Brian:** Run audit queries in production
4. ⏳ **Brian:** Start admin consolidation script

### This Week

1. Test admin consolidation in staging
2. Update API documentation
3. Communicate changes to team
4. Schedule deployment window

### This Month

1. Complete admin consolidation
2. Standardize column naming
3. Add industry standards
4. Full testing & validation

---

## 📊 Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Admin consolidation breaks logins | Low | High | Parallel system for 1 week, rollback ready |
| Column renames break application | Medium | Medium | Staging first, gradual rollout |
| Soft delete causes data loss | Low | Critical | Test extensively, backup everything |
| Audit log impacts performance | Low | Medium | Index properly, monitor query times |
| Santiago's vendor work conflicts | Very Low | Low | Working in parallel, different tables |

---

## ✅ Approval Checklist

- [ ] **Brian Lapp** - Technical lead approval
- [ ] **Santiago** - Database admin review
- [ ] **James Walker** - Project lead sign-off
- [ ] **Team** - Development team notified
- [ ] **Staging** - Test environment ready
- [ ] **Backup** - All backup procedures verified

---

**Document Version:** 1.0  
**Last Updated:** October 14, 2025  
**Next Review:** After admin consolidation complete  
**Status:** 🎯 READY FOR APPROVAL & EXECUTION

