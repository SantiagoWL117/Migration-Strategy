# Frontend Build Memory Bank
**Project:** MenuCA V3 Customer Ordering App
**Last Updated:** 2025-10-24
**Purpose:** Persistent context and memory for frontend development sessions

---

## 🎯 PROJECT OVERVIEW

### What We're Building
A customer-facing online food ordering platform (like UberEats/DoorDash) for MenuCA V3.

### Current Phase
**Phase 1 MVP - Restaurant Browsing & Menu Display** ✅ COMPLETE

### Tech Stack
- **Framework:** Next.js 16 (App Router, Turbopack)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **Database:** Supabase (PostgreSQL with menuca_v3 schema)
- **State:** Zustand (cart management)
- **Deployment:** Local dev on port 3001

---

## 📁 PROJECT STRUCTURE

```
/Users/brianlapp/Documents/GitHub/Migration-Strategy/Frontend-build/
├── customer-app/                    # Main Next.js application
│   ├── app/
│   │   ├── page.tsx                # Homepage with search
│   │   ├── search/page.tsx         # Search results page
│   │   ├── r/[slug]/page.tsx       # Restaurant menu page
│   │   └── api/                    # API routes
│   ├── components/
│   │   ├── restaurant-card.tsx     # Restaurant listing card
│   │   ├── restaurant-grid.tsx     # Grid layout for restaurants
│   │   ├── restaurant-header.tsx   # Restaurant page header
│   │   ├── menu-display.tsx        # Menu categories & dishes
│   │   ├── dish-card.tsx           # Individual dish card
│   │   ├── search-bar.tsx          # Search input component
│   │   ├── mini-cart-button.tsx    # Floating cart button
│   │   └── ...                     # Other UI components
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts           # Browser Supabase client
│   │   │   └── server.ts           # Server Supabase client
│   │   └── store/
│   │       └── cart-store.ts       # Zustand cart state
│   └── ...
├── DATABASE_SCHEMA_REFERENCE.md    # Complete schema documentation
├── RESTAURANT_DATA_AUDIT_2025_10_24.md  # Data quality audit
├── HANDOFF_TO_NEW_SESSION.md       # Session handoff instructions
└── FRONTEND_BUILD_MEMORY.md        # This file

```

---

## ✅ COMPLETED FEATURES

### Phase 0: Foundation
- [x] Next.js 16 app setup with Turbopack
- [x] Supabase authentication and connection
- [x] Database schema discovery via MCP
- [x] RLS policies for public read access
- [x] TypeScript interfaces matching actual schema

### Phase 1: Restaurant Browsing & Menu Display
- [x] Homepage with hero section
- [x] Restaurant search functionality
- [x] Restaurant grid/list view
- [x] Restaurant detail page with header
- [x] Menu display with categories
- [x] Dish cards with pricing
- [x] Sticky category navigation
- [x] Industry-standard menu layout (2-column grid)
- [x] Compact spacing matching UberEats/DoorDash
- [x] Data audit identifying 29 restaurants with menu data

---

## 🎨 DESIGN STANDARDS

### UI/UX Philosophy
- **Industry Standard:** Match UberEats/DoorDash look and feel
- **Mobile-First:** Responsive design, works on all devices
- **Information Density:** Show 8-12 dishes per viewport on desktop
- **No Gating:** All content visible, categories for navigation only
- **Clean & Minimal:** White space, clear hierarchy, readable typography

### Current Design Patterns

#### Menu Layout (Redesigned 2025-10-24)
- **Grid:** 2 columns on desktop (`md:grid-cols-2`), 1 on mobile
- **Spacing:** 3px gaps between cards, 6 units between categories
- **Card Style:** Horizontal layout - image left (120px square), content right
- **Typography:** Compact headers (text-lg), tight line heights
- **Navigation:** Sticky pills with dish counts, jump-to-section anchors

#### Color Scheme
- **Primary:** Red 600 (`#dc2626`) - buttons, accents, branding
- **Background:** Gray 50 (`#f9fafb`) - page background
- **Cards:** White with border-gray-200
- **Text:** Gray 900 (headings), Gray 600 (descriptions)

---

## 🗄️ DATABASE KNOWLEDGE

### Supabase Connection
- **Project:** `nthpbtdjhhnwfxqsxbvy.supabase.co`
- **Schema:** `menuca_v3` (NOT public!)
- **Auth:** Anon key for public access, service key for admin

### Key Tables (Verified via MCP)

#### restaurants (31 columns)
```
id, uuid, name, slug, status
online_ordering_enabled
created_at, updated_at, deleted_at
... (see DATABASE_SCHEMA_REFERENCE.md for full list)
```

#### courses (17 columns) - Menu Categories
```
id, uuid, restaurant_id, name, description
display_order, is_active
created_at, updated_at, deleted_at
```

#### dishes (32 columns) - Menu Items
```
id, uuid, restaurant_id, course_id (nullable!)
name, description, base_price, image_url
has_customization, is_active, display_order
prices (JSONB), size_options (JSONB)
created_at, updated_at, deleted_at
```

#### dish_modifiers (22 columns) - Customizations
```
id, dish_id, ingredient_id, modifier_group_id
name, price, is_default, is_included
modifier_type, display_order
```

### Critical Data Issues
1. **65% of dishes have course_id = NULL** (10,259 out of 15,684)
   - Solution: Fetch courses and dishes separately, manually group them
   - Create "Other Items" category for uncategorized dishes

2. **Only 29 out of 277 "active" restaurants have menu data**
   - See RESTAURANT_DATA_AUDIT_2025_10_24.md for full list
   - Use these IDs for testing: 8, 15, 42, 54, 65, 72, 89, 90, 119, 126, 131, 147, 174, 180, 245, 267, 269, 427, 486, 511, 929, 963, 964, 965, 966, 973, 974, 978

3. **No images in database currently**
   - image_url column exists but is empty for most dishes
   - Frontend handles missing images gracefully (0 width container)

---

## 🔧 TECHNICAL PATTERNS

### Supabase Queries
```typescript
// Always use menuca_v3 schema
const supabase = await createClient()

// RPC calls need explicit schema
await supabase
  .schema('menuca_v3')
  .rpc('function_name', { params })

// Standard queries auto-use default schema from config
const { data } = await supabase
  .from('restaurants')
  .select('*')
  .eq('status', 'active')
```

### Menu Data Fetching Pattern
```typescript
// Get courses and dishes separately (due to NULL course_id issue)
const { data: courses } = await supabase
  .from('courses')
  .select('*')
  .eq('restaurant_id', restaurant.id)
  .eq('is_active', true)
  .order('display_order')

const { data: dishes } = await supabase
  .from('dishes')
  .select('*')
  .eq('restaurant_id', restaurant.id)
  .eq('is_active', true)
  .order('display_order')

// Manually group
const menu = courses?.map(course => ({
  ...course,
  dishes: dishes?.filter(dish => dish.course_id === course.id) || []
})) || []

// Handle uncategorized
const uncategorizedDishes = dishes?.filter(dish => dish.course_id === null) || []
if (uncategorizedDishes.length > 0) {
  menu.push({ /* "Other Items" category */ })
}
```

### TypeScript Interfaces
```typescript
interface Restaurant {
  id: number
  name: string
  slug: string
  status: string
  online_ordering_enabled: boolean
}

interface Course {
  id: number
  name: string
  description?: string
  display_order: number
  is_active: boolean
  dishes: Dish[]
}

interface Dish {
  id: number
  name: string
  description?: string
  base_price: number
  image_url?: string
  is_active: boolean
  has_customization: boolean
}
```

---

## 🧪 TESTING URLS

### Local Development
- **Dev Server:** http://localhost:3001
- **Port:** 3001 (3000 is taken by another process)

### Test Restaurants (Guaranteed Menu Data)
```
http://localhost:3001/r/pho-dau-bo-restaurant-kitchener-147  # 186 dishes ⭐
http://localhost:3001/r/lucky-star-chinese-food-8            # 142 dishes
http://localhost:3001/r/cathay-restaurants-72                # 233 dishes
http://localhost:3001/r/shaan-tandoori-269                   # 199 dishes
http://localhost:3001/r/cypress-garden-42                    # 169 dishes
```

### Search Testing
```
http://localhost:3001/search?q=pizza
http://localhost:3001/search?q=chinese
http://localhost:3001/search?cuisine=Asian
```

---

## 🚧 KNOWN ISSUES & WORKAROUNDS

### Issue: NULL course_id in 65% of dishes
**Impact:** Nested Supabase queries fail to return dishes without course_id
**Workaround:** Fetch separately and manually group (implemented)
**Long-term Fix:** Backend team needs to link dishes to courses

### Issue: 89.5% of "active" restaurants have no menu data
**Impact:** Most restaurant pages show "No menu available"
**Workaround:** Data audit identifies 29 working restaurants
**Long-term Fix:** Data migration team needs to populate menu data

### Issue: No dish images in database
**Impact:** Menu looks text-heavy without photos
**Workaround:** Graceful handling (0-width container when no image)
**Long-term Fix:** Image upload system + data population

---

## 📚 DOCUMENTATION REFERENCE

### Primary Docs (Check These First!)
1. **DATABASE_SCHEMA_REFERENCE.md** - Complete schema with all columns
2. **RESTAURANT_DATA_AUDIT_2025_10_24.md** - Which restaurants have data
3. **HANDOFF_TO_NEW_SESSION.md** - Session startup instructions
4. **FRONTEND_BUILD_MEMORY.md** - This file

### Business Rules (In /documentation folder)
- `Menu & Catalog/BUSINESS_RULES.md` - Menu system rules
- `Vendors & Franchises/` - Restaurant management
- `Orders & Checkout/` - Order processing (Phase 2)

---

## 🎯 NEXT STEPS (Pending User Direction)

### Phase 2: Shopping Cart & Checkout (Not Started)
- [ ] Cart sidebar component
- [ ] Add/remove items
- [ ] Modifier selection modal
- [ ] Size selection
- [ ] Cart persistence
- [ ] Checkout flow
- [ ] Guest checkout
- [ ] Order submission

### Phase 3: User Accounts (Not Started)
- [ ] Sign up / Sign in
- [ ] User profile
- [ ] Order history
- [ ] Saved addresses
- [ ] Payment methods

### Improvements to Current Phase
- [ ] Add dish images when available
- [ ] Improve search with filters
- [ ] Add restaurant ratings/reviews (when data available)
- [ ] Add delivery time estimates
- [ ] Add cuisine type badges

---

## 💡 LESSONS LEARNED

### What Worked Well
1. **Using Supabase MCP** to discover schema instead of guessing
2. **Data audit first** before building features dependent on data
3. **Competitive analysis** (UberEats/DoorDash) for design standards
4. **Incremental testing** with verified restaurant IDs

### What Didn't Work
1. **Assuming schema structure** - wasted multiple sessions
2. **Not checking data quality** - built features for missing data
3. **Gated UX patterns** - user hated single-category-at-a-time display
4. **Not comparing to competitors** - initial design was too sparse

### User Preferences (Critical!)
- ✅ **Do:** Match industry standards (don't reinvent the wheel)
- ✅ **Do:** Show all content at once, categories as navigation
- ✅ **Do:** Verify data exists before building features
- ❌ **Don't:** Use placeholder/fake data
- ❌ **Don't:** Hide features - show indicators and fix data flow
- ❌ **Don't:** Assume schema - always verify with MCP

---

## 🔄 UPDATE LOG

### 2025-10-24 - Menu Redesign Complete
- Redesigned dish cards: horizontal layout, 120px images, compact spacing
- Updated menu display: 2-column grid, reduced spacing (space-y-6)
- Achieved 4x better space efficiency (8-12 dishes per viewport)
- Matches UberEats/DoorDash aesthetic
- User feedback: "incredible work!!!!!! nicely done this is way better looking"

### 2025-10-24 - Menu UX Fix
- Changed from single-category view to show-all-dishes-at-once
- Categories now serve as jump navigation, not content gates
- User feedback: Resolved frustration with gated content behind 20 clicks

### 2025-10-24 - Schema Discovery & Data Audit
- Used Supabase MCP to query menuca_v3 schema
- Documented all menu tables (courses, dishes, dish_prices, modifiers, ingredients)
- Added RLS policies for public read access
- Completed data audit: 29/277 restaurants have menu data
- Created RESTAURANT_DATA_AUDIT_2025_10_24.md

### 2025-10-24 - Initial Menu Implementation
- Built restaurant menu page with category navigation
- Implemented dish cards with pricing
- Fixed NULL course_id issue with separate fetches + manual grouping
- Added "Other Items" category for uncategorized dishes

---

**Last Session End:** Menu redesign complete, ready for Phase 2 or additional Phase 1 improvements
**Dev Server:** Running on http://localhost:3001
**Status:** ✅ Phase 1 MVP Complete - Restaurant browsing and menu display working
