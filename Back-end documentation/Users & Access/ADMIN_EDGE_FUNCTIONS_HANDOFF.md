# Admin User Management Edge Functions - Handoff Document

**Date**: 2025-10-30
**Status**: ✅ Production Ready
**Developer**: Claude Code Agent
**Reviewed By**: Santiago Garcia

---

## 📋 Executive Summary

This document provides a comprehensive overview of the admin user management Edge Functions implemented in Supabase. Two Edge Functions have been developed and deployed to enable secure admin user creation and restaurant assignment management.

### What Was Accomplished

1. ✅ Implemented JWT-based authentication for Edge Functions
2. ✅ Created role-based access control (Super Admin only)
3. ✅ Deployed `create-admin-user` Edge Function with full validation
4. ✅ Documented existing `assign-admin-restaurants` Edge Function
5. ✅ Created two Super Admin accounts (Santiago & Brian)
6. ✅ Comprehensive testing and security validation

---

## 🎯 Edge Functions Overview

### 1. create-admin-user

**Purpose**: Allows Super Admin users to create new admin users with proper authentication and role assignment.

**Endpoint**: `https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/create-admin-user`

**Status**: 🟢 ACTIVE (Version 19)

**Deployment Date**: 2025-10-30 18:45:25 UTC

**Location**: `supabase/functions/create-admin-user/index.ts`

#### Authentication & Authorization

- **Authentication Method**: JWT Bearer Token
- **Authorization Level**: Super Admin Only (role_id = 1)
- **JWT Validation**: Uses Supabase's `auth.getUser()` method
- **Security Checks**:
  1. Validates JWT token is present and valid
  2. Extracts calling user's ID from JWT
  3. Queries `menuca_v3.admin_users` to verify user has role_id = 1
  4. Validates user status is 'active'
  5. Only proceeds if all checks pass

#### Request Format

```typescript
POST /functions/v1/create-admin-user
Headers:
  Authorization: Bearer <USER_JWT_TOKEN>
  Content-Type: application/json

Body:
{
  "email": "newadmin@worklocal.ca",        // Required
  "password": "securePassword123*",        // Required (min 8 chars)
  "first_name": "John",                    // Required
  "last_name": "Doe",                      // Required
  "role_id": 2,                            // Optional (defaults to table default)
  "restaurant_ids": [349, 350],            // Optional (array of restaurant IDs)
  "mfa_enabled": false                     // Optional (defaults to false)
}
```

#### Response Format

**Success (201):**
```json
{
  "success": true,
  "admin_user_id": 935,
  "auth_user_id": "87cc02fd-a72d-46bb-acb8-fda5dd83f209",
  "email": "newadmin@worklocal.ca",
  "restaurants_assigned": 2,
  "message": "Admin user created successfully with 2 restaurant(s)"
}
```

**Error (401/403/400/500):**
```json
{
  "success": false,
  "error": "Super Admin role required",
  "details": "Only Super Admins can create admin users"
}
```

#### Functionality

**STEP 1: JWT Validation & Role Check**
- Validates calling user's JWT token
- Checks if user has Super Admin role (role_id = 1)
- Validates user account is active

**STEP 2: Input Validation**
- Email format validation (regex)
- Password strength check (minimum 8 characters)
- Required field validation (email, password, first_name, last_name)

**STEP 3: Create Auth User**
- Creates record in `auth.users` table using Supabase Auth Admin API
- Stores first_name, last_name in user_metadata
- Sets email_confirm: true (no email verification needed)
- Adds metadata: is_admin=true, created_via='admin-portal'

**STEP 4: Create Admin User Record**
- Inserts record into `menuca_v3.admin_users` table
- Links to auth.users via auth_user_id
- Sets role_id (if provided, otherwise uses table default)
- Sets status to 'active' by default
- Sets mfa_enabled flag

**STEP 5: Assign Restaurants (Optional)**
- Validates restaurant IDs exist in `menuca_v3.restaurants`
- Creates records in `menuca_v3.admin_user_restaurants` junction table
- Returns count of successfully assigned restaurants

**STEP 6: Error Handling & Rollback**
- If admin_users insert fails, automatically deletes the auth.users record
- Ensures data consistency (no orphaned auth users)
- Returns detailed error messages for debugging

#### Error Codes

| Code | Error | Description |
|------|-------|-------------|
| 401 | Missing authorization header | No JWT token provided |
| 401 | Invalid token | JWT token is malformed or expired |
| 403 | User is not an admin | Calling user not found in admin_users table |
| 403 | Admin account not active | Calling user's status is not 'active' |
| 403 | Super Admin role required | Calling user's role_id is not 1 |
| 400 | Missing required fields | email, password, first_name, or last_name missing |
| 400 | Invalid email format | Email does not match regex pattern |
| 400 | Password must be at least 8 characters | Password too short |
| 500 | Failed to create auth user | Supabase Auth API error (usually duplicate email) |
| 500 | Failed to create admin user record | Database insert error |

#### Key Implementation Details

**Variable Naming Convention:**
- `callingUserId` - The Super Admin user invoking the function
- `newAuthUserId` - The auth user ID of the newly created admin
- `adminUserId` - The admin_users table ID of the newly created admin

**Type Definitions:**
```typescript
interface CreateAdminRequest {
  email: string;
  password: string;
  first_name: string;
  last_name: string;
  role_id?: number;
  restaurant_ids?: number[];
  mfa_enabled?: boolean;
}

interface CreateAdminResponse {
  success: boolean;
  admin_user_id?: number;
  auth_user_id?: string;
  email?: string;
  restaurants_assigned?: number;
  error?: string;
  details?: string;
}
```

---

### 2. assign-admin-restaurants

**Purpose**: Allows admins to manage restaurant assignments for admin users (add, remove, or replace).

**Endpoint**: `https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/assign-admin-restaurants`

**Status**: 🟢 ACTIVE (Version 5)

**Location**: `supabase/functions/assign-admin-restaurants/index.ts`

#### Authentication & Authorization

- **Authentication Method**: Service Role Key (in Authorization header)
- **Authorization Level**: Service Role Only
- **Security Check**: Validates service role key is included in Authorization header

#### Request Format

```typescript
POST /functions/v1/assign-admin-restaurants
Headers:
  Authorization: Bearer <SERVICE_ROLE_KEY>
  Content-Type: application/json

Body:
{
  "admin_user_id": 932,              // Required
  "restaurant_ids": [349, 350, 351], // Required (array of restaurant IDs)
  "action": "add"                    // Required: "add" | "remove" | "replace"
}
```

#### Actions Explained

| Action | Description |
|--------|-------------|
| **add** | Adds new restaurant assignments (ignores duplicates) |
| **remove** | Removes specific restaurant assignments |
| **replace** | Removes ALL existing assignments and adds new ones |

#### Response Format

**Success (200):**
```json
{
  "success": true,
  "action": "add",
  "admin_user_id": 932,
  "admin_email": "santiago@worklocal.ca",
  "assignments_before": 2,
  "assignments_after": 5,
  "affected_count": 3,
  "message": "Successfully added 3 restaurant assignment(s) for santiago@worklocal.ca"
}
```

#### Functionality

**STEP 1: Validate Admin User**
- Checks admin_user_id exists in `menuca_v3.admin_users`
- Validates user is not deleted (deleted_at IS NULL)
- Validates user status is 'active'
- Gets current assignment count

**STEP 2: Validate Restaurants**
- Checks all restaurant_ids exist in `menuca_v3.restaurants`
- Filters out deleted restaurants (deleted_at IS NULL)
- Returns count of valid restaurants found

**STEP 3: Perform Action**
- **ADD**: Inserts new assignments (duplicate constraint prevents re-adding same restaurant)
- **REMOVE**: Deletes specified assignments
- **REPLACE**: Deletes all existing assignments, then inserts new ones

**STEP 4: Return Results**
- Returns before/after assignment counts
- Returns count of affected assignments
- Includes admin email for confirmation

---

## 👥 Super Admin Accounts

Two Super Admin accounts were created during implementation:

### Santiago Garcia
- **Email**: `santiago@worklocal.ca`
- **Password**: `WL2129925*` (user-provided)
- **Role**: Super Admin (role_id = 1)
- **Admin ID**: 932
- **Auth UUID**: `d0a48b93-9ba9-4020-9813-894f5ccdab02`
- **Status**: Active
- **Created**: 2025-10-30

### Brian Lapp
- **Email**: `brian@worklocal.ca`
- **Password**: `brianpassword123*` (user-provided)
- **Role**: Super Admin (role_id = 1)
- **Admin ID**: 7
- **Auth UUID**: `f0803a11-0fa1-45e1-b6c9-846651863467`
- **Status**: Active
- **Updated**: 2025-10-30 (promoted from Restaurant Manager)

---

## 🧪 Testing Performed

### Security Testing

✅ **Test 1: Super Admin Can Create Users**
- Santiago (Super Admin) successfully created test admin users
- JWT validation passed
- Role check passed
- Database records created correctly

✅ **Test 2: Non-Super Admin Is Blocked**
- Manager role (role_id = 2) was blocked with "Super Admin role required"
- Security validation working as expected

✅ **Test 3: Unauthorized Access Blocked**
- Request without JWT token rejected with 401 error
- Request with invalid/expired token rejected

✅ **Test 4: Input Validation**
- Missing required fields rejected with 400 error
- Invalid email format rejected
- Weak password (< 8 chars) rejected

✅ **Test 5: Rollback on Failure**
- Duplicate email properly rejected
- No orphaned auth users created
- Data consistency maintained

✅ **Test 6: Restaurant Assignment**
- Valid restaurant IDs successfully assigned
- Invalid restaurant IDs filtered out
- Junction table records created correctly

### Functional Testing

✅ **Test 7: Complete User Creation Flow**
- Auth user created in auth.users
- Admin user created in menuca_v3.admin_users
- User can login with created credentials
- User metadata stored correctly

✅ **Test 8: Both Super Admins Verified**
- Santiago can login and call admin functions
- Brian can login and call admin functions
- Both have correct role_id = 1

---

## 🔧 Debugging Process

### Issues Encountered and Resolved

#### Issue 1: Variable Name Collision (Primary Issue)
**Problem**: Variable `authUserId` was declared twice:
- Once for the calling Super Admin user
- Once for the newly created admin user

**Symptom**: `BOOT_ERROR` when invoking Edge Function

**Solution**: Renamed variables for clarity:
- `callingUserId` - The Super Admin calling the function
- `newAuthUserId` - The newly created user's auth ID

#### Issue 2: Manual JWT Decoding
**Problem**: Attempted manual JWT decoding using `atob()` with base64url handling

**Symptom**: Complex, error-prone code that was unreliable

**Solution**: Used Supabase's built-in `auth.getUser(token)` method instead
- More reliable
- Properly validates JWT signatures
- Simpler code

#### Issue 3: Complex Code Structure
**Problem**: Multiple client instantiations and nested validation logic

**Solution**: Streamlined implementation:
- Single Supabase admin client created at top
- Clear, linear flow
- Proper error handling at each step

---

## 📝 Usage Examples

### Example 1: Create Manager Role Admin

```bash
# Step 1: Login as Super Admin
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/auth/v1/token?grant_type=password" \
  -H "apikey: eyJhbGc..." \
  -H "Content-Type: application/json" \
  -d '{
    "email": "santiago@worklocal.ca",
    "password": "WL2129925*"
  }'

# Response includes: access_token

# Step 2: Create new admin user
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/create-admin-user" \
  -H "Authorization: Bearer <access_token_from_step_1>" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "manager@worklocal.ca",
    "password": "SecurePass123*",
    "first_name": "John",
    "last_name": "Manager",
    "role_id": 2
  }'
```

### Example 2: Create Support Admin with Restaurants

```bash
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/create-admin-user" \
  -H "Authorization: Bearer <super_admin_jwt>" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "support@worklocal.ca",
    "password": "SecurePass123*",
    "first_name": "Sarah",
    "last_name": "Support",
    "role_id": 3,
    "restaurant_ids": [349, 350, 351],
    "mfa_enabled": true
  }'
```

### Example 3: Add Restaurant Assignments

```bash
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/assign-admin-restaurants" \
  -H "Authorization: Bearer <service_role_key>" \
  -H "Content-Type: application/json" \
  -d '{
    "admin_user_id": 932,
    "restaurant_ids": [352, 353],
    "action": "add"
  }'
```

### Example 4: Replace All Restaurant Assignments

```bash
curl -X POST "https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/assign-admin-restaurants" \
  -H "Authorization: Bearer <service_role_key>" \
  -H "Content-Type: application/json" \
  -d '{
    "admin_user_id": 932,
    "restaurant_ids": [349],
    "action": "replace"
  }'
```

---

## 🏗️ Database Schema

### Tables Involved

#### menuca_v3.admin_users
```sql
- id: bigint (PK)
- email: varchar(255) UNIQUE
- first_name: varchar(100)
- last_name: varchar(100)
- auth_user_id: uuid (FK to auth.users)
- role_id: bigint (FK to admin_roles.id)
- status: admin_user_status enum (active/suspended/inactive)
- deleted_at: timestamp with time zone
- mfa_enabled: boolean
```

#### menuca_v3.admin_roles
```sql
- id: bigint (PK)
- name: varchar(100) UNIQUE
- description: text
- permissions: jsonb
- is_system_role: boolean
```

**Available Roles:**
- 1: Super Admin (Full platform access)
- 2: Manager
- 3: Support
- 5: Restaurant Manager
- 6: Staff

#### menuca_v3.admin_user_restaurants
```sql
- id: bigint (PK)
- admin_user_id: bigint (FK to admin_users.id)
- restaurant_id: bigint (FK to restaurants.id)
- created_at: timestamp with time zone

UNIQUE (admin_user_id, restaurant_id)
```

#### auth.users
```sql
- id: uuid (PK)
- email: varchar UNIQUE
- encrypted_password: varchar
- email_confirmed_at: timestamp
- user_metadata: jsonb
- app_metadata: jsonb
- created_at: timestamp
- updated_at: timestamp
```

---

## 🔐 Security Considerations

### Current Implementation

✅ **JWT-Based Authentication**
- User must be authenticated to call create-admin-user
- JWT token validated using Supabase's auth.getUser()
- Expired or invalid tokens are rejected

✅ **Role-Based Authorization**
- Only Super Admin users (role_id = 1) can create admin users
- User must have active status
- Database-level role validation (not just JWT claims)

✅ **Input Validation**
- Email format validation
- Password strength requirements (min 8 characters)
- Required field validation
- Restaurant ID validation

✅ **Data Consistency**
- Automatic rollback if admin_users insert fails
- No orphaned auth users
- Transaction-like behavior

✅ **CORS Configuration**
- CORS headers properly configured
- OPTIONS preflight handling

### Service Role Key Protection

⚠️ **IMPORTANT**: The `assign-admin-restaurants` function uses service role key authentication. This key:
- Bypasses all Row Level Security (RLS) policies
- Has full database access
- Should NEVER be exposed to clients
- Should only be used server-side

**Recommendation**: Consider updating `assign-admin-restaurants` to use the same JWT-based Super Admin validation as `create-admin-user` for consistency and security.

---

## 🚀 Future Enhancements

### Recommended Improvements

#### 1. Enhanced Password Validation
**Current**: Minimum 8 characters
**Suggested**:
- Require uppercase, lowercase, number, special character
- Check against common password lists
- Implement password strength meter

#### 2. Welcome Email Functionality
**Current**: Placeholder (logs message only)
**Suggested**:
- Integrate with email service (SendGrid, Resend, etc.)
- Send welcome email with login instructions
- Include temporary password reset link if desired

#### 3. Admin Creation Audit Logging
**Current**: Console logs only
**Suggested**:
- Create `admin_audit_log` table
- Log who created which admin, when
- Log failed creation attempts
- Track all admin account modifications

#### 4. Two-Factor Authentication Setup
**Current**: mfa_enabled flag only
**Suggested**:
- Generate TOTP secret during creation
- Send setup QR code via email
- Enforce MFA for Super Admin accounts

#### 5. Rate Limiting
**Current**: No rate limiting
**Suggested**:
- Implement rate limiting per user
- Prevent rapid-fire admin creation
- Add cooldown period between creations

#### 6. Bulk User Creation
**Suggested**:
- Accept array of users in single request
- Create multiple admins efficiently
- Return detailed results for each user

#### 7. Update assign-admin-restaurants Authentication
**Suggested**:
- Replace service role key with JWT validation
- Use same Super Admin role check as create-admin-user
- Maintain consistency across functions

---

## 📚 Related Documentation

- **Supabase Edge Functions**: https://supabase.com/docs/guides/functions
- **Supabase Auth Admin API**: https://supabase.com/docs/reference/javascript/auth-admin-createuser
- **JWT Authentication**: https://jwt.io/introduction
- **Row Level Security**: https://supabase.com/docs/guides/auth/row-level-security

---

## 🆘 Troubleshooting

### Common Issues

#### Issue: "Missing authorization header"
**Cause**: No JWT token provided in Authorization header
**Solution**: Include `Authorization: Bearer <token>` header in request

#### Issue: "Invalid token"
**Cause**: JWT token is malformed, expired, or invalid
**Solution**:
1. Login again to get fresh token
2. Ensure token is not expired (default 1 hour)
3. Verify token is properly formatted

#### Issue: "Super Admin role required"
**Cause**: User's role_id is not 1
**Solution**:
1. Verify user has Super Admin role in database
2. Check admin_users.role_id = 1
3. Ensure user is calling with correct JWT (not service role key)

#### Issue: "Failed to create auth user" with "User already registered"
**Cause**: Email address already exists in auth.users
**Solution**:
1. Check if user already exists
2. Use different email address
3. Or delete existing user first (if appropriate)

#### Issue: "Failed to create admin user record"
**Cause**: Database constraint violation (usually duplicate email or invalid role_id)
**Solution**:
1. Check admin_users table for duplicate email
2. Verify role_id exists in admin_roles table
3. Check database logs for specific constraint violation

---

## 📞 Support & Contact

For questions or issues related to these Edge Functions:

**Primary Contact**: Santiago Garcia (santiago@worklocal.ca)
**Secondary Contact**: Brian Lapp (brian@worklocal.ca)

**Supabase Project**: nthpbtdjhhnwfxqsxbvy
**Dashboard**: https://supabase.com/dashboard/project/nthpbtdjhhnwfxqsxbvy/functions

---

## ✅ Deployment Checklist

- [x] create-admin-user Edge Function deployed (Version 19)
- [x] assign-admin-restaurants Edge Function documented (Version 5)
- [x] Super Admin accounts created (Santiago & Brian)
- [x] JWT validation implemented
- [x] Role-based access control implemented
- [x] Input validation implemented
- [x] Error handling and rollback implemented
- [x] Security testing completed
- [x] Functional testing completed
- [x] Test users cleaned up
- [x] Documentation completed

---

**Document Version**: 1.0
**Last Updated**: 2025-10-30
**Status**: ✅ Complete and Production Ready
