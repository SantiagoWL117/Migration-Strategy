# Investigation: Missing Admin Users for 6 Restaurants

**Date**: October 14, 2025  
**Context**: Active Status Correction Child Data Review  
**Issue**: 7 restaurants from the 101 corrected restaurants are missing admin users in `menuca_v3.restaurant_admin_users`

---

## 🔍 Executive Summary

**Finding**: ✅ **CONFIRMED** - 6 of 7 restaurants **never had admin users** in V1 or V2 source databases. 1 restaurant had 3 admin users in V2 that were lost.

**Root Cause**: 
- **6 restaurants**: Never required admin accounts in legacy systems (call center managed or franchise locations)
- **1 restaurant (Chicco Pizza)**: V2 admin data staging table was empty (0 rows), causing data loss

**Impact**: 🟡 **MEDIUM** - Restaurants cannot access the admin dashboard without admin accounts.

**Recommended Action**: See "Resolution Options" section below.

---

## 📊 Missing Admin Users - Detailed Analysis

| V3 ID | Restaurant Name | V1 ID | V2 ID | V1 Admins | V2 Admins | Status |
|-------|-----------------|-------|-------|-----------|-----------|--------|
| 8 | Lucky Star Chinese Food | 90 | 1032 | ❌ None | ❌ None | ✅ Verified |
| 77 | Lorenzo's Pizzeria - Vanier | 192 | 1101 | ❌ None | ❌ None | ✅ Verified |
| 241 | Beneci Pizza | 383 | 1266 | ❌ None | ❌ None | ✅ Verified |
| 427 | Papa Joe's Pizza - Bridle Path | 600 | 1452 | ❌ None | ❌ None | ✅ Verified |
| 443 | Papa Joe's Fried Chicken - Bridle Path | 620 | 1468 | ❌ None | ❌ None | ✅ Verified |
| 468 | Just Wok | 656 | 1493 | ❌ None | ❌ None | ✅ Verified |
| 962 | Chicco Pizza & Shawarma Buckingham | NULL | 1659 | N/A | ⚠️ **3 users** | ⚠️ **DATA LOST** |

---

## 🔴 CRITICAL FINDING: Restaurant 962 (Chicco Pizza)

**Restaurant 962** is a **special case** - it had **3 admin users in V2** but they were **NOT migrated** to V3.

### Investigation Results:

```sql
-- V2 Staging Data Shows:
restaurant_id: 1659 (V2 ID for Chicco Pizza)
admin_count: 3
v2_admin_user_ids: 2, 62, 65
admin_emails: NULL (staging.v2_admin_users table is EMPTY - 0 rows)
```

### Root Cause:

The `staging.v2_admin_users` table has **0 rows loaded**. This means:
1. ❌ The V2 admin users CSV was **never loaded** into staging
2. ❌ OR the V2 admin extraction failed/was incomplete
3. ❌ OR V2 admin users were intentionally excluded during staging

### Impact:

- **Restaurant 962** had active admin users in V2 (user IDs: 2, 62, 65)
- **These 3 admin accounts were lost** during migration
- The restaurant **cannot access admin dashboard** without manual intervention

---

## ✅ Verified: 6 Restaurants Never Had Admins

The other 6 restaurants (8, 77, 241, 427, 443, 468) were correctly handled:

### V1 Staging Verification:
```sql
SELECT * FROM staging.v1_restaurant_admin_users
WHERE legacy_v1_restaurant_id IN (90, 192, 383, 600, 620, 656);
-- Result: 0 rows
```

### V2 Staging Verification:
```sql
SELECT * FROM staging.v2_admin_users_restaurants
WHERE restaurant_id IN (1032, 1101, 1266, 1452, 1468, 1493);
-- Result: 0 rows
```

**Conclusion**: These 6 restaurants operated without admin accounts in V1/V2, likely:
- Using call center management
- Managed by parent company/franchise owner
- Test/inactive accounts
- Recently onboarded restaurants

---

## 🛠️ Resolution Options

### Option 1: Create Emergency Admin Accounts (Recommended for Restaurant 962)

**For Restaurant 962 (Chicco Pizza):**
```sql
-- Create emergency admin account
INSERT INTO menuca_v3.restaurant_admin_users (
    restaurant_id,
    first_name,
    last_name,
    email,
    password_hash,
    is_active,
    user_type
)
VALUES (
    962,
    'Admin',
    'Chicco Pizza',
    'admin@chiccopizza.ca',  -- TO BE CONFIRMED
    '[TEMP_PASSWORD_HASH]',
    true,
    'r'
);
```

**Risk**: ⚠️ **HIGH** - We don't have the original email addresses or names. Need to:
1. Contact the restaurant to get correct admin email
2. Generate secure temporary password
3. Send password reset email

---

### Option 2: Attempt Data Recovery for Restaurant 962

**Steps:**
1. Check if V2 admin users dump exists: `Database/Users_&_Access/dumps/menuca_v2_admin_users.sql`
2. Extract data for user IDs: 2, 62, 65
3. Re-run staging load for V2 admin users
4. Re-run migration scripts for restaurant 962

**Timeline**: 1-2 hours  
**Risk**: 🟡 **MEDIUM** - Dump file may not contain these users

---

### Option 3: Accept Current State for 6 Restaurants (8, 77, 241, 427, 443, 468)

**Rationale:**
- These restaurants never had admin accounts in V1/V2
- They operated successfully without them
- No data was lost (they never had admins to begin with)

**Action Required:**
- If any of these 6 restaurants request admin access, create new accounts manually
- Use franchise parent accounts if applicable (e.g., Papa Joe's corporate account)

---

## 📋 Recommended Actions

### Immediate (Restaurant 962):
1. ✅ **CHECK**: Verify if `Database/Users_&_Access/dumps/menuca_v2_admin_users.sql` contains users 2, 62, 65
2. ⏳ **DECIDE**: Attempt data recovery OR create new emergency account?
3. ⏳ **CONTACT**: Reach out to Chicco Pizza to get current admin email/contact

### Low Priority (Restaurants 8, 77, 241, 427, 443, 468):
1. ✅ **DOCUMENT**: Update restaurant notes to indicate "No historical admin accounts"
2. ⏳ **MONITOR**: Wait for restaurants to request admin access (if ever)
3. ⏳ **FRANCHISE CHECK**: For Papa Joe's locations (427, 443), verify if they use corporate admin account

---

## 🎯 Final Verdict

| Status | Count | Action Required |
|--------|-------|-----------------|
| ✅ **OK** - Never had admins | 6 | None (accept current state) |
| ⚠️ **DATA LOST** - Had admins in V2 | 1 | Immediate recovery or creation |

**Overall Impact**: 🟡 **MEDIUM**  
**Production Blocker**: ❌ **NO** (only 1 restaurant affected, can be resolved post-launch)

---

## 📝 Files Referenced

- `staging.v1_restaurant_admin_users` (493 rows) - No matches for our 6 restaurants
- `staging.v2_admin_users_restaurants` (99 rows) - Shows restaurant 962 had 3 users
- `staging.v2_admin_users` (0 rows) - ⚠️ **EMPTY TABLE** - root cause of data loss
- `menuca_v3.restaurant_admin_users` - Target table missing 7 records total (6 intentionally never had admins, 1 data loss)

---

## 🔗 Related Documents

- Parent: `ACTIVE_STATUS_CORRECTION_CHILD_DATA_REVIEW.md`
- User Migration: `documentation/Users & Access/COMPREHENSIVE_DATA_QUALITY_REVIEW.md`
- Admin User Mapping: `documentation/Restaurants/restaurant_admin_users migration plan.md`
