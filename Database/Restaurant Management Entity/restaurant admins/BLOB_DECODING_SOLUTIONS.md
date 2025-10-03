# BLOB Data Decoding Solutions
## PHP Serialized Arrays → PostgreSQL Relational Tables

**Date:** 2025-10-02  
**Context:** V1 `allowed_restaurants` BLOB field contains PHP serialized arrays  
**Goal:** Decode and store in `menuca_v3.restaurant_admin_access` junction table

---

## 📊 **Problem Statement**

### **Current State:**
```
V1 restaurant_admins.allowed_restaurants: BLOB containing PHP serialized array
Example: _binary 'a:847:{i:0;s:2:"72";i:1;s:2:"89";i:2;s:2:"90";...}'
Represents: Array of 847 restaurant IDs that user can access
```

### **Desired State:**
```sql
-- Relational junction table in Supabase
menuca_v3.restaurant_admin_access (
  id bigint PRIMARY KEY,
  admin_user_id bigint REFERENCES restaurant_admin_users(id),
  restaurant_id bigint REFERENCES restaurants(id),
  granted_at timestamptz DEFAULT now()
)
```

---

## 🎯 **Recommended Solutions**

### **SOLUTION 1: PostgreSQL Serverless Function (Recommended)** ⭐

Use Supabase Edge Functions to decode PHP serialized data directly in the cloud.

#### **Advantages:**
- ✅ Runs in Supabase infrastructure
- ✅ No external dependencies
- ✅ Scalable and serverless
- ✅ Can be triggered via API or RPC call
- ✅ Direct database access via Supabase client

#### **Implementation:**

**Step 1: Create Supabase Edge Function**

```typescript
// supabase/functions/decode-allowed-restaurants/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// PHP unserialize implementation for Deno
function phpUnserialize(str: string): any {
  // Simplified PHP unserialize for arrays
  // Format: a:count:{i:index;s:length:"value";...}
  
  const arrayMatch = str.match(/^a:(\d+):\{(.+)\}$/)
  if (!arrayMatch) return null
  
  const count = parseInt(arrayMatch[1])
  const content = arrayMatch[2]
  const result: any[] = []
  
  // Parse each element: i:index;s:length:"value";
  const elementRegex = /i:(\d+);s:(\d+):"([^"]+)";/g
  let match
  
  while ((match = elementRegex.exec(content)) !== null) {
    const index = parseInt(match[1])
    const value = match[3]
    result[index] = value
  }
  
  return result
}

serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Get all staging records with BLOB data
    const { data: stagingData, error: fetchError } = await supabase
      .from('v1_restaurant_admin_users')
      .select('legacy_admin_id, email, allowed_restaurants')
      .not('allowed_restaurants', 'is', null)

    if (fetchError) throw fetchError

    let processed = 0
    let errors = 0

    for (const record of stagingData) {
      try {
        // Convert bytea to string
        const blobStr = new TextDecoder().decode(record.allowed_restaurants)
        
        // Decode PHP serialized array
        const restaurantIds = phpUnserialize(blobStr)
        
        if (!restaurantIds || restaurantIds.length === 0) {
          console.log(`No restaurant IDs for ${record.email}`)
          continue
        }

        // Get the v3 admin_user_id
        const { data: adminUser } = await supabase
          .from('restaurant_admin_users')
          .select('id')
          .eq('email', record.email.toLowerCase().trim())
          .single()

        if (!adminUser) {
          console.log(`Admin user not found for ${record.email}`)
          errors++
          continue
        }

        // Insert access records for each restaurant
        for (const restId of restaurantIds) {
          if (!restId) continue

          // Resolve V1 restaurant ID to V3 restaurant ID
          const { data: restaurant } = await supabase
            .from('restaurants')
            .select('id')
            .eq('legacy_v1_id', parseInt(restId))
            .single()

          if (!restaurant) {
            console.log(`Restaurant not found for V1 ID ${restId}`)
            continue
          }

          // Insert access record
          const { error: insertError } = await supabase
            .from('restaurant_admin_access')
            .insert({
              admin_user_id: adminUser.id,
              restaurant_id: restaurant.id,
              granted_at: new Date().toISOString()
            })
            .onConflict('admin_user_id, restaurant_id')
            .ignoreDuplicates()

          if (insertError && insertError.code !== '23505') { // Ignore duplicate errors
            console.error(`Insert error for ${record.email}:`, insertError)
          }
        }

        processed++
        console.log(`Processed ${record.email}: ${restaurantIds.length} restaurants`)

      } catch (err) {
        console.error(`Error processing ${record.email}:`, err)
        errors++
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        processed, 
        errors,
        total: stagingData.length 
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
```

**Step 2: Deploy Edge Function**

```bash
# From your project root
supabase functions deploy decode-allowed-restaurants

# Test the function
curl -X POST \
  'https://nthpbtdjhhnwfxqsxbvy.supabase.co/functions/v1/decode-allowed-restaurants' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'
```

---

### **SOLUTION 2: Python Script with Database Connection** 🐍

Use Python to decode PHP serialized data and insert into Supabase.

#### **Advantages:**
- ✅ Robust PHP deserialization library
- ✅ Direct database connection
- ✅ Good error handling
- ✅ Can run locally or in CI/CD

#### **Implementation:**

**Step 1: Install Dependencies**

```bash
pip install psycopg2-binary phpserialize supabase
```

**Step 2: Python Script**

```python
# decode_allowed_restaurants.py

import psycopg2
from phpserialize import loads
import os

# Database connection
DB_URL = os.getenv('SUPABASE_DB_URL')  # postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres

conn = psycopg2.connect(DB_URL)
cursor = conn.cursor()

def decode_php_array(blob_data):
    """Decode PHP serialized array from BLOB"""
    try:
        if not blob_data:
            return []
        
        # Convert bytes to PHP serialized string
        php_str = blob_data.decode('latin-1')
        
        # Deserialize PHP array
        data = loads(php_str.encode('latin-1'))
        
        # Extract restaurant IDs
        if isinstance(data, dict):
            return [int(v.decode()) if isinstance(v, bytes) else int(v) 
                    for v in data.values()]
        return []
    except Exception as e:
        print(f"Decode error: {e}")
        return []

def main():
    # Get all staging records with BLOB data
    cursor.execute("""
        SELECT 
            s.legacy_admin_id,
            s.email,
            s.allowed_restaurants
        FROM staging.v1_restaurant_admin_users s
        WHERE s.allowed_restaurants IS NOT NULL
          AND s.legacy_v1_restaurant_id > 0
    """)
    
    records = cursor.fetchall()
    print(f"Processing {len(records)} records...")
    
    processed = 0
    errors = 0
    
    for legacy_id, email, blob_data in records:
        try:
            # Decode PHP array
            restaurant_ids = decode_php_array(blob_data)
            
            if not restaurant_ids:
                print(f"No restaurants for {email}")
                continue
            
            # Get v3 admin_user_id
            cursor.execute("""
                SELECT id 
                FROM menuca_v3.restaurant_admin_users
                WHERE email = %s
            """, (email.lower().strip(),))
            
            result = cursor.fetchone()
            if not result:
                print(f"Admin user not found: {email}")
                errors += 1
                continue
            
            admin_user_id = result[0]
            
            # Insert access records
            inserted = 0
            for rest_v1_id in restaurant_ids:
                try:
                    cursor.execute("""
                        INSERT INTO menuca_v3.restaurant_admin_access 
                            (admin_user_id, restaurant_id)
                        SELECT %s, r.id
                        FROM menuca_v3.restaurants r
                        WHERE r.legacy_v1_id = %s
                        ON CONFLICT (admin_user_id, restaurant_id) DO NOTHING
                        RETURNING id
                    """, (admin_user_id, rest_v1_id))
                    
                    if cursor.fetchone():
                        inserted += 1
                        
                except psycopg2.Error as e:
                    print(f"Insert error for restaurant {rest_v1_id}: {e}")
            
            conn.commit()
            processed += 1
            print(f"✓ {email}: {inserted}/{len(restaurant_ids)} restaurants")
            
        except Exception as e:
            print(f"Error processing {email}: {e}")
            errors += 1
            conn.rollback()
    
    print(f"\nComplete! Processed: {processed}, Errors: {errors}")
    
    cursor.close()
    conn.close()

if __name__ == '__main__':
    main()
```

**Step 3: Run Script**

```bash
export SUPABASE_DB_URL="postgresql://postgres:[password]@db.nthpbtdjhhnwfxqsxbvy.supabase.co:5432/postgres"
python decode_allowed_restaurants.py
```

---

### **SOLUTION 3: PostgreSQL Function with PL/Python** 🔧

Create a PostgreSQL function to decode PHP arrays directly in the database.

#### **Advantages:**
- ✅ Runs entirely in database
- ✅ Can be called via SQL
- ✅ No external scripts needed

#### **Prerequisites:**
```sql
-- Enable PL/Python extension (requires Supabase Pro or self-hosted)
CREATE EXTENSION IF NOT EXISTS plpython3u;
```

#### **Implementation:**

```sql
CREATE OR REPLACE FUNCTION decode_php_serialized_array(blob_data bytea)
RETURNS integer[]
LANGUAGE plpython3u
AS $$
    import re
    
    if not blob_data:
        return []
    
    # Convert bytes to string
    php_str = blob_data.decode('latin-1')
    
    # Simple regex parser for PHP serialized arrays
    # Format: a:count:{i:index;s:length:"value";...}
    array_match = re.match(r'^a:(\d+):\{(.+)\}$', php_str)
    if not array_match:
        return []
    
    content = array_match.group(2)
    result = []
    
    # Extract each element: i:index;s:length:"value";
    for match in re.finditer(r'i:(\d+);s:(\d+):"([^"]+)";', content):
        value = match.group(3)
        try:
            result.append(int(value))
        except ValueError:
            pass
    
    return result
$$;

-- Use the function to populate junction table
INSERT INTO menuca_v3.restaurant_admin_access (admin_user_id, restaurant_id)
SELECT DISTINCT
    au.id AS admin_user_id,
    r.id AS restaurant_id
FROM staging.v1_restaurant_admin_users s
JOIN menuca_v3.restaurant_admin_users au 
    ON au.email = lower(trim(s.email))
CROSS JOIN LATERAL unnest(decode_php_serialized_array(s.allowed_restaurants)) AS v1_rest_id
JOIN menuca_v3.restaurants r 
    ON r.legacy_v1_id = v1_rest_id
WHERE s.legacy_v1_restaurant_id > 0
ON CONFLICT (admin_user_id, restaurant_id) DO NOTHING;
```

---

### **SOLUTION 4: Node.js Script** 🟢

Use Node.js with `serialize-php` library.

```javascript
// decode-blob.js
const { createClient } = require('@supabase/supabase-js')
const { unserialize } = require('serialize-php')

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

async function decodeAllowedRestaurants() {
  // Get staging data
  const { data: staging } = await supabase
    .from('v1_restaurant_admin_users')
    .select('legacy_admin_id, email, allowed_restaurants')
    .not('allowed_restaurants', 'is', null)

  for (const record of staging) {
    try {
      // Decode PHP serialized BLOB
      const restaurantIds = unserialize(record.allowed_restaurants)
      
      // Get admin user ID
      const { data: adminUser } = await supabase
        .from('restaurant_admin_users')
        .select('id')
        .eq('email', record.email.toLowerCase())
        .single()

      if (!adminUser) continue

      // Insert access records
      for (const restId of Object.values(restaurantIds)) {
        await supabase.rpc('insert_admin_access', {
          p_admin_user_id: adminUser.id,
          p_v1_restaurant_id: parseInt(restId)
        })
      }
      
      console.log(`✓ Processed ${record.email}`)
    } catch (err) {
      console.error(`Error: ${record.email}`, err)
    }
  }
}

decodeAllowedRestaurants()
```

---

## 📋 **Comparison Matrix**

| Solution | Complexity | Performance | Infrastructure | Recommended For |
|----------|------------|-------------|----------------|-----------------|
| **Supabase Edge Function** | Medium | Good | Supabase Cloud | ⭐ Production |
| **Python Script** | Low | Excellent | Local/CI-CD | Development/Testing |
| **PL/Python** | High | Excellent | Supabase Pro+ | Self-hosted only |
| **Node.js** | Low | Good | Local/CI-CD | Quick migration |

---

## ✅ **Recommended Approach**

### **For Supabase Cloud (Your Case):**

1. **Step 1:** Use **Python Script** (Solution 2) for initial migration
   - Easy to debug
   - Robust error handling
   - Can run locally

2. **Step 2:** Create **Supabase Edge Function** (Solution 1) for ongoing needs
   - Future-proof
   - Can be triggered via API
   - Scalable

---

## 🚀 **Execution Plan**

### **Phase 1: One-Time Migration (Use Python)**
```bash
# 1. Install dependencies
pip install psycopg2-binary phpserialize

# 2. Get database connection string from Supabase dashboard
#    Settings > Database > Connection string (Direct connection)

# 3. Run script
export SUPABASE_DB_URL="your_connection_string"
python decode_allowed_restaurants.py

# 4. Verify results
psql $SUPABASE_DB_URL -c "SELECT COUNT(*) FROM menuca_v3.restaurant_admin_access;"
```

### **Phase 2: Future Use (Edge Function)**
- Deploy Edge Function for any future BLOB decoding needs
- Can be triggered manually or via webhook

---

## 📊 **Verification Queries**

```sql
-- Count total access grants
SELECT COUNT(*) AS total_grants
FROM menuca_v3.restaurant_admin_access;

-- Users with multi-restaurant access
SELECT 
    au.email,
    COUNT(ara.restaurant_id) AS restaurant_count
FROM menuca_v3.restaurant_admin_users au
JOIN menuca_v3.restaurant_admin_access ara ON ara.admin_user_id = au.id
GROUP BY au.id, au.email
HAVING COUNT(ara.restaurant_id) > 1
ORDER BY restaurant_count DESC;

-- Top users by restaurant access
SELECT 
    au.email,
    au.first_name,
    au.last_name,
    COUNT(ara.restaurant_id) AS access_count,
    array_agg(r.name ORDER BY r.name) AS restaurant_names
FROM menuca_v3.restaurant_admin_users au
JOIN menuca_v3.restaurant_admin_access ara ON ara.admin_user_id = au.id
JOIN menuca_v3.restaurants r ON r.id = ara.restaurant_id
GROUP BY au.id, au.email, au.first_name, au.last_name
ORDER BY access_count DESC
LIMIT 10;
```

---

**Recommendation:** Start with **Solution 2 (Python Script)** for simplicity and reliability.


