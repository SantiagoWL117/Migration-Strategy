# Restaurant Active Status Correction Summary

**Date:** October 14, 2025  
**Status:** ✅ Ready for Execution  
**Impact:** 101 restaurants will be corrected from suspended/pending → active

---

## 📋 Problem Summary

During the V1→V2→V3 migration, V2 data overwrote V1 data. However:

- Someone attempted a V1→V2 migration years ago
- Prepped restaurants but **never completed the migration**
- **99% of restaurants remained operational in V1 database**
- These were marked as `inactive`, `suspended`, or `pending` in V2 (because they never migrated)
- **Migration logic gave priority to V2**, so V3 inherited incorrect statuses

---

## 🎯 Solution

**Priority Rule:** If a restaurant is marked `active` in **EITHER** V1 **OR** V2 → set `status='active'` in V3

---

## 📊 Analysis Results

### V1 Active Restaurants: 228 total

**Current V3 Status Distribution:**
- ✅ 125 correctly marked as `active` in V3
- ❌ **87 incorrectly marked as `suspended` in V3**
- ❌ **14 incorrectly marked as `pending` in V3**
- ⚠️ 2 missing from V3 entirely (test restaurants)

### V2 Active Restaurants: 25 total
- ✅ All 25 are correctly marked as `active` in V3
- ✅ No corrections needed from V2 source

### **Total Corrections Needed: 101 restaurants**
- 87 suspended → active
- 14 pending → active

---

## 🔍 Notable Findings

### Restaurants with Suspension Timestamps

**3 restaurants have `suspended_at` timestamps but are active in V1:**

| Correction ID | V3 ID | Restaurant Name | Current Status | Suspended At | Notes |
|---------------|-------|-----------------|----------------|--------------|-------|
| 13 | 47 | Mr Mozzarella - Nepean | suspended | 2025-01-12 17:04:48+00 | Active in V1, will be corrected to active |
| 62 | 223 | 2 for 1 Pizza | suspended | 2023-04-14 20:56:07+00 | Active in V1, will be corrected to active |
| 86 | 468 | Just Wok | suspended | 2022-10-31 01:02:58+00 | Active in V1, will be corrected to active |

**Decision:** These will be corrected to `active` and `suspended_at` will be cleared, following the rule "if active in V1 OR V2 → active in V3"

### Sample Restaurants Being Corrected

Classic MenuCA restaurants that will be corrected:
- Milano
- Papa Joe's Pizza (Downtown, Greely & Findlay Creek, Bridle Path)
- House of Lasagna
- Eastview Pizza
- Mozza Pizza
- House of Pizza
- Lucky Star Chinese Food
- Cypress Garden
- Kiki Lebanese Pineview Pizza
- Bobbie's Pizza & Subs

---

## 🗂️ Files Created

### Staging Table
- **Table:** `staging.active_restaurant_corrections`
- **Records:** 101 corrections loaded
- **Purpose:** Review and audit trail

### SQL Script
- **File:** `update_active_status_corrections.sql`
- **Purpose:** Execute the status corrections
- **Safety:** Wrapped in transaction with rollback capability

### Columns in Staging Table
```sql
correction_id          - Sequential ID
source_version         - 'v1' or 'v2'
source_id              - Original ID from source
v1_id                  - V1 ID
restaurant_name        - Restaurant name
v3_restaurant_id       - Matched V3 ID
current_v3_status      - Current status in V3
source_active          - Source active value
source_pending         - Source pending value
source_suspend         - Source suspend_operation value
should_be_active       - TRUE if should be active
notes                  - Correction notes
created_at             - Timestamp
```

---

## ✅ Validation Complete

### Pre-Execution Checks Passed:
- ✅ No duplicate entries in staging table
- ✅ All V3 restaurant IDs exist and are valid
- ✅ Status distribution matches expectations (87 + 14 = 101)
- ✅ No conflicts with closed restaurants (closed_at is NULL for all)
- ✅ Sample data verified (Milano, Papa Joe's Pizza, etc.)
- ✅ Source data validated (all have active='Y' in V1)

---

## 🚀 Execution Plan

### Phase 5: Generate UPDATE Script ✅ COMPLETE
- Created `update_active_status_corrections.sql`
- Script includes verification queries
- Wrapped in transaction for safety

### Phase 6: Execute & Verify (NEXT STEP)

**To execute:**
1. Review the SQL script: `update_active_status_corrections.sql`
2. Run the script in Supabase SQL Editor or via MCP
3. Review verification output
4. If correct: `COMMIT;`
5. If issues: `ROLLBACK;`

**Expected outcome:**
- 101 restaurants updated
- Status distribution will change:
  - Before: 736 suspended, 158 active, 50 pending
  - After: 649 suspended (-87), 259 active (+101), 36 pending (-14)

---

## 📈 Impact Assessment

### Business Impact
- ✅ **Positive:** 101 restaurants will be correctly marked as active
- ✅ **No Breaking Changes:** Only status field updates
- ✅ **FK Integrity:** All foreign key relationships maintained
- ✅ **Customer-Facing:** Customers will see correct restaurant availability

### Technical Impact
- ✅ **Safe Operation:** Only UPDATE statements, no deletions
- ✅ **Reversible:** Transaction-wrapped, can be rolled back
- ✅ **Audit Trail:** Staging table provides complete record
- ✅ **No Data Loss:** All original data preserved in staging

### Restaurants NOT Affected
- Restaurants already marked as `active`: No change
- Restaurants marked as `suspended` in BOTH V1 and V2: No change (correctly suspended)
- Restaurants marked as `pending` in BOTH V1 and V2: No change (correctly pending)

---

## 🔒 Safety Measures

1. **Staging Table Created:** All corrections reviewed before execution
2. **Transaction Wrapped:** Can rollback if issues found
3. **Verification Queries:** Built into execution script
4. **No Data Deletion:** Only status updates
5. **Audit Trail:** Pre-update state saved in temp table
6. **Documentation:** Complete record of changes

---

## 📝 Next Steps

### Immediate Actions:
1. ✅ Analysis complete
2. ✅ Staging table created and populated
3. ✅ Validation complete
4. ✅ UPDATE script generated
5. ⏳ **READY FOR EXECUTION** - Review script and execute

### After Execution:
1. Update Memory Bank with results
2. Document final status distribution
3. Notify stakeholders of corrected restaurants
4. Archive staging table for audit purposes

---

## 📞 Stakeholder Communication

### Restaurants Being Reactivated
- 101 restaurants will show as "active" in V3
- These restaurants were already operating from V1 database
- No operational changes required
- Simply correcting the status to match reality

---

## ✨ Success Criteria

- [ ] 101 restaurants updated to `active` status
- [ ] Suspended count reduced by 87
- [ ] Pending count reduced by 14
- [ ] Active count increased by 101
- [ ] No FK violations
- [ ] All verification queries pass
- [ ] Staging table preserved for audit

---

**Status:** ✅ **READY FOR PHASE 6 EXECUTION**

**Prepared by:** AI Migration Assistant  
**Reviewed by:** Pending stakeholder review  
**Execution:** Awaiting approval

