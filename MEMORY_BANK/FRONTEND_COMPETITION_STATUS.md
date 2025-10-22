# 🥊 Frontend Build Competition - Status & Environment

**Created:** October 22, 2025  
**Status:** 🟡 SETUP IN PROGRESS  
**Phase:** Phase 0 (Pre-Build Database Fixes)

---

## 🎯 COMPETITION OVERVIEW

**Goal:** Determine best tool for building MenuCA V3 customer ordering frontend

**Competitors:**
- 🔵 **Cursor** (with Supabase MCP + Composer)
- 🟢 **Replit** (with Supabase connector)

**Timeline:** 7-10 days from Phase 0 completion

**Prize:** Winning tool becomes primary development environment for all future frontend work

---

## 🗄️ DATABASE ENVIRONMENT SETUP

### **CRITICAL: Dual Database Strategy** ⚠️

**We are using TWO separate database instances for the competition:**

#### **1. cursor-build Branch (Cursor Environment)** 🔵
```
Branch ID: 483e8dde-2cfc-4e7e-913d-acb92117b30d
Branch Name: cursor-build
Status: FUNCTIONS_DEPLOYED ✅
Created: 2025-10-22 14:01:24 UTC
Purpose: Isolated development environment for Cursor
```

**Characteristics:**
- ✅ Completely isolated preview branch
- ✅ Full copy of all 74 production tables
- ✅ All Edge Functions deployed
- ✅ Separate credentials (URL, anon key, service key)
- ✅ Safe to break/test - no production impact
- ✅ Serves as backup snapshot of production

**Get Credentials:**
1. Go to: https://supabase.com/dashboard
2. Select branch: **cursor-build** (from dropdown)
3. Settings → API
4. Copy: Project URL, anon key, service_role key

**Usage:**
- Cursor Composer connects to this branch
- Cursor Supabase MCP points to this branch
- All Cursor frontend development uses this

---

#### **2. Production/Main Branch (Replit Environment)** 🟢
```
Project Ref: nthpbtdjhhnwfxqsxbvy
Project URL: https://nthpbtdjhhnwfxqsxbvy.supabase.co
Status: Active (main production branch)
Purpose: Development environment for Replit
```

**Characteristics:**
- ⚠️ Main production database
- ✅ Can be modified (no live frontend yet!)
- ✅ Backed up by cursor-build snapshot
- ✅ Low risk - no customers using it
- ✅ Can restore from cursor-build if needed

**Get Credentials:**
1. Go to: https://supabase.com/dashboard
2. Ensure you're viewing **production** (main branch)
3. Settings → API
4. Copy: Project URL, anon key, service_role key

**Usage:**
- Replit connects to this database
- All Replit frontend development uses this
- If broken, restore from cursor-build

---

## ✅ WHY THIS STRATEGY IS SAFE

**User's Brilliant Insight:**
> "We technically have 2 branches now then right? We have production the OG DB and now the Cursor branch. If Replit nukes production we still have the cursor branch right? So no risk I can see as we dont have a front end to disrupt yet right?"

**Risk Analysis:**

✅ **No Live Frontend Yet**
- No customers using the platform
- No production traffic
- No live orders being processed
- Perfect time to test aggressively

✅ **cursor-build is Complete Backup**
- Full snapshot of production at competition start
- All 74 tables copied
- All data preserved
- Can restore in 10 minutes if needed

✅ **Isolated Environments**
- Cursor changes DON'T affect Replit
- Replit changes DON'T affect Cursor
- True parallel development

✅ **Recovery Options**
- If Replit breaks production → Restore from cursor-build
- If Cursor breaks branch → Delete and recreate
- If both break → Restore production from cursor-build snapshot
- Worst case: 10 minutes to restore

---

## 🚨 CRITICAL RULES

### **NEVER Confuse the Two Databases!**

**When working in Cursor:**
- ✅ ALWAYS use cursor-build credentials
- ✅ ALWAYS verify Supabase MCP points to cursor-build
- ✅ ALWAYS check `.env.local` has cursor-build URL
- ❌ NEVER accidentally connect Cursor to production

**When working in Replit:**
- ✅ ALWAYS use production credentials
- ✅ ALWAYS verify environment variables in Replit Secrets
- ✅ ALWAYS check connection URL is `nthpbtdjhhnwfxqsxbvy`
- ❌ NEVER accidentally connect Replit to cursor-build

**How to Verify:**
```bash
# In Cursor project:
cat .env.local | grep SUPABASE_URL
# Should contain cursor-build ref, NOT nthpbtdjhhnwfxqsxbvy

# In Replit:
echo $NEXT_PUBLIC_SUPABASE_URL
# Should be https://nthpbtdjhhnwfxqsxbvy.supabase.co
```

---

## 📋 COMPETITION PHASES

### **Phase 0: Pre-Build Fixes (CURRENT)** 🟡

**Status:** In Progress  
**Duration:** 2 days  
**Applies To:** BOTH environments (via main branch)

**Critical Database Updates Required:**

1. **Guest Checkout Support** 🔴 CRITICAL
   - Add guest order fields to `menuca_v3.orders`
   - Allow orders without user_id FK
   - Store guest email/phone for notifications

2. **Real-Time Inventory** 🔴 CRITICAL
   - Create `menuca_v3.dish_inventory` table
   - Add `check_cart_availability()` function
   - Prevent ordering unavailable items

3. **Server-Side Price Validation** 🔴 CRITICAL
   - Create `calculate_order_total()` function
   - Never trust client-sent prices
   - Recalculate on server before Stripe payment

4. **Order Cancellation** 🟡 HIGH
   - Create `cancel_customer_order()` function
   - Handle Stripe refunds
   - Update order status workflow

**Deliverables:**
- [ ] `PHASE_0_DATABASE_UPDATES.sql`
- [ ] `STATE_MANAGEMENT_RULES.md`
- [ ] `SECURITY_CHECKLIST.md`
- [ ] `TESTING_STRATEGY.md`

**Application:**
- Run migrations on **production (main branch)**
- cursor-build inherits updates automatically
- Both environments ready to build

---

### **Phase 1-9: Parallel Building** 🏗️

**Status:** Not Started  
**Duration:** 7-10 days  
**Mode:** Parallel development

**Cursor Track (on cursor-build):**
- Phase 1: Foundation (Day 1-2)
- Phase 2: Restaurant Menu Display (Day 3-4)
- Phase 3: Cart System (Day 5)
- Phase 4: Checkout Flow (Day 6-7)
- Phase 5: Payment Integration (Day 8-9)
- Phase 6-9: Additional features

**Replit Track (on production):**
- Same phases, same timeline
- Different tool, different approach
- Independent from Cursor

**No Coordination Needed:**
- Each environment is isolated
- Build freely without conflicts
- Compare at the end

---

### **Phase 10: Comparison & Winner** 🏆

**Status:** Not Started  
**Duration:** 1 day  
**Criteria:**

1. **Code Quality (30%)**
   - TypeScript usage
   - Component structure
   - State management
   - Error handling

2. **Feature Completeness (30%)**
   - Tasks completed from plan
   - Critical gaps addressed
   - Guest checkout working
   - Payment flow secure

3. **Test Coverage (20%)**
   - Unit tests present
   - Integration tests
   - E2E tests
   - Coverage percentage

4. **Performance (10%)**
   - Lighthouse scores
   - Bundle size
   - Load times
   - Core Web Vitals

5. **Developer Experience (10%)**
   - Ease of use
   - AI assistance quality
   - Fewer bugs/issues
   - Iteration speed

---

## 📁 KEY FILES

### **Competition Documentation:**
- `/FRONTEND_BUILD_START_HERE.md` - Gap analysis from Cognition Wheel
- `/CUSTOMER_ORDERING_APP_BUILD_PLAN.md` - Original 58-task build plan
- `/FULL_STACK_BUILD_GUIDE.md` - Frontend-to-backend mapping
- `/COMPLETE_PLATFORM_OVERVIEW.md` - Both platforms documented
- `/BRANCH_SETUP_GUIDE.md` - Branch creation guide
- `/COMPETITION_ENVIRONMENT_SETUP.md` - Credentials and setup
- `/CREATE_BRANCHES.sh` - Automated branch creation script

### **Phase 0 Files (To Be Created):**
- `/PHASE_0_DATABASE_UPDATES.sql` - Critical database migrations
- `/STATE_MANAGEMENT_RULES.md` - Zustand vs React Query
- `/SECURITY_CHECKLIST.md` - Server-side validation rules
- `/TESTING_STRATEGY.md` - What/how to test

---

## 🎯 CURRENT STATUS

**Environment Setup:**
- ✅ cursor-build branch created
- ✅ Production branch ready
- ✅ Dual database strategy documented
- ⏳ Waiting for cursor-build credentials
- ⏳ Phase 0 database updates (next)

**Immediate Next Steps:**
1. Get cursor-build credentials from Supabase dashboard
2. Get production credentials from Supabase dashboard
3. Write Phase 0 database updates
4. Apply Phase 0 to main branch
5. Verify both branches have updates
6. **START COMPETITION!**

---

## 🚨 IMPORTANT REMINDERS

### **For Future AI Agents Working on Frontend:**

1. **Check which database you're working with!**
   - Cursor = cursor-build branch
   - Replit = production branch

2. **Never mix credentials!**
   - Each tool has its own environment
   - Use correct .env for each tool

3. **cursor-build is the backup!**
   - If production breaks, restore from cursor-build
   - cursor-build is snapshot from competition start

4. **No live frontend yet = Safe to test**
   - No customers affected
   - No production impact
   - Perfect time for aggressive testing

5. **Phase 0 MUST complete before building**
   - Guest checkout required
   - Server-side validation required
   - Inventory checking required
   - Testing strategy required

---

## 🔗 Quick Links

**Supabase Dashboard:** https://supabase.com/dashboard  
**Cursor-build Branch:** Switch branch dropdown → cursor-build  
**Production Branch:** Switch branch dropdown → production (main)  
**Branch Status:** Run `supabase branches list --experimental`

---

**Last Updated:** 2025-10-22 14:05 UTC  
**Next Update:** After Phase 0 completion  
**Status:** 🟡 Phase 0 in progress - Awaiting credentials and database updates

