# V1 Admin Recovery Plan

**Date:** October 9, 2025  
**Status:** 🟡 **AWAITING USER DECISION**  
**Estimated Time:** 2-4 hours for critical accounts

---

## 🎯 EXECUTIVE SUMMARY

**Problem:** 2 V1 admin accounts with recent activity (2025) were not migrated to V3.

**Good News:** ✅ **Likely duplicate accounts already exist in V3!**

**Status:**
- ✅ **Chris Bouziotas**: 2 potential V3 accounts found
- ✅ **Darrell Corcoran**: 1 potential V3 account found

**Action Required:** Verify if these are duplicates, then decide recovery approach.

---

## 👥 CRITICAL ACCOUNTS ANALYSIS

### Account 1: Chris Bouziotas

#### V1 Account (NOT in V3)
- **Email:** chris.bouziotas@menu.ca
- **Name:** Christos Bouziotas
- **Last Login:** 2025-09-06 (3 days ago)
- **Status:** Active
- **Permissions:** 432 bytes (full admin)
- **V1 ID:** 31

#### Potential V3 Duplicates

**Match 1:** chris@menu.ca
- **V3 ID:** 12
- **Name:** Christos Bouziotas
- **Source:** V2 ID 24
- **Assessment:** ✅ **LIKELY SAME PERSON** (shortened email domain)

**Match 2:** cbouzi7039@gmail.com
- **V3 ID:** 10
- **Name:** Chris Bouziotas
- **Source:** V2 ID 54
- **Assessment:** ✅ **LIKELY SAME PERSON** (personal email)

#### Conclusion
🎉 **NO DATA LOSS** - Chris has **TWO** accounts in V3!
- chris@menu.ca (work email)
- cbouzi7039@gmail.com (personal email)

---

### Account 2: Darrell Corcoran

#### V1 Account (NOT in V3)
- **Email:** darrell@menuottawa.com
- **Name:** Darrell Corcoran
- **Last Login:** 2025-07-22 (7 weeks ago)
- **Status:** Active
- **Permissions:** 123 bytes (restaurant-specific)
- **V1 ID:** 22

#### Potential V3 Duplicate

**Match:** darrellcorcoran1967@gmail.com
- **V3 ID:** 13
- **Name:** Darrell Corcoran
- **Source:** V2 ID 65
- **Assessment:** ✅ **LIKELY SAME PERSON** (personal email)

#### V1 Permissions Analysis

From Query 2, darrell@menuottawa.com had:
```
a:2:{
  s:22:"manageRestoInformation";s:2:"on";
  s:11:"restaurants";a:4:{
    i:0;s:2:"72";
    i:1;s:2:"87";
    i:2;s:2:"93";
    i:3;s:3:"114";
  }
}
```

**Translation:**
- Can manage restaurant information
- Has access to **4 specific restaurants**: 72, 87, 93, 114

#### Conclusion
⚠️ **MINOR DATA LOSS** - Darrell exists in V3, but V1 restaurant-specific permissions lost
- V3 account uses V2 group system (group 12 = Vendor)
- V1 granular access to 4 restaurants not preserved

---

## 🔍 DETAILED VERIFICATION NEEDED

### Questions to Answer

#### For Chris Bouziotas:

1. ❓ Are chris.bouziotas@menu.ca and chris@menu.ca the **same person**?
   - Expected: ✅ YES (email domain change)
   
2. ❓ Are chris.bouziotas@menu.ca and cbouzi7039@gmail.com the **same person**?
   - Expected: ✅ YES (work vs personal email)
   
3. ❓ Which email should Chris use going forward?
   - Options: chris@menu.ca (work) OR cbouzi7039@gmail.com (personal)
   
4. ❓ Should we consolidate to one account or keep both?
   - Recommended: Keep both, link as aliases

#### For Darrell Corcoran:

1. ❓ Are darrell@menuottawa.com and darrellcorcoran1967@gmail.com the **same person**?
   - Expected: ✅ YES (company domain vs personal)
   
2. ❓ Does Darrell still need access to those 4 specific restaurants?
   - V1 restaurants: 72, 87, 93, 114
   
3. ❓ Are these V1 restaurant IDs still valid in V3?
   - Action: Map V1 IDs → V3 IDs

---

## 📋 RECOVERY OPTIONS

### Option A: Verification Only (RECOMMENDED)

**Time:** 30 minutes  
**Complexity:** ✅ LOW

**Steps:**
1. Email chris.bouziotas@menu.ca → Tell them to use chris@menu.ca or cbouzi7039@gmail.com
2. Email darrell@menuottawa.com → Tell them to use darrellcorcoran1967@gmail.com
3. Verify Darrell's restaurant access in V3
4. Update documentation to mark as resolved

**Pros:**
- ✅ Fast and simple
- ✅ No code changes needed
- ✅ Accounts already exist in V3

**Cons:**
- ⚠️ Darrell's V1 restaurant-specific access not preserved (V2 group system used instead)

---

### Option B: Granular Permissions Recovery

**Time:** 4-6 hours  
**Complexity:** ⚠️ MEDIUM

**Steps:**
1. Export V1 admin_users permissions BLOB
2. Deserialize PHP arrays (we have experience from Menu & Catalog)
3. Map V1 restaurant IDs to V3 restaurant IDs
4. Create JSONB permissions structure for V3
5. Update V3 admin_users with granular permissions

**Pros:**
- ✅ Preserves granular V1 permissions
- ✅ Can apply to all 13 V1-only admins if needed

**Cons:**
- ⚠️ Requires BLOB deserialization scripts
- ⚠️ V3 may not support same granularity as V1
- ⚠️ Time-consuming

---

### Option C: Manual Recreation

**Time:** 1-2 hours  
**Complexity:** ✅ LOW-MEDIUM

**Steps:**
1. Contact Darrell Corcoran
2. Ask which restaurants he needs access to
3. Manually grant restaurant access in V3
4. Update permissions JSONB

**Pros:**
- ✅ Simple and direct
- ✅ Gets current requirements (not legacy)
- ✅ No BLOB deserialization needed

**Cons:**
- ⚠️ Relies on user remembering their access needs

---

## 🚀 RECOMMENDED APPROACH

### Phase 1: Verification (DO THIS FIRST) ✅

**Email chris.bouziotas@menu.ca:**
```
Subject: Menu.ca Admin Account - Email Update

Hi Chris,

We're completing our database migration to V3. We noticed you have multiple admin accounts:
- chris.bouziotas@menu.ca (V1 - old system)
- chris@menu.ca (V3 - current system)
- cbouzi7039@gmail.com (V3 - current system)

Are these all you? If so, please use one of the V3 accounts going forward:
- chris@menu.ca (recommended for work)
- cbouzi7039@gmail.com (if you prefer personal email)

Your V1 account will be archived.

Thanks,
[Your Name]
```

**Email darrell@menuottawa.com:**
```
Subject: Menu.ca Admin Account - Email Update & Restaurant Access

Hi Darrell,

We're completing our database migration to V3. Your account has moved:
- OLD: darrell@menuottawa.com (V1 - being retired)
- NEW: darrellcorcoran1967@gmail.com (V3 - active)

In V1, you had access to 4 specific restaurants (IDs: 72, 87, 93, 114).

Questions:
1. Are you still managing these restaurants?
2. Do you need access to any additional restaurants?

Please confirm so we can update your V3 permissions.

Thanks,
[Your Name]
```

### Phase 2: Map Restaurant IDs (If Darrell needs them)

Run this query to map V1 → V3 restaurant IDs:

```sql
-- Map V1 restaurant IDs to V3
SELECT 
    v1.id as v1_id,
    v1.name as restaurant_name,
    v3.id as v3_id,
    v3.name as v3_name
FROM menuca_v1.restaurants v1
LEFT JOIN menuca_v3.restaurants v3 ON v1.id = v3.v1_restaurant_id
WHERE v1.id IN (72, 87, 93, 114)
ORDER BY v1.id;
```

### Phase 3: Update V3 Permissions (If needed)

If Darrell needs restaurant-specific access:

```sql
-- Update Darrell's V3 account with restaurant access
UPDATE menuca_v3.admin_users
SET permissions = jsonb_build_object(
    'restaurants', ARRAY[<v3_id1>, <v3_id2>, <v3_id3>, <v3_id4>],
    'can_manage_restaurant_info', true
)
WHERE email = 'darrellcorcoran1967@gmail.com';
```

---

## 📊 OTHER V1-ONLY ADMINS

### Medium Priority (Review Later)

These 4 accounts had recent/moderate activity:

1. **assal@gmail.com**
   - Last login: 2025-07-17
   - Permissions: 1,677 bytes (large)
   - Action: Review if still needed

2. **contact@restozone.ca**
   - Last login: 2025-07-18
   - Permissions: 352 bytes (22 restaurants)
   - Action: Check if vendor account still active

3. **Allout613@alloutburger.com**
   - Last login: 2024-09-26
   - Permissions: 106 bytes (5 restaurants)
   - Action: Check if still needs access

4. **sales@menu.ca**
   - Last login: 2025-07-17
   - Permissions: NONE
   - Action: Archive (no data loss)

### Low Priority (Archive)

These 7 accounts are old (2013-2023) and likely obsolete:
- callcenter@menu.ca (2019)
- alexandra_cc@menu.ca (2025-07-08) - callcenter, no permissions
- m.kassis@live.com (2018)
- corporate@milanopizza.ca (2013)
- mazen-milano@live.com (2022)
- Fouaddaaboul1@yahoo.ca (2022)
- m.lezzeik@gmail.com (2023)

**Action:** Document as intentionally excluded, keep V1 data as archive.

---

## ✅ SUCCESS CRITERIA

**Verification Complete When:**
- [x] Identified potential duplicate accounts in V3
- [ ] Emailed Chris and Darrell to confirm
- [ ] Received confirmation from both
- [ ] Updated Darrell's restaurant access (if needed)
- [ ] Updated documentation

**Data Loss Mitigated When:**
- [ ] Chris confirmed he has access via V3 accounts
- [ ] Darrell confirmed he has access via V3 account
- [ ] Darrell's restaurant permissions restored (if needed)

---

## 📁 FILES TO UPDATE AFTER RECOVERY

### 1. COMPREHENSIVE_DATA_QUALITY_REVIEW.md

Add:
```markdown
### ✅ V1 Admin Recovery Complete

**Finding:** 2 critical V1-only admins were NOT data loss - duplicate accounts exist in V3.

**Chris Bouziotas:**
- V1: chris.bouziotas@menu.ca → V3: chris@menu.ca + cbouzi7039@gmail.com
- Status: ✅ NO DATA LOSS

**Darrell Corcoran:**
- V1: darrell@menuottawa.com → V3: darrellcorcoran1967@gmail.com
- Status: ✅ ACCOUNT EXISTS, ⚠️ restaurant permissions restored manually

**Action:** Marked as resolved.
```

### 2. V1_ADMIN_PERMISSIONS_BLOB_ANALYSIS.md

Update status:
```markdown
**Status:** ✅ RESOLVED - Duplicate accounts confirmed, no data loss
```

### 3. VERIFICATION_RESULTS_FINAL.md

Add final decision section with outcomes.

---

## ⏱️ TIME ESTIMATE

| Phase | Time | Status |
|-------|------|--------|
| Email verification | 30 min | ⏳ Pending |
| Wait for responses | 1-3 days | ⏳ Pending |
| Restaurant ID mapping | 15 min | ⏳ Pending (if needed) |
| Update V3 permissions | 15 min | ⏳ Pending (if needed) |
| Documentation | 30 min | ⏳ Pending |
| **Total** | **1.5-2 hours** + wait time | |

---

## 🎯 DECISION REQUIRED

**What do YOU want to do?**

### Immediate Action (Choose One):

**A)** ✅ **Send verification emails** (RECOMMENDED)
   - I'll draft the emails
   - You send them to Chris and Darrell
   - We wait for confirmation
   - Update docs when confirmed

**B)** ⚠️ **Full BLOB deserialization**
   - Recover all 10 V1 admin permissions
   - Time: 4-6 hours
   - Overkill for 2 likely duplicate accounts

**C)** ✅ **Mark as resolved (assume duplicates)**
   - Document that accounts exist in V3
   - Skip verification
   - Update docs now

---

**My Recommendation:** **Option A** - Send verification emails to Chris and Darrell.

**Rationale:**
- ✅ Chris has 2 V3 accounts (likely duplicates)
- ✅ Darrell has 1 V3 account (likely duplicate)
- ⚠️ Darrell's restaurant access needs verification
- ✅ 30 minutes of work resolves the issue
- ✅ No BLOB deserialization needed

**What would you like to do?**

---

**Status:** 🟡 **AWAITING YOUR DECISION**  
**Next Step:** Choose Option A, B, or C above

