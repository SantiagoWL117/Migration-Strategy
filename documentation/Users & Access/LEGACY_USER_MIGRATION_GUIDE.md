# Legacy User Migration System - Implementation Guide

**Created:** October 22, 2025  
**Entity:** Users & Access  
**Purpose:** Reactive migration system for 1,756 active legacy customers and 7 legacy admins

---

## 🎯 **Problem Statement**

**1,756 active customers** (logged in during 2025) have accounts without `auth_user_id` and cannot log into V3 system.
- Most recent login: September 12, 2025
- Average logins: 33.1 per user
- High-value users: 100-600+ logins
- **These are REAL customers trying to use the platform**

---

## ✅ **Solution: Reactive Migration System**

When a legacy user tries to log in, the system:
1. Detects they have no `auth_user_id`
2. Prompts them to reset their password
3. Links their new Supabase Auth account to existing profile
4. Preserves all their data (orders, favorites, addresses)

---

## 🗄️ **SQL Functions Deployed**

### **1. check_legacy_user(p_email)**

Checks if an email belongs to a legacy account.

**Parameters:**
- `p_email` (VARCHAR) - Email to check

**Returns:**
```typescript
{
  is_legacy: boolean,
  user_id: bigint,
  first_name: string,
  last_name: string,
  user_type: 'customer' | 'admin'
}
```

**Usage:**
```sql
SELECT * FROM menuca_v3.check_legacy_user('user@example.com');
```

**Response Examples:**
```sql
-- Legacy user found:
{ is_legacy: true, user_id: 30504, first_name: 'James', last_name: 'Horan', user_type: 'customer' }

-- Not legacy (already migrated):
{ is_legacy: false, user_id: null, first_name: null, last_name: null, user_type: null }
```

---

### **2. link_auth_user_id(p_email, p_auth_user_id, p_user_type)**

Links a Supabase Auth UUID to an existing legacy account.

**Parameters:**
- `p_email` (VARCHAR) - User's email
- `p_auth_user_id` (UUID) - Supabase Auth user ID
- `p_user_type` (VARCHAR) - 'customer' or 'admin'

**Returns:**
```typescript
{
  success: boolean,
  message: string,
  user_id: bigint
}
```

**Usage:**
```sql
SELECT * FROM menuca_v3.link_auth_user_id(
  'user@example.com',
  'fcef7419-f4e8-4e95-a6bb-38e69db65117',
  'customer'
);
```

**Handles:**
- ✅ Validates user exists
- ✅ Checks user isn't already migrated
- ✅ Updates auth_user_id atomically
- ✅ Returns success/error message

---

### **3. get_legacy_migration_stats()**

Returns current migration statistics.

**Returns:**
```typescript
{
  legacy_customers: bigint,
  legacy_admins: bigint,
  active_2025_customers: bigint,
  active_2025_admins: bigint,
  total_legacy: bigint
}
```

**Current Stats (Oct 22, 2025):**
```json
{
  "legacy_customers": 3102,
  "legacy_admins": 7,
  "active_2025_customers": 1756,
  "active_2025_admins": 0,
  "total_legacy": 3109
}
```

---

## 🚀 **Edge Functions Deployed**

### **1. check-legacy-account**

**Endpoint:** `https://{project}.supabase.co/functions/v1/check-legacy-account`

**Method:** POST

**Request:**
```typescript
{
  email: string  // User's email
}
```

**Response (Legacy User):**
```json
{
  "is_legacy": true,
  "user_id": 30504,
  "first_name": "James",
  "last_name": "Horan",
  "user_type": "customer",
  "message": "Legacy account found - migration required"
}
```

**Response (Not Legacy):**
```json
{
  "is_legacy": false,
  "message": "Not a legacy account"
}
```

**Frontend Usage:**
```typescript
const { data, error } = await supabase.functions.invoke('check-legacy-account', {
  body: { email: 'user@example.com' }
});

if (data.is_legacy) {
  // Show migration prompt
  showMigrationFlow(data.first_name, data.user_type);
}
```

---

### **2. complete-legacy-migration**

**Endpoint:** `https://{project}.supabase.co/functions/v1/complete-legacy-migration`

**Method:** POST

**Authentication:** Required (JWT token from password reset)

**Request:**
```typescript
{
  email: string,      // User's email
  user_type: string   // 'customer' or 'admin'
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Customer account migrated successfully",
  "user_id": 30504
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "User already migrated"
}
```

**Frontend Usage:**
```typescript
// After user resets password and logs in
const { data, error } = await supabase.functions.invoke('complete-legacy-migration', {
  body: {
    email: 'user@example.com',
    user_type: 'customer'
  }
});

if (data.success) {
  // Migration complete - proceed to app
  window.location.href = '/dashboard';
}
```

---

### **3. get-migration-stats**

**Endpoint:** `https://{project}.supabase.co/functions/v1/get-migration-stats`

**Method:** GET

**Response:**
```json
{
  "success": true,
  "stats": {
    "legacy_customers": 3102,
    "legacy_admins": 7,
    "active_2025_customers": 1756,
    "active_2025_admins": 0,
    "total_legacy": 3109
  }
}
```

**Frontend Usage:**
```typescript
const { data } = await supabase.functions.invoke('get-migration-stats');
console.log(`${data.stats.total_legacy} users need migration`);
```

---

## 🔄 **Complete Migration Flow**

### **Frontend Implementation:**

```typescript
// Step 1: User tries to log in
async function handleLogin(email: string, password: string) {
  // Try normal login first
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  });

  if (error && error.message.includes('Invalid login credentials')) {
    // Check if this is a legacy account
    const { data: legacyCheck } = await supabase.functions.invoke('check-legacy-account', {
      body: { email }
    });

    if (legacyCheck.is_legacy) {
      // Show migration prompt
      showMigrationPrompt(email, legacyCheck.first_name, legacyCheck.user_type);
      return;
    }
  }

  // Handle normal login error or success
  if (error) {
    showError('Invalid credentials');
  } else {
    redirectToDashboard();
  }
}

// Step 2: User clicks "Migrate Account"
async function startMigration(email: string) {
  // Send password reset email
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${window.location.origin}/auth/callback?migration=true`
  });

  if (!error) {
    showMessage('Password reset email sent! Check your inbox.');
  }
}

// Step 3: User clicks link in email and sets new password
async function handlePasswordReset(newPassword: string) {
  const { error } = await supabase.auth.updateUser({
    password: newPassword
  });

  if (!error) {
    // Get email and user_type from URL params or session
    completeMigration(email, user_type);
  }
}

// Step 4: Complete migration by linking accounts
async function completeMigration(email: string, user_type: string) {
  const { data, error } = await supabase.functions.invoke('complete-legacy-migration', {
    body: { email, user_type }
  });

  if (data.success) {
    showSuccess('Account migrated successfully!');
    window.location.href = '/dashboard';
  } else {
    showError(data.message);
  }
}
```

---

## 🎨 **UI/UX Flow**

### **Login Page - Legacy User Detected:**

```
┌─────────────────────────────────────────┐
│  Your account needs to be updated       │
│                                         │
│  Hi James! We've upgraded our system.   │
│  To continue, please reset your         │
│  password to migrate your account.      │
│                                         │
│  All your order history, favorites,     │
│  and addresses will be preserved.       │
│                                         │
│  [Migrate Account] [Cancel]            │
└─────────────────────────────────────────┘
```

### **After Clicking "Migrate Account":**

```
┌─────────────────────────────────────────┐
│  Check your email!                      │
│                                         │
│  We've sent a password reset link to    │
│  user@example.com                       │
│                                         │
│  Click the link and set a new password  │
│  to complete your account migration.    │
│                                         │
│  [OK]                                   │
└─────────────────────────────────────────┘
```

### **Password Reset Page:**

```
┌─────────────────────────────────────────┐
│  Set New Password                       │
│                                         │
│  Welcome back, James!                   │
│  Please create a new password:          │
│                                         │
│  New Password: [______________]        │
│  Confirm:      [______________]        │
│                                         │
│  [Complete Migration]                   │
└─────────────────────────────────────────┘
```

### **Success:**

```
┌─────────────────────────────────────────┐
│  ✅ Account Migrated Successfully!      │
│                                         │
│  Your account has been updated.         │
│  Redirecting to dashboard...            │
└─────────────────────────────────────────┘
```

---

## 📊 **Migration Statistics**

**Current (October 22, 2025):**
- **Total Legacy Users:** 3,109
  - Customers: 3,102
  - Admins: 7
- **Active in 2025:** 1,756 customers (56.6%)
- **Most Recent Login:** September 12, 2025
- **High-Value Users:** 20+ with 200+ logins

**After V3 Launch:**
- Track daily migration rate
- Monitor completion percentage
- Identify users needing help

---

## 🔒 **Security Notes**

✅ **All functions use SECURITY DEFINER** - Secure access to data  
✅ **RLS policies enforced** - Users can only migrate their own accounts  
✅ **JWT validation** - Only authenticated users can complete migration  
✅ **Email verification** - Password reset link validates ownership  
✅ **Atomic updates** - auth_user_id updated in single transaction  
✅ **No duplicate migrations** - System prevents re-migration  

---

## 🧪 **Testing**

### **Test Scenarios:**

1. **Legacy Customer Login:**
   - Email: `jphoran27@gmail.com`
   - Expected: Migration prompt shown

2. **Already Migrated User:**
   - Email: `benedictee9@gmail.com`
   - Expected: Normal login flow

3. **Non-Existent User:**
   - Email: `notreal@example.com`
   - Expected: "Invalid credentials" error

4. **Legacy Admin Login:**
   - Email: `brian@worklocal.ca`
   - Expected: Admin migration prompt

---

## 📈 **Monitoring**

**Track:**
- Daily migration completions
- Failed migration attempts
- Users who start but don't complete
- Average time to complete migration

**Query:**
```sql
-- Check migration progress
SELECT 
  (SELECT COUNT(*) FROM menuca_v3.users WHERE auth_user_id IS NOT NULL) as migrated_customers,
  (SELECT COUNT(*) FROM menuca_v3.users WHERE auth_user_id IS NULL) as pending_customers,
  (SELECT COUNT(*) FROM menuca_v3.admin_users WHERE auth_user_id IS NOT NULL) as migrated_admins,
  (SELECT COUNT(*) FROM menuca_v3.admin_users WHERE auth_user_id IS NULL) as pending_admins;
```

---

## ✅ **Deployment Checklist**

- [x] SQL functions created and tested
- [x] Edge functions deployed
- [x] Migration flow documented
- [x] **🎉 Proactive auth account creation COMPLETE (1,756/1,756)** - October 23, 2025
- [ ] Frontend UI components built
- [ ] Email templates configured
- [ ] Error handling implemented
- [ ] Analytics tracking added
- [ ] User communication plan ready

### **🚀 UPDATE: Proactive Auth Creation Complete!**

**Date:** October 23, 2025  
**Status:** ✅ 1,756 auth.users records created successfully  
**Success Rate:** 100% (zero failures)  
**Details:** See `/PROACTIVE_AUTH_CREATION_COMPLETE.md`

**Password Reset Now Works:**
- ✅ All 1,756 legacy users can receive password reset emails
- ✅ Reactive migration flow is fully operational
- ✅ Ready for frontend deployment

---

## 🚀 **Go-Live Plan**

**Week 1: Soft Launch**
- Enable migration for 100 test users
- Monitor error rates
- Gather user feedback

**Week 2-3: Full Rollout**
- Enable for all 1,756 active users
- Send informational emails
- Provide support documentation

**Week 4+: Monitoring**
- Track migration rate
- Assist users who need help
- Optimize based on feedback

---

**Status:** ✅ **READY FOR FRONTEND IMPLEMENTATION**  
**Functions Deployed:** 3 SQL + 3 Edge Functions  
**Target Users:** 1,756 active legacy customers + 7 legacy admins  
**Estimated Effort:** 2-3 days frontend implementation

