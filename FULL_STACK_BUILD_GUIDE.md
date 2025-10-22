# 🚀 MenuCA V3 - Full-Stack Build Guide
## Frontend Features → Backend APIs Complete Mapping

**Created:** October 21, 2025  
**Purpose:** Connect customer ordering frontend plan with Santiago's backend implementation  
**Status:** Restaurant Management APIs Complete | 9 Entities Pending

---

## 📖 HOW TO USE THIS GUIDE

This document maps **every frontend feature** from the Customer Ordering App Build Plan to the **corresponding backend APIs** documented in Brian's Master Index.

**For Each Feature:**
- ✅ Frontend component to build
- 🔌 Backend API/function to call
- 📚 Documentation reference
- 💡 Integration example code

---

## 🎯 PROJECT OVERVIEW

**What We're Building:**
A complete full-stack customer ordering platform connecting:
- **Frontend:** Next.js 14 customer ordering app (58 checklist items, 200+ components)
- **Backend:** Supabase PostgreSQL with 50+ SQL functions + 29 Edge Functions

**Current Backend Coverage:**
- ✅ **Restaurant Management** - 100% Complete (50+ SQL, 29 Edge Functions)
- ⏳ **Users & Access** - Backend ready, frontend mapping pending
- ⏳ **Menu & Catalog** - Backend ready, frontend mapping pending  
- ⏳ **Orders & Checkout** - Backend ready, frontend mapping pending
- ⏳ **Service Configuration** - Backend ready, frontend mapping pending
- ⏳ **Location & Geography** - Backend ready, frontend mapping pending

---

## 🏗️ PHASE-BY-PHASE FEATURE MAPPING

### **PHASE 1: FOUNDATION (Day 1-2)**

#### **Frontend Checklist Item #1: Setup Next.js 14 project**

**What to Build:**
```bash
npx create-next-app@latest menu-ca-ordering --typescript --tailwind --app
```

**Backend Requirements:**
- ✅ Supabase project exists
- ✅ Database schema deployed
- ✅ RLS policies active

**Backend Reference:**
- No API calls yet

**Integration Example:**
```typescript
// lib/supabase/client.ts
import { createClientComponentClient } from '@supabase/ssr'

export const supabase = createClientComponentClient({
  supabaseUrl: 'https://nthpbtdjhhnwfxqsxbvy.supabase.co',
  supabaseKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
})
```

---

#### **Frontend Checklist Item #2-6: Install dependencies**

**What to Build:**
```bash
npm install @supabase/supabase-js @supabase/ssr
npm install stripe @stripe/stripe-js @stripe/react-stripe-js
npm install react-hook-form @hookform/resolvers zod
npm install @tanstack/react-query zustand
npm install shadcn-ui components
```

**Backend Requirements:**
- None (frontend dependencies)

---

#### **Frontend Checklist Item #7: Create database migrations**

**What to Build:**
8 new tables for cart, addresses, payments

**Backend API Reference:**
- None (manual SQL execution)

**Tables to Create:**
1. `cart_sessions` - Temporary cart storage
2. `user_delivery_addresses` - Saved addresses
3. `user_payment_methods` - Saved cards (Stripe tokens only!)
4. `payment_transactions` - Payment records
5. `order_status_history` - Order tracking
6. `stripe_webhook_events` - Webhook idempotency
7. `user_favorite_dishes` - Favorites
8. `restaurant_reviews` - Reviews

**Documentation Reference:**
- `/PAYMENT_DATA_STORAGE_PLAN.md` (lines 62-212)

---

### **PHASE 2: RESTAURANT MENU DISPLAY (Day 3-4)**

#### **Frontend Checklist Item #8: Build restaurant page route `/r/[slug]`**

**What to Build:**
- Restaurant menu page
- Dynamic route based on restaurant slug
- SSG with generateStaticParams

**Backend APIs to Call:**

##### **API #1: Get Restaurant Details**

**Function:** `get_restaurant_by_slug()`  
**Type:** SQL Function  
**Location:** Restaurant Management Entity

**Backend Reference:**
- [BRIAN_MASTER_INDEX.md → Restaurant Management → Component 7: SEO & Full-Text Search](documentation/Frontend-Guides/BRIAN_MASTER_INDEX.md#7-restaurant-management)
- [07-SEO-Full-Text-Search.md](documentation/Frontend-Guides/Restaurant%20Management/07-SEO-Full-Text-Search.md)

**Integration Example:**
```typescript
// app/(public)/r/[slug]/page.tsx
import { createClient } from '@/lib/supabase/server'

export default async function RestaurantPage({ params }: { params: { slug: string } }) {
  const supabase = createClient()
  
  // Call SQL function
  const { data: restaurant, error } = await supabase
    .rpc('get_restaurant_by_slug', {
      p_slug: params.slug
    })
  
  if (!restaurant) {
    notFound()
  }
  
  return (
    <div>
      <h1>{restaurant.name}</h1>
      <p>{restaurant.description}</p>
      {/* ... */}
    </div>
  )
}
```

**What You Get Back:**
```typescript
{
  id: number
  name: string
  slug: string
  description: string
  logo_url: string
  banner_url: string
  min_order_amount: number
  delivery_fee: number
  estimated_delivery_time: number
  is_online: boolean
  status: 'active' | 'inactive'
  location: {
    street_address: string
    city: string
    province: string
  }
}
```

---

##### **API #2: Check Restaurant Availability**

**Function:** `check_restaurant_availability()`  
**Type:** Edge Function  
**Location:** Restaurant Management Entity → Component 3

**Backend Reference:**
- [03-Status-Online-Toggle.md](documentation/Frontend-Guides/Restaurant%20Management/03-Status-Online-Toggle.md)

**Integration Example:**
```typescript
// Check if restaurant is open right now
const { data: availability } = await supabase.functions.invoke('check-restaurant-availability', {
  body: { restaurant_id: restaurant.id }
})

if (!availability.is_available) {
  return (
    <Alert>
      <AlertTitle>Restaurant Closed</AlertTitle>
      <AlertDescription>
        Opens at {availability.next_open_time}
      </AlertDescription>
    </Alert>
  )
}
```

**What You Get Back:**
```typescript
{
  is_available: boolean
  status: 'open' | 'closed' | 'temporarily_closed'
  reason: string | null
  next_open_time: string | null
  current_schedule: {
    day: string
    open_time: string
    close_time: string
  }
}
```

---

##### **API #3: Get Menu with Categories**

**Function:** Direct Supabase query (optimized with indexes)  
**Type:** SQL Query  
**Location:** Menu & Catalog Entity

**Backend Reference:**
- [BRIAN_MASTER_INDEX.md → Menu & Catalog](documentation/Frontend-Guides/BRIAN_MASTER_INDEX.md#3-menu--catalog) (pending documentation)

**Integration Example:**
```typescript
// Get full menu structure
const { data: courses } = await supabase
  .from('courses')
  .select(`
    id,
    name,
    description,
    display_order,
    dishes (
      id,
      name,
      description,
      image_url,
      is_active,
      dish_prices (
        id,
        size_name,
        price
      ),
      dish_modifiers (
        id,
        name,
        price,
        is_required,
        max_selection
      )
    )
  `)
  .eq('restaurant_id', restaurant.id)
  .eq('is_active', true)
  .order('display_order')
```

**What You Get Back:**
```typescript
[
  {
    id: number
    name: string // "Appetizers", "Main Dishes", etc.
    description: string
    display_order: number
    dishes: [
      {
        id: number
        name: string
        description: string
        image_url: string | null
        is_active: boolean
        dish_prices: [
          { id: number, size_name: string, price: number }
        ]
        dish_modifiers: [
          { 
            id: number, 
            name: string, 
            price: number, 
            is_required: boolean,
            max_selection: number 
          }
        ]
      }
    ]
  }
]
```

---

#### **Frontend Checklist Item #9-13: Build UI Components**

**Components to Build:**
1. `RestaurantHeader` - Restaurant info, logo, hours
2. `MenuCategoryNav` - Sticky sidebar navigation
3. `DishCard` - Dish preview card
4. `DishModal` - Dish detail + customization
5. `RestaurantHours` - Operating hours display

**Backend APIs Used:**
- `get_restaurant_by_slug()` ✅ (from above)
- `check_restaurant_availability()` ✅ (from above)
- Menu query ✅ (from above)

**Integration Example for RestaurantHeader:**
```typescript
'use client'

import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'

export function RestaurantHeader({ restaurantId }: { restaurantId: number }) {
  // Real-time availability check
  const { data: availability } = useQuery({
    queryKey: ['restaurant-availability', restaurantId],
    queryFn: async () => {
      const { data } = await supabase.functions.invoke('check-restaurant-availability', {
        body: { restaurant_id: restaurantId }
      })
      return data
    },
    refetchInterval: 60000 // Check every minute
  })
  
  return (
    <header>
      <div className="flex items-center gap-2">
        <h1>Restaurant Name</h1>
        {availability?.is_available ? (
          <Badge variant="success">Open Now</Badge>
        ) : (
          <Badge variant="secondary">Closed</Badge>
        )}
      </div>
    </header>
  )
}
```

---

### **PHASE 3: CART SYSTEM (Day 5)**

#### **Frontend Checklist Item #14: Build Zustand cart store**

**What to Build:**
Client-side cart state management with localStorage persistence

**Backend APIs:**
- None (pure client-side state)

**However, for logged-in users, sync cart to database:**

##### **API #4: Save Cart to Database**

**Function:** Direct insert to `cart_sessions` table  
**Type:** SQL Insert  
**Location:** Custom table (not in BRIAN_MASTER_INDEX yet)

**Integration Example:**
```typescript
// stores/use-cart-store.ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface CartStore {
  items: CartItem[]
  syncToDatabase: () => Promise<void>
}

export const useCartStore = create<CartStore>()(
  persist(
    (set, get) => ({
      items: [],
      
      // Sync cart to database for logged-in users
      syncToDatabase: async () => {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user) return
        
        const cart = get()
        await supabase
          .from('cart_sessions')
          .upsert({
            user_id: user.id,
            restaurant_id: cart.restaurantId,
            cart_data: {
              items: cart.items,
              subtotal: cart.getSubtotal(),
              tax: cart.getTax()
            },
            expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours
          })
      }
    }),
    { name: 'menu-ca-cart' }
  )
)
```

---

#### **Frontend Checklist Item #15-18: Build Cart Components**

**Components to Build:**
1. `CartDrawer` - Sliding cart panel
2. `CartItem` - Individual cart item with quantity controls
3. `CartSummary` - Subtotal, tax, fees, total
4. `MiniCartButton` - Floating cart button with badge

**Backend APIs:**
- None (uses client-side cart store)

---

### **PHASE 4: CHECKOUT FLOW (Day 6-7)**

#### **Frontend Checklist Item #19: Build checkout page**

**What to Build:**
Multi-step checkout form with delivery, address, time, payment

**Backend APIs to Call:**

##### **API #5: Get User Saved Addresses**

**Function:** Direct query to `user_delivery_addresses` table  
**Type:** SQL Query with RLS  
**Location:** Users & Access Entity

**Backend Reference:**
- [BRIAN_MASTER_INDEX.md → Users & Access](documentation/Frontend-Guides/BRIAN_MASTER_INDEX.md#2-users--access) (pending documentation)

**Integration Example:**
```typescript
// components/checkout/address-selector.tsx
'use client'

import { useQuery } from '@tanstack/react-query'

export function AddressSelector() {
  const { data: addresses } = useQuery({
    queryKey: ['user-addresses'],
    queryFn: async () => {
      const { data } = await supabase
        .from('user_delivery_addresses')
        .select(`
          id,
          address_label,
          street_address,
          unit,
          city_id,
          postal_code,
          is_default,
          cities (
            name,
            provinces (name)
          )
        `)
        .order('is_default', { ascending: false })
      
      return data
    }
  })
  
  return (
    <RadioGroup>
      {addresses?.map(address => (
        <div key={address.id}>
          <RadioGroupItem value={address.id.toString()} />
          <Label>
            {address.address_label}
            {address.street_address}, {address.cities.name}
          </Label>
        </div>
      ))}
    </RadioGroup>
  )
}
```

---

##### **API #6: Validate Delivery Address**

**Function:** `check_delivery_zone()`  
**Type:** SQL Function (PostGIS)  
**Location:** Restaurant Management Entity → Component 6

**Backend Reference:**
- [06-PostGIS-Delivery-Zones.md](documentation/Frontend-Guides/Restaurant%20Management/06-PostGIS-Delivery-Zones.md)

**Integration Example:**
```typescript
// Verify restaurant delivers to this address
const { data: deliveryCheck } = await supabase.rpc('check_delivery_zone', {
  p_restaurant_id: restaurantId,
  p_latitude: address.latitude,
  p_longitude: address.longitude
})

if (!deliveryCheck.in_zone) {
  return (
    <Alert variant="destructive">
      <AlertTitle>Outside Delivery Area</AlertTitle>
      <AlertDescription>
        This restaurant doesn't deliver to your address.
        Try pickup instead.
      </AlertDescription>
    </Alert>
  )
}

// Show delivery fee
const deliveryFee = deliveryCheck.zone.delivery_fee
```

**What You Get Back:**
```typescript
{
  in_zone: boolean
  zone: {
    id: number
    name: string
    delivery_fee: number
    min_order_amount: number
    estimated_time: number
  } | null
  distance_km: number
}
```

---

#### **Frontend Checklist Item #20-25: Build Checkout Components**

**Components to Build:**
1. `DeliveryTypeSelector` - Delivery vs Pickup
2. `AddressSelector` - Choose saved address or add new
3. `TimeSelector` - ASAP or schedule for later
4. `CouponInput` - Apply promotional code
5. `OrderSummary` - Final review before payment
6. `PaymentForm` - Stripe Elements integration

**Backend APIs:**

##### **API #7: Apply Coupon Code**

**Function:** Direct query to `promotional_coupons` table  
**Type:** SQL Query  
**Location:** Marketing & Promotions Entity

**Backend Reference:**
- [BRIAN_MASTER_INDEX.md → Marketing & Promotions](documentation/Frontend-Guides/BRIAN_MASTER_INDEX.md#6-marketing--promotions) (pending documentation)

**Integration Example:**
```typescript
// components/checkout/coupon-input.tsx
async function applyCoupon(code: string, restaurantId: number) {
  const { data: coupon, error } = await supabase
    .from('promotional_coupons')
    .select('*')
    .eq('code', code.toUpperCase())
    .eq('restaurant_id', restaurantId)
    .eq('is_active', true)
    .gte('valid_to', new Date().toISOString())
    .lte('valid_from', new Date().toISOString())
    .single()
  
  if (error || !coupon) {
    throw new Error('Invalid or expired coupon code')
  }
  
  // Calculate discount
  let discount = 0
  if (coupon.discount_type === 'percentage') {
    discount = (subtotal * coupon.discount_value) / 100
    if (coupon.max_discount_amount) {
      discount = Math.min(discount, coupon.max_discount_amount)
    }
  } else if (coupon.discount_type === 'fixed') {
    discount = coupon.discount_value
  }
  
  return { coupon, discount }
}
```

---

### **PHASE 5: PAYMENT INTEGRATION (Day 8-9)**

#### **Frontend Checklist Item #26-32: Stripe Integration**

**What to Build:**
- Stripe Payment Intent API route
- Stripe Elements payment form
- Order confirmation API route
- Webhook handler for payment events

**Backend APIs:**

##### **API #8: Create Payment Intent**

**Function:** Custom API route (not in Supabase)  
**Type:** Next.js API Route  
**Location:** Your app

**Integration Example:**
```typescript
// app/api/checkout/create-payment-intent/route.ts
import { NextRequest, NextResponse } from 'next/server'
import Stripe from 'stripe'
import { createClient } from '@/lib/supabase/server'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(request: NextRequest) {
  const supabase = createClient()
  
  // Get authenticated user
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }
  
  const { amount, restaurantId, items } = await request.json()
  
  // Create Stripe Payment Intent
  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(amount * 100), // Convert to cents
    currency: 'cad',
    metadata: {
      user_id: user.id,
      restaurant_id: restaurantId.toString()
    }
  })
  
  return NextResponse.json({
    clientSecret: paymentIntent.client_secret
  })
}
```

**Frontend Usage:**
```typescript
// components/checkout/payment-form.tsx
import { CardElement, useStripe, useElements } from '@stripe/react-stripe-js'

export function PaymentForm({ amount, onSuccess }: PaymentFormProps) {
  const stripe = useStripe()
  const elements = useElements()
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    // Create Payment Intent
    const res = await fetch('/api/checkout/create-payment-intent', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        amount,
        restaurantId,
        items: cartItems
      })
    })
    
    const { clientSecret } = await res.json()
    
    // Confirm payment with Stripe
    const { error, paymentIntent } = await stripe!.confirmCardPayment(clientSecret, {
      payment_method: {
        card: elements!.getElement(CardElement)!
      }
    })
    
    if (error) {
      setError(error.message)
    } else if (paymentIntent.status === 'succeeded') {
      // Create order in database
      await confirmOrder(paymentIntent.id)
      onSuccess(orderId)
    }
  }
  
  return (
    <form onSubmit={handleSubmit}>
      <CardElement />
      <Button type="submit">Pay ${amount.toFixed(2)}</Button>
    </form>
  )
}
```

---

##### **API #9: Confirm Order (Create Order in Database)**

**Function:** Custom API route + direct Supabase inserts  
**Type:** Next.js API Route + SQL Inserts  
**Location:** Your app + Orders & Checkout Entity

**Backend Reference:**
- [BRIAN_MASTER_INDEX.md → Orders & Checkout](documentation/Frontend-Guides/BRIAN_MASTER_INDEX.md#7-orders--checkout) (pending documentation)

**Integration Example:**
```typescript
// app/api/checkout/confirm-order/route.ts
export async function POST(request: NextRequest) {
  const supabase = createClient()
  
  const { 
    paymentIntentId, 
    restaurantId, 
    deliveryType, 
    addressId, 
    items,
    subtotal,
    tax,
    deliveryFee,
    total 
  } = await request.json()
  
  // Create order in database
  const { data: order, error } = await supabase
    .from('orders')
    .insert({
      restaurant_id: restaurantId,
      user_id: user.id,
      order_status: 'pending',
      order_type: deliveryType,
      subtotal,
      tax_amount: tax,
      delivery_fee: deliveryFee,
      total_amount: total,
      stripe_payment_intent_id: paymentIntentId,
      payment_status: 'succeeded'
    })
    .select()
    .single()
  
  // Create order items
  const orderItems = items.map(item => ({
    order_id: order.id,
    created_at: order.created_at, // Partition key
    dish_id: item.dishId,
    item_name: item.dishName,
    quantity: item.quantity,
    unit_price: item.dishPrice,
    total_price: item.subtotal,
    customizations: item.modifiers
  }))
  
  await supabase.from('order_items').insert(orderItems)
  
  return NextResponse.json({
    success: true,
    orderId: order.id
  })
}
```

---

### **PHASE 6: CUSTOMER ACCOUNT (Day 10-11)**

#### **Frontend Checklist Item #33-39: Account Pages**

**What to Build:**
- Customer signup/login
- Account dashboard
- Order history page
- Order detail page
- Saved addresses page
- Saved payment methods page
- Favorites page

**Backend APIs:**

##### **API #10: Customer Authentication**

**Function:** Supabase Auth  
**Type:** Built-in Auth  
**Location:** Users & Access Entity

**Backend Reference:**
- [SANTIAGO_BACKEND_INTEGRATION_GUIDE.md → Users & Access](documentation/Users%20&%20Access/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)

**Integration Example:**
```typescript
// lib/auth/signup.ts
export async function signUp(email: string, password: string, name: string) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        name,
        user_type: 'customer'
      }
    }
  })
  
  if (error) throw error
  
  // Insert into users table (via trigger or manual)
  await supabase
    .from('users')
    .insert({
      auth_user_id: data.user!.id,
      email,
      name,
      user_type: 'customer'
    })
  
  return data.user
}

// lib/auth/login.ts
export async function signIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  })
  
  if (error) throw error
  return data.session
}
```

---

##### **API #11: Get Customer Order History**

**Function:** `get_customer_order_history()`  
**Type:** SQL Function (if exists) or direct query  
**Location:** Orders & Checkout Entity

**Backend Reference:**
- [ORDERS_CHECKOUT_COMPLETION_REPORT.md](Database/Orders_&_Checkout/ORDERS_CHECKOUT_COMPLETION_REPORT.md) (lines 86-88)

**Integration Example:**
```typescript
// app/(customer)/account/orders/page.tsx
export default async function OrderHistoryPage() {
  const supabase = createClient()
  
  // Option 1: Use SQL function (if available)
  const { data: orders } = await supabase.rpc('get_customer_order_history', {
    p_limit: 20,
    p_offset: 0
  })
  
  // Option 2: Direct query with RLS (RLS ensures user sees only their orders)
  const { data: orders } = await supabase
    .from('orders')
    .select(`
      id,
      order_number,
      order_status,
      total_amount,
      created_at,
      restaurants (
        name,
        logo_url
      ),
      order_items (
        item_name,
        quantity
      )
    `)
    .order('created_at', { ascending: false })
    .limit(20)
  
  return (
    <div>
      <h1>Order History</h1>
      {orders?.map(order => (
        <OrderCard key={order.id} order={order} />
      ))}
    </div>
  )
}
```

---

##### **API #12: Manage Saved Addresses**

**Function:** CRUD operations on `user_delivery_addresses` table  
**Type:** SQL Inserts/Updates/Deletes with RLS  
**Location:** Users & Access Entity

**Integration Example:**
```typescript
// Add new address
async function addAddress(address: AddressInput) {
  const { data, error } = await supabase
    .from('user_delivery_addresses')
    .insert({
      address_label: address.label,
      street_address: address.street,
      unit: address.unit,
      city_id: address.cityId,
      postal_code: address.postalCode,
      latitude: address.lat,
      longitude: address.lng,
      is_default: address.isDefault
    })
    .select()
    .single()
  
  return data
}

// Update address
async function updateAddress(addressId: number, updates: Partial<AddressInput>) {
  const { data, error } = await supabase
    .from('user_delivery_addresses')
    .update(updates)
    .eq('id', addressId)
    .select()
    .single()
  
  return data
}

// Delete address
async function deleteAddress(addressId: number) {
  const { error } = await supabase
    .from('user_delivery_addresses')
    .delete()
    .eq('id', addressId)
}
```

---

### **PHASE 7: ORDER TRACKING (Day 12)**

#### **Frontend Checklist Item #40-44: Real-Time Order Tracking**

**What to Build:**
- Order confirmation page
- Order tracking component with timeline
- Real-time status updates via WebSocket
- Order status notifications

**Backend APIs:**

##### **API #13: Subscribe to Order Status Updates**

**Function:** Supabase Realtime  
**Type:** WebSocket Subscription  
**Location:** Orders & Checkout Entity → Phase 4

**Backend Reference:**
- [ORDERS_CHECKOUT_COMPLETION_REPORT.md](Database/Orders_&_Checkout/ORDERS_CHECKOUT_COMPLETION_REPORT.md) (lines 154-182)
- [PHASE_4_BACKEND_DOCUMENTATION.md](Database/Orders_&_Checkout/PHASE_4_BACKEND_DOCUMENTATION.md)

**Integration Example:**
```typescript
// app/order-confirmation/[id]/page.tsx
'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase/client'

export default function OrderTrackingPage({ params }: { params: { id: string } }) {
  const [order, setOrder] = useState(null)
  const [statusHistory, setStatusHistory] = useState([])
  
  useEffect(() => {
    // Initial load
    loadOrder()
    
    // Subscribe to real-time updates
    const channel = supabase
      .channel(`order:${params.id}`)
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'menuca_v3',
          table: 'orders',
          filter: `id=eq.${params.id}`
        },
        (payload) => {
          console.log('Order updated!', payload.new)
          setOrder(payload.new)
          
          // Show notification
          toast({
            title: 'Order Update',
            description: `Your order is now ${payload.new.order_status}`
          })
        }
      )
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'menuca_v3',
          table: 'order_status_history',
          filter: `order_id=eq.${params.id}`
        },
        (payload) => {
          console.log('New status entry!', payload.new)
          setStatusHistory(prev => [...prev, payload.new])
        }
      )
      .subscribe()
    
    return () => {
      channel.unsubscribe()
    }
  }, [params.id])
  
  return (
    <div>
      <h1>Order #{order?.order_number}</h1>
      <OrderTimeline status={order?.order_status} history={statusHistory} />
    </div>
  )
}

async function loadOrder() {
  const { data } = await supabase
    .from('orders')
    .select(`
      *,
      restaurants (name, logo_url),
      order_items (*),
      order_status_history (*)
    `)
    .eq('id', params.id)
    .single()
  
  setOrder(data)
  setStatusHistory(data.order_status_history)
}
```

**Status Timeline Component:**
```typescript
// components/order/order-timeline.tsx
const statuses = [
  { key: 'pending', label: 'Order Placed', icon: CheckCircle },
  { key: 'confirmed', label: 'Confirmed', icon: Clock },
  { key: 'preparing', label: 'Being Prepared', icon: Chef },
  { key: 'ready', label: 'Ready for Pickup', icon: Package },
  { key: 'out_for_delivery', label: 'Out for Delivery', icon: Truck },
  { key: 'delivered', label: 'Delivered', icon: Home }
]

export function OrderTimeline({ status, history }: OrderTimelineProps) {
  return (
    <div className="space-y-4">
      {statuses.map((s, idx) => {
        const statusEntry = history.find(h => h.status === s.key)
        const isComplete = statusEntry != null
        const isCurrent = status === s.key
        
        return (
          <div key={s.key} className={cn(
            'flex items-start gap-4',
            isComplete && 'text-green-600',
            isCurrent && 'text-blue-600 font-semibold'
          )}>
            <div className="flex-shrink-0">
              {isComplete ? (
                <CheckCircle className="w-6 h-6" />
              ) : (
                <Circle className="w-6 h-6" />
              )}
            </div>
            <div>
              <p className="font-medium">{s.label}</p>
              {statusEntry && (
                <p className="text-sm text-gray-500">
                  {formatDistanceToNow(new Date(statusEntry.created_at), { addSuffix: true })}
                </p>
              )}
            </div>
          </div>
        )
      })}
    </div>
  )
}
```

---

### **PHASE 8: POLISH & TESTING (Day 13-14)**

#### **Frontend Checklist Item #45-51: Final Polish**

**What to Build:**
- Mobile responsiveness testing
- Loading states for all async operations
- Error handling and user feedback
- Form validation with Zod
- Performance optimization
- SEO metadata
- End-to-end testing

**Backend APIs:**
No new APIs - testing existing integrations

**Key Testing Scenarios:**

1. **Restaurant Discovery:**
   - Search restaurants
   - Filter by cuisine/tags
   - Check availability
   - View menu

2. **Order Placement:**
   - Add items to cart with modifiers
   - Apply coupon code
   - Select delivery address
   - Complete payment
   - Receive confirmation

3. **Order Tracking:**
   - View order history
   - Track active order in real-time
   - Receive status notifications

4. **Account Management:**
   - Sign up / Log in
   - Save addresses
   - Save payment methods
   - View favorites

---

## 🔌 BACKEND API QUICK REFERENCE

### **Restaurant Management APIs (✅ Complete)**

| Feature | SQL Function | Edge Function | Documentation |
|---------|--------------|---------------|---------------|
| Get restaurant by slug | `get_restaurant_by_slug()` | - | [07-SEO](documentation/Frontend-Guides/Restaurant%20Management/07-SEO-Full-Text-Search.md) |
| Check availability | `is_restaurant_open_now()` | `check-restaurant-availability` | [03-Status](documentation/Frontend-Guides/Restaurant%20Management/03-Status-Online-Toggle.md) |
| Check delivery zone | `check_delivery_zone()` | - | [06-PostGIS](documentation/Frontend-Guides/Restaurant%20Management/06-PostGIS-Delivery-Zones.md) |
| Search restaurants | `search_restaurants()` | `search-restaurants` | [07-SEO](documentation/Frontend-Guides/Restaurant%20Management/07-SEO-Full-Text-Search.md) |
| Get by cuisine | `get_restaurants_by_cuisine()` | - | [08-Categorization](documentation/Frontend-Guides/Restaurant%20Management/08-Categorization-System.md) |
| Get by tags | `get_restaurants_by_tag()` | - | [08-Categorization](documentation/Frontend-Guides/Restaurant%20Management/08-Categorization-System.md) |
| Franchise locations | `get_franchise_locations()` | - | [01-Franchise](documentation/Frontend-Guides/Restaurant%20Management/01-Franchise-Chain-Hierarchy.md) |

**Total:** 50+ SQL Functions | 29 Edge Functions

---

### **Users & Access APIs (⏳ Documentation Pending)**

| Feature | Function/Table | Type | Status |
|---------|----------------|------|--------|
| Sign up | `supabase.auth.signUp()` | Auth | ✅ Ready |
| Sign in | `supabase.auth.signInWithPassword()` | Auth | ✅ Ready |
| Get profile | `users` table | Query | ✅ Ready |
| Update profile | `users` table | Update | ✅ Ready |
| Saved addresses | `user_delivery_addresses` | CRUD | ✅ Ready |
| Payment methods | `user_payment_methods` | CRUD | ✅ Ready |

**Backend Reference:**
- [SANTIAGO_BACKEND_INTEGRATION_GUIDE.md](documentation/Users%20&%20Access/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)

---

### **Menu & Catalog APIs (⏳ Documentation Pending)**

| Feature | Function/Table | Type | Status |
|---------|----------------|------|--------|
| Get menu | `courses` + `dishes` | Query | ✅ Ready |
| Get dish details | `dishes` table | Query | ✅ Ready |
| Get modifiers | `dish_modifiers` table | Query | ✅ Ready |
| Get combo items | `combo_items` table | Query | ✅ Ready |
| Search dishes | TBD | Function | ⏳ Pending |

**Backend Reference:**
- [MENU_CATALOG_COMPLETION_REPORT.md](Database/Menu%20&%20Catalog%20Entity/)

---

### **Orders & Checkout APIs (⏳ Documentation Pending)**

| Feature | Function | Type | Status |
|---------|----------|------|--------|
| Create order | `create_order()` | SQL Function | ✅ Ready |
| Get order details | `get_order_details()` | SQL Function | ✅ Ready |
| Order history | `get_customer_order_history()` | SQL Function | ✅ Ready |
| Update status | `update_order_status()` | SQL Function | ✅ Ready |
| Cancel order | `cancel_order()` | SQL Function | ✅ Ready |
| Process payment | `process_payment()` | SQL Function | ✅ Ready |
| Process refund | `process_refund()` | SQL Function | ✅ Ready |
| Real-time updates | Supabase Realtime | WebSocket | ✅ Ready |

**Backend Reference:**
- [ORDERS_CHECKOUT_COMPLETION_REPORT.md](Database/Orders_&_Checkout/ORDERS_CHECKOUT_COMPLETION_REPORT.md)
- [SANTIAGO_BACKEND_INTEGRATION_GUIDE.md](documentation/Orders%20&%20Checkout/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)

---

### **Service Configuration APIs (⏳ Documentation Pending)**

| Feature | Function/Table | Type | Status |
|---------|----------------|------|--------|
| Get restaurant hours | `restaurant_schedules` | Query | ✅ Ready |
| Check if open | `is_restaurant_open_now()` | Function | ✅ Ready |
| Get holidays | `schedule_holidays` | Query | ✅ Ready |
| Get service types | `service_types` | Query | ✅ Ready |

**Backend Reference:**
- [SERVICE_SCHEDULES_COMPLETION_REPORT.md](Database/Service%20Configuration%20&%20Schedules/)

---

### **Location & Geography APIs (⏳ Documentation Pending)**

| Feature | Function | Type | Status |
|---------|----------|------|--------|
| Get restaurants near location | `get_restaurants_near_location()` | SQL (PostGIS) | ✅ Ready |
| Search cities | `search_cities()` | SQL Function | ✅ Ready |
| Get by province | `get_cities_by_province()` | SQL Function | ✅ Ready |
| Distance calculation | PostGIS operators | Native | ✅ Ready |

**Backend Reference:**
- [SANTIAGO_BACKEND_INTEGRATION_GUIDE.md](documentation/Location%20&%20Geography/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)

---

### **Marketing & Promotions APIs (⏳ Documentation Pending)**

| Feature | Function/Table | Type | Status |
|---------|----------------|------|--------|
| Get active deals | `deals` table | Query | ✅ Ready |
| Apply coupon | `promotional_coupons` | Query | ✅ Ready |
| Get tags | `tags` table | Query | ✅ Ready |
| Get cuisines | `cuisines` table | Query | ✅ Ready |

**Backend Reference:**
- [SANTIAGO_BACKEND_INTEGRATION_GUIDE.md](documentation/Marketing%20&%20Promotions/)

---

## 🎯 INTEGRATION PATTERNS

### **Pattern #1: Server-Side Data Fetching (SSR)**

Use for SEO-critical pages and initial page load.

```typescript
// app/(public)/r/[slug]/page.tsx
import { createClient } from '@/lib/supabase/server'

export default async function RestaurantPage({ params }) {
  const supabase = createClient()
  
  // Server-side: Fast, SEO-friendly
  const { data: restaurant } = await supabase
    .rpc('get_restaurant_by_slug', { p_slug: params.slug })
  
  return <RestaurantView restaurant={restaurant} />
}
```

**When to use:**
- Restaurant pages
- Menu pages
- Public content

---

### **Pattern #2: Client-Side with React Query**

Use for authenticated routes and dynamic data.

```typescript
// app/(customer)/account/orders/page.tsx
'use client'

import { useQuery } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase/client'

export default function OrderHistoryPage() {
  const { data: orders, isLoading } = useQuery({
    queryKey: ['orders'],
    queryFn: async () => {
      const { data } = await supabase
        .from('orders')
        .select('*')
        .order('created_at', { ascending: false })
      return data
    }
  })
  
  if (isLoading) return <Skeleton />
  return <OrderList orders={orders} />
}
```

**When to use:**
- Customer account pages
- Order history
- Saved addresses/cards
- Real-time data

---

### **Pattern #3: Real-Time Subscriptions**

Use for live updates (order status, availability).

```typescript
'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase/client'

export function OrderTracker({ orderId }) {
  const [status, setStatus] = useState(null)
  
  useEffect(() => {
    const channel = supabase
      .channel(`order:${orderId}`)
      .on('postgres_changes', {
        event: 'UPDATE',
        schema: 'menuca_v3',
        table: 'orders',
        filter: `id=eq.${orderId}`
      }, (payload) => {
        setStatus(payload.new.order_status)
      })
      .subscribe()
    
    return () => { channel.unsubscribe() }
  }, [orderId])
  
  return <StatusBadge status={status} />
}
```

**When to use:**
- Order tracking
- Restaurant availability
- Live menu updates

---

### **Pattern #4: Edge Functions for Write Operations**

Use for complex business logic or external API calls.

```typescript
// Call Edge Function from frontend
const { data, error } = await supabase.functions.invoke('create-order', {
  body: {
    restaurant_id: 123,
    items: cartItems,
    delivery_address: address
  }
})
```

**When to use:**
- Order creation (with validation)
- Payment processing
- Email notifications
- External API integrations

---

## 🚀 GETTING STARTED

### **Step 1: Review Backend APIs**

Start with Santiago's complete documentation:
- [BRIAN_MASTER_INDEX.md](documentation/Frontend-Guides/BRIAN_MASTER_INDEX.md)
- [Restaurant Management guides](documentation/Frontend-Guides/Restaurant%20Management/)

### **Step 2: Setup Frontend Project**

Follow Phase 1 of the Customer Ordering App Build Plan:
- [CUSTOMER_ORDERING_APP_BUILD_PLAN.md](CUSTOMER_ORDERING_APP_BUILD_PLAN.md)

### **Step 3: Build Phase by Phase**

Use this guide to map each frontend feature to backend APIs:
1. **Phase 2:** Restaurant menu display → Restaurant Management APIs
2. **Phase 3:** Cart system → Local state (no backend yet)
3. **Phase 4:** Checkout flow → Delivery zones, addresses, coupons
4. **Phase 5:** Payments → Stripe + Order creation APIs
5. **Phase 6:** Account → Users & Access APIs
6. **Phase 7:** Tracking → Real-time order updates

### **Step 4: Test Integration**

For each feature:
1. ✅ Call backend API
2. ✅ Handle loading state
3. ✅ Handle error state
4. ✅ Display data
5. ✅ Test real-time updates (if applicable)

---

## 📚 DOCUMENTATION REFERENCES

### **Frontend Build Plans:**
- [CUSTOMER_ORDERING_APP_BUILD_PLAN.md](CUSTOMER_ORDERING_APP_BUILD_PLAN.md) - Customer app (58 tasks)
- [ULTIMATE_REPLIT_BUILD_PLAN.md](ULTIMATE_REPLIT_BUILD_PLAN.md) - Admin dashboard (168 features)

### **Backend API Documentation:**
- [BRIAN_MASTER_INDEX.md](documentation/Frontend-Guides/BRIAN_MASTER_INDEX.md) - Master API reference
- [Restaurant Management guides](documentation/Frontend-Guides/Restaurant%20Management/) - 11 components complete
- [SANTIAGO_MASTER_INDEX.md](SANTIAGO_MASTER_INDEX.md) - Backend implementation index

### **Database Schema:**
- [PAYMENT_DATA_STORAGE_PLAN.md](PAYMENT_DATA_STORAGE_PLAN.md) - Payment tables and Stripe integration
- [PRE_FLIGHT_COMPLETE.md](Database/PRE_FLIGHT_COMPLETE.md) - Schema validation
- [V3_COMPLETE_TABLE_AUDIT.md](Database/V3_COMPLETE_TABLE_AUDIT.md) - All 74 tables

### **Entity Completion Reports:**
- [Orders & Checkout](Database/Orders_&_Checkout/ORDERS_CHECKOUT_COMPLETION_REPORT.md)
- [Menu & Catalog](Database/Menu%20&%20Catalog%20Entity/)
- [Users & Access](Database/Users_&_Access/)
- [Service Configuration](Database/Service%20Configuration%20&%20Schedules/)

---

## 🎉 SUCCESS METRICS

### **Phase 2-3 Complete = MVP:**
- ✅ Browse restaurant menus
- ✅ Add items to cart
- ✅ See cart total

### **Phase 4-5 Complete = Functional App:**
- ✅ Checkout flow working
- ✅ Payment processing
- ✅ Orders created in database

### **Phase 6-7 Complete = Production Ready:**
- ✅ Customer accounts
- ✅ Order history
- ✅ Real-time tracking
- ✅ Full customer experience

---

## 💡 PRO TIPS

### **Tip #1: Start with Restaurant Management**
Santiago's Restaurant Management APIs are 100% complete with full documentation. Build restaurant browsing first!

### **Tip #2: Use TypeScript Types**
Import database types for type safety:
```typescript
import { Database } from '@/types/supabase-database'

type Restaurant = Database['menuca_v3']['Tables']['restaurants']['Row']
```

### **Tip #3: Test with Real Data**
You have:
- 961 restaurants
- 15,740 dishes
- 32,000+ users
Test with production data from day 1!

### **Tip #4: Real-Time from Day 1**
Supabase Realtime is already enabled. Add subscriptions early for better UX.

### **Tip #5: Follow the Build Plan Order**
Don't skip phases - each builds on the previous. Phase 2 before Phase 3!

---

**Ready to build the full-stack app? You have all the APIs! 🚀**

**Last Updated:** October 21, 2025  
**Status:** Restaurant Management APIs fully mapped | Other entities pending  
**Next Steps:** Complete Phase 2 (Restaurant Menu Display) using Restaurant Management APIs

---


