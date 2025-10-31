# Yelp Integration Process Flow

Visual guide to understand how the script works.

---

## High-Level Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    START: Run Script                        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  1. Load Configuration                                      │
│     • Read .env file                                        │
│     • Validate YELP_FUSION_API_KEY                         │
│     • Check SUPABASE credentials                           │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  2. Fetch Active Restaurants                                │
│     • Query Supabase: status='active'                      │
│     • Include restaurant_locations (phone, address)        │
│     • Result: ~75 restaurants                              │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  3. Process Each Restaurant (Loop)                          │
│     ┌───────────────────────────────────────────┐          │
│     │  For each restaurant:                     │          │
│     │  • Match with Yelp                        │          │
│     │  • Fetch reviews                          │          │
│     │  • Insert into database                   │          │
│     └───────────────────────────────────────────┘          │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  4. Generate Summary Report                                 │
│     • Total matched/unmatched                              │
│     • Reviews inserted                                      │
│     • Error details                                         │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│                    END: Complete                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Detailed Restaurant Processing Flow

```
┌─────────────────────────────────────────────────────────────┐
│  Restaurant: "Season's Pizza"                               │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Prepare Data                                       │
│  ┌────────────────────────────────────────────────┐        │
│  │  Name: Season's Pizza                          │        │
│  │  Phone: +1 (905) 555-1234                      │        │
│  │  Address: 123 Main St                          │        │
│  │  City: Mississauga                             │        │
│  │  Postal: L5B 1A1                               │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: Call Yelp Business Match API                      │
│  ┌────────────────────────────────────────────────┐        │
│  │  GET /v3/businesses/matches                    │        │
│  │  ?name=Season's Pizza                          │        │
│  │  &phone=+19055551234                           │        │
│  │  &address1=123 Main St                         │        │
│  │  &city=Mississauga                             │        │
│  │  &postal_code=L5B1A1                           │        │
│  │  &country=CA                                   │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
        ┌─────────┴──────────┐
        │                    │
        ▼                    ▼
┌──────────────┐      ┌──────────────┐
│  Match Found │      │  No Match    │
└──────┬───────┘      └──────┬───────┘
       │                     │
       │                     ▼
       │              ┌──────────────────────┐
       │              │  Log "No Match"      │
       │              │  Move to next        │
       │              └──────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: Extract Yelp Business Data                         │
│  ┌────────────────────────────────────────────────┐        │
│  │  Yelp Business ID: seasons-pizza-mississauga   │        │
│  │  Rating: 4.5                                   │        │
│  │  Review Count: 127                             │        │
│  │  URL: yelp.com/biz/seasons-pizza-mississauga  │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 4: Check if Already Imported                          │
│  ┌────────────────────────────────────────────────┐        │
│  │  Query: restaurant_reviews                     │        │
│  │  WHERE yelp_business_id =                      │        │
│  │    'seasons-pizza-mississauga'                 │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
        ┌─────────┴──────────┐
        │                    │
        ▼                    ▼
┌──────────────┐      ┌──────────────┐
│  Not Imported│      │  Already     │
│              │      │  Imported    │
└──────┬───────┘      └──────┬───────┘
       │                     │
       │                     ▼
       │              ┌──────────────────────┐
       │              │  Skip - Already done │
       │              │  Move to next        │
       │              └──────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 5: Fetch Reviews from Yelp                            │
│  ┌────────────────────────────────────────────────┐        │
│  │  GET /v3/businesses/                           │        │
│  │      seasons-pizza-mississauga/reviews         │        │
│  │                                                │        │
│  │  Returns: Array of 3 reviews                   │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 6: Process Each Review                                │
│  ┌────────────────────────────────────────────────┐        │
│  │  Review 1:                                     │        │
│  │  • ID: abc123                                  │        │
│  │  • Rating: 5                                   │        │
│  │  • Text: "Amazing pizza! The crust was..."    │        │
│  │  • User: John D.                               │        │
│  │  • Date: 2024-10-15                            │        │
│  │                                                │        │
│  │  Review 2: ...                                 │        │
│  │  Review 3: ...                                 │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 7: Insert Reviews into Database                       │
│  ┌────────────────────────────────────────────────┐        │
│  │  For each review:                              │        │
│  │  INSERT INTO restaurant_reviews (              │        │
│  │    restaurant_id: 42,                          │        │
│  │    rating: 5,                                  │        │
│  │    review_text: "Amazing pizza!...",           │        │
│  │    source: 'yelp',                             │        │
│  │    external_review_id: 'abc123',               │        │
│  │    external_user_name: 'John D.',              │        │
│  │    yelp_business_id: 'seasons-pizza...',       │        │
│  │    created_at: '2024-10-15'                    │        │
│  │  )                                             │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  Result: ✅ Inserted 3 reviews                              │
│  Move to next restaurant...                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## API Call Sequence

```
┌──────────────┐
│  Your Script │
└──────┬───────┘
       │
       │  1. Match Request
       │  GET /v3/businesses/matches?name=...
       ▼
┌──────────────┐
│  Yelp API    │
└──────┬───────┘
       │
       │  2. Match Response
       │  { businesses: [{id: "...", rating: 4.5, ...}] }
       ▼
┌──────────────┐
│  Your Script │
└──────┬───────┘
       │
       │  ⏱️ Wait 250ms (rate limiting)
       │
       │  3. Reviews Request
       │  GET /v3/businesses/{id}/reviews
       ▼
┌──────────────┐
│  Yelp API    │
└──────┬───────┘
       │
       │  4. Reviews Response
       │  { reviews: [{id, text, rating, user}...] }
       ▼
┌──────────────┐
│  Your Script │
└──────┬───────┘
       │
       │  ⏱️ Wait 250ms (rate limiting)
       │
       │  5. Database Insert
       │  INSERT INTO restaurant_reviews
       ▼
┌──────────────┐
│  Supabase    │
└──────────────┘
```

---

## Rate Limiting Strategy

```
Time (seconds)    Action
─────────────     ──────
0.000            → Restaurant 1: Match API call
0.250            → Restaurant 1: Reviews API call
0.500            → Restaurant 1: Database insert
0.750            → Restaurant 2: Match API call
1.000            → Restaurant 2: Reviews API call
1.250            → Restaurant 2: Database insert
...              ...
```

**Calculations:**
- 2 API calls per restaurant (match + reviews)
- 250ms between calls = 4 calls/second max
- 75 restaurants × 2 calls = 150 total calls
- 150 calls × 250ms = 37.5 seconds minimum
- Plus database operations ≈ **5-10 minutes total**

**Daily Capacity:**
- Free tier: 5,000 calls/day
- With 2 calls/restaurant = 2,500 restaurants/day
- Your 75 restaurants = **3% of daily quota**

---

## Error Handling Flow

```
┌─────────────────────┐
│   API Call          │
└─────────┬───────────┘
          │
          ▼
    ┌─────────┐
    │ Success?│
    └────┬────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
  YES        NO
    │         │
    │         ▼
    │    ┌─────────┐
    │    │ Error   │
    │    │ 429?    │
    │    └────┬────┘
    │         │
    │    ┌────┴────┐
    │    │         │
    │    ▼         ▼
    │   YES       NO
    │    │         │
    │    │         ▼
    │    │    ┌──────────────┐
    │    │    │ Log error    │
    │    │    │ Continue next│
    │    │    └──────────────┘
    │    │
    │    ▼
    │  ┌──────────────┐
    │  │ Wait 60 sec  │
    │  └──────┬───────┘
    │         │
    │         ▼
    │  ┌──────────────┐
    │  │ Retry once   │
    │  └──────┬───────┘
    │         │
    └─────────┘
          │
          ▼
    ┌──────────────┐
    │  Continue    │
    └──────────────┘
```

---

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        Supabase Database                     │
│  ┌──────────────────────────────────────────────────┐       │
│  │  restaurants                                     │       │
│  │  • id: 42                                        │       │
│  │  • name: "Season's Pizza"                        │       │
│  │  • status: 'active'                              │       │
│  └──────────────┬───────────────────────────────────┘       │
│                 │                                            │
│  ┌──────────────▼───────────────────────────────────┐       │
│  │  restaurant_locations                            │       │
│  │  • restaurant_id: 42                             │       │
│  │  • phone: "+19055551234"                         │       │
│  │  • street_address: "123 Main St"                 │       │
│  └──────────────────────────────────────────────────┘       │
└──────────────┬──────────────────────────────────────────────┘
               │
               │ Script fetches
               │
               ▼
┌──────────────────────────────────────────────────────────────┐
│                        Your Script                            │
│                                                               │
│  Combines restaurant + location data                         │
│  Sends to Yelp API                                           │
└───────────────┬──────────────────────────────────────────────┘
                │
                │ Match + Fetch
                │
                ▼
┌──────────────────────────────────────────────────────────────┐
│                        Yelp API                               │
│  ┌──────────────────────────────────────────────────┐        │
│  │  Business: seasons-pizza-mississauga             │        │
│  │  • Rating: 4.5                                   │        │
│  │  • Reviews: [                                    │        │
│  │      {id: 'abc', rating: 5, text: '...'},       │        │
│  │      {id: 'def', rating: 4, text: '...'},       │        │
│  │      {id: 'ghi', rating: 5, text: '...'}        │        │
│  │    ]                                             │        │
│  └──────────────────────────────────────────────────┘        │
└───────────────┬──────────────────────────────────────────────┘
                │
                │ Returns data
                │
                ▼
┌──────────────────────────────────────────────────────────────┐
│                        Your Script                            │
│                                                               │
│  Transforms to database format                               │
└───────────────┬──────────────────────────────────────────────┘
                │
                │ Insert reviews
                │
                ▼
┌─────────────────────────────────────────────────────────────┐
│                        Supabase Database                     │
│  ┌──────────────────────────────────────────────────┐       │
│  │  restaurant_reviews                              │       │
│  │  • id: 1001                                      │       │
│  │  • restaurant_id: 42                             │       │
│  │  • rating: 5                                     │       │
│  │  • review_text: "Amazing pizza! The crust..."    │       │
│  │  • source: 'yelp'                                │       │
│  │  • external_review_id: 'abc'                     │       │
│  │  • external_user_name: 'John D.'                 │       │
│  │  • yelp_business_id: 'seasons-pizza...'          │       │
│  │  • created_at: '2024-10-15'                      │       │
│  └──────────────────────────────────────────────────┘       │
│  (Repeat for review 2, 3...)                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Command Options

```
┌─────────────────────────────────────────────────────────┐
│  npm run yelp:test                                      │
│  = tsx scripts/fetch-yelp-reviews.ts --dry-run --limit 5│
└─────────────┬───────────────────────────────────────────┘
              │
              ▼
        ┌──────────┐
        │ --dry-run│  Skip database inserts
        └──────────┘
              │
        ┌──────────┐
        │ --limit 5│  Process only 5 restaurants
        └──────────┘
              │
              ▼
        Outputs preview, no data changed


┌─────────────────────────────────────────────────────────┐
│  npm run yelp:dry-run                                   │
│  = tsx scripts/fetch-yelp-reviews.ts --dry-run         │
└─────────────┬───────────────────────────────────────────┘
              │
              ▼
        ┌──────────┐
        │ --dry-run│  Skip database inserts
        └──────────┘
              │
              ▼
        Process all 75, preview results


┌─────────────────────────────────────────────────────────┐
│  npm run yelp:fetch                                     │
│  = tsx scripts/fetch-yelp-reviews.ts                   │
└─────────────┬───────────────────────────────────────────┘
              │
              ▼
        No flags = Production mode
              │
              ▼
        Process all, insert real data
```

---

## Success Metrics

```
BEFORE IMPORT                    AFTER IMPORT
─────────────                    ────────────

restaurants: 75                  restaurants: 75
restaurant_reviews: 0            restaurant_reviews: ~174

                                 By source:
                                 • yelp: ~174
                                 • menu.ca: 0

                                 Coverage:
                                 • Restaurants with reviews: ~58
                                 • Restaurants without: ~17

                                 Average per restaurant:
                                 • ~3 reviews
                                 • ~4.3 avg rating
```

---

This visual guide helps understand the complete flow from start to finish!
