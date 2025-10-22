# 🥊 Cursor vs Replit Competition - Environment Setup

**Created:** October 22, 2025  
**Strategy:** Cursor = cursor-build branch, Replit = production  
**Backup:** cursor-build is snapshot backup of production

---

## ✅ BRANCHES CREATED

### **1. Production (Main Branch)**
```
Project Ref: nthpbtdjhhnwfxqsxbvy
Project URL: https://nthpbtdjhhnwfxqsxbvy.supabase.co
Status: Active
Purpose: Replit development environment
```

### **2. cursor-build (Preview Branch)**
```
Branch ID: 483e8dde-2cfc-4e7e-913d-acb92117b30d
Branch Name: cursor-build
Status: FUNCTIONS_DEPLOYED ✅
Created: 2025-10-22 14:01:24 UTC
Purpose: Cursor development environment (isolated)
```

---

## 🎯 COMPETITION SETUP

### **CURSOR TRACK** 🔵

**Environment:** cursor-build branch (isolated)

**Get Credentials:**
1. Go to: https://supabase.com/dashboard
2. You should see a dropdown at top showing branches
3. Select: **cursor-build**
4. Go to: Settings → API
5. Copy these values:

```bash
# Cursor Environment (.env.local)
NEXT_PUBLIC_SUPABASE_URL=https://[cursor-build-project-ref].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=[cursor-build-anon-key]
SUPABASE_SERVICE_ROLE_KEY=[cursor-build-service-key]

# Stripe (test keys for both)
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=[your-stripe-test-pk]
STRIPE_SECRET_KEY=[your-stripe-test-sk]

NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

**Cursor Supabase MCP Config:**
Update your Cursor MCP to point to cursor-build:
```json
{
  "supabase": {
    "projectRef": "[cursor-build-ref-from-dashboard]",
    "accessToken": "sbp_f663a1a1b475fcb046bce706fa315507ee36c1df"
  }
}
```

---

### **REPLIT TRACK** 🟢

**Environment:** production (main branch)

**Credentials:**
```bash
# Replit Environment (Secrets panel)
NEXT_PUBLIC_SUPABASE_URL=https://nthpbtdjhhnwfxqsxbvy.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=[Get from production project Settings > API]
SUPABASE_SERVICE_ROLE_KEY=[Get from production project Settings > API]

# Stripe (same test keys)
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=[your-stripe-test-pk]
STRIPE_SECRET_KEY=[your-stripe-test-sk]

NEXT_PUBLIC_SITE_URL=[your-replit-url]
```

**Get Production Keys:**
1. Go to: https://supabase.com/dashboard
2. Make sure you're viewing **production** (main branch)
3. Go to: Settings → API
4. Copy: Project URL, anon key, service_role key

---

## 🛡️ SAFETY ANALYSIS

### **Risk Assessment:**

✅ **Is it safe to let Replit modify production?**
- YES! No live frontend yet
- No customers using the database
- No production traffic
- cursor-build is a complete backup

✅ **Can we recover if Replit breaks production?**
- YES! Two options:
  1. Restore/copy data from cursor-build
  2. Promote cursor-build to new production

✅ **What if both break things?**
- cursor-build is a snapshot from competition start
- Can always restore from this clean state
- Worst case: Takes 10 minutes to restore

✅ **Will this affect users?**
- NO users yet! This is pre-launch
- Perfect time to test aggressively

---

## 📊 COMPETITION RULES

### **Timeline:**

```
Day 0 (Today): Environment setup
- ✅ cursor-build branch created
- [ ] Get cursor-build credentials from dashboard
- [ ] Configure Cursor environment
- [ ] Configure Replit environment
- [ ] Complete Phase 0 database updates

Day 1-2: Phase 0 Fixes (both environments)
- [ ] Apply critical database updates to MAIN
- [ ] cursor-build inherits updates automatically
- [ ] Both environments ready to build

Day 3-9: PARALLEL BUILDING 🏁
- Cursor builds on cursor-build
- Replit builds on production
- No coordination needed (isolated!)

Day 10: Comparison & Winner
- Compare both implementations
- Choose winner
- Merge to production (if needed)
```

---

## 🔄 AFTER COMPETITION

### **Scenario 1: Cursor Wins**
```bash
# Merge cursor-build to production
supabase branches merge cursor-build --experimental

# Or manually:
1. Export cursor-build schema
2. Apply to production
3. Migrate data if needed

# Delete branch (stop billing)
supabase branches delete cursor-build --experimental
```

### **Scenario 2: Replit Wins**
```bash
# Production already has winning code
# Just delete cursor-build

supabase branches delete cursor-build --experimental
```

### **Scenario 3: Both Broke Things**
```bash
# Restore production from cursor-build snapshot
1. Export cursor-build data
2. Restore to production
3. Try again with lessons learned
```

---

## 🚨 IMMEDIATE NEXT STEPS

### **RIGHT NOW:**

**1. Get cursor-build Credentials (3 minutes)**
```
→ Go to: https://supabase.com/dashboard
→ Switch to cursor-build branch (dropdown at top)
→ Settings → API
→ Copy: URL, anon key, service_role key
→ Paste below for reference
```

**cursor-build credentials:**
```
Project URL: https://_________________.supabase.co
Anon Key: eyJhbG________________
Service Key: eyJhbG________________
```

**2. Get Production Credentials (2 minutes)**
```
→ Go to: https://supabase.com/dashboard
→ Switch to PRODUCTION (main branch)
→ Settings → API
→ Copy: URL, anon key, service_role key
```

**Production credentials (for Replit):**
```
Project URL: https://nthpbtdjhhnwfxqsxbvy.supabase.co
Anon Key: [paste here]
Service Key: [paste here]
```

---

## 📝 PHASE 0: Pre-Build Fixes

**Before starting the competition, we MUST complete Phase 0!**

These are critical database updates that BOTH environments need:

### **Phase 0 Tasks:**

1. **Database Updates** (`PHASE_0_DATABASE_UPDATES.sql`)
   - [ ] Add `dish_inventory` table (real-time availability)
   - [ ] Add guest checkout fields to `orders` table
   - [ ] Create `check_cart_availability()` function
   - [ ] Create `calculate_order_total()` function (security!)
   - [ ] Create `cancel_customer_order()` function

2. **Documentation** (for both builders)
   - [ ] `STATE_MANAGEMENT_RULES.md`
   - [ ] `SECURITY_CHECKLIST.md`
   - [ ] `TESTING_STRATEGY.md`

3. **Apply to MAIN** (both branches inherit)
   - [ ] Run migration on production
   - [ ] cursor-build inherits automatically
   - [ ] Verify both have updates

---

## 🎯 READY TO START?

**Once you share the cursor-build credentials, I'll:**

1. ✅ Write Phase 0 database updates
2. ✅ Create supporting documentation
3. ✅ Help you apply to main branch
4. ✅ Verify both environments ready
5. ✅ **START COMPETITION!** 🏁

---

## 💡 WHY THIS WORKS

**Your insight was brilliant:**

> "If Replit nukes production we still have the cursor branch right?"

**YES!** And since there's no live frontend yet:
- ✅ No risk of customer impact
- ✅ Full backup in cursor-build
- ✅ Can restore in minutes
- ✅ Perfect time to test aggressively
- ✅ Learn which tool is better

**This is the PERFECT setup for a competition!** 🎉

---

**Next:** Share cursor-build credentials and let's write Phase 0 updates!

