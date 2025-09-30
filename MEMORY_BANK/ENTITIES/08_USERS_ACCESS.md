# Users & Access Entity

**Status:** ⏳ NOT STARTED - READY TO BEGIN ✅  
**Priority:** HIGH  
**Developer:** Available for assignment

---

## 📊 Entity Overview

**Purpose:** Customer accounts, admin users, authentication, and user delivery addresses

**Scope:** User management, authentication, authorization, and user preferences

**Dependencies:** Location & Geography (for user addresses) ✅ COMPLETE

**Blocks:** Orders & Checkout (needs user accounts)

---

## 📋 Tables in Scope (Estimated)

Based on V1/V2 analysis, likely tables:

### Customer Accounts
- `site_users` - Customer accounts
- `site_users_delivery_addresses` - Saved delivery addresses (needs cities/provinces ✅)
- `site_users_favorite_restaurants` - User favorites
- `site_users_recent_orders` or similar

### Admin Access
- `admin_users` - Platform administrator accounts
- `admin_roles` or `admin_permissions` - Role-based access control
- `admin_sessions` - Admin login sessions

### Authentication
- Password reset tokens
- Email verification
- Session management

---

## 🎯 Why This Entity Next?

**Advantages:**
1. ✅ **Not blocked** - Location & Geography complete
2. ✅ **High priority** - Needed for Orders & Checkout
3. ✅ **Clear scope** - Well-defined tables
4. ✅ **Independent** - Can work while Restaurant Management completes

**Dependencies Status:**
- ✅ provinces table (DONE)
- ✅ cities table (DONE)
- ❌ restaurants table (for favorites) - IN PROGRESS (can defer this)

---

## 📁 Files to Create

1. `users-access-mapping.md` - Source to target field mapping
2. `site_users_migration_plan.md` - Customer accounts ETL plan
3. `admin_users_migration_plan.md` - Admin accounts ETL plan
4. `user_addresses_migration_plan.md` - User addresses ETL plan
5. Additional plans based on table discovery

---

## 🔍 Analysis Needed

### Step 1: Schema Review
- Read menuca_v1_structure.sql for user-related tables
- Read menuca_v2_structure.sql for user-related tables
- Identify all tables in scope

### Step 2: Data Assessment
- Determine V1 vs V2 authoritative sources
- Check for password hashing algorithms
- Understand user roles and permissions
- Analyze address storage format

### Step 3: Create Mapping
- Map V1/V2 fields to menuca_v3 schema
- Document transformations needed
- Identify data quality issues

---

## 🔗 Dependencies

**Required (Completed):**
- ✅ Location & Geography (for user_delivery_addresses)

**Optional (Can defer):**
- 🔄 Restaurant Management (for favorite_restaurants FK)

**Blocks (Waiting on this entity):**
- ⏳ Orders & Checkout

---

**Status:** Ready to start. Recommended as next entity.
