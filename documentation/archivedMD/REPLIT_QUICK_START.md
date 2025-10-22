# 🚀 Replit Quick Start Guide
**Get your frontend development started in 5 minutes!**

---

## ✅ **Step 1: Files to Attach to Replit**

When starting a new Replit project, **attach these 2 files:**

1. **`types/supabase-database.ts`** ⭐ **REQUIRED**
   - Full TypeScript types for all 74 tables
   - Enables autocomplete in VS Code/Replit

2. **`REPLIT_SUPABASE_SETUP.md`**
   - Database documentation
   - Table relationships
   - Business rules
   - Example queries

---

## ✅ **Step 2: GitHub Links to Reference**

**Include these links in your prompt** (Replit Agent can access them):

```
Build Plan:
https://github.com/SantiagoWL117/Migration-Strategy/blob/main/MENU_CA_BUILD_PLAN.md

Database Setup Guide:
https://github.com/SantiagoWL117/Migration-Strategy/blob/main/REPLIT_SUPABASE_SETUP.md

Mermaid Diagrams (Visual Schema):
https://github.com/SantiagoWL117/Migration-Strategy/tree/main/Database/Mermaid_Diagrams
```

---

## ✅ **Step 3: Your First Prompt**

Copy this prompt to Replit Agent:

````markdown
# Menu.ca V3 - Restaurant Ordering Platform

## Context
I'm building a white-label restaurant ordering platform. 74 restaurants use our service. Each has custom branding and manages their own menus, delivery, and promotions.

## Tech Stack
- Next.js 14 (App Router) + TypeScript
- Supabase PostgreSQL (menuca_v3 database)
- TailwindCSS + shadcn/ui
- React Hook Form + Zod

## Attached Files
- `types/supabase-database.ts` - Full DB types (74 tables)
- `REPLIT_SUPABASE_SETUP.md` - Database docs

## Reference Docs
- Build Plan: https://github.com/SantiagoWL117/Migration-Strategy/blob/main/MENU_CA_BUILD_PLAN.md
- Mermaid Diagrams: https://github.com/SantiagoWL117/Migration-Strategy/tree/main/Database/Mermaid_Diagrams

## Environment Variables Needed
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
```

---

## 🎯 First Feature: Restaurant Menu Page

Build a restaurant menu display page:

**Route:** `/restaurant/[id]/menu`

**Requirements:**

1. **Fetch Restaurant Data:**
   ```typescript
   const { data: restaurant } = await supabase
     .from('restaurants')
     .select(`
       *,
       restaurant_locations(*),
       restaurant_service_configs(*)
     `)
     .eq('id', restaurantId)
     .eq('status', 'active')
     .single()
   ```

2. **Fetch Menu with Courses:**
   ```typescript
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
         base_price,
         image_url,
         allergen_info,
         is_active,
         dish_prices (
           size_variant,
           price
         )
       )
     `)
     .eq('restaurant_id', restaurantId)
     .eq('is_active', true)
     .order('display_order')
   ```

3. **Display Components:**
   - **Header:** Restaurant name, address, phone, hours
   - **Course Nav:** Sticky navigation with smooth scroll
   - **Dish Cards:** Image, name, description, price
   - **Search:** Full-text search using `search_vector` column
   - **Filters:** Course filter, dietary filters

4. **Styling:**
   - Use shadcn/ui components (Card, Button, Badge)
   - Apply custom brand colors from `restaurant_service_configs`
   - Mobile-first responsive design
   - Skeleton loaders for async data

5. **Interactions:**
   - Click dish → Open detail modal
   - Search bar → Filter dishes in real-time
   - Course nav → Smooth scroll to section

---

## 📊 Database Tables Used:

| Table | Purpose | Row Count |
|-------|---------|-----------|
| `restaurants` | Restaurant info | 74 |
| `restaurant_locations` | Address, coordinates | 82 |
| `restaurant_service_configs` | Settings, branding | 944 |
| `courses` | Menu categories | 1,207 |
| `dishes` | Menu items | 15,740 |
| `dish_prices` | Size-based pricing | 6,005 |

---

## 🎨 Design Reference:

**Modern, clean UI like:**
- Toast POS
- Square Online Ordering
- Uber Eats (but branded per restaurant)

**Key Features:**
- Large, appetizing food images
- Clear pricing
- Easy navigation
- Fast loading

---

## ✅ Success Criteria:

- [ ] Page loads in < 1 second
- [ ] Smooth scroll navigation
- [ ] Full-text search works
- [ ] Mobile responsive
- [ ] Custom branding applies
- [ ] TypeScript types used throughout

---

Use the types from `types/supabase-database.ts` for all Supabase queries!
````

---

## ✅ **Step 4: Environment Setup in Replit**

1. **Create `.env.local` file:**
   ```env
   NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
   ```

2. **Install dependencies:**
   ```bash
   npm install @supabase/supabase-js
   npm install -D tailwindcss postcss autoprefixer
   npx tailwindcss init -p
   ```

3. **Initialize Supabase client:**
   ```typescript
   // lib/supabase.ts
   import { createClient } from '@supabase/supabase-js'
   import { Database } from '@/types/supabase-database'

   export const supabase = createClient<Database>(
     process.env.NEXT_PUBLIC_SUPABASE_URL!,
     process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
   )
   ```

---

## 🎯 **Build Order (Recommended)**

### **Phase 1: Customer Frontend** (Start Here)
1. ✅ Restaurant menu page
2. ✅ Dish detail modal
3. ✅ Shopping cart
4. ✅ Checkout flow

### **Phase 2: Restaurant Portal**
1. ✅ Login system
2. ✅ Menu management
3. ✅ Analytics dashboard

### **Phase 3: Master Admin**
1. ✅ Restaurant management
2. ✅ Platform analytics
3. ✅ System monitoring

---

## 📦 **Key Files You'll Create**

```
your-replit-project/
├── app/
│   ├── restaurant/
│   │   └── [id]/
│   │       ├── menu/
│   │       │   └── page.tsx        # Menu display
│   │       └── page.tsx            # Restaurant landing
│   ├── admin/
│   │   ├── dashboard/
│   │   │   └── page.tsx            # Master admin
│   │   └── restaurant/
│   │       └── [id]/
│   │           └── page.tsx        # Restaurant portal
│   └── layout.tsx
├── components/
│   ├── menu/
│   │   ├── DishCard.tsx
│   │   ├── CourseNav.tsx
│   │   └── DishModal.tsx
│   ├── cart/
│   │   └── ShoppingCart.tsx
│   └── ui/                         # shadcn/ui components
├── lib/
│   ├── supabase.ts                 # Supabase client
│   └── utils.ts
├── types/
│   └── supabase-database.ts        # ⭐ ATTACH THIS
└── .env.local
```

---

## 🚨 **Common Issues & Solutions**

### **Issue: "Cannot find module 'types/supabase-database'"**
**Solution:** Make sure you copied `types/supabase-database.ts` to your project root.

### **Issue: "Supabase client not connecting"**
**Solution:** Check your `.env.local` file has correct `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`.

### **Issue: "No autocomplete for Supabase queries"**
**Solution:** Make sure you're using `createClient<Database>()` with the Database type.

### **Issue: "Tables not found"**
**Solution:** Tables are in `menuca_v3` schema, but Supabase handles this automatically. Just use `.from('restaurants')` not `.from('menuca_v3.restaurants')`.

---

## 💡 **Pro Tips**

1. **Always use TypeScript types:**
   ```typescript
   import { Restaurant, Dish } from '@/types/supabase-database'
   
   const restaurant: Restaurant = ... // Full autocomplete!
   ```

2. **Use React Query for data fetching:**
   ```typescript
   const { data, isLoading } = useQuery({
     queryKey: ['restaurant', restaurantId],
     queryFn: () => fetchRestaurant(restaurantId)
   })
   ```

3. **Leverage shadcn/ui:**
   ```bash
   npx shadcn-ui@latest init
   npx shadcn-ui@latest add button card dialog
   ```

4. **Check Mermaid diagrams for relationships:**
   - `menu_catalog.mmd` - Menu structure
   - `restaurant_management.mmd` - Restaurant entities
   - `orders_checkout.mmd` - Order flow

5. **Reference the build plan for features:**
   - Full feature breakdown in `MENU_CA_BUILD_PLAN.md`
   - Database relationships documented
   - Business rules explained

---

## 🎉 **You're Ready!**

Start with the **Restaurant Menu Page** (easiest user-facing feature) and build from there!

**GitHub Repo:**
```
https://github.com/SantiagoWL117/Migration-Strategy
```

**Questions?** Check the build plan or setup guide! 🚀

