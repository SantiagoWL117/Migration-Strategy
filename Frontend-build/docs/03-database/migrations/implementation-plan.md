# 🚀 Database Connection Implementation Plan

Step-by-step plan to connect the Menu.ca demo to the Supabase database with the provided connection string.

## Phase 1: Environment Setup (5 mins)

### 1.1 Update Environment Variables
```bash
# Add to .env.local
SUPABASE_BRANCH_DB_URL=postgresql://postgres.nthpbtdjhhnwfxqsxbvy:Gz35CPTom1RnsmGM@aws-1-us-east-1.pooler.supabase.com:5432/postgres

# Keep existing variables
NEXT_PUBLIC_SUPABASE_URL=https://nthpbtdjhhnwfxqsxbvy.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 1.2 Update Supabase Server Client
- Modify `/lib/supabase/server.ts` to use direct database connection
- Add connection pooling configuration
- Ensure proper error handling

## Phase 2: Database Verification (10 mins)

### 2.1 Test Connection
```sql
-- Run test query to verify connection
SELECT version();
SELECT current_database();
```

### 2.2 Check Existing Schema
```sql
-- List all tables
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check if restaurants table exists
SELECT * FROM restaurants LIMIT 5;

-- Check RPC functions
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'public' AND routine_type = 'FUNCTION';
```

### 2.3 Verify Required Tables
- [ ] restaurants
- [ ] restaurant_locations  
- [ ] cities
- [ ] provinces
- [ ] get_restaurants_near_location function

## Phase 3: Data Setup (15 mins)

### 3.1 If Tables Are Missing
Create the essential tables:
```sql
-- Create restaurants table
CREATE TABLE IF NOT EXISTS restaurants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  cuisine_type TEXT,
  image_url TEXT,
  average_rating NUMERIC(3,2),
  review_count INTEGER DEFAULT 0,
  delivery_fee NUMERIC(10,2),
  minimum_order NUMERIC(10,2),
  estimated_delivery_time TEXT,
  is_active BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create RPC function
CREATE OR REPLACE FUNCTION get_restaurants_near_location(
  p_latitude NUMERIC,
  p_longitude NUMERIC,
  p_radius_km NUMERIC DEFAULT 10
)
RETURNS TABLE (...) AS $$
...
$$ LANGUAGE sql;
```

### 3.2 Populate Sample Data
If tables are empty, add the 8 restaurants we've been showing

## Phase 4: Update Application Code (20 mins)

### 4.1 Server Components
- [ ] Update home page to use real database connection
- [ ] Fix search page database queries
- [ ] Update restaurant detail pages
- [ ] Add proper error boundaries

### 4.2 Client Components
- [ ] Ensure Supabase client uses correct URL
- [ ] Update real-time subscriptions (if any)
- [ ] Fix any authentication issues

### 4.3 Type Safety
- [ ] Generate TypeScript types from database
- [ ] Update component interfaces
- [ ] Fix any type errors

## Phase 5: Testing & Optimization (10 mins)

### 5.1 Functionality Testing
- [ ] Homepage loads restaurants
- [ ] Search works with real data
- [ ] Restaurant details display correctly
- [ ] AI search integrates with real restaurants

### 5.2 Performance Testing
- [ ] Check query performance
- [ ] Optimize slow queries with indexes
- [ ] Implement caching where needed
- [ ] Test connection pooling

### 5.3 Error Handling
- [ ] Database connection failures
- [ ] Empty result sets
- [ ] Invalid queries
- [ ] Network timeouts

## Implementation Order

1. **Start with environment setup** - Get the connection string in place
2. **Test the connection** - Verify we can connect and query
3. **Check what exists** - See what tables/data we have
4. **Fix missing pieces** - Create tables/functions as needed
5. **Update the code** - Make components use real data
6. **Test everything** - Ensure all features work
7. **Optimize** - Make it fast and reliable

## Quick Wins

If everything is already set up in the database:
1. Just update `.env.local` with connection string
2. Restart the dev server
3. Everything should work!

## Potential Issues & Solutions

### Issue: Connection refused
- Check if IP is whitelisted in Supabase
- Verify connection string format
- Check network connectivity

### Issue: Tables don't exist
- Run the SQL creation scripts
- Use Supabase migrations
- Manually create via dashboard

### Issue: No data
- Insert sample restaurants
- Use the data we already have (8 restaurants)
- Import from existing database

### Issue: RPC function missing
- Create the PostGIS-based function
- Or use simple distance calculation
- Fallback to showing all restaurants

## Success Criteria

✅ Homepage shows real restaurants from database
✅ Search returns actual results
✅ AI search knows about real restaurants
✅ No more mock data anywhere
✅ Fast page loads
✅ Proper error handling

Ready to implement! This should take about 30-60 minutes total.
