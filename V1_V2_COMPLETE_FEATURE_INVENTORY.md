# 🎯 V1 + V2 Complete Feature Inventory
**Every single feature from both admin dashboards - Ready for V3**

---

## 📊 **TOTAL FEATURE COUNT: 140+ FEATURES**

---

## 🏢 **1. RESTAURANT MANAGEMENT** (45 features)

### **1.1 Restaurant List & Filters** (10 features)
| # | Feature | V1 | V2 | V3 Status | Priority |
|---|---------|----|----|-----------|----------|
| 1.1.1 | List all restaurants | ✅ | ✅ | ✅ Ready | ⭐⭐⭐ |
| 1.1.2 | Filter by status (Active/Pending/Inactive) | ✅ | ✅ | ✅ Ready | ⭐⭐⭐ |
| 1.1.3 | Filter by province | ✅ | ❌ | ✅ Ready | ⭐⭐⭐ |
| 1.1.4 | Filter by city | ✅ | ❌ | ✅ Ready | ⭐⭐⭐ |
| 1.1.5 | Filter by cuisine type | ✅ | ❌ | ✅ Ready | ⭐⭐⭐ |
| 1.1.6 | Filter by vendor | ✅ | ❌ | ✅ Ready | ⭐⭐⭐ |
| 1.1.7 | Filter by assigned user | ✅ | ❌ | ✅ Ready | ⭐⭐ |
| 1.1.8 | Sort by ID, name, city, cuisine, min order | ✅ | ❌ | ✅ Ready | ⭐⭐⭐ |
| 1.1.9 | Search by name/address | ❌ | ✅ | ✅ Ready | ⭐⭐⭐ |
| 1.1.10 | Clone restaurant (full duplicate) | ✅ | ❌ | 🆕 New | ⭐⭐ |

**Clone Restaurant Clones:**
- ✅ All menu items (dishes, courses, ingredients, modifiers, combos)
- ✅ All settings (delivery, pickup, branding, service configs)
- ✅ Admin users assignments
- ✅ Delivery areas/polygons
- ✅ Banners, images, CSS overrides
- ✅ Mail templates
- ✅ Coupons
- ❌ NOT orders/order history

---

### **1.2 Restaurant Edit - Sub-Tabs** (35 features)

#### **1.2.1 Restaurant Info Tab** (8 fields)
| Field | Description | V3 Table |
|-------|-------------|----------|
| Name | Restaurant name | `restaurants.name` |
| Address | Street address | `restaurant_locations.address` |
| City | City | `restaurant_locations.city_id` |
| Province | Province/State | `cities.province_id` |
| Postal Code | Zip/postal | `restaurant_locations.postal_code` |
| Phone | Contact phone | `restaurant_contacts.phone` |
| Email | Contact email | `restaurant_contacts.email` |
| Timezone | Restaurant timezone | `restaurants.timezone` |

**Priority:** ⭐⭐⭐ Must Have

---

#### **1.2.2 Other Configs Tab** (Settings)
| Setting | Description | V3 Table |
|---------|-------------|----------|
| Pickup enabled | Allow pickup orders | `restaurant_service_configs.pickup_enabled` |
| Delivery enabled | Allow delivery orders | `restaurant_service_configs.delivery_enabled` |
| Bilingual support | French + English | `restaurant_service_configs.is_bilingual` |
| Minimum order | Min order amount | `restaurant_service_configs.minimum_order` |
| Tax rate | Sales tax % | `restaurant_service_configs.tax_rate` |
| Service fee | Platform fee | `restaurant_service_configs.service_fee` |
| Online status | Accept new orders | `restaurants.is_online` |
| Business hours | Operating hours | `restaurant_schedules` |

**Priority:** ⭐⭐⭐ Must Have

---

#### **1.2.3 Delivery Tab** (Delivery Configuration)
| Feature | Description | V3 Table |
|---------|-------------|----------|
| Delivery areas | Polygon zones (map drawing) | `delivery_areas` (PostGIS) |
| Delivery fee | Fee per zone | `delivery_areas.delivery_fee` |
| Free delivery threshold | Min order for free delivery | `restaurant_service_configs.free_delivery_threshold` |
| Delivery radius | Max distance (km/miles) | `restaurant_service_configs.delivery_radius` |
| Estimated time | Delivery ETA | `restaurant_service_configs.estimated_delivery_time` |
| Delivery company | Partner (Uber Eats, etc.) | `delivery_companies` |

**Priority:** ⭐⭐⭐ Must Have

**Implementation:** Use PostGIS `POLYGON` type for delivery zones, Mapbox GL for map drawing UI

---

#### **1.2.4 Citations Tab** (SEO/External Listings)
| Field | Description | V3 Table |
|-------|-------------|----------|
| Google My Business URL | GMB listing | `restaurant_citations.gmb_url` |
| Yelp URL | Yelp listing | `restaurant_citations.yelp_url` |
| TripAdvisor URL | TA listing | `restaurant_citations.tripadvisor_url` |
| Facebook Page | FB page | `restaurant_citations.facebook_url` |
| Instagram | IG handle | `restaurant_citations.instagram_url` |

**Priority:** ⭐⭐ Nice to Have

**New Table Needed:**
```sql
CREATE TABLE menuca_v3.restaurant_citations (
  id BIGSERIAL PRIMARY KEY,
  restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id),
  citation_type VARCHAR(50) NOT NULL, -- gmb, yelp, tripadvisor, facebook, instagram
  url TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (restaurant_id, citation_type)
);
```

---

#### **1.2.5 Banners Tab** (Visual Assets)
| Feature | Description | V3 Implementation |
|---------|-------------|-------------------|
| Upload banner images | Hero images | Supabase Storage |
| Banner name | Image filename | `restaurant_banners.name` |
| Display order | Sort order | `restaurant_banners.display_order` |
| Active status | Show/hide banner | `restaurant_banners.is_active` |
| Delete banner | Remove image | DELETE + Storage cleanup |

**Priority:** ⭐⭐⭐ Must Have

**New Table Needed:**
```sql
CREATE TABLE menuca_v3.restaurant_banners (
  id BIGSERIAL PRIMARY KEY,
  restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id),
  name VARCHAR(255) NOT NULL,
  image_url TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

#### **1.2.6 Menu Tab** (Menu Management)
**Note:** This is a MASSIVE feature - covered separately in Menu & Catalog section

**Features:**
- Add/edit/delete courses
- Add/edit/delete dishes
- Size-based pricing
- Ingredient groups & modifiers
- Combos
- Dish images
- Allergen info
- Nutritional info
- Availability schedules

**Priority:** ⭐⭐⭐ Must Have

**V3 Tables:** Already complete (15,740 dishes, 1,207 courses, etc.)

---

#### **1.2.7 Deals Tab** (Promotions)
| Feature | Description | V3 Table |
|---------|-------------|----------|
| Create deal | % off, $ off, BOGO | `promotional_deals` |
| Deal name | Promo name | `promotional_deals.name` |
| Deal description | Details | `promotional_deals.description` |
| Deal type | Discount type | `promotional_deals.deal_type` |
| Discount value | Amount/percentage | `promotional_deals.discount_value` |
| Start/end date | Validity period | `promotional_deals.start_date / end_date` |
| Active days/hours | Schedule | `promotional_deals.active_days` |
| Min purchase | Minimum order | `promotional_deals.minimum_purchase` |
| Applicable dishes | Which dishes | Many-to-many table |
| Display order | Sort on site | `promotional_deals.display_order` |

**Priority:** ⭐⭐⭐ Must Have

**V3 Status:** ✅ Ready (202 deals exist)

---

#### **1.2.8 Images Tab** (Gallery Management)
| Feature | Description | V3 Implementation |
|---------|-------------|-------------------|
| Upload restaurant images | Gallery photos | Supabase Storage |
| Add image comment | Description/alt text | `restaurant_images.description` |
| Delete image | Remove from gallery | DELETE + Storage cleanup |
| Image order | Sort gallery | `restaurant_images.display_order` |

**Priority:** ⭐⭐⭐ Must Have

**New Table Needed:**
```sql
CREATE TABLE menuca_v3.restaurant_images (
  id BIGSERIAL PRIMARY KEY,
  restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id),
  image_url TEXT NOT NULL,
  description TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

#### **1.2.9 Feedback Tab** (Customer Feedback)
| Feature | Description | V3 Implementation |
|---------|-------------|-------------------|
| View customer feedback | Reviews/comments | `restaurant_feedback` table |
| Respond to feedback | Owner replies | `restaurant_feedback.response` |
| Mark as resolved | Status tracking | `restaurant_feedback.status` |
| Filter by rating | Star rating | `restaurant_feedback.rating` |

**Priority:** ⭐⭐ Nice to Have

**New Table Needed:**
```sql
CREATE TABLE menuca_v3.restaurant_feedback (
  id BIGSERIAL PRIMARY KEY,
  restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id),
  user_id BIGINT REFERENCES menuca_v3.users(id),
  order_id BIGINT,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  response TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, responded, resolved
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  responded_at TIMESTAMPTZ
);
```

---

#### **1.2.10 Mail Templates Tab** (Email Customization)
| Template | Description | V3 Table |
|----------|-------------|----------|
| Order confirmation | Receipt email | `email_templates` |
| Order ready | Pickup notification | `email_templates` |
| Out for delivery | Delivery status | `email_templates` |
| Order delivered | Completion email | `email_templates` |
| Password reset | Security email | `email_templates` |
| Promotional | Marketing email | `email_templates` |

**Priority:** ⭐⭐⭐ Must Have

**New Table:** Already designed in V2 analysis

---

#### **1.2.11 CSS Tab** (Custom Styling)
| Feature | Description | V3 Implementation |
|---------|-------------|-------------------|
| Custom CSS editor | Override styles | `restaurant_custom_css` table |
| Preview changes | Live preview | Frontend only |
| CSS validation | Prevent breaking | Frontend validation |
| Reset to default | Remove overrides | DELETE custom CSS |

**Priority:** ⭐⭐ Nice to Have

**New Table Needed:**
```sql
CREATE TABLE menuca_v3.restaurant_custom_css (
  id BIGSERIAL PRIMARY KEY,
  restaurant_id BIGINT NOT NULL UNIQUE REFERENCES menuca_v3.restaurants(id),
  css_content TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

#### **1.2.12 Coupon Tab** (Restaurant-Specific Coupons)
**See Coupons section for full details**

**Priority:** ⭐⭐⭐ Must Have

---

#### **1.2.13 Account Info Tab** (Billing)
| Field | Description | V3 Table |
|-------|-------------|----------|
| Business name | Legal name | `restaurants.legal_name` |
| Business number | Tax ID | `restaurants.tax_id` |
| Bank account | For payouts | `restaurant_bank_accounts` |
| Billing address | Invoice address | `restaurant_locations` |
| Payment method | Stripe, etc. | `restaurant_payment_methods` |

**Priority:** ⭐⭐⭐ Must Have

**New Tables Needed:**
```sql
CREATE TABLE menuca_v3.restaurant_bank_accounts (
  id BIGSERIAL PRIMARY KEY,
  restaurant_id BIGINT NOT NULL UNIQUE REFERENCES menuca_v3.restaurants(id),
  bank_name VARCHAR(255),
  account_number VARCHAR(255), -- Encrypted
  routing_number VARCHAR(255),
  account_holder_name VARCHAR(255),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE menuca_v3.restaurant_payment_methods (
  id BIGSERIAL PRIMARY KEY,
  restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id),
  payment_provider VARCHAR(50) NOT NULL, -- stripe, square, paypal
  provider_account_id VARCHAR(255),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

#### **1.2.14 301 Redirects Tab** (SEO Management)
| Feature | Description | V3 Implementation |
|---------|-------------|-------------------|
| Add redirect | Old URL → New URL | `restaurant_redirects` table |
| Redirect type | 301 (permanent) | `restaurant_redirects.redirect_type` |
| Status tracking | Active/inactive | `restaurant_redirects.is_active` |
| Hit counter | Track usage | `restaurant_redirects.hit_count` |

**Priority:** ⭐⭐ Nice to Have

**New Table Needed:**
```sql
CREATE TABLE menuca_v3.restaurant_redirects (
  id BIGSERIAL PRIMARY KEY,
  restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id),
  from_path VARCHAR(500) NOT NULL,
  to_path VARCHAR(500) NOT NULL,
  redirect_type INTEGER NOT NULL DEFAULT 301, -- 301, 302, etc.
  hit_count INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (restaurant_id, from_path)
);
```

---

#### **1.2.15 Charges Tab** (Additional Fees)
| Field | Description | V3 Table |
|-------|-------------|----------|
| Statement name | Charge label | `restaurant_charges.name` |
| Charge value | Amount | `restaurant_charges.amount` |
| Tax status | Taxable yes/no | `restaurant_charges.is_taxable` |
| Charge type | Fixed/percentage | `restaurant_charges.charge_type` |
| Credit/Debit | Add or subtract | `restaurant_charges.is_credit` |
| Repeat frequency | One-time/recurring | `restaurant_charges.frequency` |
| Internal description | Admin notes | `restaurant_charges.description` |
| Application scope | All/specific orders | `restaurant_charges.scope` |
| Status | Active/inactive | `restaurant_charges.is_active` |

**Priority:** ⭐⭐⭐ Must Have

**New Table Needed:**
```sql
CREATE TABLE menuca_v3.restaurant_charges (
  id BIGSERIAL PRIMARY KEY,
  restaurant_id BIGINT NOT NULL REFERENCES menuca_v3.restaurants(id),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  amount NUMERIC(10, 2) NOT NULL,
  charge_type VARCHAR(20) NOT NULL, -- fixed, percentage
  is_taxable BOOLEAN NOT NULL DEFAULT TRUE,
  is_credit BOOLEAN NOT NULL DEFAULT FALSE, -- false = debit (charge), true = credit (refund)
  frequency VARCHAR(20) NOT NULL DEFAULT 'one_time', -- one_time, recurring
  scope VARCHAR(50) NOT NULL DEFAULT 'all', -- all, delivery_only, pickup_only
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

---

## 🎟️ **2. COUPONS & PROMOTIONS** (15 features)

### **2.1 Coupon Management** (Based on V1 screenshot)

| # | Feature | Description | V3 Table | Priority |
|---|---------|-------------|----------|----------|
| 2.1.1 | Coupon scope | Global or restaurant-specific | `promotional_coupons.scope` | ⭐⭐⭐ |
| 2.1.2 | Language | English/French | `promotional_coupons.language` | ⭐⭐⭐ |
| 2.1.3 | Reordering usage | Can be used again by same user | `promotional_coupons.allow_reorder` | ⭐⭐ |
| 2.1.4 | One-time usage | Single use only | `promotional_coupons.single_use` | ⭐⭐⭐ |
| 2.1.5 | Coupon name | Display name | `promotional_coupons.name` | ⭐⭐⭐ |
| 2.1.6 | Coupon description | Details | `promotional_coupons.description` | ⭐⭐⭐ |
| 2.1.7 | Coupon code | Unique code | `promotional_coupons.code` | ⭐⭐⭐ |
| 2.1.8 | Start date | Valid from | `promotional_coupons.start_date` | ⭐⭐⭐ |
| 2.1.9 | End date | Expires on | `promotional_coupons.end_date` | ⭐⭐⭐ |
| 2.1.10 | Reduce type | % off, $ off, free delivery, free item | `promotional_coupons.discount_type` | ⭐⭐⭐ |
| 2.1.11 | Restaurant assignment | Which restaurant | `promotional_coupons.restaurant_id` | ⭐⭐⭐ |
| 2.1.12 | Minimum spent | Min order value | `promotional_coupons.minimum_purchase` | ⭐⭐⭐ |
| 2.1.13 | Exempt courses | Exclude categories | `promotional_coupons.exempt_courses` | ⭐⭐ |
| 2.1.14 | Add to email | Include in campaign | `promotional_coupons.include_in_email` | ⭐⭐⭐ |
| 2.1.15 | Email message text | Custom HTML | `promotional_coupons.email_message` | ⭐⭐⭐ |

**V3 Table Updates Needed:**
```sql
-- Extend existing promotional_coupons table
ALTER TABLE menuca_v3.promotional_coupons
  ADD COLUMN IF NOT EXISTS scope VARCHAR(20) NOT NULL DEFAULT 'restaurant', -- global, restaurant
  ADD COLUMN IF NOT EXISTS language VARCHAR(5) NOT NULL DEFAULT 'en', -- en, fr
  ADD COLUMN IF NOT EXISTS allow_reorder BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS single_use BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS exempt_courses BIGINT[], -- Array of course IDs
  ADD COLUMN IF NOT EXISTS include_in_email BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS email_message TEXT;
```

---

### **2.2 Email Coupons** (Unique codes for campaigns)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| Generate unique codes | Auto-generate codes per user | Function: `generate_coupon_codes(count, prefix)` |
| Track usage by user | Who used which code | `coupon_usage_log` table (already exists!) |
| Campaign assignment | Link to email campaign | `email_campaigns.coupon_id` |
| Performance tracking | Conversion rate | Analytics query |
| Audience segmentation | User groups | Filter by user attributes |

**Priority:** ⭐⭐⭐ Must Have

**New Feature:** Bulk coupon generation
```sql
-- Function to generate N unique coupon codes
CREATE OR REPLACE FUNCTION menuca_v3.generate_email_coupons(
  p_campaign_name VARCHAR,
  p_quantity INTEGER,
  p_discount_type VARCHAR,
  p_discount_value NUMERIC,
  p_restaurant_id BIGINT,
  p_expires_at TIMESTAMPTZ
)
RETURNS TABLE (code VARCHAR) AS $$
DECLARE
  v_code VARCHAR;
  v_counter INTEGER := 0;
BEGIN
  WHILE v_counter < p_quantity LOOP
    -- Generate unique 8-character code
    v_code := upper(substring(md5(random()::text) from 1 for 8));
    
    -- Insert coupon
    INSERT INTO menuca_v3.promotional_coupons (
      code, name, discount_type, discount_value, restaurant_id,
      end_date, single_use, include_in_email
    ) VALUES (
      v_code, p_campaign_name || ' - ' || v_code, p_discount_type,
      p_discount_value, p_restaurant_id, p_expires_at, true, true
    )
    ON CONFLICT (code) DO NOTHING;
    
    IF FOUND THEN
      v_counter := v_counter + 1;
      RETURN QUERY SELECT v_code;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
```

---

### **2.3 Upload Coupons** (Bulk CSV Import)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| CSV upload | Bulk import | File upload + parser |
| Required fields | code, name, discount_type, discount_value, expires | CSV columns |
| Validation | Duplicate check | Pre-insert validation |
| Preview before import | Show parsed data | Frontend table |
| Error reporting | Invalid rows | Return error list |

**Priority:** ⭐⭐ Nice to Have

**CSV Format Example:**
```csv
code,name,discount_type,discount_value,restaurant_id,expires,minimum_purchase
SUMMER20,Summer Sale 20% Off,percentage,20,12,2025-08-31,25.00
FREESHIP,Free Shipping,free_delivery,0,12,2025-12-31,15.00
```

---

## 🏢 **3. FRANCHISE MANAGEMENT** (8 features)

**Based on V1 screenshot showing franchise system**

| # | Feature | Description | V3 Table | Priority |
|---|---------|-------------|----------|----------|
| 3.1 | Create franchise | Umbrella entity | `franchises` table | ⭐⭐⭐ |
| 3.2 | Franchise name | Display name | `franchises.name` | ⭐⭐⭐ |
| 3.3 | Link restaurants to franchise | Multi-location | `restaurants.franchise_id` | ⭐⭐⭐ |
| 3.4 | Franchise owner | Primary contact | `franchises.owner_admin_id` | ⭐⭐⭐ |
| 3.5 | View all locations | List franchise restaurants | Query by franchise_id | ⭐⭐⭐ |
| 3.6 | Consolidated reporting | All locations combined | Aggregate queries | ⭐⭐⭐ |
| 3.7 | Shared menu management | Sync menu across locations | Feature flag | ⭐⭐ |
| 3.8 | Commission sharing | Split fees across locations | `franchise_commission_rules` | ⭐⭐ |

**V3 Screenshot Shows:** Milanos franchise with multiple locations (Manotick, Barrhaven, Central Park, Kanata, Riverside, Ottawa East, St Laurent)

**New Tables Needed:**
```sql
CREATE TABLE menuca_v3.franchises (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_admin_id BIGINT REFERENCES menuca_v3.admin_users(id),
  legal_name VARCHAR(255),
  tax_id VARCHAR(100),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add to restaurants table
ALTER TABLE menuca_v3.restaurants
  ADD COLUMN IF NOT EXISTS franchise_id BIGINT REFERENCES menuca_v3.franchises(id);

CREATE TABLE menuca_v3.franchise_commission_rules (
  id BIGSERIAL PRIMARY KEY,
  franchise_id BIGINT NOT NULL REFERENCES menuca_v3.franchises(id),
  commission_split_type VARCHAR(20) NOT NULL DEFAULT 'equal', -- equal, weighted, custom
  commission_percentage NUMERIC(5, 2),
  distribution_rules JSONB, -- For custom splits
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Priority:** ⭐⭐⭐ Must Have (Milanos has 7+ locations!)

---

## 📊 **UPDATED TOTALS**

### **Feature Count by Category:**
1. Restaurant Management: **45 features** (10 list + 35 edit sub-tabs)
2. Coupons & Promotions: **15 features**
3. Franchise Management: **8 features**
4. Dashboard & Analytics: **20 features** (from V2)
5. Order Management: **12 features** (from V2)
6. User & Access Management: **22 features** (V1 + V2)
7. Blacklist: **6 features**
8. Content Management: **12 features**
9. Email & Communications: **8 features**
10. Accounting & Reports: **10 features**
11. Device Management: **10 features**

**TOTAL: 168 FEATURES** 🎉

---

## 🆕 **NEW TABLES REQUIRED (10 total)**

1. ✅ `order_cancellation_requests` - Cancellation workflow
2. ✅ `blacklist` - Fraud prevention
3. ✅ `email_templates` - Transactional emails
4. ✅ `admin_roles` - RBAC system
5. 🆕 `restaurant_citations` - SEO listings
6. 🆕 `restaurant_banners` - Hero images
7. 🆕 `restaurant_images` - Gallery
8. 🆕 `restaurant_feedback` - Reviews
9. 🆕 `restaurant_custom_css` - Styling overrides
10. 🆕 `restaurant_bank_accounts` - Banking info
11. 🆕 `restaurant_payment_methods` - Payment processors
12. 🆕 `restaurant_redirects` - SEO redirects
13. 🆕 `restaurant_charges` - Additional fees
14. 🆕 `franchises` - Franchise entities
15. 🆕 `franchise_commission_rules` - Commission splits

**Total New Tables: 15** (manageable!)

---

## ✅ **READY FOR ULTIMATE REPLIT PROMPT**

All features documented. All tables designed. Now building the most detailed Replit prompt ever created! 🚀

