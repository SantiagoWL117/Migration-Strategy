# Yelp Reviews Import - Quick Start

5-minute setup guide to import Yelp reviews into your Menu.ca database.

## Step 1: Get Yelp API Key (2 minutes)

1. Visit: https://www.yelp.com/developers/v3/manage_app
2. Sign in and click "Create New App"
3. Fill form:
   - Name: `Menu.ca Integration`
   - Industry: `Food & Beverage`
4. Copy your API Key

## Step 2: Install Dependencies (1 minute)

```bash
npm install --save-dev tsx dotenv
```

## Step 3: Configure API Key (1 minute)

Add to your `.env` file:

```bash
YELP_FUSION_API_KEY=your-api-key-here
```

## Step 4: Test Run (1 minute)

```bash
# Test with 5 restaurants (no data inserted)
npm run yelp:test
```

Expected output:
```
✅ Matched with Yelp:        4
❌ No Yelp match:            1
📝 Total reviews inserted:   0  (dry run mode)
```

## Step 5: Full Import (5-10 minutes)

```bash
# Import all reviews
npm run yelp:fetch
```

This will process all 75 restaurants and import ~150-180 reviews.

## Step 6: Verify

```bash
# Check total reviews
npx supabase db query "SELECT COUNT(*) FROM menuca_v3.restaurant_reviews WHERE source='yelp'"
```

Or run verification queries in Supabase SQL Editor (see `verify-reviews.sql`).

---

## Commands Reference

```bash
npm run yelp:test      # Test with 5 restaurants (dry run)
npm run yelp:dry-run   # Test all restaurants (no inserts)
npm run yelp:fetch     # Production import
```

---

## Troubleshooting

**"YELP_FUSION_API_KEY is not set"**
- Check `.env` file exists
- Verify key format: `YELP_FUSION_API_KEY=abc123...`
- No spaces or quotes

**"No match found on Yelp"**
- Normal for some restaurants
- Expected: 75-80% match rate

**"Rate limit exceeded"**
- Script auto-retries after 60s
- Or run in batches: `npx tsx scripts/fetch-yelp-reviews.ts --limit 25`

---

## Next Steps

1. Display reviews on restaurant pages
2. Add Yelp attribution (logo + link)
3. Schedule monthly updates

---

**Need more help?** See `YELP_INTEGRATION_GUIDE.md` for complete documentation.
