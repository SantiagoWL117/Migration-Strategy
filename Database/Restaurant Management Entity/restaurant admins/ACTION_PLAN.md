# 📋 Action Plan: Post-Migration Data Quality Improvements

**Date:** October 2, 2025  
**Priority:** Medium (Non-Blocking)  
**Estimated Total Effort:** 8-16 hours over 3 months

---

## Quick Reference

| Action | Priority | Effort | Impact | Timeline |
|--------|----------|--------|--------|----------|
| Implement password auto-upgrade | 🟢 HIGH | 2-4h | Security | Immediate |
| Fix 1 invalid email | 🟢 HIGH | 5min | Enable account | Immediate |
| Archive 10+ year old accounts | 🟡 MEDIUM | 1h | Cleanup | This month |
| Review suspended restaurant accounts | 🟡 LOW | 4-8h | Major cleanup | This quarter |

---

## Immediate Actions (This Week)

### Action 1: Implement SHA-1 to Bcrypt Auto-Upgrade ⭐ HIGHEST PRIORITY

**Goal:** Automatically upgrade SHA-1 passwords to bcrypt when users log in

**Implementation:**

```javascript
// Add to your authentication middleware (e.g., Express.js)

const crypto = require('crypto');
const bcrypt = require('bcrypt');

async function authenticateUser(email, password) {
    // Fetch user
    const user = await db.query(
        'SELECT * FROM menuca_v3.restaurant_admin_users WHERE email = $1',
        [email.toLowerCase()]
    );
    
    if (!user) {
        return { success: false, error: 'Invalid credentials' };
    }
    
    // Check if password is SHA-1 (40 hex characters)
    if (user.password_hash.length === 40 && /^[a-f0-9]{40}$/.test(user.password_hash)) {
        // Verify SHA-1 password
        const sha1Hash = crypto.createHash('sha1').update(password).digest('hex');
        
        if (sha1Hash === user.password_hash) {
            // Password correct - upgrade to bcrypt
            const bcryptHash = await bcrypt.hash(password, 12);
            
            await db.query(
                `UPDATE menuca_v3.restaurant_admin_users 
                 SET password_hash = $1, updated_at = now() 
                 WHERE id = $2`,
                [bcryptHash, user.id]
            );
            
            console.log(`[Security] Upgraded SHA-1 password to bcrypt for user ${user.id}`);
            return { success: true, user, passwordUpgraded: true };
        } else {
            return { success: false, error: 'Invalid credentials' };
        }
    }
    
    // Regular bcrypt verification
    const isValid = await bcrypt.compare(password, user.password_hash);
    
    if (isValid) {
        return { success: true, user };
    } else {
        return { success: false, error: 'Invalid credentials' };
    }
}

module.exports = { authenticateUser };
```

**Testing:**
```bash
# Test with a known SHA-1 user (if any attempt to log in)
# Monitor logs for "Upgraded SHA-1 password to bcrypt" messages
```

**Metrics to Track:**
- Number of SHA-1 passwords upgraded per week/month
- Expected: 0-5 upgrades (since all SHA-1 users are inactive)

**Effort:** 2-4 hours  
**Risk:** Low (backward compatible, no breaking changes)  
**Impact:** High (automatic security improvement)

---

### Action 2: Fix Invalid Email for Active Restaurant

**Goal:** Fix the one invalid email for user linked to an active restaurant

**User Details:**
- **User ID:** 280
- **Current Email:** `aaharaltavista`
- **Restaurant:** Aahar The Taste of India (active)
- **Last Login:** 2016-04-07 (never actually logged in)

**Steps:**

1. **Contact Restaurant:**
   ```
   Email/Call: Aahar The Taste of India
   Ask: "What is the correct email address for your admin account?"
   ```

2. **Update Email:**
   ```sql
   -- Once you have the correct email
   UPDATE menuca_v3.restaurant_admin_users
   SET 
       email = 'correct_email@example.com', -- Replace with actual email
       updated_at = now()
   WHERE id = 280;
   ```

3. **Verify:**
   ```sql
   SELECT id, email, first_name, last_name, restaurant_id
   FROM menuca_v3.restaurant_admin_users
   WHERE id = 280;
   ```

**Alternative (if restaurant unreachable):**
```sql
-- Disable the account
UPDATE menuca_v3.restaurant_admin_users
SET 
    is_active = false,
    updated_at = now()
WHERE id = 280;
```

**Effort:** 5 minutes (+ time to contact restaurant)  
**Risk:** None  
**Impact:** Medium (enable account for active restaurant)

---

## Short-term Actions (This Month)

### Action 3: Archive Very Old Inactive Accounts (10+ years)

**Goal:** Clean up 82 accounts inactive since pre-2015

**Affected Users:**
- 82 users with last login before 2015-01-01
- 76 have SHA-1 passwords (never migrated to V2)
- 81 unique restaurants

**Implementation:**

**Step 1: Create Archive Table**
```sql
-- Create archive table if not exists
CREATE TABLE IF NOT EXISTS menuca_v3.restaurant_admin_users_archived (
    LIKE menuca_v3.restaurant_admin_users INCLUDING ALL
);

-- Add archival metadata
ALTER TABLE menuca_v3.restaurant_admin_users_archived
ADD COLUMN IF NOT EXISTS archived_at timestamptz DEFAULT now(),
ADD COLUMN IF NOT EXISTS archived_reason text;
```

**Step 2: Archive Old Accounts**
```sql
-- Archive users inactive for 10+ years
INSERT INTO menuca_v3.restaurant_admin_users_archived
SELECT 
    *,
    now() AS archived_at,
    'Inactive for 10+ years (pre-2015)' AS archived_reason
FROM menuca_v3.restaurant_admin_users
WHERE last_login < '2015-01-01'
  AND is_active = false;

-- Verify count
SELECT COUNT(*) FROM menuca_v3.restaurant_admin_users_archived;
-- Expected: 82
```

**Step 3: Delete from Main Table (OPTIONAL)**
```sql
-- Only run after verifying archive was successful
DELETE FROM menuca_v3.restaurant_admin_users
WHERE last_login < '2015-01-01'
  AND is_active = false;

-- Verify remaining count
SELECT COUNT(*) FROM menuca_v3.restaurant_admin_users;
-- Expected: 357 (439 - 82)
```

**Rollback Plan:**
```sql
-- If needed, restore from archive
INSERT INTO menuca_v3.restaurant_admin_users
SELECT 
    id, uuid, restaurant_id, user_type, first_name, last_name,
    email, password_hash, last_login, login_count, is_active,
    send_statement, created_at, updated_at
FROM menuca_v3.restaurant_admin_users_archived
WHERE archived_reason = 'Inactive for 10+ years (pre-2015)';
```

**Effort:** 1 hour  
**Risk:** Very low (extremely old accounts)  
**Impact:** Medium (reduces user table by 18.7%)

---

## Long-term Actions (This Quarter)

### Action 4: Review Suspended Restaurant Accounts

**Goal:** Clean up 287 inactive users from suspended restaurants

**Affected Users:**
- 287 users from 252 suspended restaurants
- 71% of all inactive users
- 177 last logged in before 2020

**Phased Approach:**

**Phase 1: Review (Week 1-2)**
```sql
-- Generate report of suspended restaurant admins
SELECT 
    au.id,
    au.email,
    au.first_name || ' ' || au.last_name AS name,
    au.last_login,
    au.login_count,
    r.name AS restaurant_name,
    r.status,
    LENGTH(au.password_hash) AS pwd_length,
    CASE 
        WHEN au.last_login < '2015-01-01' THEN 'Very Old (10+ years)'
        WHEN au.last_login < '2020-01-01' THEN 'Old (5+ years)'
        ELSE 'Recent (< 5 years)'
    END AS age_category
FROM menuca_v3.restaurant_admin_users au
JOIN menuca_v3.restaurants r ON r.id = au.restaurant_id
WHERE au.is_active = false
  AND r.status = 'suspended'
ORDER BY au.last_login NULLS LAST
LIMIT 100;

-- Export to CSV for review
\copy (SELECT ...) TO 'suspended_restaurant_admins.csv' CSV HEADER;
```

**Phase 2: Archive by Age (Week 3)**
```sql
-- Archive very old (10+ years) from suspended restaurants
INSERT INTO menuca_v3.restaurant_admin_users_archived
SELECT 
    au.*,
    now() AS archived_at,
    'Suspended restaurant, inactive 10+ years' AS archived_reason
FROM menuca_v3.restaurant_admin_users au
JOIN menuca_v3.restaurants r ON r.id = au.restaurant_id
WHERE au.is_active = false
  AND r.status = 'suspended'
  AND au.last_login < '2015-01-01';

-- Expected: ~150 users
```

**Phase 3: Archive Medium Age (Week 4)**
```sql
-- Archive old (5-10 years) from suspended restaurants
INSERT INTO menuca_v3.restaurant_admin_users_archived
SELECT 
    au.*,
    now() AS archived_at,
    'Suspended restaurant, inactive 5-10 years' AS archived_reason
FROM menuca_v3.restaurant_admin_users au
JOIN menuca_v3.restaurants r ON r.id = au.restaurant_id
WHERE au.is_active = false
  AND r.status = 'suspended'
  AND au.last_login >= '2015-01-01'
  AND au.last_login < '2020-01-01';

-- Expected: ~100 users
```

**Phase 4: Review Recent (Month 2)**
- Review 30-67 users with last login 2020+
- Contact restaurants if reactivation is planned
- Archive if confirmed permanently closed

**Total Cleanup Potential:** 250-287 users (57-65% reduction)

**Effort:** 4-8 hours over 4 weeks  
**Risk:** Low (restaurants already suspended)  
**Impact:** High (major cleanup, reduced database size)

---

## Monitoring & Verification

### Weekly Checks (First Month)

```sql
-- Check 1: Monitor SHA-1 password upgrades
SELECT 
    COUNT(*) FILTER (WHERE LENGTH(password_hash) = 40) AS sha1_remaining,
    COUNT(*) FILTER (WHERE password_hash LIKE '$2%') AS bcrypt_total
FROM menuca_v3.restaurant_admin_users;

-- Check 2: Invalid email status
SELECT COUNT(*) 
FROM menuca_v3.restaurant_admin_users
WHERE email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
-- Expected: 5 → 4 after fixing ID=280

-- Check 3: Inactive user count
SELECT 
    COUNT(*) FILTER (WHERE is_active = false) AS inactive,
    COUNT(*) AS total
FROM menuca_v3.restaurant_admin_users;
-- Track reduction over time
```

### Monthly Reports

```sql
-- Generate monthly data quality report
SELECT 
    'Data Quality Report' AS report,
    COUNT(*) AS total_users,
    COUNT(*) FILTER (WHERE is_active = true) AS active_users,
    COUNT(*) FILTER (WHERE is_active = false) AS inactive_users,
    COUNT(*) FILTER (WHERE LENGTH(password_hash) = 40) AS sha1_passwords,
    COUNT(*) FILTER (WHERE password_hash LIKE '$2%') AS bcrypt_passwords,
    COUNT(*) FILTER (WHERE email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') AS invalid_emails
FROM menuca_v3.restaurant_admin_users;
```

---

## Success Criteria

### Immediate (Week 1)
- [x] SHA-1 auto-upgrade implemented
- [ ] Invalid email for ID=280 fixed

### Short-term (Month 1)
- [ ] SHA-1 password upgrades monitored (if any logins occur)
- [ ] 82 very old accounts archived

### Long-term (Quarter 1)
- [ ] 250+ suspended restaurant accounts archived
- [ ] Inactive user percentage reduced to < 70%
- [ ] All active users have bcrypt passwords

---

## Risk Mitigation

### Backup Strategy

**Before any deletion:**
```sql
-- Full backup of users table
CREATE TABLE menuca_v3.restaurant_admin_users_backup_20251002 AS
SELECT * FROM menuca_v3.restaurant_admin_users;

-- Verify backup
SELECT COUNT(*) FROM menuca_v3.restaurant_admin_users_backup_20251002;
-- Expected: 439
```

### Rollback Procedures

All archival operations use `INSERT INTO archive` + `DELETE FROM main` pattern:
- Archive table preserves all data
- Rollback = `INSERT` back from archive
- Test rollback before large operations

---

## Summary

**Total Effort:** 8-16 hours over 3 months  
**Total Impact:** 
- ✅ 100% of active users will have secure bcrypt passwords
- ✅ Invalid emails reduced by 20% (5 → 4)
- ✅ Database size reduced by 57-65% (439 → 150-189 users)
- ✅ Improved data quality and security posture

**Risk Level:** 🟢 LOW (all actions are reversible with proper backups)

---

**Document Owner:** Santiago  
**Last Updated:** October 2, 2025  
**Next Review:** November 2, 2025


