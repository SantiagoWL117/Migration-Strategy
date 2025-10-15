# Vendor Migration Rollback Plan

**Version:** 1.0  
**Date:** October 15, 2025  
**Status:** Prepared (Not Executed)

---

## 🎯 Purpose

This document provides a comprehensive rollback plan to revert the vendor migration if critical issues are encountered in production.

---

## ⚠️ When to Execute Rollback

### Critical Triggers

Execute rollback immediately if:

1. **Data Corruption**
   - Commission amounts incorrect by >5%
   - Missing or orphaned vendor records
   - Report data inconsistency

2. **System Failure**
   - Edge Function failure rate >10%
   - Database trigger failures
   - Critical constraint violations

3. **Performance Issues**
   - Query response time >50% slower than expected
   - Database connection saturation
   - Edge Function timeout rate >5%

4. **Security Breach**
   - Unauthorized data access detected
   - RLS policy bypass discovered
   - Data leak identified

5. **Business Impact**
   - Vendors unable to access reports
   - Incorrect commission payments
   - Stakeholder requests immediate rollback

---

## 🔄 Rollback Strategy

### Phase 1: Immediate Actions (0-15 minutes)

1. **Stop New Operations**
   - Disable commission report generation
   - Block vendor portal access (if applicable)
   - Prevent new data writes

2. **Assess Impact**
   - Identify affected vendors
   - Determine data integrity status
   - Document issue details

3. **Notify Stakeholders**
   - Alert technical team
   - Notify vendors (if needed)
   - Inform management

### Phase 2: Data Rollback (15-30 minutes)

1. **Create Backup of Current State**
2. **Execute Rollback Scripts**
3. **Verify Rollback Success**

### Phase 3: System Restoration (30-60 minutes)

1. **Verify V2 System Availability**
2. **Restore Original Functionality**
3. **Validate Data Integrity**

### Phase 4: Communication (60+ minutes)

1. **Stakeholder Notification**
2. **Root Cause Analysis**
3. **Remediation Planning**

---

## 📋 Rollback Procedures

### Procedure 1: Database Rollback

#### Step 1: Backup Current V3 State

```sql
-- Create backup of V3 data before rollback
BEGIN;

-- Export V3 data to backup tables
CREATE TABLE menuca_v3.vendors_backup_rollback AS 
SELECT * FROM menuca_v3.vendors WHERE metadata->>'source_system' = 'v2';

CREATE TABLE menuca_v3.vendor_restaurants_backup_rollback AS 
SELECT * FROM menuca_v3.vendor_restaurants WHERE metadata->>'source_system' = 'v2';

CREATE TABLE menuca_v3.vendor_commission_reports_backup_rollback AS 
SELECT * FROM menuca_v3.vendor_commission_reports WHERE metadata->>'source_system' = 'v2';

CREATE TABLE menuca_v3.vendor_statement_numbers_backup_rollback AS 
SELECT * FROM menuca_v3.vendor_statement_numbers;

COMMIT;
```

**Expected Result:** 4 backup tables created

---

#### Step 2: Delete V3 Migrated Data

```sql
-- ============================================================================
-- ROLLBACK SCRIPT - DELETE V3 MIGRATED DATA
-- ============================================================================
-- WARNING: This will remove all migrated vendor data from V3
-- Only execute if rollback is confirmed necessary
-- ============================================================================

BEGIN;

-- Delete in reverse order of dependencies
DELETE FROM menuca_v3.vendor_commission_reports 
WHERE metadata->>'source_system' = 'v2';

DELETE FROM menuca_v3.vendor_statement_numbers 
WHERE vendor_id IN (
    SELECT id FROM menuca_v3.vendors WHERE metadata->>'source_system' = 'v2'
);

DELETE FROM menuca_v3.vendor_restaurants 
WHERE metadata->>'source_system' = 'v2';

DELETE FROM menuca_v3.vendors 
WHERE metadata->>'source_system' = 'v2';

-- Verify deletion
SELECT 
    'Rollback Verification' as check_name,
    (SELECT COUNT(*) FROM menuca_v3.vendors WHERE metadata->>'source_system' = 'v2') as vendors_remaining,
    (SELECT COUNT(*) FROM menuca_v3.vendor_restaurants WHERE metadata->>'source_system' = 'v2') as assignments_remaining,
    (SELECT COUNT(*) FROM menuca_v3.vendor_commission_reports WHERE metadata->>'source_system' = 'v2') as reports_remaining,
    (SELECT COUNT(*) FROM menuca_v3.vendor_statement_numbers) as statement_trackers_remaining;

-- Expected: All counts should be 0 (except statement_trackers may have non-v2 entries)

COMMIT;
```

**Expected Result:** All V3 migrated data removed

---

#### Step 3: Verify Staging Data Intact

```sql
-- Verify staging tables are still available as backup
SELECT 
    'Staging Data Verification' as check_name,
    (SELECT COUNT(*) FROM staging.v2_vendor_users) as vendor_users,
    (SELECT COUNT(*) FROM staging.v2_vendor_restaurant_assignments) as assignments,
    (SELECT COUNT(*) FROM staging.v2_vendor_reports_recent) as reports,
    (SELECT COUNT(*) FROM staging.v2_vendor_reports_numbers) as statement_numbers;

-- Expected: 
-- vendor_users: 2
-- assignments: 31 (includes duplicate)
-- reports: 286
-- statement_numbers: 2
```

**Expected Result:** All staging data intact

---

### Procedure 2: Edge Function Rollback

#### Option A: Disable Edge Function

```bash
# Disable the Edge Function in Supabase
# Method 1: Via Supabase Dashboard
# 1. Go to Edge Functions
# 2. Select calculate-vendor-commission
# 3. Click "Disable"

# Method 2: Via CLI (if available)
supabase functions delete calculate-vendor-commission
```

#### Option B: Revert Edge Function to Previous Version

```bash
# If previous version exists, revert to it
# This depends on your deployment strategy
```

**Expected Result:** Edge Function disabled or reverted

---

### Procedure 3: Restore V2 System Access

#### Step 1: Verify V2 Data Integrity

```sql
-- Connect to V2 database
-- Verify vendor data is intact

SELECT 
    'V2 Data Verification' as check_name,
    (SELECT COUNT(*) FROM menuca_v2.admin_users WHERE `group` = 12 AND active = 'y') as vendor_users,
    (SELECT COUNT(*) FROM menuca_v2.admin_users_restaurants WHERE user_id IN (
        SELECT id FROM menuca_v2.admin_users WHERE `group` = 12
    )) as assignments,
    (SELECT COUNT(*) FROM menuca_v2.vendor_reports) as total_reports;

-- Expected counts based on V2 original data
```

**Expected Result:** V2 data unchanged

---

#### Step 2: Re-enable V2 Functionality

- [ ] Re-enable V2 vendor portal (if disabled)
- [ ] Re-enable V2 report generation
- [ ] Verify V2 commission calculations working
- [ ] Test V2 statement number increment

**Expected Result:** V2 system fully functional

---

## 🔍 Post-Rollback Verification

### Verification Checklist

#### V3 System State

```sql
-- Verify V3 is clean of migrated data
SELECT 
    'Post-Rollback V3 State' as check_name,
    COUNT(*) as migrated_records_remaining
FROM menuca_v3.vendor_commission_reports
WHERE metadata->>'source_system' = 'v2'

UNION ALL

SELECT 
    'V3 Vendors',
    COUNT(*)
FROM menuca_v3.vendors
WHERE metadata->>'source_system' = 'v2';

-- Expected: 0 for both queries
```

#### Staging Data Preserved

```sql
-- Verify staging data available for re-migration
SELECT 
    'Staging Preservation' as check_name,
    (SELECT COUNT(*) FROM staging.v2_vendor_users) +
    (SELECT COUNT(*) FROM staging.v2_vendor_restaurant_assignments) +
    (SELECT COUNT(*) FROM staging.v2_vendor_reports_recent) as total_staging_records;

-- Expected: 319 (2 + 31 + 286)
```

#### Backup Tables Created

```sql
-- Verify backup tables exist
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'menuca_v3'
  AND tablename LIKE '%_backup_rollback'
ORDER BY tablename;

-- Expected: 4 backup tables
```

---

## 📊 Rollback Impact Assessment

### Data Impact

- **Vendors Affected:** 2 (Menu Ottawa, Darrell Corcoran)
- **Reports Rolled Back:** 286 (12 months historical)
- **Assignments Rolled Back:** 30
- **Statement Numbers:** Reverted to V2 values

### System Impact

- **V3 Vendor System:** Inactive
- **V2 Vendor System:** Restored
- **Edge Function:** Disabled/Removed
- **Commission Calculations:** Reverted to V2 logic

### Business Impact

- **Vendor Portal:** Reverted to V2
- **Report Generation:** Using V2 process
- **Commission Payments:** Using V2 data
- **Historical Reports:** Accessible via V2 backup

---

## 🔄 Re-Migration Path

If rollback is executed, follow this path to re-attempt migration:

### Phase 1: Root Cause Analysis

1. **Identify Issue**
   - What caused the rollback?
   - Is it a data issue, code issue, or process issue?

2. **Document Findings**
   - Create incident report
   - Document lessons learned

3. **Develop Fix**
   - Address root cause
   - Update migration scripts if needed
   - Add additional tests

### Phase 2: Re-Test

1. **Test in Non-Production**
   - Apply fix to staging environment
   - Re-run all Phase 8 tests
   - Add new tests for the identified issue

2. **Stakeholder Review**
   - Present findings and fix
   - Get approval for re-migration

### Phase 3: Re-Migration

1. **Start from Phase 6**
   - Staging data is preserved
   - Apply updated migration scripts
   - Execute Phases 6-9 again

2. **Enhanced Monitoring**
   - Add specific monitoring for the issue
   - Implement additional safeguards

---

## 📞 Communication Plan

### Immediate Communication (During Rollback)

**To: Technical Team**
```
Subject: URGENT - Vendor Migration Rollback in Progress

The vendor migration is being rolled back due to [REASON].

Status: In Progress
ETA: [TIME]
Impact: [DESCRIPTION]

Next Update: [TIME]
```

**To: Stakeholders**
```
Subject: Vendor System - Temporary Rollback

We've temporarily reverted the vendor system to the previous version to address [ISSUE].

Impact: Minimal - system returning to familiar V2 interface
Timeline: Resolution expected by [DATE]
Action Required: None - system will function normally

We'll provide updates as we resolve this issue.
```

**To: Vendors (if needed)**
```
Subject: Vendor Portal - Brief Service Update

We've made a temporary adjustment to the vendor portal. You may notice the interface has reverted to the previous version.

This does not affect your commission payments or reports.
All data is safe and accessible.

We apologize for any inconvenience.
```

---

## ✅ Rollback Success Criteria

Rollback is considered successful when:

- [x] All V3 migrated data removed
- [x] V2 system fully functional
- [x] Vendors can access V2 system
- [x] Staging data preserved for re-migration
- [x] Backup of V3 state created
- [x] All stakeholders notified
- [x] Root cause documented
- [x] Re-migration plan created

---

## 🎯 Prevention Measures

To prevent future rollbacks:

### Enhanced Testing

- [ ] Add production-like load testing
- [ ] Extended integration testing period
- [ ] Shadow mode testing (run V3 parallel to V2)

### Gradual Rollout

- [ ] Migrate 1 vendor first (pilot)
- [ ] Monitor for 1 week
- [ ] Migrate remaining vendors

### Enhanced Monitoring

- [ ] Real-time commission accuracy checks
- [ ] Automated data integrity validation
- [ ] Performance degradation alerts

---

## 📚 Reference Documents

- **Migration Plan:** `vendor-business-logic-analysis.plan.md`
- **Deployment Checklist:** `DEPLOYMENT_CHECKLIST.md`
- **Phase 6 Report:** `PHASE_6_COMPLETE.md`
- **Phase 7 Report:** `PHASE_7_COMPLETE.md`
- **Phase 8 Report:** `PHASE_8_COMPLETE.md`

---

## 🔒 Rollback Script Storage

**Location:** `Database/Vendors & Franchises/ROLLBACK_PLAN.md`

**Access:** Restricted to authorized personnel

**Approval Required:** Yes - Technical Lead + Product Owner

---

## ⚠️ WARNING

**This rollback plan should only be executed if absolutely necessary.**

All rollback actions are irreversible once committed. Ensure:
- [ ] Issue severity justifies rollback
- [ ] Alternative solutions explored
- [ ] Stakeholder approval obtained
- [ ] Backup of current state created
- [ ] Team ready to execute procedures

**Execution Authority:** Technical Lead or Database Administrator

---

**Plan Status:** ✅ Prepared and Ready (Not Executed)

