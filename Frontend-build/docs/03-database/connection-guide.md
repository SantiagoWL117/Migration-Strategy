# 🔌 Database Connection & Data Integration Plan

Connect the Menu.ca demo to the Supabase database and ensure all features work with real data.

## Connection Setup

### 1. Environment Configuration
- Update `.env.local` with the branch database URL
- Ensure proper connection pooling settings
- Add connection string for server-side operations
- Test connection with basic query

### 2. Database URL Structure
```
postgresql://postgres.nthpbtdjhhnwfxqsxbvy:Gz35CPTom1RnsmGM@aws-1-us-east-1.pooler.supabase.com:5432/postgres
```
- Username: `postgres.nthpbtdjhhnwfxqsxbvy`
- Password: `Gz35CPTom1RnsmGM`
- Host: `aws-1-us-east-1.pooler.supabase.com`
- Port: `5432`
- Database: `postgres`

## Data Verification & Setup

### 1. Check Existing Tables
- Verify `restaurants` table exists and has data
- Check `restaurant_locations` for address data
- Verify `cities` and `provinces` tables
- Ensure RPC function `get_restaurants_near_location` exists

### 2. Required Data Setup
If tables are missing or empty:
- Create base tables (restaurants, locations, etc.)
- Insert sample restaurant data
- Create necessary RPC functions
- Set up proper indexes for performance

### 3. RPC Functions Needed
```sql
-- get_restaurants_near_location
-- Parameters: p_latitude, p_longitude, p_radius_km
-- Returns: restaurants with distance calculation
```

## Feature Integration

### 1. Homepage
- Restaurant grid loading from database
- Location-based filtering
- Real restaurant images and data
- Proper error handling

### 2. Search Page
- Full-text search on restaurant names
- Cuisine type filtering
- Description search
- AI integration with real restaurant data

### 3. Restaurant Details
- Menu items (if available)
- Business hours
- Delivery zones
- Real-time availability

### 4. Dynamic Data Features
- Live order counter (mock or real)
- Restaurant online/offline status
- Dynamic pricing and fees
- Real delivery times

## Testing Plan

### 1. Connection Testing
- Test database connection
- Verify Supabase client initialization
- Check both server and client connections
- Test RPC function calls

### 2. Data Flow Testing
- Homepage restaurant loading
- Search functionality
- Individual restaurant pages
- Error states and loading states

### 3. Performance Testing
- Query optimization
- Image loading performance
- Caching strategies
- Connection pooling

## Implementation Steps

1. **Update Environment Variables**
   - Add `SUPABASE_BRANCH_DB_URL`
   - Update Supabase client configuration
   - Test connection

2. **Verify Database Schema**
   - Check all required tables
   - Ensure proper data exists
   - Create missing elements

3. **Update Components**
   - Ensure all components handle real data
   - Add proper TypeScript types
   - Handle edge cases

4. **Test Everything**
   - Full user flow testing
   - Error handling
   - Performance optimization

## Security Considerations

- Keep database credentials in environment variables
- Use Row Level Security (RLS) where appropriate
- Sanitize all user inputs
- Use prepared statements for queries

## Expected Outcome

After implementation:
- Demo uses real database data
- All features work with actual restaurants
- Search returns real results
- Performance is optimized
- Error handling is robust

This will transform the demo from using mock data to a fully functional system with real database integration!
