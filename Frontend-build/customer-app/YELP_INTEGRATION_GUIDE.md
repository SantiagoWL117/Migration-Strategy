# Yelp Fusion API Integration Guide

Complete guide to populate your Menu.ca restaurant database with real Yelp reviews and ratings.

## Table of Contents

1. [Overview](#overview)
2. [What You'll Get](#what-youll-get)
3. [Prerequisites](#prerequisites)
4. [Setup Instructions](#setup-instructions)
5. [Running the Script](#running-the-script)
6. [Understanding Results](#understanding-results)
7. [Verification](#verification)
8. [Troubleshooting](#troubleshooting)
9. [Next Steps](#next-steps)

---

## Overview

This integration fetches authentic reviews and ratings from Yelp's Fusion API v3 and populates your `restaurant_reviews` table with real customer feedback for your 75 active restaurants.

### Key Features

- Automatic matching of restaurants to Yelp businesses
- Import of ratings, review counts, and review text
- Proper attribution to Yelp reviewers
- Rate limiting to stay within API quotas
- Dry-run mode for safe testing
- Comprehensive error handling and logging

---

## What You'll Get

After running the script, your database will contain:

- **Real Yelp Ratings**: Authentic 1-5 star ratings from Yelp users
- **Review Count**: Total number of reviews each restaurant has on Yelp
- **Review Excerpts**: Up to 3 review texts per restaurant (first 160 characters)
- **Reviewer Info**: Yelp reviewer names and profile images
- **Original Timestamps**: When reviews were originally posted on Yelp
- **Yelp Attribution**: Links back to Yelp business pages

### Expected Coverage

Based on typical scenarios:
- **~75-80%** of restaurants will match to Yelp listings
- **~15-20%** may not have Yelp listings or won't match
- **3 reviews per restaurant** on average (Yelp free tier limit)
- **Total: ~150-180 reviews** imported

---

## Prerequisites

### 1. Yelp Fusion API Key

You need a free Yelp Fusion API key.

**Steps to Get Your Key:**

1. Go to: https://www.yelp.com/developers/v3/manage_app
2. Sign in with Yelp account (create one if needed)
3. Click **"Create New App"**
4. Fill in the form:
   - **App Name**: `Menu.ca Restaurant Reviews`
   - **Industry**: `Food & Beverage`
   - **Email**: Your email address
   - **Description**: `Integration to display Yelp reviews on Menu.ca platform`
   - **Terms**: Accept Terms of Service
5. Click **"Create App"**
6. Copy your **API Key** (looks like: `ABCdef123GHI456jkl...`)

**Free Tier Limits:**
- 5,000 API calls per day
- Resets at midnight UTC
- No credit card required
- Sufficient for ~2,500 restaurants/day

### 2. Environment Setup

Ensure you have:
- Node.js 18+ installed
- Supabase credentials in `.env` file
- Project dependencies installed

---

## Setup Instructions

### Step 1: Install Dependencies

Install the required packages:

```bash
npm install --save-dev tsx dotenv
```

Or if you prefer Yarn:

```bash
yarn add -D tsx dotenv
```

### Step 2: Configure Environment Variables

Add your Yelp API key to the `.env` file in the project root:

```bash
# Open your .env file
nano .env

# Add this line (replace with your actual key):
YELP_FUSION_API_KEY=your-api-key-here
```

Your `.env` should now include:

```env
# Supabase (existing)
SUPABASE_URL=https://nthpbtdjhhnwfxqsxbvy.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Yelp Fusion API (new)
YELP_FUSION_API_KEY=your-yelp-api-key
```

**Security Note**: The `.env` file is in `.gitignore` and will not be committed to git.

### Step 3: Verify Setup

Check that everything is configured:

```bash
# Verify tsx is installed
npx tsx --version

# Check environment variables are loaded
node -e "require('dotenv').config(); console.log('Yelp Key:', process.env.YELP_FUSION_API_KEY ? 'Set ✓' : 'Missing ✗')"
```

---

## Running the Script

### Test Run (Dry Run) - RECOMMENDED FIRST

Run without inserting any data to see what would happen:

```bash
npm run yelp:dry-run
```

This will:
- Show which restaurants match on Yelp
- Display what reviews would be inserted
- Show ratings and review counts
- **NOT** insert any data into the database

### Test with 5 Restaurants

Test with a small batch first:

```bash
npm run yelp:test
```

This runs in dry-run mode with only 5 restaurants.

### Production Run

Once you're confident, run the full import:

```bash
npm run yelp:fetch
```

This will process all 75 active restaurants and insert real data.

### Process in Batches

If you want to process restaurants in smaller batches:

```bash
# First batch of 25
npx tsx scripts/fetch-yelp-reviews.ts --limit 25

# Wait a bit, then continue...
npx tsx scripts/fetch-yelp-reviews.ts --limit 25

# And so on...
```

### Manual Execution

You can also run the script directly:

```bash
# Production mode
npx tsx scripts/fetch-yelp-reviews.ts

# Dry run mode
npx tsx scripts/fetch-yelp-reviews.ts --dry-run

# Limited batch
npx tsx scripts/fetch-yelp-reviews.ts --limit 10
```

---

## Understanding Results

### Console Output

The script provides detailed progress information:

#### Successful Match

```
[5/75] --------------------------------------------------
🔍 Processing: Season's Pizza

   📞 Matching with Yelp...
   ✅ Matched! Yelp ID: seasons-pizza-mississauga
   ⭐ Rating: 4.5 (127 reviews)
   📄 Fetching reviews...
   💾 Inserting 3 reviews...
   ✅ Inserted 3 reviews
```

#### No Match Found

```
[12/75] --------------------------------------------------
🔍 Processing: Local Family Restaurant

   📞 Matching with Yelp...
   ❌ No match found on Yelp
```

#### Already Imported

```
[18/75] --------------------------------------------------
🔍 Processing: Thai Express

   📞 Matching with Yelp...
   ✅ Matched! Yelp ID: thai-express-toronto
   ⭐ Rating: 4.2 (89 reviews)
   ℹ️  Reviews already imported for this business
```

### Summary Report

At the end, you'll see a summary:

```
╔════════════════════════════════════════════════════╗
║                   📊 SUMMARY                       ║
╚════════════════════════════════════════════════════╝

✅ Matched with Yelp:        58
❌ No Yelp match:            17
📝 Total reviews inserted:   174

✅ Successfully matched restaurants:
   - Season's Pizza
     Yelp: 4.5⭐ (127 reviews)
     Imported: 3 reviews
   ...
```

---

## Verification

After running the script, verify the imported data using the provided SQL queries.

### Quick Verification

Run these queries in your Supabase SQL Editor:

#### 1. Check Total Reviews

```sql
SELECT COUNT(*) as total_reviews
FROM menuca_v3.restaurant_reviews
WHERE source = 'yelp';
```

Expected: ~150-180 reviews

#### 2. Check Coverage

```sql
SELECT
  COUNT(DISTINCT r.id) as total_restaurants,
  COUNT(DISTINCT rv.restaurant_id) as with_reviews,
  ROUND(
    COUNT(DISTINCT rv.restaurant_id)::numeric /
    COUNT(DISTINCT r.id) * 100, 1
  ) as coverage_pct
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_reviews rv ON rv.restaurant_id = r.id
WHERE r.status = 'active' AND rv.source = 'yelp';
```

Expected: ~75-80% coverage

#### 3. View Sample Reviews

```sql
SELECT
  r.name,
  rv.rating,
  rv.external_user_name,
  LEFT(rv.review_text, 80) as preview
FROM menuca_v3.restaurant_reviews rv
JOIN menuca_v3.restaurants r ON r.id = rv.restaurant_id
WHERE rv.source = 'yelp'
ORDER BY rv.created_at DESC
LIMIT 10;
```

### Comprehensive Verification

Use the verification SQL file for detailed analysis:

```bash
# Open the verification file
cat scripts/verify-reviews.sql

# Or run specific queries in Supabase SQL Editor
```

The file includes 15 different queries to analyze:
- Total reviews and ratings
- Restaurant coverage
- Review distribution
- Data quality checks
- Rating breakdowns
- And more...

See: `/scripts/verify-reviews.sql`

---

## Troubleshooting

### Error: "YELP_FUSION_API_KEY is not set"

**Problem**: The script can't find your API key.

**Solutions**:
1. Check `.env` file exists in project root
2. Verify the key is on its own line: `YELP_FUSION_API_KEY=your-key`
3. No spaces around the `=` sign
4. No quotes around the key
5. Save the file and re-run the script

### Error: "Rate limit exceeded (429)"

**Problem**: You've made too many requests to Yelp API.

**Solutions**:
1. The script will automatically wait 60 seconds and retry
2. If it happens repeatedly, use `--limit` to process fewer restaurants:
   ```bash
   npx tsx scripts/fetch-yelp-reviews.ts --limit 10
   ```
3. Check your daily quota at: https://www.yelp.com/developers/v3/manage_app
4. Wait until midnight UTC for quota reset

### "No match found on Yelp"

**Problem**: Restaurant doesn't match any Yelp listing.

**Reasons**:
- Restaurant name differs on Yelp (e.g., "Mike's Pizza" vs "Michael's Pizzeria")
- Restaurant not listed on Yelp yet
- Phone number or address doesn't match
- Restaurant closed or moved

**Solutions**:
1. Manually search on Yelp: https://www.yelp.com/search?find_desc={restaurant_name}
2. If found but not matched, the business info may differ
3. You may need to manually add those reviews or update restaurant data
4. Some restaurants legitimately don't have Yelp listings (this is normal)

### "Failed to fetch restaurants"

**Problem**: Can't connect to Supabase database.

**Solutions**:
1. Check `SUPABASE_URL` in `.env`
2. Verify `SUPABASE_SERVICE_ROLE_KEY` is set (not anon key)
3. Test connection: `npx supabase status`
4. Check internet connection
5. Verify Supabase project is active

### "Failed to insert review"

**Problem**: Database insertion error.

**Solutions**:
1. Check `restaurant_reviews` table exists
2. Verify table structure matches expected schema
3. Check for database constraints or triggers
4. Review error message in console for specific issue
5. Verify you have write permissions (using service role key)

### Script Hangs or Runs Slowly

**Problem**: Script seems stuck or taking too long.

**Normal Behavior**:
- The script has built-in rate limiting (250ms between requests)
- Processing 75 restaurants takes approximately 5-10 minutes
- This is intentional to respect Yelp's rate limits

**Check If Actually Stuck**:
- Look for console output (should update every few seconds)
- If no output for >60 seconds, it may be stuck
- Press Ctrl+C to cancel and restart

---

## Next Steps

After successfully importing reviews:

### 1. Update Frontend to Display Reviews

Modify restaurant pages to show Yelp reviews:

```typescript
// Example: Fetch reviews in your restaurant page component
const { data: reviews } = await supabase
  .from('restaurant_reviews')
  .select('*')
  .eq('restaurant_id', restaurantId)
  .eq('source', 'yelp')
  .order('created_at', { ascending: false })
  .limit(10)
```

### 2. Add Yelp Attribution

Per Yelp's Terms of Service, you must:

- Display "Reviews from Yelp" or similar
- Include Yelp logo (download from Yelp Brand Assets)
- Link back to the business's Yelp page
- Show reviewer names as they appear on Yelp

Example attribution:

```html
<div class="review-attribution">
  <img src="/yelp-logo.png" alt="Yelp" />
  <a href="{yelp_business_url}">View on Yelp</a>
</div>
```

### 3. Combine with Menu.ca Reviews

If you have native reviews:

```sql
-- Fetch all reviews (Yelp + Menu.ca)
SELECT * FROM menuca_v3.restaurant_reviews
WHERE restaurant_id = $1
ORDER BY created_at DESC;

-- Calculate combined rating
SELECT ROUND(AVG(rating), 1) as avg_rating
FROM menuca_v3.restaurant_reviews
WHERE restaurant_id = $1;
```

### 4. Keep Reviews Updated

Schedule regular updates to refresh Yelp data:

```bash
# Run monthly via cron job or GitHub Actions
npm run yelp:fetch
```

**Note**: The script automatically skips restaurants that already have reviews (checks by `yelp_business_id`). To re-import, you'd need to delete existing reviews first.

### 5. Consider Upgrading Yelp Plan

If you need more data:

**Yelp Fusion Plus** ($299/month):
- 25,000 API calls/day
- Up to 3 full reviews per business
- Business highlights and attributes

**Yelp Fusion Enterprise** (Custom pricing):
- Unlimited API calls
- Up to 7 reviews per business
- Premium support

### 6. Monitor API Usage

Track your Yelp API usage:

1. Go to: https://www.yelp.com/developers/v3/manage_app
2. View your app dashboard
3. Check daily call counts
4. Monitor rate limit status

### 7. Handle Edge Cases

- **Duplicate Reviews**: Script prevents duplicates via `yelp_business_id` check
- **Updated Reviews**: Re-running won't fetch updated review text (Yelp limitation)
- **Deleted Reviews**: Yelp doesn't notify when reviews are removed
- **New Reviews**: Re-run script periodically to fetch newer reviews

---

## API Documentation Reference

- [Yelp Fusion API Docs](https://www.yelp.com/developers/documentation/v3)
- [Business Match Endpoint](https://www.yelp.com/developers/documentation/v3/business_match)
- [Business Reviews Endpoint](https://www.yelp.com/developers/documentation/v3/business_reviews)
- [Authentication](https://www.yelp.com/developers/documentation/v3/authentication)
- [Rate Limiting](https://www.yelp.com/developers/documentation/v3/rate_limiting)
- [Yelp Brand Assets](https://www.yelp.com/brand)

---

## Files Created

This integration includes:

```
scripts/
├── fetch-yelp-reviews.ts    # Main script
├── yelp-types.ts             # TypeScript types
├── database-client.ts        # Supabase client for scripts
├── verify-reviews.sql        # Verification queries
└── README.md                 # Quick reference

.env.example                  # Environment template
YELP_INTEGRATION_GUIDE.md    # This comprehensive guide
```

---

## Support and Resources

**Questions?**
- Review this guide
- Check `scripts/README.md` for quick reference
- Read Yelp API documentation
- Review console output for detailed error messages

**Common Issues?**
- See Troubleshooting section above
- Check verification queries in `verify-reviews.sql`
- Validate your API key at Yelp developer portal

**Need Help?**
- Yelp Developer Support: https://www.yelp.com/developers/support
- Supabase Documentation: https://supabase.com/docs

---

## Summary

You now have a complete Yelp integration that will:

- Automatically match your restaurants to Yelp businesses
- Import authentic reviews and ratings
- Respect API rate limits
- Handle errors gracefully
- Provide detailed logging and verification

**To get started:**

1. Get your Yelp API key
2. Add it to `.env`
3. Run `npm run yelp:test` to verify setup
4. Run `npm run yelp:fetch` to import all reviews
5. Verify data using provided SQL queries
6. Update frontend to display reviews

Good luck!
