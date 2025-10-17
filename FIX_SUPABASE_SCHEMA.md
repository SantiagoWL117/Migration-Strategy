# 🔧 Fix Supabase Schema Configuration

## 🎯 Problem
Your database uses the `menuca_v3` schema, but Supabase's PostgREST API only exposes the `public` schema by default.

**Error:** `"Could not find the table 'public.restaurants' in the schema cache"`

---

## ✅ SOLUTION: Expose menuca_v3 Schema

### Method 1: Configure Supabase Settings (RECOMMENDED) ⭐

**Time: 2 minutes**

1. **Open Supabase Dashboard:**
   - Go to: https://supabase.com/dashboard/project/nthpbtdjhhnwfxqsxbvy
   - Or: https://app.supabase.com/project/nthpbtdjhhnwfxqsxbvy

2. **Navigate to API Settings:**
   - Click **Settings** (gear icon in left sidebar)
   - Click **API** in the settings menu

3. **Find "Exposed schemas":**
   - Scroll down to **"Schema Settings"** or **"API Settings"**
   - Look for **"Exposed schemas"** field

4. **Add menuca_v3 schema:**
   - Current value: `public, graphql_public`
   - Change to: `public, graphql_public, menuca_v3`
   - Or add: `menuca_v3` to the list (comma-separated)

5. **Save and Wait:**
   - Click **Save**
   - Wait 30-60 seconds for PostgREST to restart
   - The API will refresh automatically

6. **Test the Connection:**
   - Go to: http://localhost:5000/api/test-connection
   - Should now return: `{ "success": true, "counts": { "restaurants": 74, "users": 32349 } }`

---

### Method 2: Create Public Schema Views (WORKAROUND)

**Only if you can't access Supabase settings!**

**Time: 5 minutes**

Run this SQL in your Supabase SQL Editor:

```sql
-- Create views in public schema that point to menuca_v3 tables
CREATE OR REPLACE VIEW public.restaurants AS 
SELECT * FROM menuca_v3.restaurants;

CREATE OR REPLACE VIEW public.users AS 
SELECT * FROM menuca_v3.users;

CREATE OR REPLACE VIEW public.orders AS 
SELECT * FROM menuca_v3.orders;

CREATE OR REPLACE VIEW public.restaurant_locations AS 
SELECT * FROM menuca_v3.restaurant_locations;

CREATE OR REPLACE VIEW public.restaurant_contacts AS 
SELECT * FROM menuca_v3.restaurant_contacts;

CREATE OR REPLACE VIEW public.restaurant_domains AS 
SELECT * FROM menuca_v3.restaurant_domains;

CREATE OR REPLACE VIEW public.restaurant_schedules AS 
SELECT * FROM menuca_v3.restaurant_schedules;

CREATE OR REPLACE VIEW public.restaurant_service_configs AS 
SELECT * FROM menuca_v3.restaurant_service_configs;

CREATE OR REPLACE VIEW public.restaurant_payment_methods AS 
SELECT * FROM menuca_v3.restaurant_payment_methods;

CREATE OR REPLACE VIEW public.restaurant_integrations AS 
SELECT * FROM menuca_v3.restaurant_integrations;

CREATE OR REPLACE VIEW public.restaurant_seo AS 
SELECT * FROM menuca_v3.restaurant_seo;

CREATE OR REPLACE VIEW public.restaurant_images AS 
SELECT * FROM menuca_v3.restaurant_images;

CREATE OR REPLACE VIEW public.restaurant_feedback AS 
SELECT * FROM menuca_v3.restaurant_feedback;

CREATE OR REPLACE VIEW public.restaurant_custom_css AS 
SELECT * FROM menuca_v3.restaurant_custom_css;

CREATE OR REPLACE VIEW public.delivery_areas AS 
SELECT * FROM menuca_v3.delivery_areas;

CREATE OR REPLACE VIEW public.courses AS 
SELECT * FROM menuca_v3.courses;

CREATE OR REPLACE VIEW public.dishes AS 
SELECT * FROM menuca_v3.dishes;

CREATE OR REPLACE VIEW public.promotional_coupons AS 
SELECT * FROM menuca_v3.promotional_coupons;

CREATE OR REPLACE VIEW public.admin_users AS 
SELECT * FROM menuca_v3.admin_users;

-- Add more views for other tables as needed
```

**Pros:** Works immediately  
**Cons:** Requires creating views for every table (tedious)

---

## 🧪 VERIFY THE FIX WORKED

After applying either method, test the connection:

```bash
# Visit in browser:
http://localhost:5000/api/test-connection

# Expected response:
{
  "success": true,
  "connection": "CONNECTED",
  "sampleRestaurants": [
    { "id": 1, "name": "Restaurant 1", "status": "active" },
    { "id": 2, "name": "Restaurant 2", "status": "active" },
    ...
  ],
  "counts": {
    "restaurants": 74,
    "users": 32349
  }
}
```

✅ **If you see your 74 restaurants, the fix worked!**

---

## 📊 WHAT HAPPENS NEXT

Once the schema is exposed:
- ✅ Dashboard will show real data (74 restaurants, 32,349 users)
- ✅ Restaurant list will populate
- ✅ All API queries will work
- ✅ Orders, coupons, users will all load properly

---

## 🚨 IF IT STILL DOESN'T WORK

**Check these:**

1. **Are you using the right Supabase project?**
   - URL should be: `https://nthpbtdjhhnwfxqsxbvy.supabase.co`

2. **Is the ANON_KEY correct in .env.local?**
   - Should be: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

3. **Did PostgREST restart?**
   - Wait 60 seconds after saving settings
   - Or manually restart: Project Settings → General → Restart project

4. **Are RLS policies blocking access?**
   - Temporarily disable RLS for testing: `ALTER TABLE menuca_v3.restaurants DISABLE ROW LEVEL SECURITY;`

---

## 💡 RECOMMENDED APPROACH

**Use Method 1 (Expose Schema)** - It's cleaner, faster, and proper.

Only use Method 2 (Views) if you absolutely can't access Supabase settings.

---

**Let me know once you've applied the fix and the connection test passes!** 🚀

