# 🌿 Supabase Branch Setup for Cursor vs Replit Competition

**Created:** October 21, 2025  
**Purpose:** Create isolated development branches for parallel frontend builds  
**Duration:** 1 week competition  
**Estimated Cost:** ~$50 total (prorated monthly cost)

---

## 🎯 THE PLAN

Create **2 development branches** from production:

```
menuca_v3 (Production - main branch)
  ├── cursor-build (Cursor Composer + Supabase MCP)
  └── replit-build (Replit Agent + Supabase Connector)
```

---

## ✅ BRANCH 1: cursor-build

**Purpose:** Cursor Composer development environment

**Features:**
- Full copy of all 74 production tables
- All migrations applied
- Separate project URL & credentials
- Supabase MCP integration for schema intelligence
- Direct database access from Cursor

**Access:**
```bash
# Once created, you'll get:
Project URL: https://cursor-build-[project-ref].supabase.co
Anon Key: [separate anon key]
Service Role Key: [separate service key]

# Use these in Cursor's .env:
NEXT_PUBLIC_SUPABASE_URL=https://cursor-build-[project-ref].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=[anon-key]
```

---

## ✅ BRANCH 2: replit-build

**Purpose:** Replit Agent development environment

**Features:**
- Full copy of all 74 production tables
- All migrations applied
- Separate project URL & credentials
- Supabase connector for Replit
- Hosted testing environment

**Access:**
```bash
# Once created, you'll get:
Project URL: https://replit-build-[project-ref].supabase.co
Anon Key: [separate anon key]
Service Role Key: [separate service key]

# Use these in Replit's .env:
NEXT_PUBLIC_SUPABASE_URL=https://replit-build-[project-ref].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=[anon-key]
```

---

## 🛠️ CREATION METHODS

### **Option A: Supabase Dashboard (EASIEST)** ✅

1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Select your MenuCA V3 project
3. Click **"Branches"** in sidebar
4. Click **"Create Branch"**
5. Name: `cursor-build`
6. Confirm cost (~$25/month, prorated)
7. Wait ~2-3 minutes for provisioning
8. Copy credentials

9. Repeat for `replit-build`

**This is the recommended method!**

---

### **Option B: Supabase CLI**

```bash
# Install Supabase CLI (if not installed):
brew install supabase/tap/supabase

# Login:
supabase login

# Link to your project:
supabase link --project-ref [your-project-ref]

# Create cursor-build branch:
supabase branches create cursor-build

# Create replit-build branch:
supabase branches create replit-build

# List branches to verify:
supabase branches list
```

---

### **Option C: Supabase MCP (Via Cursor)**

**Note:** The MCP requires cost confirmation through Supabase dashboard first.

```typescript
// Once cost is confirmed in dashboard, you can manage branches via MCP:
- List branches
- Switch between branches
- Merge branches
- Delete branches
```

---

## 📋 AFTER BRANCH CREATION

### **1. Get Branch Credentials**

For each branch, save these to your password manager:

```
Branch Name: cursor-build
Project URL: [from dashboard]
Project Ref: [from dashboard]
Anon Key: [from dashboard]
Service Role Key: [from dashboard]
Database Password: [from dashboard]
```

```
Branch Name: replit-build
Project URL: [from dashboard]
Project Ref: [from dashboard]
Anon Key: [from dashboard]
Service Role Key: [from dashboard]
Database Password: [from dashboard]
```

---

### **2. Create Environment Files**

**For Cursor build (`cursor-build` branch):**

Create `/cursor-frontend/.env.local`:
```bash
# Cursor Build - Development Branch
NEXT_PUBLIC_SUPABASE_URL=https://cursor-build-[ref].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=[cursor-anon-key]
SUPABASE_SERVICE_ROLE_KEY=[cursor-service-key]

# Stripe (use test keys)
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=[stripe-test-pk]
STRIPE_SECRET_KEY=[stripe-test-sk]

# App Config
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

**For Replit build (`replit-build` branch):**

Create environment variables in Replit Secrets:
```bash
NEXT_PUBLIC_SUPABASE_URL=https://replit-build-[ref].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=[replit-anon-key]
SUPABASE_SERVICE_ROLE_KEY=[replit-service-key]

NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=[stripe-test-pk]
STRIPE_SECRET_KEY=[stripe-test-sk]

NEXT_PUBLIC_SITE_URL=[replit-url]
```

---

### **3. Configure Cursor for cursor-build Branch**

In Cursor, update your Supabase MCP config to point to the branch:

```json
// .cursor/mcp.json or wherever your MCP config lives
{
  "supabase": {
    "projectRef": "[cursor-build-ref]",
    "accessToken": "[your-supabase-token]"
  }
}
```

Now Cursor's Supabase MCP will query the **cursor-build branch database**!

---

### **4. Configure Replit for replit-build Branch**

In Replit:

1. Open Secrets panel
2. Add all environment variables listed above
3. Use the **replit-build** credentials
4. Restart your Repl

---

## 🏁 COMPETITION RULES

### **Goal:**
Build the customer ordering app from `CUSTOMER_ORDERING_APP_BUILD_PLAN.md` + `FRONTEND_BUILD_START_HERE.md`

### **Timeline:**
- **Start:** After Phase 0 fixes (2 days)
- **Duration:** 7 days of building
- **End:** Compare results on Day 9

### **Judging Criteria:**

1. **Code Quality (30%)**
   - TypeScript usage
   - Component structure
   - State management
   - Error handling

2. **Feature Completeness (30%)**
   - How many Phase tasks completed?
   - All critical gaps addressed?
   - Guest checkout working?
   - Payment flow complete?

3. **Test Coverage (20%)**
   - Unit tests written?
   - Integration tests?
   - E2E tests?
   - Coverage percentage?

4. **Performance (10%)**
   - Lighthouse scores
   - Bundle size
   - Time to Interactive
   - Core Web Vitals

5. **Developer Experience (10%)**
   - Which was easier to work with?
   - Fewer bugs/issues?
   - Better AI suggestions?
   - Faster iteration?

---

## 🎯 COMPETITION WORKFLOW

### **Day 0-2: Phase 0 Fixes (Together)**

Before the competition starts, complete Phase 0 together:

- [ ] Create `PHASE_0_DATABASE_UPDATES.sql`
- [ ] Apply to **main branch** (production)
- [ ] Test migrations work
- [ ] Then create branches (they'll inherit Phase 0 fixes)

**Why?** Both builds need the same foundation (guest checkout, inventory, security functions)

---

### **Day 3-9: Parallel Building**

**Cursor Track:**
```
Day 3-4: Phase 1-2 (Foundation + Menu Display)
Day 5: Phase 3 (Cart System)
Day 6-7: Phase 4 (Checkout)
Day 8-9: Phase 5 (Payment)
```

**Replit Track:**
```
Day 3-4: Phase 1-2 (Foundation + Menu Display)
Day 5: Phase 3 (Cart System)
Day 6-7: Phase 4 (Checkout)
Day 8-9: Phase 5 (Payment)
```

Both follow same plan, different tools!

---

### **Day 10: Comparison & Decision**

**Compare:**
1. Run both apps side-by-side
2. Test all features
3. Check code quality
4. Review test coverage
5. Measure performance
6. Note any bugs

**Decide:**
- Which build won?
- Merge winner to production
- Delete both branches (cleanup)
- Document lessons learned

---

## 🔄 AFTER COMPETITION

### **Merge Winner:**

```bash
# Via Supabase Dashboard:
1. Go to Branches
2. Select winning branch
3. Click "Merge to Production"
4. Review changes
5. Confirm merge

# This will:
- Apply any new migrations to production
- Deploy any Edge Functions
- Update production schema
```

### **Delete Both Branches:**

```bash
# Via Dashboard:
1. Go to Branches
2. Select cursor-build
3. Click "Delete Branch"
4. Confirm

5. Select replit-build
6. Click "Delete Branch"
7. Confirm

# Stops billing immediately!
```

### **Document Results:**

Create `CURSOR_VS_REPLIT_RESULTS.md` with:
- Which won and why
- Key differences
- Lessons learned
- Future tool choice recommendation

---

## 💰 COST BREAKDOWN

**Expected costs for 1-week competition:**

```
cursor-build branch:
- ~$25/month prorated to 7 days = ~$6
- Compute: $0.01/hour × 168 hours = ~$2
- Storage: Minimal
Total: ~$8

replit-build branch:
- ~$25/month prorated to 7 days = ~$6
- Compute: $0.01/hour × 168 hours = ~$2
- Storage: Minimal
Total: ~$8

TOTAL COMPETITION COST: ~$16-20
```

**You were right - totally worth it for a week! 🎉**

---

## 🚨 IMPORTANT NOTES

### **Data Isolation:**
- Each branch is **completely isolated**
- Changes in cursor-build DON'T affect replit-build
- Neither affects production
- Perfect for parallel development!

### **Schema Sync:**
- Both start with same 74 tables
- If you add tables during competition, they diverge
- That's fine! You're testing approaches
- Winner's schema gets merged

### **No Risk:**
- Production database untouched
- Can delete branches anytime
- Cost stops immediately when deleted
- Zero downside!

---

## 📞 NEED HELP?

**I'm here to:**
- Help with branch creation if CLI fails
- Write Phase 0 fixes before branching
- Coordinate during competition
- Compare results at the end
- Merge winner back to production

---

## ✅ NEXT STEPS

**Right now:**

1. [ ] **Create branches via Supabase Dashboard**
   - Go to dashboard.supabase.com
   - Select MenuCA V3 project
   - Create `cursor-build` branch
   - Create `replit-build` branch

2. [ ] **Save credentials**
   - Copy cursor-build URL + keys
   - Copy replit-build URL + keys
   - Store securely

3. [ ] **Configure environments**
   - Setup Cursor with cursor-build credentials
   - Setup Replit with replit-build credentials

4. [ ] **Verify connection**
   - Test Cursor can connect to cursor-build
   - Test Replit can connect to replit-build

5. [ ] **Complete Phase 0 fixes** (together, on main branch)

6. [ ] **Start competition!** 🏁

---

**Let's do this! May the best tool win! 🚀**

**P.S.** Once you create the branches in the dashboard, share the credentials and we'll configure both environments properly!

