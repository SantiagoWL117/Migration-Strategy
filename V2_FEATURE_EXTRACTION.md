# 🔍 V2 Feature Extraction
**Comprehensive catalog of ALL features from V2 admin dashboard**

---

## 📋 **HOW TO USE THIS DOCUMENT**

1. **Upload V2 screenshots** to `v2-design-reference/` folder
2. **For each screenshot**, I'll document:
   - Feature name
   - What it does
   - Which V3 tables it uses
   - Priority (Must Have / Nice to Have / Skip)
   - Modern equivalent/improvement
3. **Check off features** as we implement them in V3

---

## 🏗️ **MASTER ADMIN FEATURES (From V2 Screenshots)**

### **1. Restaurant Management**

#### **Screenshot 01: Restaurants - Inactive List**
**Features Observed:**
- ✅ Search bar (by name or address)
- ✅ Table view with columns: Name
- ✅ Edit button per restaurant
- ✅ Status-based filtering (Inactive, Pending, Active)

**V3 Implementation:**
- Table: `restaurants` (WHERE status = 'inactive')
- Component: DataTable with server-side search
- Actions: Edit (navigate to restaurant detail)

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Add bulk actions (activate multiple, delete multiple)
- Add filters (city, cuisine type, created date)
- Add "reason for inactive" column
- Export to CSV

---

#### **Screenshot 07: Restaurants - Add Restaurant Form**
**Features Observed:**
- ✅ Restaurant name input
- ✅ Contact info section (street, phone, email)
- ✅ Restaurant info section (pickup Y/N, delivery Y/N, bilingual Y/N)
- ✅ Save restaurant button

**V3 Implementation:**
- Tables: `restaurants`, `restaurant_locations`, `restaurant_service_configs`
- Component: Multi-step form wizard
- Validation: Zod schema

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Step 1: Basic info (name, cuisine type)
- Step 2: Location (address, coordinates via map picker)
- Step 3: Services (delivery/pickup toggles)
- Step 4: Contact (phone, email, owner info)
- Auto-geocode address to lat/lng
- Show preview before saving

---

#### **Screenshot 08: Restaurants - Pending List**
**Features Observed:**
- ✅ Search bar
- ✅ Table with: Name, Address, Phone columns
- ✅ Edit button per restaurant
- ✅ List of pending restaurants (awaiting activation)

**V3 Implementation:**
- Table: `restaurants` (WHERE status = 'pending')
- Component: DataTable with approve/reject actions

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Add "Approve" and "Reject" quick actions
- Show "pending since" date
- Add bulk approve
- Send email notification on approval
- Show completion percentage (e.g., "80% complete - missing menu")

---

#### **Screenshot 16: Restaurants - Active List**
**Features Observed:**
- ✅ Search bar
- ✅ Table with: Name, Address, Phone columns
- ✅ Edit button per restaurant
- ✅ Clickable phone numbers (tel: links)

**V3 Implementation:**
- Table: `restaurants` (WHERE status = 'active')
- Component: DataTable with inline actions

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Add status indicators (online/offline)
- Show last order time
- Add quick stats (orders today, revenue this week)
- Color-code by performance (green = high orders, yellow = medium, red = low)

---

### **2. Dashboard & Analytics**

#### **Screenshot 02: Dashboard - Cancel Order Requests**
**Features Observed:**
- ✅ Grouped by restaurant name
- ✅ Table with: Order ID, Reason supplied, Requested by, Requested at, Accepted
- ✅ Clickable order IDs (links to order detail)
- ✅ Accept/Reject buttons (with ✖ No icons)
- ✅ Timestamp tracking

**V3 Implementation:**
- Table: Custom table `order_cancellation_requests` (needs to be created)
- Relationships: `orders`, `users`, `admin_users`
- Component: Grouped accordion/card view

**Priority:** ⭐⭐ **NICE TO HAVE** (not in current V3 schema)

**Modern Improvements:**
- Add cancellation reason categories (customer request, duplicate order, restaurant issue)
- Show refund amount
- Auto-approve after 24 hours if no action
- Show customer impact (loyal customer vs new customer)

**V3 Schema Addition Needed:**
```sql
CREATE TABLE menuca_v3.order_cancellation_requests (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL,
  order_created_at TIMESTAMPTZ NOT NULL, -- for partitioned FK
  requested_by_user_id BIGINT,
  requested_by_admin_id BIGINT,
  reason TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, approved, rejected
  reviewed_by_admin_id BIGINT,
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  FOREIGN KEY (order_id, order_created_at) REFERENCES menuca_v3.orders(id, created_at)
);
```

---

#### **Screenshot 05: Dashboard - Live Feeds & Stats**
**Features Observed:**
- ✅ "Show all restaurants" dropdown
- ✅ Live feeds tab vs Active deals tab toggle
- ✅ Search by order ID
- ✅ Custom date range search (start/stop)
- ✅ "Future orders" count display
- ✅ Stats cards for:
  - Today: Total orders, Accepted orders, Pending orders, Rejected orders, Total order value
  - Yesterday: Same metrics
  - This month: Same metrics
  - Last month: Same metrics
- ✅ Top tabs: Availability, Statements, Dishes sales, Client list, Announcements, Disable dishes, Cancel order, Reports

**V3 Implementation:**
- Tables: `orders`, `order_items`, `restaurants`
- Queries: Aggregations by date range
- Component: Dashboard grid with stat cards
- Real-time: Use Supabase Realtime subscriptions

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Add charts (line chart for revenue trend)
- Add "vs last period" comparison (e.g., "+12% vs yesterday")
- Color-code trends (green = up, red = down)
- Add filters: by restaurant, by city, by cuisine type
- Add "export report" button
- Show top 5 restaurants by revenue
- Show busiest hours (heatmap)

---

### **3. User & Permission Management**

#### **Screenshot 09: Groups & Users - Permission Management**
**Features Observed:**
- ✅ "Add a group" form with group name input
- ✅ Page access permissions (checkboxes):
  - Dashboard home
  - Commissions
  - Issue statements
  - Cancel requests
  - View site users
  - View orders from dashboard
  - Vendor reports interface
  - Access active restaurants
  - Tablets page
  - Landing page setup
  - Access pending restaurants
  - Add new restaurants
  - Manage users
  - Manage groups
  - Blacklist (add/list users)
  - Manage aggregators
  - Others (cities, cuisine/tags, newsletter images, mail templates)
  - Reports page
  - AI Settings
  - Show AI context
- ✅ Restaurant access permissions (checkboxes):
  - Info tab, Schedule tab, Delivery area tab, Config tab
  - Citations tab, Banners tab, Menu tab, Deals tab
  - Images & About text tab, Feedback tab, Mail templates tab
  - Charges tab, Landing page tab, Split settings tab, Image assignement tab
- ✅ "Check all" option
- ✅ Groups management list (right side):
  - Admin, Employee, Restaurant owners, Vendors, test group, president
  - Edit and Remove buttons per group

**V3 Implementation:**
- Tables: Need to create `admin_roles` and `admin_permissions` tables
- Current: Only has `admin_user_restaurants` with basic `role` field
- Component: Permission matrix UI

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Use role-based access control (RBAC) instead of group-based
- Predefined roles: Super Admin, Restaurant Manager, Staff, Viewer
- Custom roles with granular permissions
- Permission templates (e.g., "E-commerce Manager" = menu + deals + analytics)
- Show permission conflicts
- Audit trail (who changed permissions when)

**V3 Schema Addition Needed:**
```sql
CREATE TABLE menuca_v3.admin_roles (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  permissions JSONB NOT NULL, -- {page_access: [], restaurant_access: []}
  is_system_role BOOLEAN NOT NULL DEFAULT FALSE, -- can't be deleted
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Update admin_user_restaurants to reference roles
ALTER TABLE menuca_v3.admin_user_restaurants
  ADD COLUMN role_id BIGINT REFERENCES menuca_v3.admin_roles(id);
```

---

#### **Screenshot 14: Users - Add User Form**
**Features Observed:**
- ✅ First name, Last name, Email, Password inputs
- ✅ Preferred language dropdown (English)
- ✅ "Assign to group" dropdown
- ✅ "Allow login to restaurants" (Yes/No radio)
- ✅ "Assign restaurants" (Yes/No radio)
- ✅ "Receive statements from assigned restaurants" (Yes/No radio)
- ✅ Create user button
- ✅ Existing users list (right side):
  - Columns: First name, Last name, Email, Group, Restaurants
  - Shows "Menu Ottawa" user assigned to multiple restaurants
  - Edit button per user

**V3 Implementation:**
- Tables: `admin_users`, `admin_user_restaurants`
- Component: Form with conditional fields

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Send invitation email instead of setting password
- User accepts invitation and sets their own password
- Show user status (invited, active, inactive)
- Add "Resend invitation" button
- Multi-select for restaurants (instead of Yes/No)
- Show restaurant count in table ("15 restaurants")
- Add "Last login" column
- Add "Deactivate" quick action

---

#### **Screenshot 11: List Users - Current Site Users**
**Features Observed:**
- ✅ "Show 250 entries" dropdown
- ✅ Search bar for users
- ✅ Table with columns:
  - First name, Last name, Email address, Creation date, Last login
  - Sortable columns (arrows)
- ✅ Clickable rows (edit icon)
- ✅ 32,349+ users visible in list

**V3 Implementation:**
- Table: `users` (customer accounts)
- Component: DataTable with pagination

**Priority:** ⭐⭐ **NICE TO HAVE**

**Modern Improvements:**
- Add filters: by registration date, by last login, by order count
- Show "Total orders" and "Total spent" columns
- Add "Export users" button
- Add "Send email blast" action
- Show user segments (new, active, at-risk, churned)
- Add "Merge duplicate accounts" feature

---

### **4. Blacklist Management**

#### **Screenshot 03: Blacklist - Search Interface**
**Features Observed:**
- ✅ "Blacklist a user" heading
- ✅ Search input: "Enter term to search for..."
- ✅ Find button
- ✅ Sidebar menu:
  - Add entry
  - Show entries

**V3 Implementation:**
- Table: Need to create `blacklist` table
- Component: Search form with results list

**Priority:** ⭐⭐ **NICE TO HAVE**

**Modern Improvements:**
- Blacklist by: email, phone, IP address, payment method
- Show reason for blacklist
- Show who added them (admin name)
- Add expiration date (temporary blocks)
- Add "appeal" workflow
- Auto-blacklist after 3 failed fraud attempts

**V3 Schema Addition Needed:**
```sql
CREATE TABLE menuca_v3.blacklist (
  id BIGSERIAL PRIMARY KEY,
  identifier_type VARCHAR(20) NOT NULL, -- email, phone, ip, payment_method
  identifier_value VARCHAR(255) NOT NULL,
  reason TEXT NOT NULL,
  blocked_by_admin_id BIGINT REFERENCES menuca_v3.admin_users(id),
  expires_at TIMESTAMPTZ, -- NULL = permanent
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (identifier_type, identifier_value)
);
```

---

### **5. Content Management**

#### **Screenshot 04: Cuisine Types & Restaurant Tags**
**Features Observed:**
- ✅ Two-panel layout: "Cuisine types" | "Restaurant tags"
- ✅ Cuisine types panel:
  - Input: "Cuisine name"
  - Add button
  - List with Delete/Update buttons per item:
    - Barbecue, Brazilian, Breakfast, Chinese, Cuban, Dessert, Ethiopian, Family, French, German, Greek, Hamburger, Indian, Italian (and more)
- ✅ Restaurant tags panel:
  - Input: "Tag name"
  - Add button
  - List with Delete/Update buttons per item:
    - Pita Sandwich, Poutine and Fries, Chinese, Chicken Wings, Soups, Sushi, Pasta, Ribs, Barbecue, Subs, Sandwiches, Wraps, Asian Food, Burgers

**V3 Implementation:**
- Table: `marketing_tags` (already exists with 36 rows)
- Component: Two-column CRUD interface

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Merge cuisine types and tags into single "tags" system with categories
- Add tag icons/images
- Show "used by X restaurants" count
- Add tag suggestions (AI-powered)
- Allow multi-language tags
- Show popular tags (trending)
- Allow restaurants to request new tags

---

#### **Screenshot 06: Cities Management**
**Features Observed:**
- ✅ "Add a new city" form:
  - City name input
  - Display name input
  - Province dropdown ("Choose one")
  - Save button
- ✅ "Available cities" table:
  - Columns: Name, Display name, Province, Timezone
  - Edit button per city
  - 114 cities listed:
    - Kanata, Ottawa, Orleans, Downtown Ottawa, Toronto, London, Almonte, Stittsville, Greely, Nepean, Vanier, Ville de Québec, Montreal, Gatineau, Gloucester, Aylmer, Smiths Falls, Kemptville, Cornwall (and more)
  - All show "America/Toronto" or "America/Montreal" timezones

**V3 Implementation:**
- Tables: `cities` (114 rows), `provinces` (13 rows)
- Component: Form + DataTable

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Auto-populate lat/lng and timezone from city name (API lookup)
- Show map preview
- Group cities by province
- Show "restaurants in this city" count
- Add "merge duplicate cities" feature
- Import cities from CSV

---

#### **Screenshot 18: Email Templates**
**Features Observed:**
- ✅ Two-panel layout: "English" | "French"
- ✅ Template types:
  - Password recover
  - Registration confirmation
  - Order mail
- ✅ WYSIWYG editor per template:
  - Rich text toolbar (font, size, bold, italic, underline, strikethrough, colors, alignment, lists, links, images, tables, code, etc.)
  - Template variables:
    - ##logo##
    - ##restaurantName##
    - ##restaurantAddress##
  - HTML preview
  - "Password Reset" red header
  - Pre-formatted email body with merge fields

**V3 Implementation:**
- Table: Need to create `email_templates` table
- Component: Tabbed editor with WYSIWYG

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Add template preview with live data
- Add "Send test email" button
- Version history (revert to previous version)
- Template library (presets)
- Drag-drop email builder (like Mailchimp)
- Mobile preview
- A/B testing

**V3 Schema Addition Needed:**
```sql
CREATE TABLE menuca_v3.email_templates (
  id BIGSERIAL PRIMARY KEY,
  restaurant_id BIGINT REFERENCES menuca_v3.restaurants(id), -- NULL = global template
  template_type VARCHAR(50) NOT NULL, -- password_reset, order_confirmation, etc.
  language VARCHAR(5) NOT NULL DEFAULT 'en', -- en, fr
  subject VARCHAR(255) NOT NULL,
  body_html TEXT NOT NULL,
  body_text TEXT, -- plain text fallback
  variables JSONB, -- available variables: {name: "customerName", description: "Customer's first name"}
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  version INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (restaurant_id, template_type, language)
);
```

---

### **6. Accounting & Reporting**

#### **Screenshot 10: Statement Generator**
**Features Observed:**
- ✅ "Restaurants" multiselect input
- ✅ "From" date picker
- ✅ "Until" date picker
- ✅ Options section (collapsed/expandable)
- ✅ "Generate statements" button (full-width, blue)

**V3 Implementation:**
- Tables: `orders`, `order_items`, `restaurants`
- Component: Form with date range picker
- Output: PDF generation

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Add statement templates (detailed, summary, tax report)
- Schedule automatic statements (weekly, monthly)
- Email statements automatically
- Show preview before generating
- Export to Excel/CSV
- Include charts in PDF

---

#### **Screenshot 12: Commission Manager**
**Features Observed:**
- ✅ "Restaurant commissions" heading
- ✅ Print button
- ✅ Table with columns:
  - **This week:** Net Paid, Commission, Charges
  - **Prev week:** Net paid, Commission, Charges
  - **Carry values:** Amount, Commission, Net Paid, Commissions collected
  - **Next week:** Ammount carried, Commission carried
  - ID, Name, Address
- ✅ Empty table (no data showing)

**V3 Implementation:**
- Tables: `vendors`, `vendor_restaurants`, `vendor_commission_reports`
- Component: Complex table with multi-week view

**Priority:** ⭐⭐⭐ **MUST HAVE** (partially exists in V3)

**Modern Improvements:**
- Add filters: by vendor, by restaurant, by date range
- Add commission rate display
- Show "paid" vs "unpaid" status
- Add "Mark as paid" action
- Export report to PDF
- Send report to vendor email
- Show commission trends (line chart)

---

#### **Screenshot 15: Vendor Reports**
**Features Observed:**
- ✅ "Generate vendor reports" heading
- ✅ "Generate reports for" checkboxes:
  - Menu Ottawa
  - Darrell Corcoran
- ✅ Start date and stop date pickers
- ✅ "Generate" button
- ✅ "Statements" section showing generated reports:
  - Multiple date ranges listed (2025-09-01 to 2025-09-30, etc.)
  - Links to: Darrell Corcoran, Menu Ottawa, Shared Inc. (per vendor)
- ✅ "Vendor invoices" and "Menu invoice" columns (empty)
- ✅ Reports going back to 2024-12-01

**V3 Implementation:**
- Tables: `vendor_commission_reports`, `vendors`
- Component: Form + report list

**Priority:** ⭐⭐⭐ **MUST HAVE** (already exists in V3)

**Modern Improvements:**
- Add report status (draft, sent, paid)
- Auto-generate monthly reports (cron job)
- Add "Resend report" button
- Show "last generated" timestamp
- Add report preview modal
- Include commission breakdown by restaurant

---

### **7. Restaurant Tools**

#### **Screenshot 13: Landing Page Setup**
**Features Observed:**
- ✅ "Existing landing pages" table:
  - Columns: Page name, Domain
  - Edit and Delete buttons per page
  - Examples: "CHICCO PIZZA SHAWARMA" (chiccopizzashawarma.com), "landing example" (landing.menu.ca)
  - "Add new page" button
- ✅ "Add landing page" form:
  - Page name input
  - Domain input
  - Background image file upload
  - Logo position:
    - Position on X axis slider
    - Position on Y axis slider
  - Settings section:
    - Display template dropdown
    - Header background color picker (black swatch)
    - Header background transparency slider
    - Text color picker (black swatch)
    - Footer color picker (black swatch)
    - Footer transparency slider
    - Call to action text input
    - Background color picker (black swatch)
    - Text color picker (black swatch)
  - Choose restaurants (multiselect)
  - SEO section:
    - Page title input
- ✅ Color pickers with visual swatches

**V3 Implementation:**
- Tables: `restaurant_domains`, `restaurant_service_configs` (for branding)
- Component: Advanced form with color pickers, image upload, drag-position

**Priority:** ⭐⭐⭐ **MUST HAVE**

**Modern Improvements:**
- Live preview panel (split screen)
- Mobile/desktop toggle
- Template library (modern designs)
- Drag-drop builder (like Webflow)
- Custom CSS editor (advanced users)
- A/B testing for landing pages
- Analytics (views, clicks, conversions)
- SEO score checker

---

#### **Screenshot 17: Tablets Management**
**Features Observed:**
- ✅ "Manage tablets" heading
- ✅ Search bar
- ✅ Table with columns:
  - ID, Restaurant
  - Config (Enabled/Disabled buttons)
  - Editing (Enabled/Disabled buttons)
  - Suspend (Operating/Suspended buttons)
  - FW (Firmware version: Default, 15/32, 16/32, 16/99)
  - First online, Last online
  - Status (Online/Offline, with colored badges)
- ✅ Restaurants listed:
  - Little Gyros Greek Grill, Cosenza, Cuisine Bombay Indienne, Pizza Marie, Wandee Thai, Pachino Pizza, Sushi Presse, Chicco Pizza de l'Hopital, Test James, Chicco Shawarma Maloney, Chicco Pizza St-Louis, River Pizza, Chef Rad Halal Pizza, Test James (multiple), Bistro 548, Mia Pizza Grec, Genki Sushi, Test James (x2), Zait and Zaatar, La Nawab (and more)
- ✅ "Show all" checkbox in column headers

**V3 Implementation:**
- Table: `devices` (981 rows)
- Component: DataTable with status badges

**Priority:** ⭐⭐ **NICE TO HAVE**

**Modern Improvements:**
- Add "Device health" column (battery, network)
- Add "Send update" action (push firmware)
- Add "Reboot device" action
- Show device location (restaurant address)
- Add alerts (device offline for > 1 hour)
- Group by restaurant
- Show device type (tablet, printer, KDS)

---

## 📊 **FEATURE PRIORITY SUMMARY**

### **⭐⭐⭐ MUST HAVE (Phase 1)**
1. ✅ Restaurant CRUD (add, edit, list by status)
2. ✅ Dashboard with order stats (today, yesterday, month)
3. ✅ User & permission management (RBAC)
4. ✅ Cities & cuisine/tag management
5. ✅ Email template editor
6. ✅ Statement generator
7. ✅ Commission manager & vendor reports
8. ✅ Landing page builder with branding

### **⭐⭐ NICE TO HAVE (Phase 2)**
1. ✅ Cancel order requests
2. ✅ Blacklist management
3. ✅ Site user list (customers)
4. ✅ Tablets/device management

### **⭐ FUTURE (Phase 3)**
1. ✅ AI Settings (not documented yet)
2. ✅ Feedback system
3. ✅ Newsletter images
4. ✅ Announcements system
5. ✅ Reports page (custom reports)

---

## 🎨 **DESIGN PRINCIPLES FOR V3**

Based on V2 screenshots, we need:

### **What to KEEP:**
- ✅ Dark sidebar navigation (clean, professional)
- ✅ Top header with user dropdown
- ✅ Search everywhere pattern
- ✅ Table-based data display
- ✅ Edit buttons per row
- ✅ Status badges (online/offline, active/inactive)
- ✅ Multi-panel layouts (left form, right list)

### **What to MODERNIZE:**
- ❌ Replace checkboxes-everywhere with modern permissions UI
- ❌ Replace basic date pickers with better calendar UI
- ❌ Replace generic blue buttons with branded action colors
- ❌ Add loading states, skeleton loaders
- ❌ Add toast notifications (not alert boxes)
- ❌ Add bulk actions (select multiple, act on all)
- ❌ Add filters and saved views
- ❌ Add keyboard shortcuts
- ❌ Add dark mode toggle
- ❌ Mobile-responsive everything

### **Design Inspiration:**
- **Toast POS** - Clean, modern restaurant admin
- **Square Dashboard** - Simple, powerful, beautiful
- **Stripe Dashboard** - Best-in-class analytics
- **Linear** - Keyboard shortcuts, speed
- **Notion** - Flexible content editing

---

## ✅ **NEXT STEPS**

1. **Upload V2 Screenshots:** Create `v2-design-reference/` folder with all screenshots
2. **Review This Document:** Confirm all features captured
3. **Prioritize Features:** Which must be in MVP? Which can wait?
4. **Design V3 Mockups:** Modern versions of these screens
5. **Update Build Plan:** Add these features to `MENU_CA_BUILD_PLAN.md`
6. **Start Building:** Begin with highest priority features

---

**Status:** 🚧 **IN PROGRESS** - Awaiting V2 screenshot upload and review

