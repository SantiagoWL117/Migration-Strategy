# Yelp Fusion API Integration

This directory contains scripts for integrating real Yelp reviews and ratings into the Menu.ca restaurant database.

## Overview

The Yelp integration fetches authentic reviews and ratings from Yelp's Fusion API v3 and populates the `restaurant_reviews` table with real data for your 75 active restaurants.

### What It Does

1. Fetches all active restaurants from your Supabase database
2. Matches each restaurant to a Yelp business using name + phone + address
3. Retrieves ratings, review counts, and up to 3 reviews per restaurant
4. Inserts reviews into the `restaurant_reviews` table with proper attribution

## Prerequisites

### 1. Get a Yelp Fusion API Key

1. Go to [Yelp Developers Portal](https://www.yelp.com/developers/v3/manage_app)
2. Sign in with your Yelp account (or create one)
3. Click "Create New App"
4. Fill in the application form:
   - **App Name**: Menu.ca Integration
   - **Industry**: Food & Beverage
   - **Contact Email**: Your email
   - **Description**: Integration for displaying Yelp reviews on Menu.ca
5. Accept the Terms of Service
6. Click "Create App"
7. Copy your **API Key** (it looks like: `ABCdef123GHI456jklMNO789pqrSTU`)

### 2. Configure Environment Variables

Add your Yelp API key to your `.env` file:

```bash
# Add this line to your .env file
YELP_FUSION_API_KEY=your-api-key-here
```

Make sure you already have:
```bash
SUPABASE_URL=https://nthpbtdjhhnwfxqsxbvy.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### 3. Install Dependencies

The script uses `tsx` to run TypeScript directly. Install it if not already installed:

```bash
npm install --save-dev tsx dotenv
```

## Usage

### Run in Dry-Run Mode (Recommended First)

Test the script without inserting any data:

```bash
npx tsx scripts/fetch-yelp-reviews.ts --dry-run
```

This will:
- Show which restaurants match on Yelp
- Display what reviews would be inserted
- NOT insert any data into the database

### Run in Production Mode

Insert real data into the database:

```bash
npx tsx scripts/fetch-yelp-reviews.ts
```

### Process Limited Number of Restaurants

Test with just 5 restaurants:

```bash
npx tsx scripts/fetch-yelp-reviews.ts --dry-run --limit 5
npx tsx scripts/fetch-yelp-reviews.ts --limit 5  # After testing
```

### Add to package.json Scripts (Optional)

Add these scripts to your `package.json`:

```json
{
  "scripts": {
    "yelp:fetch": "tsx scripts/fetch-yelp-reviews.ts",
    "yelp:dry-run": "tsx scripts/fetch-yelp-reviews.ts --dry-run",
    "yelp:test": "tsx scripts/fetch-yelp-reviews.ts --dry-run --limit 5"
  }
}
```

Then run:
```bash
npm run yelp:dry-run   # Test mode
npm run yelp:fetch     # Production mode
npm run yelp:test      # Test with 5 restaurants
```

## Understanding the Output

### Successful Match Example
```
[1/75] --------------------------------------------------
🔍 Processing: Season's Pizza

   📞 Matching with Yelp...
   ✅ Matched! Yelp ID: seasons-pizza-mississauga
   ⭐ Rating: 4.5 (127 reviews)
   📄 Fetching reviews...
   💾 Inserting 3 reviews...
   ✅ Inserted 3 reviews
```

### No Match Example
```
[2/75] --------------------------------------------------
🔍 Processing: My Local Restaurant

   📞 Matching with Yelp...
   ❌ No match found on Yelp
```

### Summary Output
```
╔════════════════════════════════════════════════════╗
║                   📊 SUMMARY                       ║
╚════════════════════════════════════════════════════╝

✅ Matched with Yelp:        58
❌ No Yelp match:            17
📝 Total reviews inserted:   174
```

## Rate Limits

### Yelp API Limits (Free Tier)
- **Daily Limit**: 5,000 API calls per day
- **Reset Time**: Midnight UTC
- **Calls per Restaurant**: ~2 calls (1 match + 1 reviews)
- **Max Restaurants/Day**: ~2,500

### Script Rate Limiting
The script includes automatic rate limiting:
- **250ms delay** between requests (4 requests/second)
- Automatic retry on 429 (Too Many Requests) errors
- 60-second wait before retry

### If You Hit Rate Limits
```bash
# Run in batches
npx tsx scripts/fetch-yelp-reviews.ts --limit 50
# Wait a bit, then continue...
npx tsx scripts/fetch-yelp-reviews.ts --limit 50
```

## Database Schema

The script inserts data into the `restaurant_reviews` table with this structure:

```sql
-- Review columns populated by script:
restaurant_id          -- Links to restaurants table
rating                 -- 1-5 stars (from Yelp)
review_text            -- Review content (first 160 chars from Yelp)
source                 -- Set to 'yelp'
external_review_id     -- Yelp review ID
external_user_name     -- Yelp reviewer's name
external_user_image    -- Yelp reviewer's profile image
yelp_business_id       -- Yelp business ID (for future reference)
yelp_business_url      -- Link to Yelp listing
created_at             -- Original Yelp review timestamp

-- NULL columns (external reviews):
user_id                -- NULL (no Menu.ca user)
order_id               -- NULL (no Menu.ca order)
```

## Verification

After running the script, verify the data:

### Check Total Reviews
```sql
SELECT COUNT(*) as total_reviews
FROM menuca_v3.restaurant_reviews
WHERE source = 'yelp';
```

### Reviews by Restaurant
```sql
SELECT
  r.name,
  COUNT(rv.id) as review_count,
  ROUND(AVG(rv.rating), 1) as avg_rating
FROM menuca_v3.restaurants r
LEFT JOIN menuca_v3.restaurant_reviews rv ON rv.restaurant_id = r.id
WHERE rv.source = 'yelp'
GROUP BY r.id, r.name
ORDER BY review_count DESC;
```

### Sample Reviews
```sql
SELECT
  r.name as restaurant,
  rv.rating,
  rv.external_user_name,
  LEFT(rv.review_text, 100) as preview,
  rv.created_at
FROM menuca_v3.restaurant_reviews rv
JOIN menuca_v3.restaurants r ON r.id = rv.restaurant_id
WHERE rv.source = 'yelp'
ORDER BY rv.created_at DESC
LIMIT 10;
```

## Troubleshooting

### "YELP_FUSION_API_KEY is not set"
- Make sure you added the key to `.env` file
- Check that you're in the correct directory
- Verify the `.env` file is not in `.gitignore` (it should be ignored, but needs to exist locally)

### "No match found on Yelp"
This is normal. Reasons:
- Restaurant name differs from Yelp listing
- Restaurant not on Yelp yet
- Address/phone mismatch
- Restaurant closed on Yelp

Manually check: https://www.yelp.com/search?find_desc={restaurant_name}

### "Rate limit exceeded (429)"
- The script will automatically wait 60 seconds and retry
- If this happens frequently, use `--limit` to process fewer restaurants
- Check your daily quota at Yelp developer portal

### "Failed to fetch restaurants"
- Verify Supabase credentials in `.env`
- Check that `SUPABASE_SERVICE_ROLE_KEY` is set (not anon key)
- Test Supabase connection: `npx supabase status`

## Files

- `fetch-yelp-reviews.ts` - Main script
- `yelp-types.ts` - TypeScript types for Yelp API
- `database-client.ts` - Supabase client for Node.js scripts
- `README.md` - This file

## API Documentation

- [Yelp Fusion API Documentation](https://www.yelp.com/developers/documentation/v3)
- [Business Match Endpoint](https://www.yelp.com/developers/documentation/v3/business_match)
- [Business Reviews Endpoint](https://www.yelp.com/developers/documentation/v3/business_reviews)
- [Rate Limiting](https://www.yelp.com/developers/documentation/v3/rate_limiting)

## Limitations

### Yelp API Limitations (Free Tier)
- **Review Excerpts**: Only first 160 characters of each review
- **Review Count**: Max 3 reviews per business
- **No Full Text**: Cannot access complete review text
- **No Filtering**: Cannot filter by rating or date

### To Get More Reviews
- Upgrade to Yelp Fusion Plus or Enterprise plan
- Plus: Up to 3 full reviews
- Enterprise: Up to 7 reviews + more features

## Next Steps

After successfully importing reviews:

1. **Update Frontend**: Display Yelp reviews on restaurant pages
2. **Add Attribution**: Show "Source: Yelp" with logo (per Yelp TOS)
3. **Keep Updated**: Re-run script monthly to get new reviews
4. **Handle Conflicts**: Decide how to merge Yelp + Menu.ca reviews

## Notes

- The script skips restaurants that already have reviews imported (checks by `yelp_business_id`)
- External reviews have `user_id` and `order_id` as NULL
- Original Yelp timestamps are preserved
- Yelp business URLs are stored for future reference

## Support

For issues or questions:
1. Check this README
2. Review Yelp API documentation
3. Check script console output for detailed error messages
4. Verify your API key is valid at Yelp developer portal
