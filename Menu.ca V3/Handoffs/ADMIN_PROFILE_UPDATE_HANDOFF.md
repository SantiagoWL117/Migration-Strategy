# Admin Profile Update - Frontend Integration Handoff

> **For:** Replit Frontend Team  
> **Purpose:** Enable Restaurant Admins to update their own profile (email, password, phone)

---

## ⚠️ Important Security Note

The **Admin API** (`/auth/v1/admin/users/{id}`) requires the `service_role` key, which **must NEVER be exposed to the frontend**. 

There are two approaches:

| Approach | Endpoint | Key Required | Use Case |
|----------|----------|--------------|----------|
| **Client-side** | `PUT /auth/v1/user` | User's JWT (anon key) | User updates their own profile |
| **Server-side** | `PUT /auth/v1/admin/users/{id}` | service_role key | Admin updates any user (via Edge Function) |

**Recommendation:** Use the **client-side endpoint** for self-service profile updates. Use Edge Functions only for admin-level operations.

---

## 1. Client-Side Profile Update (Recommended)

### 1.1 Endpoint

```
PUT https://nthpbtdjhhnwfxqsxbvy.supabase.co/auth/v1/user
```

### 1.2 Headers

```javascript
{
  "apikey": "YOUR_SUPABASE_ANON_KEY",
  "Authorization": "Bearer {USER_JWT_TOKEN}",
  "Content-Type": "application/json"
}
```

### 1.3 Request Body

| Field | Type | Description |
|-------|------|-------------|
| `email` | string | New email address |
| `password` | string | New password |
| `phone` | string | New phone (E.164 format: +15551234567) |
| `data` | object | Update user_metadata |

### 1.4 JavaScript Examples

#### Using Supabase Client (Recommended)

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://nthpbtdjhhnwfxqsxbvy.supabase.co',
  'YOUR_SUPABASE_ANON_KEY'
)

// Update password
async function updatePassword(newPassword) {
  const { data, error } = await supabase.auth.updateUser({
    password: newPassword
  })
  
  if (error) {
    console.error('Password update failed:', error.message)
    return { success: false, error: error.message }
  }
  
  return { success: true, user: data.user }
}

// Update email
async function updateEmail(newEmail) {
  const { data, error } = await supabase.auth.updateUser({
    email: newEmail
  })
  
  if (error) {
    console.error('Email update failed:', error.message)
    return { success: false, error: error.message }
  }
  
  // Note: User will receive confirmation email at BOTH old and new addresses
  return { success: true, message: 'Confirmation email sent' }
}

// Update phone
async function updatePhone(newPhone) {
  const { data, error } = await supabase.auth.updateUser({
    phone: newPhone  // E.164 format: +15551234567
  })
  
  if (error) {
    console.error('Phone update failed:', error.message)
    return { success: false, error: error.message }
  }
  
  return { success: true, user: data.user }
}

// Update multiple fields at once
async function updateProfile({ email, phone, password }) {
  const updates = {}
  if (email) updates.email = email
  if (phone) updates.phone = phone
  if (password) updates.password = password
  
  const { data, error } = await supabase.auth.updateUser(updates)
  
  if (error) {
    return { success: false, error: error.message }
  }
  
  return { success: true, user: data.user }
}
```

#### Using Fetch API

```javascript
async function updateUserProfile(updates) {
  // Get current session
  const { data: { session } } = await supabase.auth.getSession()
  
  if (!session) {
    return { success: false, error: 'Not authenticated' }
  }

  const response = await fetch(
    'https://nthpbtdjhhnwfxqsxbvy.supabase.co/auth/v1/user',
    {
      method: 'PUT',
      headers: {
        'apikey': 'YOUR_SUPABASE_ANON_KEY',
        'Authorization': `Bearer ${session.access_token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(updates)
    }
  )

  if (!response.ok) {
    const error = await response.json()
    return { success: false, error: error.message || 'Update failed' }
  }

  const user = await response.json()
  return { success: true, user }
}

// Usage
await updateUserProfile({ password: 'NewSecurePassword123!' })
await updateUserProfile({ email: 'newemail@example.com' })
await updateUserProfile({ phone: '+15551234567' })
```

---

## 2. Password Recovery (Magic Link)

For "Forgot Password" functionality, use the password recovery flow.

### 2.1 Client-Side: Request Password Reset Email

```javascript
// Using Supabase Client
async function requestPasswordReset(email) {
  const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: 'https://admin.menu.ca/reset-password'  // Your reset page URL
  })
  
  if (error) {
    return { success: false, error: error.message }
  }
  
  return { success: true, message: 'Password reset email sent' }
}
```

### 2.2 Handle the Reset Link

When user clicks the email link, they're redirected to your `redirectTo` URL with tokens in the URL hash:

```
https://admin.menu.ca/reset-password#access_token=xxx&refresh_token=xxx&type=recovery
```

**On your reset password page:**

```javascript
// Extract tokens and set session
async function handlePasswordReset() {
  // Supabase client automatically handles the URL hash
  const { data: { session }, error } = await supabase.auth.getSession()
  
  if (error || !session) {
    return { success: false, error: 'Invalid or expired reset link' }
  }
  
  // User is now authenticated with a recovery session
  // Show password reset form
  return { success: true, canResetPassword: true }
}

// After user enters new password
async function setNewPassword(newPassword) {
  const { data, error } = await supabase.auth.updateUser({
    password: newPassword
  })
  
  if (error) {
    return { success: false, error: error.message }
  }
  
  return { success: true, message: 'Password updated successfully' }
}
```

### 2.3 Complete Password Reset Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        PASSWORD RECOVERY FLOW                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   1. User clicks "Forgot Password" on login page                            │
│      ↓                                                                       │
│   2. Frontend calls: supabase.auth.resetPasswordForEmail(email)             │
│      ↓                                                                       │
│   3. Supabase sends email with magic link                                   │
│      ↓                                                                       │
│   4. User clicks link → redirected to your reset page with tokens           │
│      ↓                                                                       │
│   5. Frontend calls: supabase.auth.getSession() to validate tokens          │
│      ↓                                                                       │
│   6. User enters new password                                                │
│      ↓                                                                       │
│   7. Frontend calls: supabase.auth.updateUser({ password: newPassword })    │
│      ↓                                                                       │
│   8. Password updated, user can log in with new password                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Server-Side Admin Operations (Edge Function)

For operations that require admin privileges (updating other users, bypassing email confirmation), use an Edge Function.

### 3.1 Edge Function: `update-admin-profile`

**Location:** `supabase/functions/update-admin-profile/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get the JWT from the request
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Missing authorization header')
    }

    // Create client with user's JWT to verify identity
    const supabaseUser = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    // Get current user
    const { data: { user }, error: userError } = await supabaseUser.auth.getUser()
    if (userError || !user) {
      throw new Error('Invalid token')
    }

    // Parse request body
    const { email, phone, password } = await req.json()

    // Validate at least one field is being updated
    if (!email && !phone && !password) {
      throw new Error('No fields to update')
    }

    // Create admin client with service role
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { auth: { autoRefreshToken: false, persistSession: false } }
    )

    // Build update payload
    const updates: any = {}
    if (email) {
      updates.email = email
      updates.email_confirm = true  // Skip email verification (admin privilege)
    }
    if (phone) updates.phone = phone
    if (password) updates.password = password

    // Update the user (only their own account)
    const { data, error } = await supabaseAdmin.auth.admin.updateUserById(
      user.id,  // Only update the authenticated user's own account
      updates
    )

    if (error) {
      throw error
    }

    // Also update admin_users table if email changed
    if (email) {
      await supabaseAdmin
        .from('admin_users')
        .update({ email: email, updated_at: new Date().toISOString() })
        .eq('auth_user_id', user.id)
    }

    return new Response(
      JSON.stringify({ success: true, user: data.user }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { 
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
```

### 3.2 Frontend: Call Edge Function

```javascript
async function updateProfileViaEdgeFunction({ email, phone, password }) {
  const { data: { session } } = await supabase.auth.getSession()
  
  if (!session) {
    return { success: false, error: 'Not authenticated' }
  }

  const response = await fetch(
    'https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/update-admin-profile',
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${session.access_token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ email, phone, password })
    }
  )

  const result = await response.json()
  return result
}
```

---

## 4. Admin Generate Magic Link (Server-Side Only)

For Super Admins to generate password reset links without sending emails.

### 4.1 Edge Function: `generate-admin-link`

```typescript
// Only Super Admins (role_id = 1) can call this
const { data: adminUser } = await supabaseAdmin
  .from('admin_users')
  .select('role_id')
  .eq('auth_user_id', user.id)
  .single()

if (adminUser?.role_id !== 1) {
  throw new Error('Unauthorized: Super Admin only')
}

// Generate the link
const { data, error } = await supabaseAdmin.auth.admin.generateLink({
  type: 'recovery',
  email: targetEmail,
  options: {
    redirectTo: 'https://admin.menu.ca/reset-password'
  }
})

// Returns: data.properties.action_link (the magic link URL)
```

---

## 5. UI Component Example (React)

```jsx
import { useState } from 'react'
import { supabase } from '../lib/supabase'

export function ProfileSettings() {
  const [email, setEmail] = useState('')
  const [phone, setPhone] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')

  const handleUpdateEmail = async () => {
    setLoading(true)
    const { error } = await supabase.auth.updateUser({ email })
    setLoading(false)
    
    if (error) {
      setMessage(`Error: ${error.message}`)
    } else {
      setMessage('Confirmation email sent to your new address')
    }
  }

  const handleUpdatePassword = async () => {
    if (password !== confirmPassword) {
      setMessage('Passwords do not match')
      return
    }
    
    if (password.length < 8) {
      setMessage('Password must be at least 8 characters')
      return
    }

    setLoading(true)
    const { error } = await supabase.auth.updateUser({ password })
    setLoading(false)

    if (error) {
      setMessage(`Error: ${error.message}`)
    } else {
      setMessage('Password updated successfully')
      setPassword('')
      setConfirmPassword('')
    }
  }

  const handleUpdatePhone = async () => {
    setLoading(true)
    const { error } = await supabase.auth.updateUser({ phone })
    setLoading(false)

    if (error) {
      setMessage(`Error: ${error.message}`)
    } else {
      setMessage('Phone updated successfully')
    }
  }

  return (
    <div className="profile-settings">
      <h2>Profile Settings</h2>
      
      {message && <div className="alert">{message}</div>}

      {/* Email Section */}
      <section>
        <h3>Change Email</h3>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="New email address"
        />
        <button onClick={handleUpdateEmail} disabled={loading || !email}>
          Update Email
        </button>
        <p className="hint">You'll receive confirmation emails at both addresses</p>
      </section>

      {/* Password Section */}
      <section>
        <h3>Change Password</h3>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="New password"
        />
        <input
          type="password"
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
          placeholder="Confirm new password"
        />
        <button onClick={handleUpdatePassword} disabled={loading || !password}>
          Update Password
        </button>
      </section>

      {/* Phone Section */}
      <section>
        <h3>Change Phone</h3>
        <input
          type="tel"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
          placeholder="+1 555 123 4567"
        />
        <button onClick={handleUpdatePhone} disabled={loading || !phone}>
          Update Phone
        </button>
      </section>
    </div>
  )
}
```

---

## 6. Password Reset Page Example

```jsx
import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { useNavigate } from 'react-router-dom'

export function ResetPassword() {
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [loading, setLoading] = useState(true)
  const [canReset, setCanReset] = useState(false)
  const [message, setMessage] = useState('')
  const navigate = useNavigate()

  useEffect(() => {
    // Check if we have a valid recovery session
    const checkSession = async () => {
      const { data: { session } } = await supabase.auth.getSession()
      
      if (session) {
        setCanReset(true)
      } else {
        setMessage('Invalid or expired reset link')
      }
      setLoading(false)
    }

    checkSession()
  }, [])

  const handleResetPassword = async () => {
    if (password !== confirmPassword) {
      setMessage('Passwords do not match')
      return
    }

    setLoading(true)
    const { error } = await supabase.auth.updateUser({ password })
    setLoading(false)

    if (error) {
      setMessage(`Error: ${error.message}`)
    } else {
      setMessage('Password updated successfully! Redirecting...')
      setTimeout(() => navigate('/login'), 2000)
    }
  }

  if (loading) {
    return <div>Loading...</div>
  }

  if (!canReset) {
    return (
      <div>
        <h2>Password Reset</h2>
        <p className="error">{message}</p>
        <a href="/forgot-password">Request a new reset link</a>
      </div>
    )
  }

  return (
    <div className="reset-password">
      <h2>Set New Password</h2>
      
      {message && <div className="alert">{message}</div>}

      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="New password"
        minLength={8}
      />
      <input
        type="password"
        value={confirmPassword}
        onChange={(e) => setConfirmPassword(e.target.value)}
        placeholder="Confirm new password"
      />
      <button onClick={handleResetPassword} disabled={loading || !password}>
        Reset Password
      </button>
    </div>
  )
}
```

---

## 7. Summary: Which Method to Use

| Scenario | Method | Endpoint/Function |
|----------|--------|-------------------|
| User updates own password | Client-side | `supabase.auth.updateUser()` |
| User updates own email | Client-side | `supabase.auth.updateUser()` |
| User updates own phone | Client-side | `supabase.auth.updateUser()` |
| User forgot password | Client-side | `supabase.auth.resetPasswordForEmail()` |
| Admin updates user + skips verification | Edge Function | `update-admin-profile` |
| Super Admin generates reset link | Edge Function | `generate-admin-link` |

---

## 8. Environment Variables Needed

```env
# Frontend (.env)
VITE_SUPABASE_URL=https://nthpbtdjhhnwfxqsxbvy.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...

# Edge Functions (automatically available)
SUPABASE_URL=https://nthpbtdjhhnwfxqsxbvy.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIs... # Never expose to frontend!
```

---

**Last Updated:** 2026-01-28  
**Author:** Database Administration
