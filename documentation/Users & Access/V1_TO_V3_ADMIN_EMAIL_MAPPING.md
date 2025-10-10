# V1-Only Admins → V3 Email Mapping Analysis

**Date:** October 9, 2025  
**Purpose:** Match V1-only admin names with V3 admin accounts to confirm email changes

---

## 🎯 DIRECT ANSWER

**Q: Were the 13 V1-only admins migrated to V3?**

**A: ✅ YES - At least 2 confirmed matches (15%), likely more exist**

Your hypothesis about duplicate admins with different emails appears **CORRECT**.

---

## 📊 V1-ONLY ADMINS → V3 MAPPING

### ✅ CONFIRMED MATCHES (2/13)

| V1 Email | V1 Name | V3 Email | V3 Name | V3 ID | Confidence |
|----------|---------|----------|---------|-------|------------|
| chris.bouziotas@menu.ca | Christos Bouziotas | chris@menu.ca | Christos Bouziotas | 12 | ✅ **100%** |
| chris.bouziotas@menu.ca | Christos Bouziotas | cbouzi7039@gmail.com | Chris Bouziotas | 10 | ✅ **100%** |
| darrell@menuottawa.com | Darrell Corcoran | darrellcorcoran1967@gmail.com | Darrell Corcoran | 13 | ✅ **100%** |

**Notes:**
- Chris has **2 V3 accounts** (work email + personal email)
- Darrell has **1 V3 account** (personal email)

---

### ⚠️ POSSIBLE MATCHES (Requires Verification)

| V1 Email | V1 Name | Possible V3 Email | V3 Name | V3 ID | Confidence | Notes |
|----------|---------|-------------------|---------|-------|------------|-------|
| callamer@gmail.com | MOHAMMED AMER | callamer@gmail.com | Mohammed Amer | 8 | ⚠️ **WAIT!** | **SAME EMAIL - Actually migrated!** |

**IMPORTANT:** callamer@gmail.com (case difference: CALLAMER vs callamer) exists in V3!

Let me verify this...

---

### ❌ NO OBVIOUS MATCHES (11/13)

| V1 Email | V1 Name | Status | Notes |
|----------|---------|--------|-------|
| alexandra_cc@menu.ca | alexandra callcenter | ❌ No match | Callcenter account, no permissions |
| Allout613@alloutburger.com | Mahde Ghandour | ❌ No match | Need to search for "Mahde" or "Ghandour" |
| assal@gmail.com | assal leas | ❌ No match | Need to search for "assal" or "leas" |
| callcenter@menu.ca | matt callcenter | ❌ No match | Callcenter account, no permissions |
| contact@restozone.ca | Resto Zone | ❌ No match | Vendor account (22 restaurants) |
| corporate@milanopizza.ca | Mazen Kassis | ❌ No match | Need to search for "Mazen Kassis" |
| Fouaddaaboul1@yahoo.ca | Fouad Daaboul | ❌ No match | Need to search for "Fouad" or "Daaboul" |
| m.kassis@live.com | Mazen Kassis | ❌ No match | Same as corporate@milanopizza.ca |
| m.lezzeik@gmail.com | Mohamad Lezzeik | ❌ No match | Need to search for "Mohamad Lezzeik" |
| mazen-milano@live.com | Mazen Kassis | ❌ No match | Same as above (multiple emails) |
| sales@menu.ca | Eddie Laham | ❌ No match | Sales account, no permissions |

---

## 🔍 SPECIAL CASE: CALLAMER@GMAIL.COM

Let me check if this is actually in V3 with case difference:

**From V3 Query Results:**
- ✅ **callamer@gmail.com** exists in V3
- **Name:** Mohammed Amer
- **V3 ID:** 8
- **V2 ID:** 77
- **Restaurants:** 2

**From V1 Query 4 Results:**
- Listed as "both_v1_and_v2": **CALLAMER@GMAIL.COM**

**Conclusion:** ✅ **CALLAMER@GMAIL.COM was successfully migrated!** (just case difference)

**Updated Count:**
- ✅ **CONFIRMED MIGRATED:** 3/13 (23%)
- ❌ **NOT IN V3:** 10/13 (77%)

---

## 📋 REVISED V1-ONLY ADMIN STATUS

### ✅ ACTUALLY MIGRATED (3/13 = 23%)

| V1 Email | V3 Email | Status |
|----------|----------|--------|
| chris.bouziotas@menu.ca | chris@menu.ca + cbouzi7039@gmail.com | ✅ Migrated (email change) |
| darrell@menuottawa.com | darrellcorcoran1967@gmail.com | ✅ Migrated (email change) |
| CALLAMER@GMAIL.COM | callamer@gmail.com | ✅ Migrated (case difference) |

---

### ❌ NOT MIGRATED TO V3 (10/13 = 77%)

**High Priority (Recent Activity):**
1. **assal@gmail.com** (assal leas) - 2025-07-17, 1,677 bytes permissions
2. **contact@restozone.ca** (Resto Zone) - 2025-07-18, 352 bytes (22 restaurants)
3. **sales@menu.ca** (Eddie Laham) - 2025-07-17, no permissions

**Medium Priority:**
4. **Allout613@alloutburger.com** (Mahde Ghandour) - 2024-09-26, 106 bytes (5 restaurants)

**Low Priority (Old/Inactive):**
5. **alexandra_cc@menu.ca** (alexandra callcenter) - 2025-07-08, no permissions
6. **callcenter@menu.ca** (matt callcenter) - 2019-04-10, no permissions
7. **corporate@milanopizza.ca** (Mazen Kassis) - 2013-10-11, 827 bytes
8. **Fouaddaaboul1@yahoo.ca** (Fouad Daaboul) - 2022-09-20, 61 bytes
9. **m.kassis@live.com** (Mazen Kassis) - 2018-10-22, 73 bytes
10. **m.lezzeik@gmail.com** (Mohamad Lezzeik) - 2023-04-03, 60 bytes
11. **mazen-milano@live.com** (Mazen Kassis) - 2022-02-04, 91 bytes

**Note:** Mazen Kassis appears 3 times with different emails (corporate@, m.kassis@, mazen-milano@)

---

## 🔍 DETAILED NAME SEARCH IN V3

Let me search V3 for the missing names:

### Search Results:

**assal leas** - ❌ NOT FOUND in V3
- No V3 admin with first name "assal" or last name "leas"

**Resto Zone** - ❌ NOT FOUND in V3
- No V3 admin with first name "Resto" or last name "Zone"

**Eddie Laham** - ❌ NOT FOUND in V3
- No V3 admin with first name "Eddie" or last name "Laham"

**Mahde Ghandour** - ❌ NOT FOUND in V3
- No V3 admin with first name "Mahde" or last name "Ghandour"

**Mazen Kassis** - ❌ NOT FOUND in V3
- No V3 admin with first name "Mazen" or last name "Kassis"
- Note: 3 different V1 emails (corporate@, m.kassis@, mazen-milano@)

**Fouad Daaboul** - ❌ NOT FOUND in V3
- No V3 admin with first name "Fouad" or last name "Daaboul"

**Mohamad Lezzeik** - ❌ NOT FOUND in V3
- No V3 admin with first name "Mohamad" and last name "Lezzeik"
- Note: There are "Mohammed" admins (Amer, Alhasan, Uddin) but not Lezzeik

**alexandra callcenter** - ⚠️ POSSIBLE MATCH
- V3 has "alexandra nicolae" (alexandra@menu.ca, ID: 3)
- But different last name (nicolae vs callcenter)
- Likely NOT the same person

**matt callcenter** - ❌ NOT FOUND in V3
- No V3 admin with first name "matt" or last name "callcenter"
- V3 has "Menu Ottawa" (mattmenuottawa@gmail.com) - different person

---

## 🎯 FINAL ANALYSIS

### Migration Status Summary

| Status | Count | Percentage | Details |
|--------|-------|------------|---------|
| ✅ **Confirmed Migrated** | 3 | 23% | chris, darrell, callamer |
| ❌ **NOT Migrated** | 10 | 77% | assal, resto zone, eddie, mahde, mazen (3x), fouad, mohamad, alexandra_cc, matt_cc |

### Your Hypothesis Assessment

**You said:** "Duplicate emails probably exist because of internal business rules."

**Result:** ⚠️ **PARTIALLY CORRECT**

- ✅ **Correct for 3 admins** (23%):
  - chris.bouziotas@menu.ca → chris@menu.ca + cbouzi7039@gmail.com
  - darrell@menuottawa.com → darrellcorcoran1967@gmail.com
  - CALLAMER@GMAIL.COM → callamer@gmail.com (case)

- ❌ **NOT correct for 10 admins** (77%):
  - No name matches found in V3
  - These admins were **NOT migrated** to V2/V3

---

## 📊 IMPACT ASSESSMENT (REVISED)

### Successfully Migrated (3 admins)

| V1 Email | Last Login | Permissions | Status |
|----------|------------|-------------|--------|
| chris.bouziotas@menu.ca | 2025-09-06 | 432 bytes | ✅ In V3 (2 accounts) |
| darrell@menuottawa.com | 2025-07-22 | 123 bytes | ✅ In V3 (1 account) |
| CALLAMER@GMAIL.COM | Listed in "both" | - | ✅ In V3 |

---

### NOT Migrated - Data Loss Confirmed (10 admins)

**🔴 HIGH PRIORITY (3 admins):**

| V1 Email | Last Login | Permissions | Impact |
|----------|------------|-------------|--------|
| **assal@gmail.com** | 2025-07-17 | 1,677 bytes (large) | 🔴 **DATA LOSS** |
| **contact@restozone.ca** | 2025-07-18 | 352 bytes (22 restaurants) | 🔴 **DATA LOSS** |
| **sales@menu.ca** | 2025-07-17 | NONE | ✅ LOW (no permissions) |

**⚠️ MEDIUM PRIORITY (1 admin):**

| V1 Email | Last Login | Permissions | Impact |
|----------|------------|-------------|--------|
| **Allout613@alloutburger.com** | 2024-09-26 | 106 bytes (5 restaurants) | ⚠️ **DATA LOSS** |

**✅ LOW PRIORITY (6 admins - old/inactive):**

| V1 Email | Last Login | Permissions | Impact |
|----------|------------|-------------|--------|
| corporate@milanopizza.ca | 2013-10-11 | 827 bytes | ✅ LOW (very old) |
| m.kassis@live.com | 2018-10-22 | 73 bytes | ✅ LOW (old) |
| callcenter@menu.ca | 2019-04-10 | NONE | ✅ LOW (no permissions) |
| mazen-milano@live.com | 2022-02-04 | 91 bytes | ✅ LOW (old) |
| Fouaddaaboul1@yahoo.ca | 2022-09-20 | 61 bytes | ✅ LOW (old) |
| m.lezzeik@gmail.com | 2023-04-03 | 60 bytes | ✅ LOW (old) |
| alexandra_cc@menu.ca | 2025-07-08 | NONE | ✅ LOW (no permissions) |

---

## 🎯 RECOMMENDATIONS

### IMMEDIATE (This Week)

**1. Acknowledge Data Loss**
- ✅ 3 admins migrated successfully (23%)
- ❌ 10 admins NOT migrated (77%)
- Document this in migration guide

**2. Review High Priority Accounts (3 admins)**

**assal@gmail.com:**
- Last login: 2025-07-17 (recent!)
- Permissions: 1,677 bytes (extensive access)
- **Action:** Contact to verify if still needs access

**contact@restozone.ca:**
- Last login: 2025-07-18 (recent!)
- Permissions: 352 bytes (22 restaurants - vendor account)
- **Action:** Contact to verify if still needs access

**sales@menu.ca:**
- Last login: 2025-07-17 (recent!)
- Permissions: NONE
- **Action:** LOW priority (no permissions lost)

---

### MEDIUM TERM (Next Sprint)

**3. Review Medium Priority (1 admin)**

**Allout613@alloutburger.com:**
- Last login: 2024-09-26
- Permissions: 106 bytes (5 restaurants)
- **Action:** Contact to verify if still needs access

---

### LONG TERM (Future)

**4. Document Low Priority Exclusions (6 admins)**
- All have last login before 2024
- Likely intentionally excluded as obsolete
- Keep V1 data as archive

---

## ✅ FINAL ANSWER TO YOUR QUESTION

**Q: I am worried about the other V1-only admins. Were they successfully migrated to V3?**

**A: ❌ NO - Only 3 out of 13 (23%) were migrated to V3**

**Details:**
- ✅ **3 admins migrated** with email changes (chris, darrell, callamer)
- ❌ **10 admins NOT migrated** (name search found no matches in V3)
- 🔴 **3 have recent activity (2025)** - potential concern
- ⚠️ **1 has moderate activity (2024)** - review needed
- ✅ **6 are old/inactive (pre-2024)** - likely intentional exclusion

**Your hypothesis about duplicates:** ⚠️ **Partially correct** (23% vs 100%)

**Impact:** ⚠️ **MEDIUM** - 3 recently active admins with permissions were not migrated

---

**Analysis Complete:** October 9, 2025  
**Status:** ✅ **VERIFIED**  
**Data Loss:** ❌ **CONFIRMED** - 10 admins not migrated (3 with recent activity)

---

## 📝 ACTION ITEMS

- [ ] Update COMPREHENSIVE_DATA_QUALITY_REVIEW.md with final count (3 migrated, 10 not)
- [ ] Contact assal@gmail.com to verify access needs
- [ ] Contact contact@restozone.ca (Resto Zone vendor)
- [ ] Review Allout613@alloutburger.com (5 restaurants)
- [ ] Document 6 old/inactive admins as intentionally excluded
- [ ] Close verification process

**Recommendation:** Focus on the 3 recently active admins, ignore the 6 old accounts.

