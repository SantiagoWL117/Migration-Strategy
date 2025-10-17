# 🍕 CUSTOMER ORDERING SYSTEM - REPLIT PROMPT

**Copy everything below and paste into Replit Agent:**

---

# BUILD CUSTOMER ORDERING SYSTEM (SAME APP, NEW ROUTES)

## CONTEXT
We have an admin dashboard at `/admin/*` that's working. Now we need to add the customer-facing ordering system to the SAME app.

## GOAL
Let customers browse restaurant menus, customize dishes, add to cart, and checkout with Stripe payment.

## DATABASE (ALREADY CONNECTED)
- Schema: `menuca_v3`
- 961 restaurants in `restaurants` table
- 15,740 dishes in `dishes` table  
- Menu categories in `courses` table
- Size options in `dish_prices` table
- Modifiers/add-ons in `dish_modifiers` table
- Orders will be saved to partitioned `orders` and `order_items` tables

## NEW ROUTES TO BUILD

### 1. **Restaurant Menu Page** `/r/[slug]`
**What it does:**
- Displays a single restaurant's full menu
- Shows restaurant name, logo, hours, delivery info at the top
- Lists dishes organized by category (courses)
- Each dish shows: image, name, description, price
- Click dish → opens customization modal

**Database Query:**
```typescript
// Get restaurant + location + hours
const { data: restaurant } = await supabase
  .from('restaurants')
  .select(`
    id, name, slug,
    restaurant_locations(street_address, city_id, phone),
    restaurant_schedules(day_of_week, open_time, close_time)
  `)
  .eq('slug', params.slug)
  .single()

// Get menu with categories
const { data: courses } = await supabase
  .from('courses')
  .select(`
    id, name, display_order,
    dishes(
      id, name, description, image_url,
      dish_prices(id, size_name, price),
      dish_modifiers(id, name, price, is_required)
    )
  `)
  .eq('restaurant_id', restaurant.id)
  .eq('is_active', true)
  .order('display_order')
```

**UI Layout:**
- Restaurant header: Logo, name, address, hours, delivery fee, min order
- Sticky sidebar: Category navigation (appetizers, mains, desserts, etc.)
- Main content: Dish grid (2 columns on desktop, 1 on mobile)
- Each dish card: Image, name, description, price, "+" button
- Floating cart button (bottom right): Shows item count

### 2. **Dish Customization Modal**
**What it does:**
- Opens when clicking a dish
- Shows full dish image + description
- If multiple sizes: Radio buttons for size selection
- If has modifiers: Checkboxes for add-ons (extra cheese, bacon, etc.)
- Special instructions textarea
- Quantity selector (+/- buttons)
- "Add to Cart" button shows calculated price

**Example:**
```
[Large Dish Image]

Pepperoni Pizza
Classic pizza with tomato sauce, mozzarella, and pepperoni

SELECT SIZE:
○ Small - $12.99
● Medium - $15.99  ← selected
○ Large - $18.99

CUSTOMIZE:
☑ Extra Cheese (+$2.00)
☐ Bacon (+$3.00)
☑ Mushrooms (+$1.50)

SPECIAL INSTRUCTIONS:
[Well done please]

QUANTITY: [−] 2 [+]

[Add 2 to Cart - $39.98]
```

### 3. **Cart Drawer** (Slides in from right)
**What it does:**
- Shows all items with modifiers
- Each item: Name, size, modifiers, quantity, subtotal
- Edit quantity or remove item
- Shows: Subtotal, Delivery Fee, Tax (13%), Total
- "Proceed to Checkout" button

**State Management:**
Use Zustand for cart state (persists to localStorage):
```typescript
interface CartItem {
  id: string // unique ID
  dishId: number
  dishName: string
  size: string
  price: number
  quantity: number
  modifiers: Array<{name: string, price: number}>
  specialInstructions?: string
  subtotal: number
}

interface CartStore {
  restaurantId: number | null
  restaurantName: string | null
  items: CartItem[]
  addItem: (item) => void
  removeItem: (id) => void
  updateQuantity: (id, quantity) => void
  clearCart: () => void
}
```

### 4. **Checkout Page** `/checkout`
**What it does:**
- Step 1: Delivery vs Pickup (radio buttons)
- Step 2: Delivery Address (if delivery selected)
  - Street address, unit, city, postal code inputs
  - "Save address" checkbox (if logged in)
- Step 3: Delivery Time
  - ASAP (default)
  - Schedule for later (date + time picker)
- Step 4: Payment (Stripe Elements)
  - Card number, expiry, CVC inputs
  - Billing postal code
- Right sidebar: Order summary (items, fees, total)
- "Place Order" button

**Order Creation Flow:**
1. Create Stripe Payment Intent (API call)
2. Confirm payment with Stripe Elements
3. If payment succeeds → Create order in database
4. Redirect to order confirmation page

**API Route:** `/api/checkout/create-order`
```typescript
// Creates order + order items in database
// Returns order ID and UUID
```

### 5. **Order Confirmation Page** `/order-confirmation/[orderId]`
**What it does:**
- Shows "Order Placed Successfully!" message
- Displays order number, estimated delivery time
- Shows order summary (items, address, total)
- "Track Order" button (links to `/account/orders/[orderId]`)

### 6. **Customer Order History** `/account/orders`
**What it does:**
- Lists all orders for logged-in customer
- Shows: Order date, restaurant name, total, status
- Click order → view full order details
- Filter by status (all, pending, delivered, cancelled)

## TECHNICAL REQUIREMENTS

### Cart System
- Use Zustand for state management
- Persist cart to localStorage
- If user switches restaurants → confirm "Clear cart?"
- Calculate tax as 13% HST (Ontario)
- Include delivery fee from restaurant settings

### Payment Integration
- Use Stripe Payment Intents
- Stripe Elements for card input
- Handle payment errors gracefully
- Save payment intent ID to order record

### Database Schema
**New tables to create:**
```sql
-- Cart sessions (temporary storage)
CREATE TABLE menuca_v3.cart_sessions (
  id BIGSERIAL PRIMARY KEY,
  session_id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
  user_id BIGINT REFERENCES menuca_v3.users(id),
  restaurant_id BIGINT REFERENCES menuca_v3.restaurants(id),
  cart_data JSONB NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '24 hours'),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User delivery addresses
CREATE TABLE menuca_v3.user_delivery_addresses (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES menuca_v3.users(id),
  street_address VARCHAR(500) NOT NULL,
  unit VARCHAR(50),
  city_id BIGINT NOT NULL REFERENCES menuca_v3.cities(id),
  postal_code VARCHAR(20) NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Payment transactions
CREATE TABLE menuca_v3.payment_transactions (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL,
  order_created_at TIMESTAMPTZ NOT NULL,
  stripe_payment_intent_id VARCHAR(255) UNIQUE NOT NULL,
  amount NUMERIC(10, 2) NOT NULL,
  status VARCHAR(50) NOT NULL, -- 'succeeded', 'failed', 'refunded'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  FOREIGN KEY (order_id, order_created_at) REFERENCES menuca_v3.orders(id, created_at)
);
```

### Responsive Design
- Mobile-first approach
- Restaurant menu: 1 column on mobile, 2 on desktop
- Cart drawer: Full width on mobile, sidebar on desktop
- Touch-friendly buttons (min 44px tap targets)

### Performance
- Image optimization with Next.js Image component
- Lazy load dish images as user scrolls
- Debounce cart updates
- Cache restaurant menu data (React Query)

## WHAT TO BUILD FIRST

**Priority Order:**
1. Restaurant menu page `/r/[slug]` with dish display
2. Dish customization modal with size/modifier selection
3. Cart drawer with add/remove/update
4. Checkout page with address + payment
5. Order confirmation page
6. Customer order history

**Start with a single restaurant** (pick any active restaurant from database, e.g., ID 1 or slug from `restaurants` table).

## SUCCESS CRITERIA

When done, a customer should be able to:
1. ✅ Browse restaurant menu by category
2. ✅ Click a dish to customize (size, modifiers, quantity)
3. ✅ Add customized dish to cart
4. ✅ View cart with all items and calculated total
5. ✅ Proceed to checkout
6. ✅ Enter delivery address
7. ✅ Pay with credit card (Stripe)
8. ✅ See order confirmation with order number
9. ✅ View order in order history

## REFERENCE FILES

Full implementation details with code examples:
- `/CUSTOMER_ORDERING_APP_BUILD_PLAN.md` (1,971 lines)
- `/types/supabase-database.ts` (TypeScript types for all tables)

## NOTES

- Admin dashboard at `/admin/*` stays untouched
- Customer routes are at root level: `/`, `/r/*`, `/checkout`, etc.
- Both use the same Supabase database connection
- Use existing Stripe environment variables
- Cart uses localStorage + Zustand (no login required for browsing)
- Orders require customer account (use Supabase Auth)

## START NOW

Build the restaurant menu page first. Let me browse dishes and add to cart. Then we'll tackle checkout.

---

**END OF PROMPT**

