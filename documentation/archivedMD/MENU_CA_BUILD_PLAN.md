# 🍕 Menu.ca V3 - Complete Build Plan
**Project:** Multi-tenant Restaurant Ordering Platform  
**Database:** menuca_v3 (Supabase PostgreSQL)  
**Tech Stack:** Next.js 14 (App Router) + TypeScript + Supabase + TailwindCSS  
**Goal:** Modern, scalable platform to replace V1/V2 legacy apps

---

## 🎯 **PROJECT OVERVIEW**

Menu.ca is a **white-label restaurant ordering platform** where:
- 🏢 **74 restaurants** use our service
- 🔗 **Each restaurant links from their own website** (no central splash page)
- 👥 **32,000+ customers** can order delivery or pickup
- 🎨 **Each restaurant has custom branding** (colors, fonts, images)
- 📊 **Restaurant owners manage their own menus, promos, delivery areas**
- 🔐 **Multi-level admin system** (master admins + restaurant admins)

---

## 📐 **ARCHITECTURE**

### **Three Main Sections:**

```
┌─────────────────────────────────────────────────────────────┐
│                     MENU.CA V3 PLATFORM                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌───────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │  Master Admin │  │ Restaurant     │  │  Customer    │  │
│  │  Dashboard    │  │ Owner Portal   │  │  Ordering    │  │
│  │               │  │                │  │  Frontend    │  │
│  │  (Brian +     │  │  (Per          │  │  (Per        │  │
│  │  Santiago)    │  │  Restaurant)   │  │  Restaurant) │  │
│  └───────────────┘  └────────────────┘  └──────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
                    ┌───────┴────────┐
                    │   Supabase     │
                    │   menuca_v3    │
                    │   (74 tables)  │
                    └────────────────┘
```

---

## 🏗️ **BUILD PHASES**

### **Phase 1: Foundation** 🟢 **(START HERE)**
1. ✅ Project Setup (Next.js 14 + TypeScript + Supabase)
2. ✅ Authentication System (admin_users, restaurant_admin_users, users)
3. ✅ Database Types Integration (`types/supabase-database.ts`)
4. ✅ Layout System (Admin Dashboard, Restaurant Portal, Customer Frontend)

### **Phase 2: Master Admin Dashboard** 🟡
1. 🔐 Master Admin Authentication
2. 📊 Restaurant Management (CRUD for 74 restaurants)
3. 👥 Admin User Management
4. 📈 Platform Analytics (orders, revenue, performance)
5. 🚨 System Monitoring (failed jobs, email queue, rate limits)

### **Phase 3: Restaurant Owner Portal** 🟡
1. 🔐 Restaurant Admin Authentication
2. 📋 Menu Management (courses, dishes, pricing, modifiers)
3. 🚚 Delivery Configuration (areas, fees, schedules)
4. 🎨 Branding Customization (colors, fonts, images)
5. 🎫 Promotions & Coupons
6. 👥 Staff Management
7. 📊 Restaurant Analytics
8. 📧 Email Template Customization

### **Phase 4: Customer Ordering Frontend** 🟢 **(PRIORITY)**
1. 🏠 Restaurant Landing Page (per-restaurant branding)
2. 📖 Menu Display (courses, dishes, combos)
3. 🛒 Shopping Cart System
4. 🎛️ Dish Customization (modifiers, extras, special instructions)
5. 💳 Checkout Flow
6. 🚚 Delivery vs Pickup Selection
7. 📧 Order Confirmation & Email
8. 📱 Order Tracking

### **Phase 5: Polish & Launch** 🔴
1. 🎨 UI/UX Refinement
2. 🔐 Security Hardening (RLS policies)
3. ⚡ Performance Optimization
4. 📱 Mobile Responsiveness
5. 🧪 Testing & QA
6. 🚀 Production Deployment

---

## 🔐 **USER ROLES & PERMISSIONS**

### **1. Master Admin** (Brian & Santiago)
**Access:** Full platform control  
**Can:**
- ✅ Manage all restaurants
- ✅ Create/edit/delete restaurant owners
- ✅ View all analytics
- ✅ Configure system settings
- ✅ Access failed jobs, email queue, audit logs
- ✅ Manage vendors & commissions

**DB Tables:**
- `admin_users` (WHERE email IN ('brian@menu.ca', 'santiago@menu.ca'))
- `admin_user_restaurants` (access to all restaurants)

---

### **2. Restaurant Owner/Admin**
**Access:** Single restaurant (or multiple if franchise)  
**Can:**
- ✅ Manage menu items (dishes, courses, ingredients, combos)
- ✅ Set delivery fees & areas
- ✅ Create promotions & coupons
- ✅ Customize branding (colors, fonts, logo, images)
- ✅ Manage staff (restaurant_admin_users)
- ✅ View restaurant analytics
- ✅ Edit email templates
- ✅ Configure schedules (delivery/takeout hours)
- ❌ Cannot see other restaurants
- ❌ Cannot access system-wide settings

**DB Tables:**
- `restaurant_admin_users` (restaurant_id = their_restaurant)
- Filtered views of all menu/config tables

---

### **3. Restaurant Staff**
**Access:** Limited restaurant access  
**Can:**
- ✅ View orders
- ✅ Update order status
- ✅ View menu (read-only)
- ❌ Cannot edit menu
- ❌ Cannot edit pricing
- ❌ Cannot manage other staff

**DB Tables:**
- `restaurant_admin_users` (WHERE role = 'staff')

---

### **4. Customer**
**Access:** Public ordering interface  
**Can:**
- ✅ Browse menu
- ✅ Place orders (delivery/pickup)
- ✅ Save delivery addresses
- ✅ View order history
- ✅ Apply coupons
- ❌ Cannot see backend

**DB Tables:**
- `users`
- `orders`, `order_items`
- `user_addresses`

---

## 🎨 **FEATURE BREAKDOWN**

### **A. Master Admin Dashboard Features**

#### **1. Restaurant Management**
```
CRUD Operations:
- Create new restaurant
- Edit restaurant details (name, status, timezone)
- Activate/suspend/close restaurants
- Assign restaurant owners
- View restaurant performance metrics

UI Components:
- DataTable with filters (status, city, created_date)
- Restaurant detail modal
- Quick actions (activate, suspend, delete)
- Bulk operations
```

#### **2. Platform Analytics**
```
Metrics:
- Total orders (today, week, month, year)
- Revenue breakdown by restaurant
- Top performing restaurants
- Order trends (line chart)
- Delivery vs Pickup ratio
- Average order value

Charts:
- Revenue over time (line chart)
- Orders by restaurant (bar chart)
- Order status breakdown (pie chart)
- Geographic distribution (map)
```

#### **3. System Monitoring**
```
Dashboards:
- Failed jobs (retry/resolve)
- Email queue status
- Rate limit alerts
- Audit log viewer
- Database health metrics
```

#### **4. Vendor Management**
```
Features:
- Create/edit vendors
- Assign restaurants to vendors
- Generate commission reports
- View payment history
```

---

### **B. Restaurant Owner Portal Features**

#### **1. Menu Management** 🍔
```
Courses:
- Create/edit/delete courses (Appetizers, Entrees, etc.)
- Reorder courses (drag & drop)
- Enable/disable courses

Dishes:
- Create/edit/delete dishes
- Upload dish images
- Set pricing (single price or size variants)
- Add allergen info & nutritional data
- Set availability schedules
- Mark as combo/upsell
- Enable customization

Ingredients & Modifiers:
- Create ingredient groups (e.g., "Choose 2 toppings")
- Add ingredients to groups
- Set pricing rules (free quantity, extra charges)
- Define min/max selections
- Allow duplicates toggle

Combos:
- Create combo groups (e.g., "Lunch Special")
- Add dishes to combo
- Set combo pricing
- Configure modifier pricing for combos
```

#### **2. Delivery Configuration** 🚚
```
Delivery Areas:
- Draw delivery zones on map (PostGIS polygons)
- Set delivery fees per zone
- Define minimum order amounts
- Set maximum delivery distance

Delivery Schedules:
- Set delivery hours (per day of week)
- Set pickup hours
- Create special schedules (holidays, closures)
- Configure time periods (lunch, dinner)

Delivery Companies:
- Assign delivery partners
- Set commission rates
- Configure notification emails
```

#### **3. Branding Customization** 🎨
```
Visual Settings:
- Primary color picker
- Secondary color picker
- Font selection (Google Fonts)
- Logo upload (SVG/PNG)
- Banner image upload
- Favicon upload

Restaurant Info:
- Restaurant name
- Description
- Phone number
- Email
- Social media links
- Operating hours display

Preview:
- Live preview of customer-facing site
- Mobile/desktop toggle
```

#### **4. Promotions & Coupons** 🎫
```
Promotional Deals:
- Create deals (% off, $ off, BOGO, etc.)
- Set validity period
- Configure active days/hours
- Set minimum purchase
- Select applicable menu items
- Create combo deals
- Set display order on site

Coupons:
- Generate coupon codes
- Set discount type (fixed/percent)
- Set usage limits (total & per user)
- Set expiration date
- Configure auto-apply rules
- Track usage in coupon_usage_log
```

#### **5. Staff Management** 👥
```
Features:
- Invite staff via email
- Assign roles (admin, manager, staff)
- Set permissions per staff member
- Deactivate/reactivate accounts
- View staff activity logs
```

#### **6. Restaurant Analytics** 📊
```
Metrics:
- Orders (today, week, month)
- Revenue (with tax/delivery breakdown)
- Top selling dishes
- Busiest hours/days
- Average order value
- Customer retention rate
- Delivery vs pickup ratio

Charts:
- Revenue trend (line chart)
- Orders by hour (bar chart)
- Dish popularity (pie chart)
- Order source breakdown (web/mobile)

Reports:
- Daily sales report
- Weekly summary
- Monthly statement
- Dish performance report
- Customer insights
```

#### **7. Email Template Customization** 📧
```
Email Types:
- Order confirmation
- Order ready for pickup
- Out for delivery
- Order delivered
- Order cancelled
- Promotional emails

Editor:
- WYSIWYG editor
- Variable insertion ({{customer_name}}, {{order_number}})
- Preview in inbox
- Test email send
- Template versioning
```

---

### **C. Customer Ordering Frontend Features**

#### **1. Restaurant Landing Page** 🏠
```
Components:
- Hero section (banner image)
- Restaurant info (name, address, phone, hours)
- Quick action buttons (Order Now, View Menu)
- Featured deals
- Customer reviews (future)
- Social media links

Branding:
- Custom colors from restaurant_service_configs
- Custom fonts
- Logo display
- Theme applied site-wide
```

#### **2. Menu Display** 📖
```
Layout:
- Sticky course navigation (Appetizers, Entrees, etc.)
- Dish cards (image, name, description, price)
- Dietary icons (vegan, gluten-free, allergens)
- Search bar (uses search_vector for full-text search)
- Filter by category/dietary
- Sort by price/popularity

Dish Detail Modal:
- Large image
- Full description
- Allergen info
- Nutritional info
- Size selection (if multiple sizes)
- Modifier groups (ingredient_groups)
- Quantity selector
- "Add to Cart" button
```

#### **3. Shopping Cart** 🛒
```
Features:
- Persistent cart (localStorage + DB for logged-in users)
- Item list with customizations
- Edit item (reopen modal)
- Remove item
- Quantity adjustment
- Subtotal calculation
- Estimated tax
- Delivery fee display
- Tip selector (%)
- Coupon code input
- Total display
- "Checkout" button

Validations:
- Minimum order check (delivery_min_order)
- Delivery area check
- Restaurant open/closed status
- Item availability
```

#### **4. Dish Customization** 🎛️
```
Modifier System:
- Display ingredient groups
- Show min/max selection rules
- Display pricing (free quantity, extra charges)
- Allow duplicates (if enabled)
- Ingredient search within group
- Special instructions text area
- Price updates in real-time

Example: Pizza
┌─────────────────────────────────┐
│ Choose Size: [S] [M] [L] [XL]  │
│                                 │
│ Toppings (Choose up to 5)      │
│ First 2 free, extra $1.50 each │
│ ☐ Pepperoni                     │
│ ☐ Mushrooms                     │
│ ☐ Extra Cheese (+$1.50)         │
│                                 │
│ Special Instructions:           │
│ [Text area...]                  │
│                                 │
│ Total: $14.99                   │
│ [Add to Cart]                   │
└─────────────────────────────────┘
```

#### **5. Checkout Flow** 💳
```
Steps:

1. Delivery/Pickup Selection
   - Toggle between delivery/pickup
   - If delivery: address input/selection
   - If pickup: show restaurant location + directions

2. Delivery Address (if delivery)
   - Saved addresses dropdown (user_addresses)
   - Add new address form
   - Address validation (in delivery area?)
   - Special delivery instructions

3. Contact Information
   - Name, phone, email
   - Pre-filled if logged in
   - Guest checkout option

4. Payment Method
   - Credit card
   - Pay at door (cash)
   - Apple Pay / Google Pay (future)

5. Order Review
   - Cart summary
   - Delivery/pickup details
   - Total breakdown
   - Apply coupon
   - Accept terms checkbox
   - "Place Order" button

6. Order Confirmation
   - Order number
   - Estimated time
   - Email confirmation sent
   - Order tracking link
```

#### **6. Order Tracking** 📱
```
Status Updates:
- Pending (order received)
- Confirmed (restaurant accepted)
- Preparing (cooking)
- Ready (for pickup or delivery)
- Out for Delivery
- Delivered/Completed

Real-time Updates:
- Order status badge
- Progress bar
- Estimated time remaining
- Live map (if out for delivery)
- SMS/email notifications

User Actions:
- Cancel order (if pending)
- Call restaurant
- Report issue
- Reorder
```

---

## 📊 **KEY DATABASE RELATIONSHIPS**

```
restaurants (74)
  ├── restaurant_locations (82) - addresses, coords
  ├── restaurant_schedules (1002) - delivery/takeout hours
  ├── restaurant_service_configs (944) - delivery settings
  ├── restaurant_domains (713) - custom domains
  ├── courses (1207) - menu categories
  │     └── dishes (15,740) - menu items
  │           ├── dish_prices (6,005) - size pricing
  │           ├── dish_modifiers (2,922) - customizations
  │           └── combo_items (16,356) - combo relationships
  ├── ingredient_groups (9,169) - modifier groups
  │     ├── ingredient_group_items (37,684) - group contents
  │     └── ingredients (31,542) - toppings, extras
  ├── combo_groups (8,234) - meal deals
  ├── promotional_deals (202) - discounts
  ├── promotional_coupons (581) - promo codes
  ├── orders (partitioned by month) - customer orders
  │     └── order_items (partitioned) - line items
  ├── admin_user_restaurants (533) - owner assignments
  └── restaurant_admin_users (439) - staff accounts

users (32,349) - customers
  ├── user_addresses (0) - saved addresses
  ├── orders - order history
  └── coupon_usage_log - coupon tracking

admin_users (456) - platform admins
  └── admin_user_restaurants (533) - restaurant access
```

---

## 🎨 **DESIGN SYSTEM**

### **Tech Stack:**
- **Framework:** Next.js 14 (App Router)
- **Styling:** TailwindCSS + shadcn/ui components
- **Database:** Supabase (PostgreSQL)
- **Auth:** Supabase Auth + RLS
- **Forms:** React Hook Form + Zod validation
- **State:** Zustand (cart) + React Query (API)
- **Maps:** Mapbox GL (delivery areas)
- **Charts:** Recharts or Chart.js
- **Images:** Next.js Image + Cloudinary/Supabase Storage
- **Email:** Resend or SendGrid

### **UI Components:**
```
shadcn/ui Components to Use:
- Button, Input, Textarea
- Select, Combobox, RadioGroup
- Dialog, Sheet, Popover
- Table, DataTable
- Card, Tabs
- Form components
- Toast notifications
- Badge, Avatar
- Accordion, Collapsible
```

### **Color Scheme:**
```
Master Admin: Professional Blue
- Primary: #2563EB (blue-600)
- Secondary: #64748B (slate-500)

Restaurant Portal: Customizable
- Uses restaurant_service_configs.primary_color
- Uses restaurant_service_configs.secondary_color

Customer Frontend: Per-Restaurant Branding
- Fully customizable via restaurant settings
```

---

## 🚀 **DEVELOPMENT ROADMAP**

### **Week 1-2: Foundation**
- [ ] Next.js 14 project setup
- [ ] Supabase connection + types integration
- [ ] Authentication system (all 3 user types)
- [ ] Layout components (Admin/Restaurant/Customer)
- [ ] Basic routing structure

### **Week 3-4: Customer Frontend (MVP)**
- [ ] Restaurant landing page
- [ ] Menu display with courses/dishes
- [ ] Dish detail modal
- [ ] Shopping cart
- [ ] Basic checkout flow
- [ ] Order confirmation

### **Week 5-6: Restaurant Portal (MVP)**
- [ ] Login system
- [ ] Dashboard home
- [ ] Menu management (CRUD)
- [ ] Basic analytics
- [ ] Staff management

### **Week 7-8: Master Admin Dashboard**
- [ ] Restaurant management
- [ ] Platform analytics
- [ ] Admin user management
- [ ] System monitoring

### **Week 9-10: Advanced Features**
- [ ] Delivery area mapping
- [ ] Promotion system
- [ ] Email templates
- [ ] Advanced customization
- [ ] Order tracking

### **Week 11-12: Polish & Launch**
- [ ] UI/UX refinement
- [ ] Mobile optimization
- [ ] Performance tuning
- [ ] Security hardening
- [ ] Production deployment

---

## 📝 **REPLIT PROMPT TEMPLATE**

Use this prompt when starting with Replit Agent:

```markdown
# Menu.ca V3 - Multi-Tenant Restaurant Ordering Platform

## Context
I'm building a white-label restaurant ordering platform where 74 restaurants use our service. Each restaurant has custom branding and manages their own menus, delivery, and promotions.

## Tech Stack
- Next.js 14 (App Router) + TypeScript
- Supabase PostgreSQL (menuca_v3 database)
- TailwindCSS + shadcn/ui
- React Hook Form + Zod

## Database
I've attached `types/supabase-database.ts` with full TypeScript types for all 74 tables.

**Key tables:**
- `restaurants` (74 restaurants)
- `dishes` (15,740 menu items)
- `orders` (partitioned by month)
- `users` (32,349 customers)
- `admin_users` (456 admins)

**GitHub Documentation:**
- Setup Guide: https://github.com/SantiagoWL117/Migration-Strategy/blob/main/REPLIT_SUPABASE_SETUP.md
- Build Plan: https://github.com/SantiagoWL117/Migration-Strategy/blob/main/MENU_CA_BUILD_PLAN.md

## First Feature: Customer Menu Page

Build a restaurant menu page that:

1. **Accepts restaurant ID** from URL params
2. **Fetches restaurant data:**
   ```typescript
   const { data: restaurant } = await supabase
     .from('restaurants')
     .select('*, restaurant_locations(*), restaurant_service_configs(*)')
     .eq('id', restaurantId)
     .single()
   ```

3. **Fetches menu with courses:**
   ```typescript
   const { data: courses } = await supabase
     .from('courses')
     .select(`
       *,
       dishes (
         *,
         dish_prices (*)
       )
     `)
     .eq('restaurant_id', restaurantId)
     .eq('is_active', true)
     .order('display_order')
   ```

4. **Displays:**
   - Restaurant header (name, address, hours)
   - Course navigation (sticky)
   - Dish cards with images, pricing
   - Full-text search using `search_vector`

5. **Styling:**
   - Use shadcn/ui components
   - Apply custom colors from `restaurant_service_configs`
   - Mobile responsive

Use TypeScript types from `types/supabase-database.ts` for all queries!
```

---

## 🎯 **SUCCESS CRITERIA**

### **Customer Frontend:**
- ✅ Load menu in < 1 second
- ✅ Smooth scrolling between courses
- ✅ Real-time cart updates
- ✅ Mobile-first responsive design
- ✅ Works on all restaurant domains

### **Restaurant Portal:**
- ✅ Menu changes reflect immediately
- ✅ Intuitive drag-drop reordering
- ✅ Image uploads < 5MB
- ✅ Analytics load < 2 seconds
- ✅ Multi-location support

### **Master Admin:**
- ✅ Manage all 74 restaurants
- ✅ Real-time platform metrics
- ✅ Failed job recovery
- ✅ Audit trail for all changes

---

## 📞 **SUPPORT & RESOURCES**

**Database Documentation:**
- Schema Audit: `Database/V3_COMPLETE_TABLE_AUDIT.md`
- Scalability Report: `Database/V3_Optimization/SCHEMA_SCALABILITY_AUDIT.md`
- Mermaid Diagrams: `Database/Mermaid_Diagrams/*.mmd`

**GitHub Repo:**
```
https://github.com/SantiagoWL117/Migration-Strategy
```

**Key Files:**
- TypeScript Types: `types/supabase-database.ts`
- Setup Guide: `REPLIT_SUPABASE_SETUP.md`
- Build Plan: `MENU_CA_BUILD_PLAN.md`

---

**Ready to build! 🚀**

Start with Phase 1 (Foundation), then tackle Phase 4 (Customer Frontend) as the first user-facing feature!

