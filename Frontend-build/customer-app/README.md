# Menu.ca Customer Ordering App

**Status:** MVP v1.0 - Core functionality implemented  
**Tech Stack:** Next.js 14 + TypeScript + Tailwind + Supabase  
**Built:** October 22, 2025

---

## ✅ What's Implemented (Phase 1 MVP)

### Core Features:
1. **Restaurant Discovery** (`/` homepage)
   - Browse restaurants near location
   - Uses `get_restaurants_near_location()` SQL function
   - Restaurant cards with ratings, distance, status

2. **Restaurant Search** (`/search?q=pizza`)
   - Full-text search using `search_restaurants_full_text()` SQL function
   - Filter by location
   - Search bar in header

3. **Restaurant Menu Page** (`/r/[slug]`)
   - Dynamic restaurant pages by slug
   - Full menu display with categories
   - Dish cards with images, prices, descriptions
   - Add to cart functionality

4. **Shopping Cart** (Zustand state management)
   - Persistent cart (localStorage)
   - Add/remove items
   - Quantity adjustment
   - Real-time subtotal/tax/total calculation
   - Cross-restaurant cart protection

5. **Checkout Page** (`/checkout`)
   - Cart review and editing
   - Order summary
   - Ready for payment integration

---

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd Frontend-build/customer-app
npm install
```

### 2. Create Environment Variables
Create `.env.local` file:
```env
NEXT_PUBLIC_SUPABASE_URL=https://nthpbtdjhhnwfxqsxbvy.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHBidGRqaGhud2Z4cXN4YnZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgzMjg2MDcsImV4cCI6MjA0MzkwNDYwN30.yk8w9SXQPHqHevN_aOnAJ4SrGH_gfHMX3RTy5zWCbZo

# Stripe (add later)
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
```

### 3. Run Development Server
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## 📦 Project Structure

```
customer-app/
├── app/
│   ├── page.tsx                  # Homepage (restaurant discovery)
│   ├── search/
│   │   └── page.tsx              # Search results
│   ├── r/
│   │   └── [slug]/
│   │       └── page.tsx          # Restaurant menu page
│   └── checkout/
│       └── page.tsx              # Checkout page
│
├── components/
│   ├── restaurant-grid.tsx       # Restaurant listing grid
│   ├── restaurant-card.tsx       # Individual restaurant card
│   ├── restaurant-header.tsx     # Restaurant page header
│   ├── menu-display.tsx          # Menu categories and dishes
│   ├── dish-card.tsx             # Individual dish card
│   ├── search-bar.tsx            # Search input component
│   └── mini-cart-button.tsx      # Floating cart button
│
├── lib/
│   ├── supabase/
│   │   ├── client.ts             # Client-side Supabase
│   │   └── server.ts             # Server-side Supabase
│   └── store/
│       └── cart-store.ts         # Zustand cart state
│
└── README.md                     # This file
```

---

## 🔗 Backend Integration

### SQL Functions Used (from Santiago's Backend):
1. `get_restaurants_near_location(p_latitude, p_longitude, p_radius_km)`
   - Returns restaurants within radius
   - Includes distance calculation
   - Used on homepage

2. `search_restaurants_full_text(p_search_query, p_limit)`
   - Full-text search across restaurants
   - Includes ranking
   - Used on search page

3. Direct table queries:
   - `restaurants` (with locations and contacts)
   - `courses` (menu categories)
   - `dishes` (menu items)
   - `dish_modifiers` (customization options)

### Phase 0 Database Features (Already Implemented):
- ✅ Guest checkout support (`is_guest_order`, `guest_email`, `guest_phone`)
- ✅ Real-time inventory system (`check_cart_availability()`)
- ✅ Server-side price validation (`calculate_order_total()`)
- ✅ Order cancellation (`cancel_customer_order()`)
- ✅ Modifier validation (`validate_dish_modifiers()`)

---

## 🎯 What's Next (Phase 2)

### 1. Guest Checkout Flow
- Email and phone capture
- Address input with geocoding
- Service type selection (delivery/pickup)

### 2. Stripe Payment Integration
- Payment Intent API
- Stripe Elements checkout form
- Webhook handler for payment confirmation

### 3. Order Tracking
- Real-time order status updates
- Order confirmation page
- Order history

### 4. User Authentication
- Sign up / sign in
- Saved addresses
- Saved payment methods
- Order history

### 5. Dish Customization Modal
- Modifier selection
- Required modifiers validation
- Price calculation with modifiers

---

## 🛠️ Tech Stack Details

**Framework:** Next.js 14 (App Router)
- Server Components for data fetching
- Client Components for interactivity
- TypeScript for type safety

**Database:** Supabase (PostgreSQL + PostGIS)
- 50+ SQL functions ready to use
- 29 Edge Functions for write operations
- Real-time subscriptions available

**Styling:** Tailwind CSS + shadcn/ui
- Mobile-first responsive design
- Accessible components
- Consistent design system

**State Management:**
- Zustand for cart state
- React Query ready for server state

**Icons:** Lucide React

---

## 📊 Database Stats

- **Restaurants:** 959 active
- **Locations:** 917 locations
- **Dishes:** 15,740+ menu items
- **Users:** 32,349 customers
- **Orders:** Partitioned for performance

---

## 🔐 Security Features

- ✅ Server-side data fetching (no exposed secrets)
- ✅ Supabase RLS (Row Level Security) enabled
- ✅ Environment variables for sensitive data
- ✅ Price validation on server (Phase 0)
- ✅ Guest data constraints (Phase 0)

---

## 🎨 Design System

**Colors:**
- Primary: Red-600 (#DC2626) - Menu.ca brand
- Success: Green-600
- Warning: Yellow-500
- Background: Gray-50

**Typography:**
- Font: System font stack (Inter)
- Headings: Bold, 20-32px
- Body: Regular, 14-16px

**Breakpoints:**
- sm: 640px
- md: 768px
- lg: 1024px
- xl: 1280px

---

## 🐛 Known Issues / TODOs

- [ ] Add dish customization modal
- [ ] Implement guest checkout form
- [ ] Add Stripe payment integration
- [ ] Add real-time order tracking
- [ ] Add user authentication (Supabase Auth)
- [ ] Add restaurant hours display
- [ ] Add delivery zone validation
- [ ] Add restaurant rating/review display
- [ ] Add error boundaries
- [ ] Add loading skeletons
- [ ] Add proper image optimization

---

## 📝 Notes

**Database Branches:**
- Production: `nthpbtdjhhnwfxqsxbvy` (Replit uses this)
- Cursor Build: `cursor-build` branch (Cursor uses this)

**Competition:** Cursor vs Replit
- Both building same frontend
- Compare speed, quality, bugs
- Winner determined in 1 week

**Backend Complete:** Santiago has built all backend APIs - frontend just needs to call them!

---

**Built by:** Cursor AI (Claude Sonnet 4.5)  
**Date:** October 22, 2025  
**Repository:** https://github.com/SantiagoWL117/Migration-Strategy
