# 🚀 Menu.ca V3 Admin Dashboard - Replit Agent Prompt
**Copy this entire prompt and paste it into Replit Agent with the 2 attached files**

---

## 📎 **ATTACHED FILES (REQUIRED)**

I've attached these 2 critical files:

1. **`types/supabase-database.ts`** (945 lines)
   - Complete TypeScript types for all 74 database tables
   - Row, Insert, and Update types for each table
   - All ENUMs and helper types
   - **USE THIS FOR ALL DATABASE QUERIES**

2. **`ULTIMATE_REPLIT_BUILD_PLAN.md`** (1,270 lines)
   - Complete technical specification
   - 168 features documented
   - Database migration SQL
   - Code examples for every component
   - 10-week implementation roadmap
   - **THIS IS YOUR COMPLETE BUILD GUIDE**

---

## 🎯 **WHAT I NEED YOU TO BUILD**

Build a **modern, multi-tenant restaurant ordering platform admin dashboard** using:

### **Tech Stack:**
- **Framework:** Next.js 14 (App Router) + TypeScript
- **Database:** Supabase PostgreSQL (already set up with menuca_v3 schema)
- **Styling:** TailwindCSS + shadcn/ui
- **Auth:** Supabase Auth
- **Forms:** React Hook Form + Zod
- **State:** Zustand + React Query
- **Maps:** Mapbox GL JS (for delivery areas)
- **Charts:** Recharts

### **Scope:**
- 74 restaurants (scaling to 500+)
- 32,000+ customers
- 168 admin features across 11 major sections
- 3 user roles: Master Admin, Restaurant Owner, Staff

---

## 📋 **BUILD INSTRUCTIONS**

### **Step 1: Project Setup (Do First)**
1. Initialize Next.js 14 with App Router + TypeScript
2. Install all dependencies listed in `ULTIMATE_REPLIT_BUILD_PLAN.md` (Section: "Install Additional Dependencies")
3. Initialize shadcn/ui and install all components listed
4. Copy the attached `types/supabase-database.ts` file to `/types/` folder
5. Set up environment variables:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
   ```

### **Step 2: Database Setup**
Run all SQL migrations from `ULTIMATE_REPLIT_BUILD_PLAN.md` Section: "DATABASE SETUP - Step 1: Create New Tables"

This creates 15 new tables:
- order_cancellation_requests
- blacklist
- email_templates
- admin_roles
- restaurant_citations
- restaurant_banners
- restaurant_images
- restaurant_feedback
- restaurant_custom_css
- restaurant_bank_accounts
- restaurant_payment_methods
- restaurant_redirects
- restaurant_charges
- franchises
- franchise_commission_rules

### **Step 3: Build Phase by Phase**

Follow the exact implementation plan from `ULTIMATE_REPLIT_BUILD_PLAN.md`:

**✅ PHASE 1: Authentication & Layout (START HERE)**
Build these files exactly as shown in the build plan:
- `lib/supabase/client.ts` - Supabase browser client
- `lib/supabase/server.ts` - Supabase server client
- `app/(auth)/login/page.tsx` - Login page (code provided)
- `app/(master-admin)/layout.tsx` - Master admin layout (code provided)
- `components/layout/sidebar.tsx` - Sidebar navigation (code provided)
- `components/layout/header.tsx` - Top header
- `middleware.ts` - Route protection

**Test this phase** before moving to Phase 2!

**✅ PHASE 2: Restaurant Management**
Build these components:
- `app/(master-admin)/restaurants/page.tsx` - Restaurant list (code provided)
- `components/restaurant/restaurant-list.tsx` - Restaurant table (code provided)
- `components/restaurant/restaurant-filters.tsx` - Advanced filters
- `app/(master-admin)/restaurants/add/page.tsx` - Add restaurant wizard
- `app/(master-admin)/restaurants/[id]/edit/page.tsx` - Edit restaurant tabs

Implement all 15 restaurant edit sub-tabs listed in the build plan.

**✅ PHASE 3: Dashboard & Analytics**
Build:
- `app/(master-admin)/dashboard/page.tsx` - Dashboard (code provided)
- `components/dashboard/stat-card.tsx` - Stat cards (code provided)
- `components/dashboard/revenue-chart.tsx` - Revenue chart
- `components/dashboard/live-order-feed.tsx` - Real-time orders

Continue with Phases 4-10 as detailed in the build plan...

---

## 🎨 **CRITICAL REQUIREMENTS**

### **TypeScript Usage:**
```typescript
// ✅ ALWAYS use types from supabase-database.ts
import { Database, Restaurant, Dish } from '@/types/supabase-database'

// ✅ ALWAYS type Supabase client
const supabase = createClient<Database>()

// ✅ ALWAYS get full autocomplete
const { data } = await supabase
  .from('restaurants') // ← Autocomplete works!
  .select('*')
```

### **Supabase Queries:**
```typescript
// ✅ Use server-side queries in Server Components
import { createClient } from '@/lib/supabase/server'

// ✅ Use client-side queries in Client Components
import { createClient } from '@/lib/supabase/client'

// ✅ Always handle errors
const { data, error } = await supabase.from('restaurants').select('*')
if (error) {
  console.error('Error:', error)
  return
}
```

### **Component Patterns:**
```typescript
// ✅ Use shadcn/ui components
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'

// ✅ Use Lucide icons
import { Plus, Edit, Trash } from 'lucide-react'

// ✅ Use proper loading states
{isLoading ? <Skeleton /> : <DataTable data={data} />}

// ✅ Use toast notifications
import { useToast } from '@/components/ui/use-toast'
const { toast } = useToast()
toast({ title: 'Success!', description: 'Restaurant created' })
```

### **Form Handling:**
```typescript
// ✅ Use React Hook Form + Zod
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1, 'Name is required'),
  email: z.string().email('Invalid email'),
})

const form = useForm({
  resolver: zodResolver(schema),
})
```

### **Styling:**
```typescript
// ✅ Use TailwindCSS + shadcn/ui
<div className="flex items-center justify-between p-6 bg-white rounded-lg shadow">

// ✅ Use cn() for conditional classes
import { cn } from '@/lib/utils'
<div className={cn('text-sm', isActive && 'font-bold text-red-600')}>
```

---

## 🚨 **IMPORTANT GUIDELINES**

### **DO:**
- ✅ Follow the exact file structure from `ULTIMATE_REPLIT_BUILD_PLAN.md`
- ✅ Use the provided code examples as templates
- ✅ Use TypeScript types from `supabase-database.ts` for EVERYTHING
- ✅ Implement proper error handling
- ✅ Add loading states (Skeleton components)
- ✅ Use toast notifications for feedback
- ✅ Make it mobile responsive
- ✅ Test each phase before moving to the next
- ✅ Ask clarifying questions if anything is unclear

### **DON'T:**
- ❌ Deviate from the provided tech stack
- ❌ Skip the database migrations
- ❌ Hardcode data instead of fetching from Supabase
- ❌ Use plain strings instead of TypeScript types
- ❌ Build features not in the spec
- ❌ Skip error handling
- ❌ Forget loading states

---

## 🎯 **START HERE - FIRST 3 TASKS**

Build these 3 features first (in order):

### **1. Login Page**
File: `app/(auth)/login/page.tsx`
- Copy the complete code from Section "1.2 Login Page" in the build plan
- Test that you can login with a Supabase user
- Verify redirect to dashboard works

### **2. Master Admin Layout**
Files:
- `app/(master-admin)/layout.tsx`
- `components/layout/sidebar.tsx`
- `components/layout/header.tsx`
- Copy the complete code from Section "1.3 Master Admin Layout"
- Test that sidebar navigation works
- Verify user info displays correctly

### **3. Restaurant List**
Files:
- `app/(master-admin)/restaurants/page.tsx`
- `components/restaurant/restaurant-list.tsx`
- `components/restaurant/restaurant-filters.tsx`
- Copy the code from Section "2.1 Restaurant List"
- Fetch real data from `restaurants` table
- Test filters work (province, city, cuisine, status)
- Test that you can see all 74 restaurants

**Once these 3 work, you've proven the architecture! Then continue with the rest.**

---

## 📊 **EXPECTED OUTPUT**

After completing all phases, I should have:

### **Master Admin Dashboard with:**
1. ✅ Login page (with Supabase Auth)
2. ✅ Sidebar navigation (11 main sections)
3. ✅ Dashboard with real-time stats
4. ✅ Restaurant management (list, add, edit, clone)
5. ✅ Restaurant edit with 15 sub-tabs
6. ✅ User management (RBAC system)
7. ✅ Coupon management (regular + email campaigns)
8. ✅ Franchise management (multi-location)
9. ✅ Accounting (statements, commissions, vendor reports)
10. ✅ Blacklist management
11. ✅ Tablet/device management
12. ✅ Content management (cities, cuisines, tags)

### **Key Features:**
- 📱 Mobile responsive
- 🎨 Modern UI (shadcn/ui)
- 🚀 Fast performance (React Query)
- 🔒 Secure (Supabase RLS)
- 📊 Real-time updates (Supabase Realtime)
- 📈 Charts & analytics (Recharts)
- 🗺️ Map integration (Mapbox)
- 📄 PDF generation (jsPDF)

---

## ✅ **SUCCESS CHECKLIST**

I'll know you've succeeded when:

- [ ] I can login with a Supabase admin user
- [ ] The sidebar shows all 11 sections
- [ ] I can see all 74 restaurants in the list
- [ ] Filters work (province, city, cuisine, status)
- [ ] I can click "Add Restaurant" and see a form
- [ ] I can edit a restaurant and see 15 tabs
- [ ] Dashboard shows real order stats from database
- [ ] Charts display real data
- [ ] No TypeScript errors
- [ ] No console errors
- [ ] Mobile responsive (works on tablet)
- [ ] Loading states work
- [ ] Error handling works
- [ ] Toast notifications work

---

## 🚀 **LET'S BUILD!**

You have everything you need:
- ✅ Complete database types (`supabase-database.ts`)
- ✅ Complete technical spec (`ULTIMATE_REPLIT_BUILD_PLAN.md`)
- ✅ Working code examples for every component
- ✅ 10-week roadmap
- ✅ Clear success criteria

**Start with Phase 1 (Authentication & Layout) and work through each phase systematically.**

**Ask questions if you need clarification on any feature!**

**Ready? Let's go! 🔥**

