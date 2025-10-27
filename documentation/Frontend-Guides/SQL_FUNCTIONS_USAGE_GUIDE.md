# SQL Functions Usage Guide for Frontend

**For:** Brian (Frontend Developer)  
**Date:** October 23, 2025  
**Status:** ✅ All 9 functions now accessible via `supabase.rpc()`

---

## 🎯 Quick Overview

All SQL functions are now in the `public` schema and accessible directly from your frontend code using `supabase.rpc()`.

**Pattern:**
```typescript
const { data, error } = await supabase.rpc('function_name', { parameters });
```

**No Next.js API routes needed!** ✅

---

## 📋 Available Functions (9 Total)

### **Customer Functions (4)**
1. `get_user_profile()` - Get logged-in customer's profile
2. `get_user_addresses()` - Get customer's delivery addresses
3. `get_favorite_restaurants()` - Get customer's favorite restaurants
4. `toggle_favorite_restaurant()` - Add/remove a favorite

### **Admin Functions (2)**
5. `get_admin_profile()` - Get logged-in admin's profile
6. `get_admin_restaurants()` - Get admin's assigned restaurants

### **Auth/Migration Functions (3)**
7. `check_legacy_user()` - Check if email is legacy user (pre-login)
8. `link_auth_user_id()` - Link auth account (internal use)
9. `get_legacy_migration_stats()` - Get migration stats (admin only)

---

## 🔐 Authentication Required

**Most functions require the user to be logged in:**
```typescript
// User must be authenticated
const { data: { user } } = await supabase.auth.getUser();
if (!user) {
  // Redirect to login
}
```

**Exception:** `check_legacy_user()` can be called before login.

---

## 📖 Function Reference

### **1. get_user_profile()**

**Purpose:** Get the logged-in customer's profile information.

**When to call:**
- On profile page load
- After login to display user info
- Before showing personalized content

**Usage:**
```typescript
const { data: profile, error } = await supabase.rpc('get_user_profile');

if (error) {
  console.error('Error fetching profile:', error);
  return;
}

console.log(profile);
// Returns:
// {
//   id: 12345,
//   email: 'customer@example.com',
//   first_name: 'John',
//   last_name: 'Doe',
//   display_name: 'John D.',
//   phone: '+1-555-0100',
//   language: 'en',
//   credit_balance: 10.50,
//   last_login_at: '2025-10-23T10:30:00Z',
//   created_at: '2024-01-15T08:00:00Z'
// }
```

**Returns:** Single object or `null` if not found

**React Example:**
```typescript
'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';

export default function ProfilePage() {
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const supabase = createClient();

  useEffect(() => {
    async function loadProfile() {
      const { data, error } = await supabase.rpc('get_user_profile');
      
      if (error) {
        console.error('Error:', error);
      } else {
        setProfile(data);
      }
      
      setLoading(false);
    }

    loadProfile();
  }, []);

  if (loading) return <div>Loading...</div>;
  if (!profile) return <div>Profile not found</div>;

  return (
    <div>
      <h1>Welcome, {profile.first_name}!</h1>
      <p>Email: {profile.email}</p>
      <p>Credit: ${profile.credit_balance}</p>
    </div>
  );
}
```

---

### **2. get_user_addresses()**

**Purpose:** Get all delivery addresses for the logged-in customer.

**When to call:**
- On checkout page
- In address management page
- When selecting delivery location

**Usage:**
```typescript
const { data: addresses, error } = await supabase.rpc('get_user_addresses');

console.log(addresses);
// Returns array:
// [
//   {
//     id: 1,
//     street_address: '123 Main St',
//     unit: 'Apt 4B',
//     address_label: 'Home',
//     city_id: 5,
//     city_name: 'Toronto',
//     province_id: 1,
//     province_name: 'Ontario',
//     postal_code: 'M5V 1A1',
//     latitude: 43.6426,
//     longitude: -79.3871,
//     is_default: true,
//     delivery_instructions: 'Ring buzzer'
//   },
//   // ... more addresses
// ]
```

**Returns:** Array (empty if no addresses)

**React Example:**
```typescript
export default function AddressSelector() {
  const [addresses, setAddresses] = useState([]);
  const supabase = createClient();

  useEffect(() => {
    async function loadAddresses() {
      const { data } = await supabase.rpc('get_user_addresses');
      setAddresses(data || []);
    }
    loadAddresses();
  }, []);

  return (
    <div>
      <h2>Select Delivery Address</h2>
      {addresses.length === 0 && <p>No addresses yet</p>}
      
      {addresses.map((addr) => (
        <div key={addr.id} className={addr.is_default ? 'default' : ''}>
          <strong>{addr.address_label}</strong>
          <p>{addr.street_address} {addr.unit}</p>
          <p>{addr.city_name}, {addr.province_name} {addr.postal_code}</p>
          {addr.is_default && <span>Default ✓</span>}
        </div>
      ))}
    </div>
  );
}
```

---

### **3. get_favorite_restaurants()**

**Purpose:** Get the logged-in customer's favorite restaurants.

**When to call:**
- On "My Favorites" page
- In restaurant list (to show heart icons)
- When displaying personalized recommendations

**Usage:**
```typescript
const { data: favorites, error } = await supabase.rpc('get_favorite_restaurants');

console.log(favorites);
// Returns array:
// [
//   {
//     restaurant_id: 83,
//     restaurant_name: 'Pizza Place',
//     restaurant_slug: 'pizza-place',
//     favorited_at: '2025-10-20T15:30:00Z'
//   },
//   // ... more favorites
// ]
```

**Returns:** Array (empty if no favorites)

**React Example:**
```typescript
export default function FavoritesPage() {
  const [favorites, setFavorites] = useState([]);
  const supabase = createClient();

  useEffect(() => {
    async function loadFavorites() {
      const { data } = await supabase.rpc('get_favorite_restaurants');
      setFavorites(data || []);
    }
    loadFavorites();
  }, []);

  return (
    <div>
      <h1>My Favorite Restaurants</h1>
      {favorites.length === 0 && <p>No favorites yet</p>}
      
      {favorites.map((fav) => (
        <div key={fav.restaurant_id}>
          <h3>{fav.restaurant_name}</h3>
          <a href={`/restaurants/${fav.restaurant_slug}`}>View Menu</a>
        </div>
      ))}
    </div>
  );
}
```

---

### **4. toggle_favorite_restaurant()**

**Purpose:** Add or remove a restaurant from favorites (smart toggle).

**When to call:**
- When user clicks heart/favorite button
- Function automatically detects if adding or removing

**Usage:**
```typescript
const { data: result, error } = await supabase.rpc('toggle_favorite_restaurant', {
  p_restaurant_id: 83
});

console.log(result);
// Returns:
// {
//   action: 'added',      // or 'removed'
//   restaurant_id: 83
// }
```

**Parameters:**
- `p_restaurant_id` (required): Restaurant ID to toggle

**Returns:** Object with `action` ('added' or 'removed') and `restaurant_id`

**React Example:**
```typescript
export default function RestaurantCard({ restaurant }) {
  const [isFavorite, setIsFavorite] = useState(false);
  const [loading, setLoading] = useState(false);
  const supabase = createClient();

  async function toggleFavorite() {
    setLoading(true);
    
    const { data, error } = await supabase.rpc('toggle_favorite_restaurant', {
      p_restaurant_id: restaurant.id
    });

    if (error) {
      console.error('Error:', error);
    } else {
      setIsFavorite(data.action === 'added');
    }
    
    setLoading(false);
  }

  return (
    <div>
      <h3>{restaurant.name}</h3>
      <button onClick={toggleFavorite} disabled={loading}>
        {isFavorite ? '❤️ Unfavorite' : '🤍 Favorite'}
      </button>
    </div>
  );
}
```

---

### **5. get_admin_profile()**

**Purpose:** Get the logged-in admin's profile information.

**When to call:**
- On admin dashboard load
- To display admin name in header
- To check admin permissions

**Usage:**
```typescript
const { data: adminProfile, error } = await supabase.rpc('get_admin_profile');

console.log(adminProfile);
// Returns:
// {
//   id: 1,
//   email: 'admin@restaurant.com',
//   first_name: 'Jane',
//   last_name: 'Smith',
//   last_login_at: '2025-10-23T09:00:00Z',
//   mfa_enabled: true,
//   is_active: true,
//   status: 'active',
//   created_at: '2024-01-01T00:00:00Z'
// }
```

**Returns:** Single object or `null` if not an admin

---

### **6. get_admin_restaurants()**

**Purpose:** Get all restaurants assigned to the logged-in admin.

**When to call:**
- On admin dashboard load
- To populate restaurant selector
- To check which restaurants admin can manage

**Usage:**
```typescript
const { data: restaurants, error } = await supabase.rpc('get_admin_restaurants');

console.log(restaurants);
// Returns array:
// [
//   {
//     restaurant_id: 83,
//     restaurant_name: 'Pizza Place',
//     restaurant_slug: 'pizza-place',
//     restaurant_phone: '+1-555-0123',
//     restaurant_email: 'info@pizza.com',
//     assigned_at: '2024-06-01T00:00:00Z'
//   },
//   // ... more restaurants
// ]
```

**Returns:** Array (empty if admin has no restaurants)

**React Example:**
```typescript
export default function AdminDashboard() {
  const [restaurants, setRestaurants] = useState([]);
  const supabase = createClient();

  useEffect(() => {
    async function loadRestaurants() {
      const { data } = await supabase.rpc('get_admin_restaurants');
      setRestaurants(data || []);
    }
    loadRestaurants();
  }, []);

  return (
    <div>
      <h1>Your Restaurants</h1>
      {restaurants.map((rest) => (
        <div key={rest.restaurant_id}>
          <h3>{rest.restaurant_name}</h3>
          <a href={`/admin/restaurant/${rest.restaurant_slug}`}>Manage</a>
        </div>
      ))}
    </div>
  );
}
```

---

### **7. check_legacy_user()** 🔓 (No auth required)

**Purpose:** Check if an email belongs to a legacy user who needs password reset.

**When to call:**
- On login page (before attempting login)
- To detect if user needs to go through password reset flow

**Usage:**
```typescript
const { data: result, error } = await supabase.rpc('check_legacy_user', {
  p_email: 'user@example.com'
});

console.log(result);
// Returns:
// {
//   is_legacy: true,
//   user_id: 12345,
//   first_name: 'John',
//   last_name: 'Doe',
//   user_type: 'customer'  // or 'admin'
// }
```

**Parameters:**
- `p_email` (required): Email to check

**Returns:** Object with legacy user info or `is_legacy: false`

**React Example:**
```typescript
export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [showPasswordReset, setShowPasswordReset] = useState(false);
  const supabase = createClient();

  async function handleEmailChange(e) {
    const newEmail = e.target.value;
    setEmail(newEmail);

    if (newEmail.includes('@')) {
      const { data } = await supabase.rpc('check_legacy_user', {
        p_email: newEmail
      });

      if (data?.is_legacy) {
        setShowPasswordReset(true);
      }
    }
  }

  return (
    <form>
      <input
        type="email"
        value={email}
        onChange={handleEmailChange}
        placeholder="Email"
      />
      
      {showPasswordReset && (
        <div className="alert">
          <p>Welcome back! Please reset your password to continue.</p>
          <button>Send Password Reset Email</button>
        </div>
      )}
    </form>
  );
}
```

---

### **8. link_auth_user_id()** 🔒 (Service role only)

**Purpose:** Link a legacy user to a new auth account (internal use).

**When to call:** ⚠️ **Do NOT call from frontend!** This is used internally by the `complete-legacy-migration` Edge Function.

**Usage:** Backend/Edge Function only
```typescript
// This runs in an Edge Function, not in frontend
const { data, error } = await supabaseAdmin.rpc('link_auth_user_id', {
  p_email: 'user@example.com',
  p_auth_user_id: 'uuid-here',
  p_user_type: 'customer'
});
```

---

### **9. get_legacy_migration_stats()** 👨‍💼 (Admin only)

**Purpose:** Get statistics about legacy user migration progress.

**When to call:**
- On admin dashboard
- In migration status page
- For reporting

**Usage:**
```typescript
const { data: stats, error } = await supabase.rpc('get_legacy_migration_stats');

console.log(stats);
// Returns:
// {
//   unmigrated_customers: 150,
//   unmigrated_admins: 5,
//   active_unmigrated_customers: 50,
//   active_unmigrated_admins: 2,
//   total_unmigrated: 155
// }
```

**Returns:** Object with migration counts

---

## 🔧 Error Handling

**Always check for errors:**
```typescript
const { data, error } = await supabase.rpc('function_name');

if (error) {
  console.error('Error calling function:', error);
  
  // Common errors:
  if (error.code === 'PGRST301') {
    // Not authenticated
    router.push('/login');
  } else if (error.message.includes('User not found')) {
    // User doesn't exist
  }
  
  return;
}

// Use data
console.log(data);
```

---

## ⚡ Performance Tips

1. **Cache results** when data doesn't change often:
```typescript
// Use React Query or SWR
import useSWR from 'swr';

const fetcher = () => supabase.rpc('get_user_profile').then(res => res.data);
const { data: profile } = useSWR('profile', fetcher);
```

2. **Call functions in parallel** when you need multiple:
```typescript
const [profileResult, addressesResult, favoritesResult] = await Promise.all([
  supabase.rpc('get_user_profile'),
  supabase.rpc('get_user_addresses'),
  supabase.rpc('get_favorite_restaurants')
]);
```

3. **Use loading states** to improve UX:
```typescript
const [loading, setLoading] = useState(true);

useEffect(() => {
  async function load() {
    setLoading(true);
    const { data } = await supabase.rpc('get_user_profile');
    setProfile(data);
    setLoading(false);
  }
  load();
}, []);
```

---

## 🐛 Common Issues & Solutions

### **Issue: "function does not exist"**
**Solution:** Make sure you're calling the correct function name (lowercase, underscores)

### **Issue: "Unauthorized" or "permission denied"**
**Solution:** User must be logged in first:
```typescript
const { data: { user } } = await supabase.auth.getUser();
if (!user) {
  // Redirect to login
}
```

### **Issue: "User not found" error**
**Solution:** This happens if the user profile doesn't exist in `menuca_v3.users`. Check that the signup trigger is working.

### **Issue: Function returns null
**Solution:** This is normal if no data exists (e.g., no addresses). Check with:
```typescript
const { data } = await supabase.rpc('get_user_addresses');
if (!data || data.length === 0) {
  // Show empty state
}
```

---

## 📚 Summary Table

| Function | Auth Required | Returns | Use Case |
|----------|--------------|---------|----------|
| `get_user_profile()` | ✅ Yes | Object | Profile page |
| `get_user_addresses()` | ✅ Yes | Array | Checkout, address list |
| `get_favorite_restaurants()` | ✅ Yes | Array | Favorites page |
| `toggle_favorite_restaurant()` | ✅ Yes | Object | Heart button |
| `check_legacy_user()` | ❌ No | Object | Login page |
| `link_auth_user_id()` | 🔒 Service only | Object | Internal only |
| `get_admin_profile()` | ✅ Yes | Object | Admin dashboard |
| `get_admin_restaurants()` | ✅ Yes | Array | Admin restaurant list |
| `get_legacy_migration_stats()` | ✅ Yes | Object | Admin reports |

---

## 🎉 You're Ready!

All functions are now accessible via `supabase.rpc()`. No Next.js API routes needed!

**Questions?** Check the main integration guide or ask Santiago.

---

**Last Updated:** October 23, 2025  
**Migration:** ✅ Complete (functions moved to public schema)  
**Status:** ✅ Production Ready

