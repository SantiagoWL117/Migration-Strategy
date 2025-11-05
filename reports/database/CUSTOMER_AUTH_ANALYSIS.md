# Customer Authentication - API Endpoints Analysis

**Date:** October 23, 2025  
**Entity:** Users & Access - Customer Authentication  
**Status:** ⚠️ **CRITICAL GAP IDENTIFIED**

---

## 🎯 **SCOPE**

Analyzing the 3 customer authentication endpoints:
1. **POST `/api/auth/signup`** - Customer Registration
2. **POST `/api/auth/login`** - Customer Login  
3. **POST `/api/auth/logout`** - Customer Logout

---

## ✅ **ENDPOINT 1: SIGNUP - `/api/auth/signup`**

### **Current Implementation:**
```typescript
export async function POST(request: Request) {
  const { email, password, first_name, last_name, phone } = await request.json();
  
  const supabase = createClient();
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: { first_name, last_name, phone }
    }
  });
  
  if (error) return Response.json({ error: error.message }, { status: 400 });
  return Response.json({ user: data.user });
}
```

### **What This Does:**

1. **Creates `auth.users` record:**
   - Email + hashed password
   - Stores user metadata (first_name, last_name, phone)
   - Generates JWT tokens

2. **Creates `auth.identities` record:**
   - Links to email provider
   - Tracks authentication method

3. **Sends verification email** (if enabled):
   - Email confirmation link
   - User must verify before full access

### **What Happens in Database:**

```sql
-- auth.users table gets:
INSERT INTO auth.users (
  id,                    -- UUID generated
  email,                 -- user@example.com
  encrypted_password,    -- bcrypt hash
  email_confirmed_at,    -- NULL until verified
  raw_user_meta_data     -- { first_name, last_name, phone }
);

-- auth.identities table gets:
INSERT INTO auth.identities (
  user_id,     -- Links to auth.users.id
  provider,    -- 'email'
  provider_id  -- Same as user_id for email auth
);
```

---

## 🚨 **CRITICAL ISSUE IDENTIFIED**

### **Problem: NO `menuca_v3.users` Record Created**

**Current Flow:**
```
1. User fills signup form
2. supabase.auth.signUp() creates auth.users ✅
3. User gets JWT token ✅
4. User tries to access profile...
5. ❌ FAILS - No menuca_v3.users record exists!
```

**Impact:**
- ✅ User CAN authenticate (has auth.users record)
- ❌ User CANNOT access app features (no menuca_v3.users record)
- ❌ `get_user_profile()` returns NULL
- ❌ Cannot add addresses (FK constraint fails)
- ❌ Cannot add favorites (FK constraint fails)

**Root Cause:**
- `auth.users` is managed by Supabase Auth
- `menuca_v3.users` is our application table
- **NO automatic sync between them**

---

## ✅ **SOLUTION: Database Trigger**

We need a PostgreSQL trigger to automatically create `menuca_v3.users` when `auth.users` is created.

### **Trigger Function:**
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Only create menuca_v3.users for email signups (not OAuth, admin signups, etc.)
  IF NEW.raw_user_meta_data->>'signup_type' IS NULL OR 
     NEW.raw_user_meta_data->>'signup_type' = 'customer' THEN
    
    INSERT INTO menuca_v3.users (
      auth_user_id,
      email,
      first_name,
      last_name,
      phone,
      has_email_verified,
      created_at,
      updated_at
    ) VALUES (
      NEW.id,
      NEW.email,
      NEW.raw_user_meta_data->>'first_name',
      NEW.raw_user_meta_data->>'last_name',
      NEW.raw_user_meta_data->>'phone',
      (NEW.email_confirmed_at IS NOT NULL),
      NOW(),
      NOW()
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

### **How It Works:**
1. User calls `supabase.auth.signUp()`
2. Supabase creates `auth.users` record
3. **Trigger fires automatically**
4. `menuca_v3.users` record created with `auth_user_id` linked
5. User can now access all app features ✅

---

## ✅ **ENDPOINT 2: LOGIN - `/api/auth/login`**

### **Current Implementation:**
```typescript
export async function POST(request: Request) {
  const { email, password } = await request.json();
  
  const supabase = createClient();
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  });
  
  if (error) return Response.json({ error: error.message }, { status: 401 });
  return Response.json({ session: data.session, user: data.user });
}
```

### **What This Does:**

1. **Validates credentials:**
   - Checks email exists in `auth.users`
   - Verifies password hash matches
   - Checks if email is confirmed (if required)

2. **Creates session:**
   - Generates access token (JWT, expires in 1 hour)
   - Generates refresh token (expires in 30 days)
   - Stores in `auth.sessions` and `auth.refresh_tokens`

3. **Returns tokens:**
   - Access token for API calls
   - Refresh token for auto-renewal
   - User object with metadata

### **Response Structure:**
```json
{
  "session": {
    "access_token": "eyJhbGci...",  // JWT for API calls
    "refresh_token": "xp4qwol...",   // For token renewal
    "expires_in": 3600,               // 1 hour
    "expires_at": 1761235486,         // Unix timestamp
    "token_type": "bearer",
    "user": {
      "id": "a74765f6-...",
      "email": "user@example.com",
      "email_confirmed_at": "2025-10-23T...",
      "user_metadata": {
        "first_name": "John",
        "last_name": "Doe"
      }
    }
  },
  "user": { /* same as session.user */ }
}
```

### **JWT Token Contents:**
```json
{
  "iss": "https://nthpbtdjhhnwfxqsxbvy.supabase.co/auth/v1",
  "sub": "a74765f6-aaa3-4b88-ab31-3d2b981b05e9",  // user_id
  "aud": "authenticated",
  "exp": 1761235486,
  "iat": 1761231886,
  "email": "user@example.com",
  "role": "authenticated",
  "session_id": "690d50eb-2184-4c32-8c97-d748bec860fb"
}
```

### **Status:** ✅ **WORKING**
- Supabase Auth handles this natively
- No additional backend code needed
- Frontend just needs to store tokens

---

## ✅ **ENDPOINT 3: LOGOUT - `/api/auth/logout`**

### **Current Implementation:**
```typescript
export async function POST(request: Request) {
  const supabase = createClient(request);
  await supabase.auth.signOut();
  return Response.json({ success: true });
}
```

### **What This Does:**

1. **Invalidates session:**
   - Deletes record from `auth.sessions`
   - Invalidates refresh token in `auth.refresh_tokens`
   - JWT access token becomes invalid

2. **Clears cookies:**
   - Removes auth cookies from browser
   - User must login again

### **Database Changes:**
```sql
-- Deletes from:
DELETE FROM auth.sessions WHERE id = 'session_id';
DELETE FROM auth.refresh_tokens WHERE token = 'refresh_token';
```

### **Status:** ✅ **WORKING**
- Supabase Auth handles this natively
- No additional backend code needed

---

## 📊 **AUTHENTICATION FLOW DIAGRAM**

### **Signup Flow:**
```
┌─────────────────────────────────────────────────────────────┐
│ 1. Frontend: supabase.auth.signUp()                        │
│    { email, password, options: { data: {...} } }           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Supabase Auth: Creates auth.users record                │
│    - Hashes password                                        │
│    - Stores user_metadata                                   │
│    - Generates UUID                                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. 🚨 MISSING: Create menuca_v3.users record               │
│    ❌ Currently NOT happening automatically                 │
│    ✅ NEEDS: Database trigger                               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Email Verification (if enabled)                         │
│    - Sends confirmation email                               │
│    - User clicks link                                       │
│    - email_confirmed_at updated                             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. User Logged In                                           │
│    - JWT token issued                                       │
│    - Can access app features                                │
└─────────────────────────────────────────────────────────────┘
```

### **Login Flow:**
```
┌─────────────────────────────────────────────────────────────┐
│ 1. Frontend: supabase.auth.signInWithPassword()            │
│    { email, password }                                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Supabase Auth: Validates credentials                    │
│    - Checks email exists                                    │
│    - Verifies password hash                                 │
│    - Checks email_confirmed (if required)                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Session Created                                          │
│    - access_token (JWT, 1 hour)                            │
│    - refresh_token (30 days)                               │
│    - Stored in auth.sessions                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Frontend: Stores tokens                                 │
│    - localStorage or cookies                                │
│    - Includes in Authorization header                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. User Can Access Protected Endpoints                     │
│    - RLS policies use auth.uid()                           │
│    - User sees only their data                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔒 **SECURITY FEATURES**

### **Password Security:**
- ✅ **Bcrypt hashing** - Industry standard
- ✅ **Salt per user** - Automatic
- ✅ **Rate limiting** - Supabase default (5 attempts/hour)
- ✅ **Password requirements** - Configurable (min 6 chars default)

### **Token Security:**
- ✅ **JWT signed** - RS256 algorithm
- ✅ **Short-lived access tokens** - 1 hour expiry
- ✅ **Refresh token rotation** - New token on each refresh
- ✅ **HttpOnly cookies** - XSS protection (optional)

### **Email Security:**
- ✅ **Email verification** - Prevents fake signups
- ✅ **Rate limiting** - Prevents spam
- ✅ **Expiring links** - 1 hour validity
- ✅ **One-time use** - Token invalidated after use

---

## ⚠️ **GAPS & RECOMMENDATIONS**

### **🚨 GAP 1: No Automatic User Profile Creation**

**Issue:** `menuca_v3.users` record not created on signup  
**Impact:** User cannot access app features after signup  
**Priority:** 🔴 **CRITICAL - BLOCKS SIGNUP FLOW**

**Solution:**
```sql
-- Add trigger to create menuca_v3.users automatically
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

### **✅ GAP 2: Email Verification Configuration**

**Current:** Unknown if email verification is required  
**Recommendation:** 
- **Development:** Disable for testing
- **Production:** Enable for security

**Configuration:**
```sql
-- Check current setting
SELECT * FROM auth.config;

-- Enable email verification
UPDATE auth.config 
SET email_confirm_required = true;
```

### **✅ GAP 3: Password Reset Endpoint**

**Missing:** `POST /api/auth/reset-password`  
**Impact:** Users can't reset forgotten passwords  
**Priority:** 🟡 MEDIUM

**Solution:**
```typescript
// POST /api/auth/reset-password
export async function POST(request: Request) {
  const { email } = await request.json();
  
  const supabase = createClient();
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${process.env.NEXT_PUBLIC_SITE_URL}/reset-password`
  });
  
  if (error) return Response.json({ error: error.message }, { status: 400 });
  return Response.json({ message: 'Password reset email sent' });
}
```

### **✅ GAP 4: Email Change Endpoint**

**Missing:** `POST /api/auth/change-email`  
**Impact:** Users can't update email address  
**Priority:** 🟢 LOW (can add later)

### **✅ GAP 5: Token Refresh Endpoint**

**Missing:** `POST /api/auth/refresh`  
**Impact:** Frontend must handle token refresh  
**Note:** Supabase SDK handles this automatically, endpoint not needed

---

## ✅ **WHAT'S WORKING CORRECTLY**

1. ✅ **Supabase Auth Integration** - All auth tables exist
2. ✅ **JWT Token Generation** - Working natively
3. ✅ **Password Hashing** - Bcrypt with salt
4. ✅ **Session Management** - Automatic
5. ✅ **Login/Logout** - Working correctly
6. ✅ **RLS Integration** - auth.uid() available in policies
7. ✅ **Rate Limiting** - Supabase default protection

---

## 📋 **REQUIRED ACTIONS**

### **Priority 1: CRITICAL** 🔴
- [ ] Add database trigger to create `menuca_v3.users` on signup
- [ ] Test signup flow end-to-end
- [ ] Verify profile creation works

### **Priority 2: HIGH** 🟡
- [ ] Add password reset endpoint
- [ ] Build password reset page (frontend)
- [ ] Test password reset flow

### **Priority 3: MEDIUM** 🟢
- [ ] Configure email verification settings
- [ ] Add email change endpoint (optional)
- [ ] Add phone verification (optional)

---

## 🎯 **NEXT STEPS**

1. **Create Database Trigger** (Critical)
2. **Test Signup Flow** (Critical)
3. **Add Password Reset Endpoint** (High)
4. **Update Documentation** (Medium)

---

**Analysis Completed By:** AI Agent (Claude Sonnet 4.5)  
**Date:** October 23, 2025  
**Status:** ⚠️ **CRITICAL GAP IDENTIFIED - TRIGGER REQUIRED**

