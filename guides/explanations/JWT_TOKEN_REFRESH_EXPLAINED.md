# JWT Token Expiry & Refresh Mechanism - Explained

**Date:** October 23, 2025  
**Context:** Customer Authentication - Token Management

---

## 🔑 **QUESTION: What happens after the 60-minute JWT expiry?**

### **SHORT ANSWER:**
After 60 minutes, the JWT access token expires and the user will receive **401 Unauthorized** errors. The frontend must use the **refresh token** to obtain a new access token **without requiring the user to log in again**.

---

## 📋 **THE TOKEN LIFECYCLE**

### **1. Initial Login**

When a user logs in, Supabase returns **TWO tokens**:

```json
{
  "access_token": "eyJhbGci...",    // Valid for 60 minutes
  "refresh_token": "tl7ylps47ql2",  // Valid for 30 days
  "expires_in": 3600,                // Seconds (60 minutes)
  "expires_at": 1761240334,          // Unix timestamp
  "token_type": "bearer"
}
```

| Token | Lifetime | Purpose |
|-------|----------|---------|
| **Access Token** | 60 minutes | Used for API requests |
| **Refresh Token** | 30 days | Used to get new access tokens |

---

### **2. During the 60-Minute Window**

✅ **Access token is valid**

```typescript
// Frontend makes API calls with access token
const response = await supabase
  .from('users')
  .select('*')
  .single();

// ✅ SUCCESS - Token is still valid
```

**What's happening behind the scenes:**
1. Frontend sends: `Authorization: Bearer <access_token>`
2. Supabase verifies JWT signature
3. Checks expiry: `if (current_time < exp) { allow_request(); }`
4. Returns data ✅

---

### **3. After 60 Minutes (Token Expired)**

❌ **Access token expires**

```typescript
// Frontend makes API call with expired token
const response = await supabase
  .from('users')
  .select('*')
  .single();

// ❌ ERROR: 401 Unauthorized
// {"code": 401, "message": "JWT expired"}
```

**What's happening:**
1. Frontend sends: `Authorization: Bearer <expired_token>`
2. Supabase checks expiry: `if (current_time > exp) { reject(); }`
3. Returns: **401 Unauthorized** ❌

---

### **4. Automatic Token Refresh (The Magic)**

✅ **Supabase JS Client handles this automatically!**

```typescript
// ✨ AUTOMATIC REFRESH (No code needed!)
// The Supabase client detects token expiry and:
// 1. Sends refresh_token to auth/v1/token?grant_type=refresh_token
// 2. Gets new access_token
// 3. Retries the original request
// 4. User never notices!

const response = await supabase
  .from('users')
  .select('*')
  .single();

// ✅ SUCCESS - Token refreshed automatically
```

**What Supabase JS does automatically:**
1. Detects `expires_at` timestamp approaching
2. Calls refresh endpoint **before** token expires
3. Sends: `POST /auth/v1/token?grant_type=refresh_token`
4. Receives new `access_token` and `refresh_token`
5. Updates stored tokens in memory/localStorage
6. Retries original request with new token

---

### **5. Manual Token Refresh (If Needed)**

If you're **not using** the Supabase JS client, you must refresh manually:

```typescript
// Manual refresh endpoint
POST https://nthpbtdjhhnwfxqsxbvy.supabase.co/auth/v1/token?grant_type=refresh_token

Headers:
  apikey: <SUPABASE_ANON_KEY>
  Content-Type: application/json

Body:
{
  "refresh_token": "tl7ylps47ql2"
}

Response:
{
  "access_token": "eyJhbGci...",     // NEW access token
  "refresh_token": "xyz123",         // NEW refresh token
  "expires_in": 3600,
  "expires_at": 1761243934,
  "token_type": "bearer"
}
```

---

### **6. After 30 Days (Refresh Token Expires)**

❌ **Refresh token expires - User must log in again**

```typescript
// Attempt to refresh with expired refresh_token
const { data, error } = await supabase.auth.refreshSession({
  refresh_token: "expired_refresh_token"
});

// ❌ ERROR: 400 Bad Request
// {"error": "invalid_grant", "error_description": "Refresh token expired"}
```

**What happens:**
1. Refresh token has expired (30 days passed)
2. Cannot get new access token
3. User must **log in again** with email/password

---

## 🔄 **COMPLETE FLOW DIAGRAM**

```
┌─────────────────────────────────────────────────────────────────┐
│ USER LOGS IN                                                     │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
     ┌───────────────┐
     │ Access Token  │ Valid for 60 minutes
     │ Refresh Token │ Valid for 30 days
     └───────┬───────┘
             │
             ▼
┌────────────────────────────────────────────────────────────────┐
│ MINUTE 0-59: Access token works                                │
│ ✅ All API calls succeed                                        │
└────────────┬───────────────────────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────────────────────────┐
│ MINUTE 60: Access token expires                                 │
│ ❌ API calls return 401                                         │
└────────────┬───────────────────────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────────────────────────┐
│ AUTOMATIC REFRESH (Supabase JS Client)                         │
│ 1. Detects expiry                                               │
│ 2. Sends refresh_token to auth/v1/token                         │
│ 3. Gets new access_token (valid for 60 more minutes)            │
│ 4. Gets new refresh_token (valid for 30 more days)              │
│ 5. Updates tokens in storage                                    │
│ ✅ User continues without interruption                          │
└────────────┬───────────────────────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────────────────────────┐
│ REPEAT: Every 60 minutes, auto-refresh happens                  │
│ User can stay logged in for 30 days without re-entering password│
└────────────┬───────────────────────────────────────────────────┘
             │
             ▼
┌────────────────────────────────────────────────────────────────┐
│ DAY 30: Refresh token expires                                   │
│ ❌ Cannot refresh anymore                                       │
│ 🔐 User must log in again                                       │
└────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ **FRONTEND IMPLEMENTATION**

### **Option 1: Supabase JS Client (Recommended) ✅**

```typescript
// ✨ AUTOMATIC - No code needed!
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://nthpbtdjhhnwfxqsxbvy.supabase.co',
  'eyJhbGci...'
);

// Supabase handles refresh automatically!
// Just use the client normally:
const { data, error } = await supabase
  .from('users')
  .select('*');

// Token refreshed automatically when needed ✅
```

**What Supabase JS does:**
- Stores tokens in `localStorage` (browser) or memory (Node.js)
- Monitors `expires_at` timestamp
- Refreshes token ~5 minutes before expiry
- Handles errors and retries
- Updates session automatically

---

### **Option 2: Manual Implementation (For Custom Clients)**

```typescript
// Store tokens
let accessToken = response.access_token;
let refreshToken = response.refresh_token;
let expiresAt = response.expires_at;

// Check if token expired
function isTokenExpired() {
  const now = Math.floor(Date.now() / 1000); // Current Unix timestamp
  return now >= expiresAt;
}

// Refresh token function
async function refreshAccessToken() {
  const response = await fetch(
    'https://nthpbtdjhhnwfxqsxbvy.supabase.co/auth/v1/token?grant_type=refresh_token',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': 'eyJhbGci...'
      },
      body: JSON.stringify({ refresh_token: refreshToken })
    }
  );

  const data = await response.json();
  
  if (response.ok) {
    // Update tokens
    accessToken = data.access_token;
    refreshToken = data.refresh_token;
    expiresAt = data.expires_at;
    return accessToken;
  } else {
    // Refresh failed - user must log in again
    throw new Error('Session expired. Please log in again.');
  }
}

// Make API request with auto-refresh
async function makeAuthenticatedRequest(url, options = {}) {
  // Check if token needs refresh
  if (isTokenExpired()) {
    try {
      await refreshAccessToken();
    } catch (error) {
      // Redirect to login page
      window.location.href = '/login';
      return;
    }
  }

  // Make request with valid token
  const response = await fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${accessToken}`,
      'apikey': 'eyJhbGci...'
    }
  });

  // If 401, try refreshing once
  if (response.status === 401) {
    await refreshAccessToken();
    // Retry request with new token
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${accessToken}`,
        'apikey': 'eyJhbGci...'
      }
    });
  }

  return response;
}
```

---

## 🔒 **SECURITY CONSIDERATIONS**

### **Why Short-Lived Access Tokens?**

✅ **Security Benefits:**
1. **Limited Attack Window:** If token is stolen, only valid for 60 minutes
2. **Reduces Exposure:** Compromised token expires quickly
3. **Frequent Validation:** Forces periodic re-authentication
4. **Audit Trail:** Each refresh creates new session log

### **Why Long-Lived Refresh Tokens?**

✅ **User Experience Benefits:**
1. **No Frequent Logins:** User stays logged in for 30 days
2. **Seamless Experience:** No interruptions during use
3. **Background Refresh:** Happens automatically and invisibly

### **Security Trade-Off:**
- **Access Token:** Short-lived (60 min) = High security, low convenience
- **Refresh Token:** Long-lived (30 days) = Lower security, high convenience
- **Solution:** Refresh tokens stored securely (httpOnly cookies or encrypted storage)

---

## 📊 **TOKEN STORAGE**

| Storage Method | Security | Persistence | Recommended For |
|----------------|----------|-------------|-----------------|
| **localStorage** | Medium | Survives page refresh | Web apps (default) |
| **sessionStorage** | Medium | Lost on tab close | Temporary sessions |
| **httpOnly Cookie** | High | Survives refresh, secure | Production apps ✅ |
| **Memory only** | Highest | Lost on refresh | High-security apps |

**Supabase Default:** Stores in `localStorage` as:
```javascript
localStorage.getItem('supabase.auth.token');
// {"access_token": "...", "refresh_token": "...", "expires_at": 1761240334}
```

---

## 🎯 **WHAT TO DO IN YOUR APP**

### **If Using Supabase JS Client:**
✅ **Do nothing!** It's automatic.

### **If Building Custom Frontend:**
1. Store `access_token`, `refresh_token`, and `expires_at` after login
2. Before each API request, check if token expired
3. If expired, call refresh endpoint with `refresh_token`
4. Update stored tokens with new values
5. Retry original request with new `access_token`

### **Handle Refresh Failure:**
```typescript
try {
  await refreshAccessToken();
} catch (error) {
  // Refresh token expired or invalid
  // Clear local storage
  localStorage.removeItem('supabase.auth.token');
  // Redirect to login
  window.location.href = '/login';
  // Show message: "Your session has expired. Please log in again."
}
```

---

## 🧪 **TESTING TOKEN EXPIRY**

### **Option 1: Wait 60 Minutes** ⏳
(Not practical for testing!)

### **Option 2: Use Expired Token** ✅

```sql
-- Create token that expires in 10 seconds (for testing)
-- Note: This requires modifying Supabase Auth settings
-- Default: 3600 seconds (60 minutes)
-- Test setting: 10 seconds

-- In Supabase Dashboard → Authentication → Settings:
-- JWT Expiry: 10 (seconds)
```

### **Option 3: Manually Invalidate Token**

```typescript
// Logout (invalidates all tokens)
await supabase.auth.signOut();

// Try to use old token (should fail with 401)
const response = await fetch(url, {
  headers: { 'Authorization': `Bearer ${oldToken}` }
});
// Returns: 401 Unauthorized ✅
```

---

## ✅ **PRODUCTION CHECKLIST**

- [ ] **Using Supabase JS Client** for automatic refresh
- [ ] **Tokens stored securely** (httpOnly cookies or encrypted storage)
- [ ] **Handle refresh errors** (redirect to login)
- [ ] **Show "Session Expired" message** when refresh fails
- [ ] **Clear tokens on logout** (remove from storage)
- [ ] **Set appropriate expiry times:**
  - Access token: 60 minutes (default) ✅
  - Refresh token: 30 days (default) ✅
  - Adjust based on security requirements
- [ ] **Monitor failed refresh attempts** (could indicate attacks)
- [ ] **Implement "Remember Me"** (optional: extend refresh token to 90 days)

---

## 🎉 **SUMMARY**

### **Normal Flow (60 minutes or less):**
1. User logs in → Gets access token (60 min) + refresh token (30 days)
2. User makes API calls → Access token works ✅
3. User continues using app → No issues ✅

### **After 60 Minutes:**
1. Access token expires → API returns 401 ❌
2. Supabase JS auto-refreshes → Sends refresh token
3. Gets new access token → User continues ✅
4. **User never notices!** 🎉

### **After 30 Days:**
1. Refresh token expires → Cannot get new access token ❌
2. User must log in again → Re-enter email/password 🔐
3. Gets new tokens → Process repeats ✅

---

**TL;DR:**
- **60 minutes:** Access token expires, but **auto-refreshes** using refresh token
- **User stays logged in** for 30 days without re-entering password
- **After 30 days:** Must log in again (refresh token expired)
- **Supabase JS handles everything automatically** ✅

---

**Recommendation for MenuCA:**
✅ **Keep default settings (60 min / 30 days)**
- Good balance between security and UX
- Standard industry practice
- Automatic refresh = seamless experience
- 30-day refresh = users don't need to login daily

**No changes needed!** 🎉

