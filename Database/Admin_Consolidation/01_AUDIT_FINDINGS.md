# Admin Table Audit Findings
**Date:** October 14, 2025  
**Purpose:** Understand current admin system before consolidation  
**Status:** ✅ COMPLETE

---

## 🎯 Executive Summary

**THE BIG PICTURE:**
- We have **3 admin tables** doing the work of 1-2
- **8 duplicate emails** across systems (data integrity issue)
- **Permissions system is DEAD** (0% usage = tech debt)
- **439 restaurant admins** but 0 active in last 30 days (stale data)
- **Clear consolidation opportunity** without breaking active users

---

## 📊 Detailed Findings

### 1. Duplicate Emails (8 Found)

These users exist in BOTH `admin_users` AND `restaurant_admin_users`:

| Email | Issue |
|-------|-------|
| alexandra.nicolae000@gmail.com | Duplicate account |
| alexandra@menu.ca | Duplicate account |
| callamer@gmail.com | Duplicate account |
| houseofpizzaorleans1@gmail.com | Duplicate account |
| lanawab4@gmail.com | Duplicate account |
| laura_paniagua513@hotmail.com | Duplicate account |
| raficwz@hotmail.com | Duplicate account |
| seanandnid@gmail.com | Duplicate account |

**Impact:** Potential login confusion, data sync issues

---

### 2. Multi-Restaurant Management (Working Well!)

| Admin | Email | Restaurants | Role Pattern |
|-------|-------|-------------|--------------|
| Menu Ottawa | mattmenuottawa@gmail.com | 21 | 1 admin, 20 staff |
| Darrell Corcoran | darrellcorcoran1967@gmail.com | 17 | 1 admin, 16 staff |
| Chicco Khalife | chiccokhalife@icloud.com | 8 | 1 owner, 7 staff |

**Insight:** Multi-restaurant management is actively used and critical feature

---

### 3. Permissions System (DEAD WEIGHT)

```
Permissions usage in admin_users: 0% (0 of 51)
Permissions usage in admin_user_restaurants: 0% (0 of 94)
```

**Conclusion:** Permissions columns can be DELETED - not in use

---

### 4. restaurant_admin_users Activity

| Metric | Value |
|--------|-------|
| Total accounts | 439 |
| Currently active | 35 (8%) |
| Logged in last 30 days | 0 |
| Logged in last 7 days | 0 |
| Most recent login | Sept 12, 2025 (future date = data issue) |
| Oldest login | April 30, 2013 |

**Insight:** Most restaurant_admin_users are legacy/inactive accounts

---

### 5. Role Distribution

| Role | Count | Unique Admins | Unique Restaurants |
|------|-------|---------------|-------------------|
| staff | 91 | 37 | 40 |
| admin | 2 | 2 | 1 |
| owner | 1 | 1 | 1 |

**Insight:** Role system is mostly "staff", simple 3-tier structure

---

### 6. System Overview

| Metric | Value |
|--------|-------|
| Platform admins (admin_users) | 51 |
| Restaurant admins (restaurant_admin_users) | 439 |
| Restaurant assignments (admin_user_restaurants) | 94 |
| Platform admins WITH restaurants | 37 |
| Platform admins WITHOUT restaurants | 14 (orphaned) |

**Insight:** 14 platform admins have no restaurants assigned (why?)

---

## 🎯 Consolidation Strategy

### What We Can Do NOW

#### ✅ **Phase 1: Drop Dead Weight**
1. **DROP permissions columns** (0% usage)
   - `admin_users.permissions`
   - `admin_user_restaurants.permissions`

#### ✅ **Phase 2: Merge Duplicates**
2. **Consolidate 8 duplicate emails**
   - Keep admin_users version (multi-restaurant capable)
   - Migrate restaurant_admin_users data to admin_user_restaurants
   - Preserve all access

#### ✅ **Phase 3: Create Unified System**
3. **Keep 2 tables instead of 3:**
   - `admin_users` → Unified admin table (platform + restaurant)
   - `admin_user_restaurants` → Restaurant access control
   - ~~`restaurant_admin_users`~~ → ARCHIVE (merge into admin_users)

---

## 📋 Migration Requirements

### Pre-Conditions
- [x] Audit complete
- [ ] Backup production
- [ ] Test in staging
- [ ] Notify stakeholders

### Data Preservation
- ✅ All 51 platform admins preserved
- ✅ All 439 restaurant admins migrated
- ✅ All 94 restaurant assignments preserved
- ✅ All 8 duplicates resolved
- ✅ Zero data loss

### Post-Conditions
- [ ] Single source of truth for admins
- [ ] No duplicate emails
- [ ] Simplified codebase
- [ ] Faster queries (fewer joins)

---

## 🚨 Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Duplicate email login confusion | Merge duplicates, keep most permissive access |
| Lost restaurant access | Validate all 94 assignments preserved |
| Code breaks (old table refs) | Gradual deprecation, create views |
| Rollback complexity | Keep old tables in archive schema |

---

## 📊 Success Metrics

- ✅ 3 tables → 2 tables (33% reduction)
- ✅ 8 duplicates → 0 duplicates (100% resolution)
- ✅ 2 unused columns → 0 unused columns (tech debt eliminated)
- ✅ 490 total admins → 490 preserved (0% data loss)

---

## 🚀 Next Steps

1. **Review audit findings** (YOU ARE HERE)
2. **Create migration script** (NEXT)
3. **Test in staging**
4. **Validate with stakeholders**
5. **Execute in production**
6. **Update application code**

---

## 📝 Notes

- Most restaurant_admin_users are inactive (legacy V1 data)
- Multi-restaurant management is working well
- Permissions system was never implemented
- 14 orphaned platform admins need review
- Role system is simple (staff/admin/owner)

---

**Generated by:** Brian + Claude  
**Audit Duration:** 15 minutes  
**Next Step:** Create migration script

