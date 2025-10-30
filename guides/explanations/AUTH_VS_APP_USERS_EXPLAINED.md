# auth.users vs menuca_v3.users - The Complete Guide

**Date:** October 23, 2025  
**Topic:** Understanding the Two-Table Authentication Architecture

---

## 🎯 **THE SHORT ANSWER**

**auth.users** = **WHO they are** (authentication & security)  
**menuca_v3.users** = **WHAT they do** (application data & business logic)

They work together but serve completely different purposes!

---

## 📊 **SIDE-BY-SIDE COMPARISON**

### **auth.users** (Supabase Auth Table)

| Column | Type | Purpose |
|--------|------|---------|
| `id` | UUID | **Unique identifier** (used in JWT tokens) |
| `email` | VARCHAR | Login email |
| `encrypted_password` | VARCHAR | Bcrypt password hash |
| `email_confirmed_at` | TIMESTAMP | When email was verified |
| `last_sign_in_at` | TIMESTAMP | Last login time |
| `phone` | TEXT | Phone number (for phone auth) |
| `raw_user_meta_data` | JSONB | Flexible metadata storage |
| `is_sso_user` | BOOLEAN | OAuth login (Google, GitHub, etc.) |
| `banned_until` | TIMESTAMP | Account suspension |

**Managed By:** Supabase Auth (you can't directly modify)  
**Location:** `auth` schema (protected)  
**Access:** Service role only

---

### **menuca_v3.users** (Your Application Table)

| Column | Type | Purpose |
|--------|------|---------|
| `id` | BIGINT | **Your app's user ID** (for foreign keys) |
| `auth_user_id` | UUID | **Links to auth.users.id** |
| `email` | VARCHAR | User's email (duplicated for queries) |
| `first_name` | VARCHAR | User's first name |
| `last_name` | VARCHAR | User's last name |
| `phone` | VARCHAR | Phone number |
| `credit_balance` | NUMERIC | Store credit for promotions |
| `stripe_customer_id` | VARCHAR | Payment integration |
| `referral_code` | VARCHAR | Referral program |
| `language` | VARCHAR | UI language preference (EN/FR/ES) |
| `has_email_verified` | BOOLEAN | Email verification status |
| `newsletter_subscribed` | BOOLEAN | Marketing consent |
| `deleted_at` | TIMESTAMP | Soft delete timestamp |

**Managed By:** Your application code  
**Location:** `menuca_v3` schema  
**Access:** RLS policies control access

---

## 🔗 **HOW THEY CONNECT**

```
auth.users                    menuca_v3.users
┌─────────────────────┐      ┌─────────────────────┐
│ id (UUID)           │◄─────│ auth_user_id (UUID) │
│ "7f9a88f5..."       │      │ "7f9a88f5..."       │
│                     │      │                     │
│ email               │      │ id: 165             │
│ encrypted_password  │      │ email               │
│ email_confirmed_at  │      │ first_name          │
│ last_sign_in_at     │      │ last_name           │
│ raw_user_meta_data  │      │ credit_balance      │
└─────────────────────┘      │ stripe_customer_id  │
                              │ language            │
                              └─────────────────────┘
```

**The Link:** `menuca_v3.users.auth_user_id = auth.users.id`

---

## 💡 **WHY WE NEED BOTH TABLES**

### **Analogy: Bank Account System**

Think of it like a bank:

**auth.users** = Your **bank vault** (security)
- Stores your PIN code (password hash)
- Verifies your identity when you login
- Controls who can access the bank
- Managed by the bank's security system (Supabase)

**menuca_v3.users** = Your **account details** (business logic)
- Your account balance
- Your transaction history
- Your personal information
- Your preferences and settings
- Managed by the bank's business system (your app)

You need BOTH:
- The vault authenticates you ✅
- The account holds your money ✅

---

## 🎭 **REAL-WORLD EXAMPLE**

Let's follow a user through the system:

### **User Signs Up:**

**Step 1: Create auth.users**
```sql
-- Supabase Auth creates:
INSERT INTO auth.users (
  id,                      -- "e83f3d1d-1f51-409e-96c1-c0129dc996c3"
  email,                   -- "semih@example.com"
  encrypted_password,      -- "$2a$10$N9qo8uLOickgx..."
  raw_user_meta_data       -- { "first_name": "Semih", "last_name": "Coba" }
);
```

**Purpose:**
- ✅ Stores password securely (bcrypt hash)
- ✅ Generates JWT tokens
- ✅ Handles email verification
- ✅ Manages login sessions

**Step 2: Create menuca_v3.users** (needs trigger!)
```sql
-- Your application creates:
INSERT INTO menuca_v3.users (
  auth_user_id,     -- "e83f3d1d-1f51-409e-96c1-c0129dc996c3"
  email,            -- "semih@example.com"
  first_name,       -- "Semih"
  last_name,        -- "Coba"
  credit_balance,   -- 0.00
  language          -- "EN"
);
```

**Purpose:**
- ✅ Stores user's profile data
- ✅ Tracks business logic (credits, referrals)
- ✅ Has foreign keys to other tables (addresses, orders)
- ✅ Can be queried by your app

---

### **User Logs In:**

**auth.users is checked:**
```sql
-- Supabase Auth validates:
SELECT * FROM auth.users 
WHERE email = 'semih@example.com'
  AND encrypted_password = hash_password('their_password');
-- If match: Generate JWT token with user.id
```

**JWT Token Contains:**
```json
{
  "sub": "e83f3d1d-1f51-409e-96c1-c0129dc996c3",  // auth.users.id
  "email": "semih@example.com",
  "role": "authenticated"
}
```

---

### **User Accesses Profile:**

**Frontend calls:**
```typescript
const { data } = await supabase.rpc('get_user_profile');
```

**Backend SQL function:**
```sql
CREATE FUNCTION get_user_profile()
RETURNS TABLE(...) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM menuca_v3.users
  WHERE auth_user_id = auth.uid();  -- Gets UUID from JWT!
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**RLS Policy filters:**
```sql
-- Automatic filter added:
SELECT * FROM menuca_v3.users
WHERE auth_user_id = auth.uid()  -- From JWT token
  AND deleted_at IS NULL;
```

**Result:**
- User sees ONLY their menuca_v3.users row ✅
- Other users are invisible ✅
- Perfect isolation ✅

---

## 🔒 **SECURITY ARCHITECTURE**

### **Why Separate Tables = Better Security**

#### **1. Separation of Concerns**
```
auth.users (Supabase manages)
- Password hashing
- Email verification
- Session management
- OAuth integration
- MFA/2FA
- Rate limiting

menuca_v3.users (You manage)
- Business logic
- Application features
- Custom fields
- Soft deletes
- Audit trails
```

#### **2. Protected Password Storage**
```sql
-- ❌ BAD: Passwords in your app table
CREATE TABLE users (
  id SERIAL,
  email VARCHAR,
  password VARCHAR  -- NEVER do this!
);

-- ✅ GOOD: Passwords in auth.users (protected schema)
-- You can't accidentally expose passwords
-- Supabase handles security updates
```

#### **3. JWT Token Security**
```javascript
// JWT contains auth.users.id (UUID)
{
  "sub": "e83f3d1d-1f51-409e-96c1-c0129dc996c3",
  "role": "authenticated"
}

// RLS policies use auth.uid() to get this UUID
// Then lookup menuca_v3.users.auth_user_id
// Perfect security chain!
```

---

## 📊 **DATA FLOW DIAGRAM**

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER SIGNUP                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Frontend Form   │
                    │  email + password│
                    └────────┬─────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │ supabase.auth.signUp │
                  └──────────┬───────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
    ┌──────────────────┐         ┌──────────────────┐
    │   auth.users     │         │ 🚨 MISSING:      │
    │   id: UUID       │         │ menuca_v3.users  │
    │   email          │         │ (needs trigger)  │
    │   password_hash  │         └──────────────────┘
    └──────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        USER LOGIN                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                  ┌──────────────────────────┐
                  │ supabase.auth.signIn      │
                  │ Validates password        │
                  └──────────┬────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  JWT Token      │
                    │  Contains UUID  │
                    └────────┬────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │  User Makes Request  │
                  │  Authorization Header│
                  └──────────┬───────────┘
                             │
                             ▼
            ┌────────────────────────────────┐
            │  RLS Policy                    │
            │  WHERE auth_user_id = auth.uid()│
            └────────────────────────────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │  menuca_v3.users     │
                  │  Returns user's row  │
                  └──────────────────────┘
```

---

## 🎯 **BUSINESS LOGIC EXAMPLES**

### **Why menuca_v3.users Holds Business Data:**

#### **Example 1: Store Credit**
```sql
-- User gets $10 credit for referral
UPDATE menuca_v3.users
SET credit_balance = credit_balance + 10.00
WHERE auth_user_id = 'uuid';

-- ❌ Can't store in auth.users (not our table!)
-- ✅ Must store in menuca_v3.users
```

#### **Example 2: Stripe Integration**
```sql
-- Link Stripe customer ID
UPDATE menuca_v3.users
SET stripe_customer_id = 'cus_abc123'
WHERE auth_user_id = 'uuid';

-- Now you can track payments, subscriptions, etc.
```

#### **Example 3: Referral System**
```sql
-- Generate referral code
UPDATE menuca_v3.users
SET referral_code = 'JOHN2025'
WHERE auth_user_id = 'uuid';

-- Track referrals
SELECT COUNT(*) FROM menuca_v3.users
WHERE referred_by_code = 'JOHN2025';
```

#### **Example 4: Foreign Keys**
```sql
-- User's addresses
CREATE TABLE user_delivery_addresses (
  id SERIAL,
  user_id BIGINT REFERENCES menuca_v3.users(id),  -- Uses menuca_v3.users.id!
  street_address VARCHAR,
  ...
);

-- ❌ Can't use auth.users.id for FK (different schema, UUID)
-- ✅ Must use menuca_v3.users.id (BIGINT, same schema)
```

---

## 🔧 **COMMON OPERATIONS**

### **Get User by JWT Token:**
```sql
-- In SQL function or RLS policy:
SELECT * FROM menuca_v3.users
WHERE auth_user_id = auth.uid();  -- auth.uid() reads JWT token
```

### **Get User by Email:**
```sql
-- For admin operations:
SELECT * FROM menuca_v3.users
WHERE email = 'user@example.com';
```

### **Check if User Exists:**
```sql
SELECT EXISTS(
  SELECT 1 FROM menuca_v3.users
  WHERE auth_user_id = 'uuid'
);
```

### **Update User Profile:**
```sql
UPDATE menuca_v3.users
SET first_name = 'NewName',
    updated_at = NOW()
WHERE auth_user_id = auth.uid();  -- Only update own record
```

---

## ⚠️ **COMMON PITFALLS**

### **Mistake 1: Using Wrong ID**
```sql
-- ❌ WRONG: Using auth.users.id as FK
CREATE TABLE orders (
  user_id UUID REFERENCES auth.users(id)  -- Don't do this!
);

-- ✅ RIGHT: Using menuca_v3.users.id
CREATE TABLE orders (
  user_id BIGINT REFERENCES menuca_v3.users(id)  -- Correct!
);
```

### **Mistake 2: Storing Business Data in auth.users**
```sql
-- ❌ WRONG: Can't add columns to auth.users
ALTER TABLE auth.users ADD COLUMN credit_balance NUMERIC;
-- ERROR: Permission denied!

-- ✅ RIGHT: Add to menuca_v3.users
ALTER TABLE menuca_v3.users ADD COLUMN credit_balance NUMERIC;
```

### **Mistake 3: Forgetting to Create menuca_v3.users**
```sql
-- User signs up → auth.users created ✅
-- But menuca_v3.users NOT created ❌
-- User can't use app features!

-- SOLUTION: Add trigger (see below)
```

---

## 🔧 **THE MISSING LINK: Database Trigger**

To automatically create menuca_v3.users when auth.users is created:

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Create menuca_v3.users record when auth.users is created
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
    NEW.id,                                      -- auth.users.id
    NEW.email,
    NEW.raw_user_meta_data->>'first_name',
    NEW.raw_user_meta_data->>'last_name',
    NEW.raw_user_meta_data->>'phone',
    (NEW.email_confirmed_at IS NOT NULL),
    NOW(),
    NOW()
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger fires AFTER INSERT on auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

---

## 📋 **SUMMARY TABLE**

| Aspect | auth.users | menuca_v3.users |
|--------|-----------|-----------------|
| **Purpose** | Authentication | Business logic |
| **Managed By** | Supabase Auth | Your app |
| **ID Type** | UUID | BIGINT (auto-increment) |
| **Contains** | Password, sessions, tokens | Profile, credits, preferences |
| **Schema** | `auth` (protected) | `menuca_v3` (your schema) |
| **Access** | Service role only | RLS policies |
| **Can Modify** | No (Supabase manages) | Yes (your code) |
| **Foreign Keys** | No (different schema) | Yes (same schema) |
| **Custom Columns** | No | Yes |
| **Soft Delete** | No | Yes (`deleted_at`) |

---

## 🎯 **KEY TAKEAWAYS**

1. **auth.users** = Authentication infrastructure (passwords, tokens, sessions)
2. **menuca_v3.users** = Application data (profiles, business logic, relationships)
3. They're **linked** via `menuca_v3.users.auth_user_id = auth.users.id`
4. **Both are required** for a working app
5. **Need a trigger** to keep them in sync
6. **RLS policies** use `auth.uid()` to filter menuca_v3.users
7. **Foreign keys** use `menuca_v3.users.id` (not auth.users.id)

---

**Created By:** AI Agent (Claude Sonnet 4.5)  
**Date:** October 23, 2025  
**Purpose:** Explain two-table authentication architecture

