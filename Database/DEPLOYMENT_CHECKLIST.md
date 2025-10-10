# MenuCA V3 - Schema Optimization Deployment Checklist

**Sprint:** Day 1 Schema Optimization  
**Date:** October 10, 2025  
**Owner:** Brian Lapp, Santiago  
**Estimated Duration:** 4-6 hours total (staging + production)

---

## 📋 Pre-Deployment Checklist

### Planning & Coordination

- [ ] **Team Notification**
  - [ ] Notify stakeholders of maintenance window
  - [ ] Alert #engineering channel on Slack
  - [ ] Post in #announcements if user-facing
  - [ ] Update status page (if applicable)

- [ ] **Team Availability**
  - [ ] Brian Lapp available (lead)
  - [ ] Santiago available (backup)
  - [ ] DevOps on standby
  - [ ] CTO informed

- [ ] **Documentation Review**
  - [ ] Read `/Database/SCHEMA_AUDIT_ACTION_PLAN.md`
  - [ ] Read `/Database/GAP_ANALYSIS_REPORT.md`
  - [ ] Read `/Database/Menu & Catalog Entity/combos/README_COMBO_FIX.md`
  - [ ] Review `/Database/QUICK_START_SANTIAGO.md`

- [ ] **Scripts Validated**
  - [ ] All SQL scripts syntax-checked locally
  - [ ] No typos in file paths
  - [ ] All scripts have rollback procedures
  - [ ] Testing scripts prepared

---

## 🧪 STAGING DEPLOYMENT

**Environment:** staging.menuca.com  
**Database:** staging-db-primary  
**Timing:** Anytime (low/no traffic)  
**Duration:** ~2 hours

### Stage 1: Backup & Preparation (15 min)

- [ ] **Create Full Backup**
  ```sql
  -- Via Supabase dashboard: Database > Backups > Create Manual Backup
  -- OR via CLI:
  supabase db dump -f staging_backup_$(date +%Y%m%d_%H%M%S).sql
  ```
  - [ ] Backup completed
  - [ ] Backup file size verified (should be > 100 MB)
  - [ ] Backup downloaded locally

- [ ] **Verify Current State**
  ```sql
  -- Check row counts
  SELECT 'combo_groups' as table_name, COUNT(*) FROM menuca_v3.combo_groups
  UNION ALL
  SELECT 'combo_items', COUNT(*) FROM menuca_v3.combo_items
  UNION ALL
  SELECT 'dishes', COUNT(*) FROM menuca_v3.dishes;
  
  -- Expected:
  -- combo_groups: ~8,234
  -- combo_items: ~63 (before fix)
  -- dishes: ~10,585
  ```
  - [ ] Row counts match expected
  - [ ] No unexpected changes since last check

- [ ] **Test Database Connection**
  ```bash
  psql -h staging-db.supabase.co -U postgres -d postgres -c "SELECT version();"
  ```
  - [ ] Connection successful
  - [ ] Credentials work

### Stage 2: Deploy Performance Indexes (30 min)

- [ ] **Run Index Creation Script**
  ```bash
  psql -h staging-db.supabase.co -U postgres -d postgres -f /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Performance/add_critical_indexes.sql
  ```
  - [ ] Script started successfully
  - [ ] No errors during execution
  - [ ] All indexes created (check output for "CREATE INDEX" confirmations)

- [ ] **Validate Indexes**
  ```sql
  -- Check that indexes exist
  SELECT 
    schemaname, 
    tablename, 
    indexname,
    indexdef
  FROM pg_indexes
  WHERE schemaname = 'menuca_v3'
    AND indexname LIKE 'idx_%'
  ORDER BY tablename, indexname;
  
  -- Expected: 45+ new indexes
  ```
  - [ ] All expected indexes present
  - [ ] No duplicate indexes
  - [ ] Index names follow convention

- [ ] **Test Query Performance**
  ```sql
  -- Test a menu query (should use index now)
  EXPLAIN ANALYZE
  SELECT d.*, c.name as course_name
  FROM menuca_v3.dishes d
  JOIN menuca_v3.courses c ON d.course_id = c.id
  WHERE d.restaurant_id = 123;
  
  -- Check output for "Index Scan" (NOT "Seq Scan")
  ```
  - [ ] Query plan shows Index Scan
  - [ ] Execution time < 100ms
  - [ ] No Seq Scans on indexed columns

### Stage 3: Deploy RLS Policies (30 min)

- [ ] **Enable RLS on Tables**
  ```bash
  psql -h staging-db.supabase.co -U postgres -d postgres -f /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/create_rls_policies.sql
  ```
  - [ ] Script completed without errors
  - [ ] All 50 tables have RLS enabled
  - [ ] All policies created successfully

- [ ] **Validate RLS Policies**
  ```sql
  -- Check that policies exist
  SELECT 
    schemaname, 
    tablename, 
    policyname,
    cmd,
    roles
  FROM pg_policies
  WHERE schemaname = 'menuca_v3'
  ORDER BY tablename, policyname;
  
  -- Expected: 100+ policies across 50 tables
  ```
  - [ ] All tables have policies
  - [ ] Policy count matches expected (~100-150)
  - [ ] No missing tables in output

- [ ] **Test RLS Functionality**
  ```bash
  psql -h staging-db.supabase.co -U postgres -d postgres -f /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/test_rls_policies.sql
  ```
  - [ ] All functional tests PASS
  - [ ] Tenant isolation working
  - [ ] Admin bypass working
  - [ ] Public read working
  - [ ] No security violations

- [ ] **Benchmark RLS Performance**
  ```sql
  -- Run performance tests from test script
  -- Look for "RLS Overhead" results
  -- Target: < 10% overhead vs no RLS
  ```
  - [ ] RLS overhead < 10%
  - [ ] Query plans still use indexes
  - [ ] P95 latency acceptable

### Stage 4: Fix Combo System (30 min)

- [ ] **Check Prerequisite Data**
  ```bash
  # Verify V1 combos file exists
  ls -lh /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu\ &\ Catalog\ Entity/converted/menuca_v1_combos_postgres.sql
  
  # Should show ~2-5 MB file
  ```
  - [ ] File exists
  - [ ] File size looks correct
  - [ ] File readable

- [ ] **Run Combo Fix Migration**
  ```bash
  psql -h staging-db.supabase.co -U postgres -d postgres -f /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu\ &\ Catalog\ Entity/combos/fix_combo_items_migration.sql
  ```
  - [ ] Script started successfully
  - [ ] "V1 combos loaded" shows > 50,000
  - [ ] "Successfully mapped" shows > 50,000
  - [ ] "New combo_items inserted" shows > 50,000
  - [ ] "Orphan rate" shows < 5%
  - [ ] No errors during execution

- [ ] **Validate Combo Fix**
  ```bash
  psql -h staging-db.supabase.co -U postgres -d postgres -f /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu\ &\ Catalog\ Entity/combos/validate_combo_fix.sql
  ```
  - [ ] Validation summary shows PASS
  - [ ] Orphan rate < 5% (ideally < 1%)
  - [ ] Data integrity checks all PASS
  - [ ] No duplicate combo items
  - [ ] Sample combos look correct

- [ ] **Spot Check Combos in Database**
  ```sql
  -- Get 5 random well-populated combos
  SELECT 
    cg.id, 
    cg.name, 
    cg.restaurant_id,
    COUNT(ci.id) as item_count,
    string_agg(d.name, ', ') as dishes
  FROM menuca_v3.combo_groups cg
  JOIN menuca_v3.combo_items ci ON cg.id = ci.combo_group_id
  JOIN menuca_v3.dishes d ON ci.dish_id = d.id
  GROUP BY cg.id, cg.name, cg.restaurant_id
  ORDER BY random()
  LIMIT 5;
  ```
  - [ ] All combos have 2+ dishes
  - [ ] Dish names look correct
  - [ ] No weird data (nulls, wrong dishes)

### Stage 5: Integration Testing (30 min)

- [ ] **Test Frontend Integration**
  - [ ] Login as test restaurant user
  - [ ] Load restaurant dashboard
  - [ ] View menu page
  - [ ] Open a combo (check dishes display)
  - [ ] Edit a dish (check RLS allows)
  - [ ] Try to access other restaurant's data (check RLS blocks)

- [ ] **Test API Endpoints**
  ```bash
  # Get menu for test restaurant
  curl -H "Authorization: Bearer $TEST_TOKEN" \
       https://staging-api.menuca.com/api/restaurants/123/menu
  
  # Should return menu with combos populated
  ```
  - [ ] API returns menu successfully
  - [ ] Combos include dishes array
  - [ ] RLS filtering working (only own restaurant)
  - [ ] Response time acceptable (< 500ms)

- [ ] **Test Ordering Flow**
  - [ ] Add regular dish to cart → Success
  - [ ] Add combo to cart → Success
  - [ ] Combo shows all dishes → Success
  - [ ] Checkout process works → Success
  - [ ] Order confirmation shows combo correctly → Success

### Stage 6: Performance Testing (15 min)

- [ ] **Load Test Key Queries**
  ```bash
  # Run 100 menu queries concurrently
  ab -n 100 -c 10 -H "Authorization: Bearer $TEST_TOKEN" \
     https://staging-api.menuca.com/api/restaurants/123/menu
  ```
  - [ ] All requests successful (0 failures)
  - [ ] P50 latency < 200ms
  - [ ] P95 latency < 500ms
  - [ ] No database errors in logs

- [ ] **Check Database Stats**
  ```sql
  -- Check for slow queries
  SELECT 
    query,
    mean_exec_time,
    calls,
    total_exec_time
  FROM pg_stat_statements
  WHERE query LIKE '%menuca_v3%'
  ORDER BY mean_exec_time DESC
  LIMIT 10;
  ```
  - [ ] No queries > 1 second average
  - [ ] All queries using indexes (check plans)
  - [ ] Cache hit ratio > 95%

### Stage 7: Monitoring & Sign-Off (15 min)

- [ ] **Check Logs**
  - [ ] No errors in database logs (last 1 hour)
  - [ ] No errors in application logs (last 1 hour)
  - [ ] No unexpected warnings

- [ ] **Verify Metrics**
  - [ ] Database CPU < 50%
  - [ ] Database RAM < 80%
  - [ ] Connection pool healthy (< 80% used)
  - [ ] No slow query alerts

- [ ] **Document Issues Found**
  - [ ] List any issues encountered (use table below)
  - [ ] Mark severity: Low / Medium / High / Critical
  - [ ] Document workarounds or fixes applied

**Issues Log:**
| Issue | Severity | Resolution | Notes |
|-------|----------|------------|-------|
| _None yet_ | - | - | - |

- [ ] **STAGING SIGN-OFF**
  - [ ] All tests passed
  - [ ] Performance acceptable
  - [ ] No blockers for production
  - [ ] **Signed:** _________________ Date: _______

---

## 🚀 PRODUCTION DEPLOYMENT

**Environment:** app.menuca.com  
**Database:** prod-db-primary  
**Timing:** Low traffic window (2-6am EST)  
**Duration:** ~2 hours  
**Rollback Time:** < 15 minutes

### Pre-Production Checklist

- [ ] **Staging Validation Complete**
  - [ ] All staging tests passed
  - [ ] No issues in staging for 24+ hours
  - [ ] Team reviewed staging results

- [ ] **Maintenance Window**
  - [ ] Scheduled for: _____________ (date/time)
  - [ ] Duration: 2-4 hours
  - [ ] Notifications sent (24h before)
  - [ ] Status page updated

- [ ] **Team Ready**
  - [ ] Brian Lapp present
  - [ ] Santiago present
  - [ ] DevOps on call
  - [ ] Rollback plan reviewed

- [ ] **Communication**
  - [ ] Engineering team notified
  - [ ] Customer support briefed
  - [ ] Monitoring dashboard open
  - [ ] Slack war room created: #prod-deployment-$(date +%m%d)

### Production Deployment Steps

**⚠️ CRITICAL: Follow these steps EXACTLY as in staging**

### Stage 1: Backup & Preparation (15 min)

- [ ] **Create Full Backup**
  ```sql
  -- Via Supabase dashboard: Create manual backup
  -- Label: "Pre-schema-optimization-$(date +%Y%m%d)"
  ```
  - [ ] Backup initiated
  - [ ] Backup completed (wait for confirmation)
  - [ ] Backup verified (can restore)
  - [ ] Backup downloaded locally

- [ ] **Set Read-Only Mode (Optional)**
  ```sql
  -- If doing during business hours, consider:
  ALTER DATABASE postgres SET default_transaction_read_only = on;
  
  -- Later revert with:
  -- ALTER DATABASE postgres SET default_transaction_read_only = off;
  ```
  - [ ] Read-only set (if applicable)
  - [ ] Verify writes blocked

- [ ] **Snapshot Current State**
  ```sql
  -- Save current metrics
  \copy (SELECT 'combo_groups', COUNT(*) FROM menuca_v3.combo_groups) TO 'prod_pre_deploy_metrics.csv' CSV
  \copy (SELECT 'combo_items', COUNT(*) FROM menuca_v3.combo_items) TO STDOUT CSV
  \copy (SELECT 'dishes', COUNT(*) FROM menuca_v3.dishes) TO STDOUT CSV
  ```
  - [ ] Metrics saved
  - [ ] Row counts documented

### Stage 2: Deploy (1.5 hours)

**Follow EXACT same steps as staging:**

- [ ] **Deploy Indexes** (30 min)
  ```bash
  psql -h prod-db.supabase.co -U postgres -d postgres -f /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Performance/add_critical_indexes.sql
  ```
  - [ ] Complete
  - [ ] Validated

- [ ] **Deploy RLS Policies** (30 min)
  ```bash
  psql -h prod-db.supabase.co -U postgres -d postgres -f /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/create_rls_policies.sql
  ```
  - [ ] Complete
  - [ ] Tested

- [ ] **Fix Combo System** (30 min)
  ```bash
  psql -h prod-db.supabase.co -U postgres -d postgres -f /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu\ &\ Catalog\ Entity/combos/fix_combo_items_migration.sql
  ```
  - [ ] Complete
  - [ ] Validated

### Stage 3: Validation (30 min)

- [ ] **Run All Validation Scripts**
  - [ ] Index validation passed
  - [ ] RLS tests passed
  - [ ] Combo validation passed
  - [ ] No integrity errors

- [ ] **Smoke Test Production**
  - [ ] Load homepage → Success
  - [ ] Login as test user → Success
  - [ ] View menu → Success
  - [ ] View combo → Success (dishes populated)
  - [ ] Add to cart → Success
  - [ ] Checkout → Success

- [ ] **Load Test**
  ```bash
  # 200 requests, 20 concurrent
  ab -n 200 -c 20 -H "Authorization: Bearer $PROD_TOKEN" \
     https://api.menuca.com/api/restaurants/123/menu
  ```
  - [ ] 0% error rate
  - [ ] P95 < 500ms
  - [ ] All requests successful

### Stage 4: Re-Enable & Monitor (30 min)

- [ ] **Re-Enable Writes (if read-only)**
  ```sql
  ALTER DATABASE postgres SET default_transaction_read_only = off;
  ```
  - [ ] Write mode enabled
  - [ ] Tested with INSERT

- [ ] **Monitor for 30 Minutes**
  - [ ] CPU normal (< 60%)
  - [ ] Memory normal (< 80%)
  - [ ] No error spikes
  - [ ] Query performance good
  - [ ] No customer reports

- [ ] **Post Maintenance Notice**
  - [ ] Update status page: "Maintenance Complete"
  - [ ] Slack #engineering: "Deployment successful"
  - [ ] Slack #announcements: "Service fully operational"

### Stage 5: Post-Deployment (24h monitoring)

- [ ] **Hour 1: Active Monitoring**
  - [ ] Check logs every 15 min
  - [ ] Watch error rates
  - [ ] Monitor query times
  - [ ] Check customer support tickets

- [ ] **Hour 2-4: Passive Monitoring**
  - [ ] Set up alerts (if not already)
  - [ ] Check dashboards every hour
  - [ ] Review any anomalies

- [ ] **Hour 4-24: Standard Monitoring**
  - [ ] Normal on-call rotation
  - [ ] Daily metrics review
  - [ ] Weekly performance report

---

## 🔙 ROLLBACK PROCEDURES

### When to Rollback

**IMMEDIATE ROLLBACK if:**
- Database corruption detected
- Data loss > 1% of any table
- Critical errors preventing orders
- Performance degradation > 50%
- Security breach detected

**CONSIDER ROLLBACK if:**
- Error rate > 5%
- P95 latency > 2x baseline
- Customer-reported issues > 10/hour
- RLS blocking valid access
- Combo system still broken (orphan rate > 20%)

### Rollback Steps

#### Option 1: Full Database Restore (15 min)

```bash
# Restore from backup
supabase db restore --backup-id <backup-id-from-step-1>

# Verify restoration
psql -c "SELECT COUNT(*) FROM menuca_v3.combo_items"
# Should show original count (~63)
```

- [ ] Restore initiated
- [ ] Restore completed
- [ ] Data verified (row counts match pre-deploy)
- [ ] Application tested
- [ ] Service restored

#### Option 2: Partial Rollback (Indexes Only)

```sql
-- Drop all new indexes
DROP INDEX CONCURRENTLY menuca_v3.idx_dishes_restaurant;
-- Repeat for each index added
```

- [ ] Indexes dropped
- [ ] Performance impact assessed
- [ ] Service stable

#### Option 3: Partial Rollback (RLS Only)

```bash
# Run RLS rollback
psql -f /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Security/rollback_rls.sql

# Or manually:
# ALTER TABLE menuca_v3.dishes DISABLE ROW LEVEL SECURITY;
# (Repeat for all tables)
```

- [ ] RLS disabled
- [ ] Access restored
- [ ] Service stable

#### Option 4: Partial Rollback (Combo Fix Only)

```bash
# Run combo rollback
psql -f /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Menu\ &\ Catalog\ Entity/combos/rollback_combo_fix.sql

# Uncomment appropriate OPTION in script
```

- [ ] Combo items deleted
- [ ] System reverted to pre-fix state
- [ ] Other changes intact

### Post-Rollback Actions

- [ ] **Root Cause Analysis**
  - [ ] Document what went wrong
  - [ ] Identify why staging didn't catch it
  - [ ] Propose fixes

- [ ] **Communication**
  - [ ] Notify team of rollback
  - [ ] Update status page
  - [ ] Send post-mortem email

- [ ] **Schedule Re-Deploy**
  - [ ] Fix identified issues
  - [ ] Re-test in staging
  - [ ] Schedule new maintenance window

---

## 📊 Success Criteria

### Must-Have (Go/No-Go for Production)
- [ ] All staging tests passed
- [ ] Combo orphan rate < 5%
- [ ] RLS functional tests 100% pass
- [ ] Query performance within 20% of baseline
- [ ] Zero data integrity errors
- [ ] Rollback tested and validated

### Nice-to-Have
- [ ] Combo orphan rate < 1%
- [ ] RLS overhead < 10%
- [ ] Query performance improved vs baseline
- [ ] Zero customer-reported issues after 24h

---

## 📞 Emergency Contacts

### On-Call Rotation
- **Primary:** Brian Lapp - XXX-XXX-XXXX
- **Backup:** Santiago - XXX-XXX-XXXX
- **Escalation:** James Walker (CTO) - XXX-XXX-XXXX

### Communication Channels
- **Slack:** #prod-deployment
- **War Room:** #deployment-war-room
- **Incident:** #incidents (if critical)

---

## 📝 Post-Deployment Report

**Fill out after production deployment:**

### Deployment Summary
- **Date:** _______________
- **Duration:** _______________
- **Deployed By:** _______________
- **Team Members:** _______________

### Results
- [ ] Successful - No issues
- [ ] Successful - Minor issues (documented below)
- [ ] Partial Success - Rollback required
- [ ] Failed - Full rollback

### Metrics
- **Combo Orphan Rate:** _______ % (target: < 5%)
- **RLS Overhead:** _______ % (target: < 10%)
- **Query Performance:** _______ ms P95 (baseline: _____)
- **Error Rate:** _______ % (target: < 1%)

### Issues Encountered
| Issue | Severity | Resolution | Time Lost |
|-------|----------|------------|-----------|
| | | | |

### Lessons Learned
- What went well:
- What could be improved:
- What to do differently next time:

### Sign-Off
- **Deployment Lead:** _________________ Date: _______
- **Technical Reviewer:** _________________ Date: _______
- **CTO Approval:** _________________ Date: _______

---

**Document Version:** 1.0  
**Last Updated:** October 10, 2025  
**Next Review:** After production deployment

