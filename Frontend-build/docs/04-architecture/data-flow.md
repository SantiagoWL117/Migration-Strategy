# Orchestrator Agent - Full Context Handoff

**Role:** You are the Orchestrator Agent managing the Frontend Build project.

**Date:** October 22, 2025

---

## 🎯 Mission

Build a production-ready frontend for the menuca_v3 platform using:
- **Database:** menuca_v3 (PostgreSQL + PostGIS on Supabase)
- **Backend:** 50+ SQL functions + 29 Edge Functions (already deployed)
- **Frontend:** Next.js 14 + TypeScript + TailwindCSS + shadcn/ui
- **Strategy:** Fix critical database gaps (Phase 0) BEFORE building UI

---

## 📊 Current Status

### Phase 0: Pre-Build Database Fixes (5 Tickets)

| Ticket | Status | Description |
|--------|--------|-------------|
| 01 | ✅ IMPLEMENTED, 🔍 AWAITING AUDIT | Guest checkout support |
| 02 | 📋 READY | Real-time inventory system |
| 03 | 📋 READY | Server-side price validation |
| 04 | 📋 READY | Order cancellation & refunds |
| 05 | 📋 READY | Complex modifier validation |

**Next Action:** Start Auditor Agent to review Ticket 01 implementation

---

## 🔄 Multi-Agent Workflow

```
YOU (Orchestrator)
    ↓ Creates ticket with full specs
Builder Agent (new chat)
    ↓ Implements migration, creates handoff
Auditor Agent (new chat)
    ↓ Reviews implementation, creates audit
YOU (Orchestrator)
    ↓ Reviews audit, decides next action:
        → APPROVED: Assign next ticket to builder
        → NEEDS FIXES: Send back to builder with fixes
        → REJECTED: Major rework needed
```

### Why This Pattern?
- **Files preserve context** (not chat history)
- **Each role has clear responsibility**
- **Quality gates** (nothing proceeds without audit)
- **Everything documented** in `/INDEX/NORTH_STAR.md`

---

## 📚 Critical Knowledge

### Phase 0 Origin (CRITICAL CONTEXT)

The frontend build plan was reviewed by **Cognition Wheel MCP** (3 AI models: Claude Opus, Gemini 2.0 Pro, GPT-4) which identified **14 critical gaps** in the database schema that would cause frontend bugs:

**Gap Analysis File:** `/DOCUMENTATION/FRONTEND_BUILD_START_HERE.md`

**The 5 Most Critical Gaps → Phase 0 Tickets:**

1. **Guest Checkout Missing** (Security Risk)
   - Problem: `orders.user_id` is NOT NULL
   - Impact: 40% of customers lost (can't order without account)
   - Fix: Add `is_guest_order`, `guest_email`, `guest_phone` columns

2. **No Inventory System** (Overselling Risk)
   - Problem: No `dish_inventory` table exists
   - Impact: Sell 100 pizzas when only 20 ingredients available
   - Fix: Create inventory table + `check_cart_availability()` function

3. **Price Validation Client-Side Only** (Revenue Loss)
   - Problem: No server-side price validation
   - Impact: Customers can manipulate prices ($50 order → $5)
   - Fix: Create `calculate_order_total()` SQL function

4. **No Cancellation System** (Customer Service Nightmare)
   - Problem: No way to cancel orders or process refunds
   - Impact: Manual refunds, angry customers, revenue disputes
   - Fix: Create `cancel_customer_order()` function with refund logic

5. **No Modifier Validation** (Order Fulfillment Failures)
   - Problem: No validation for required modifiers (size, add-ons)
   - Impact: "Large pizza" ordered with no size → kitchen can't fulfill
   - Fix: Create `modifier_groups` table + `validate_dish_modifiers()` function

**These MUST be fixed before building UI** or the frontend will be broken from day 1.

---

## 🗂️ Project Structure

### Workspace Layout
```
/Frontend-build/                      ← WORKSPACE ROOT (open in Cursor)
│
├── ORCHESTRATOR_CONTEXT.md           ← YOU ARE HERE (full context)
├── START_HERE.md                     ← Quick start guide
│
├── INDEX/
│   └── NORTH_STAR.md                 ← Master tracker (UPDATE ALWAYS)
│
├── DOCUMENTATION/
│   ├── FRONTEND_BUILD_START_HERE.md  ← Cognition Wheel gap analysis
│   ├── COMPETITION_ENVIRONMENT_SETUP.md  ← Cursor vs Replit setup
│   └── BRANCH_SETUP_GUIDE.md         ← Supabase branches
│
├── TICKETS/                          ← All 5 Phase 0 tickets (you created these)
│   ├── PHASE_0_01_GUEST_CHECKOUT_TICKET.md      (~300 lines, SQL migration)
│   ├── PHASE_0_02_INVENTORY_SYSTEM_TICKET.md    (~350 lines, table + function)
│   ├── PHASE_0_03_PRICE_VALIDATION_TICKET.md    (~280 lines, function)
│   ├── PHASE_0_04_CANCELLATION_SYSTEM_TICKET.md (~320 lines, function)
│   └── PHASE_0_05_MODIFIER_VALIDATION_TICKET.md (~340 lines, table + function)
│
├── HANDOFFS/                         ← Builder outputs
│   └── PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md  ← Latest from builder
│
└── AUDITS/                           ← Auditor outputs
    └── (Awaiting first audit)
```

---

## 🎓 Backend Knowledge You Need

### Production Database: menuca_v3 (Supabase)
- **Project:** nthpbtdjhhnwfxqsxbvy.supabase.co
- **Connection:** Supabase CLI linked to production
- **Extensions:** PostGIS 3.3.7, pgcrypto, uuid-ossp
- **RLS:** Enabled on all tables
- **Data:** 959 restaurants, 917 locations, 693 contacts

### API Documentation (Absolute Paths)
```
/Users/brianlapp/Documents/GitHub/Migration-Strategy/documentation/Frontend-Guides/
├── BRIAN_MASTER_INDEX.md             ← Master hub (start here)
├── 01-Restaurant-Management-Frontend-Guide.md  ← 11 components, 430 lines
└── Restaurant Management/
    ├── 01-Franchise-Chain-Hierarchy.md        (692 lines)
    ├── 02-Soft-Delete-Infrastructure.md       (312 lines)
    ├── 03-Status-Online-Toggle.md             (369 lines)
    ├── 04-Status-Audit-Trail.md               (320 lines)
    ├── 05-Contact-Management.md               (553 lines)
    ├── 06-PostGIS-Delivery-Zones.md           (1,489 lines)
    ├── 07-SEO-Full-Text-Search.md             (374 lines)
    ├── 08-Categorization-System.md            (516 lines)
    ├── 09-Onboarding-Status-Tracking.md       (554 lines)
    ├── 10-Restaurant-Onboarding-System.md     (579 lines)
    └── 11-Domain-Verification-SSL.md          (411 lines)
```

**Total:** 50+ SQL functions, 29 Edge Functions, 6,169 lines of API docs

### Memory Bank (Project Context)
```
/Users/brianlapp/Documents/GitHub/Migration-Strategy/MEMORY_BANK/
├── PROJECT_CONTEXT.md                ← Project overview
├── PROJECT_STATUS.md                 ← Current status of all entities
├── ETL_METHODOLOGY.md                ← Migration methodology
├── NEXT_STEPS.md                     ← Immediate priorities
├── ENTITIES/                         ← 12 entity status files
│   ├── RESTAURANT_MANAGEMENT.md      ← COMPLETE
│   ├── LOCATION_GEOGRAPHY.md         ← COMPLETE
│   ├── SERVICE_CONFIGURATION.md      ← Blocked
│   ├── DELIVERY_OPERATIONS.md        ← Ready
│   ├── MENU_CATALOG.md               ← Blocked
│   ├── ORDERS_CHECKOUT.md            ← Blocked
│   ├── PAYMENTS.md                   ← Blocked
│   ├── USERS_ACCESS.md               ← HIGH PRIORITY
│   ├── MARKETING_PROMOTIONS.md       ← Blocked
│   ├── ACCOUNTING_REPORTING.md       ← Blocked
│   ├── VENDORS_FRANCHISES.md         ← Blocked
│   └── DEVICES_INFRASTRUCTURE.md     ← Blocked
└── COMPLETED/
    └── LOCATION_GEOGRAPHY_COMPLETE.md
```

---

## 🏗️ Phase 0 Ticket Details

### Ticket 01: Guest Checkout (✅ IMPLEMENTED, 🔍 AWAITING AUDIT)

**File:** `/TICKETS/PHASE_0_01_GUEST_CHECKOUT_TICKET.md`

**What Was Implemented:**
```sql
-- Add columns for guest checkout
ALTER TABLE menuca_v3.orders
  ADD COLUMN is_guest_order BOOLEAN DEFAULT FALSE NOT NULL,
  ADD COLUMN guest_email VARCHAR(255),
  ADD COLUMN guest_phone VARCHAR(20);

-- Make user_id nullable (allow guest orders)
ALTER TABLE menuca_v3.orders
  ALTER COLUMN user_id DROP NOT NULL;

-- CHECK constraint - guest orders must have email
ALTER TABLE menuca_v3.orders
  ADD CONSTRAINT orders_guest_email_check 
  CHECK (
    (is_guest_order = FALSE) OR 
    (is_guest_order = TRUE AND guest_email IS NOT NULL)
  );

-- Index for guest email lookups
CREATE INDEX idx_orders_guest_email 
  ON menuca_v3.orders(guest_email) 
  WHERE is_guest_order = TRUE;
```

**Handoff File:** `/HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md`

**Builder Agent's Report:**
- ✅ All columns added successfully
- ✅ user_id made nullable
- ✅ CHECK constraint created and tested
- ✅ Partial index created (guest orders only)
- ✅ Comments added to all columns
- ✅ Migration is idempotent (can run multiple times safely)

**Known Limitations:**
1. No email validation (regex constraint not added)
2. No phone format validation
3. No guest order cleanup strategy (GDPR compliance)

**Questions for Auditor:**
1. Should we add email format validation?
2. Should we add phone format validation?
3. Should we add TTL for guest data (auto-delete after 90 days)?

---

### Ticket 02: Real-Time Inventory System (📋 READY)

**File:** `/TICKETS/PHASE_0_02_INVENTORY_SYSTEM_TICKET.md`

**Purpose:** Track dish availability in real-time to prevent overselling

**Implementation:**
1. Create `dish_inventory` table
2. Create `check_cart_availability()` SQL function
3. Add triggers to update inventory on orders

**Business Impact:**
- Prevents selling 100 pizzas when only 20 available
- Real-time stock updates
- Automatic "out of stock" display

**Estimated Lines:** ~200 SQL, ~150 docs = ~350 total

---

### Ticket 03: Server-Side Price Validation (📋 READY)

**File:** `/TICKETS/PHASE_0_03_PRICE_VALIDATION_TICKET.md`

**Purpose:** Prevent price manipulation attacks ($50 order → $5)

**Implementation:**
1. Create `calculate_order_total()` SQL function
2. Server validates ALL prices before payment
3. Frontend NEVER trusted for pricing

**Security Impact:**
- **Critical:** Prevents revenue loss from price manipulation
- Industry standard: Never trust client-side pricing
- Example attack: Browser DevTools → Change $50 to $5 → Checkout

**Estimated Lines:** ~150 SQL, ~130 docs = ~280 total

---

### Ticket 04: Order Cancellation & Refunds (📋 READY)

**File:** `/TICKETS/PHASE_0_04_CANCELLATION_SYSTEM_TICKET.md`

**Purpose:** Allow customers to cancel orders and process refunds

**Implementation:**
1. Create `cancel_customer_order()` SQL function
2. Handle refund logic (full/partial)
3. Update order status to 'cancelled'
4. Notify restaurant and customer

**Business Impact:**
- Reduces customer service burden (manual refunds = 30min each)
- Improves customer satisfaction (instant cancellation)
- Prevents revenue disputes

**Estimated Lines:** ~180 SQL, ~140 docs = ~320 total

---

### Ticket 05: Complex Modifier Validation (📋 READY)

**File:** `/TICKETS/PHASE_0_05_MODIFIER_VALIDATION_TICKET.md`

**Purpose:** Validate required modifiers (size, toppings, etc.)

**Implementation:**
1. Create `modifier_groups` table (size, extras, etc.)
2. Create `validate_dish_modifiers()` SQL function
3. Enforce required modifiers at database level

**Business Impact:**
- Prevents "Large pizza" orders with no size selected
- Kitchen can't fulfill orders without complete info
- Reduces order fulfillment failures

**Estimated Lines:** ~190 SQL, ~150 docs = ~340 total

---

## 🎯 Your Immediate Tasks

### Task 1: Start Auditor Agent for Ticket 01

**Create new Cursor Agent chat with this prompt:**

```
You are the Auditor Agent for the Frontend Build project.

Your job: Audit Phase 0 Ticket 01 (Guest Checkout) implementation.

Read these files:
1. /TICKETS/PHASE_0_01_GUEST_CHECKOUT_TICKET.md
2. /HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md

Verify the implementation meets all requirements.

Create audit report: /AUDITS/PHASE_0_01_GUEST_CHECKOUT_AUDIT.md

Use this template:
```markdown
# AUDIT REPORT: Guest Checkout Implementation

## Ticket Reference
PHASE_0_01_GUEST_CHECKOUT_TICKET.md

## Executive Summary
[PASS/FAIL] - Brief verdict

## Requirements Verification
- [ ] is_guest_order column added (BOOLEAN, NOT NULL, DEFAULT FALSE)
- [ ] guest_email column added (VARCHAR(255))
- [ ] guest_phone column added (VARCHAR(20))
- [ ] user_id made nullable (was NOT NULL, now allows NULL)
- [ ] CHECK constraint orders_guest_email_check works correctly
- [ ] Partial index idx_orders_guest_email created (WHERE is_guest_order = TRUE)
- [ ] Comments added to all new columns
- [ ] Migration is idempotent (can run multiple times without errors)

## Testing Results
[Test each requirement above]

## Issues Found
1. [Issue description with severity: CRITICAL/HIGH/MEDIUM/LOW]
2. [Issue description]

## Recommendations
- [Recommendation 1]
- [Recommendation 2]

## Security Concerns
- [Any security issues]

## Performance Impact
- [Index effectiveness]
- [Query performance]

## Verdict
✅ APPROVED - Ready for production
⚠️ NEEDS FIXES - Minor issues (list them)
❌ REJECTED - Major rework required

---
Auditor: [AI Model Name]
Date: [Date]
```

After audit completes, come back to me (Orchestrator) with the audit file path.
```

---

### Task 2: After Audit, Decide Next Action

**If Audit = ✅ APPROVED:**
1. Update `/INDEX/NORTH_STAR.md`:
   - Ticket 01: IN PROGRESS → COMPLETED
   - Ticket 02: READY → IN PROGRESS
2. Start Builder Agent for Ticket 02
3. Provide builder with ticket file and context

**If Audit = ⚠️ NEEDS FIXES:**
1. Update `/INDEX/NORTH_STAR.md` with "Needs Fixes" status
2. Start Builder Agent with:
   - Original ticket
   - Audit report with fixes needed
   - Instructions to fix issues

**If Audit = ❌ REJECTED:**
1. Update `/INDEX/NORTH_STAR.md` with "Rejected" status
2. Start Builder Agent with:
   - Original ticket
   - Audit report with rejection reasons
   - Instructions for complete rework

---

### Task 3: Repeat for Tickets 02-05

**Workflow Loop:**
```
FOR EACH ticket (02, 03, 04, 05):
  1. Assign to Builder Agent
  2. Builder creates handoff
  3. Assign to Auditor Agent
  4. Auditor creates audit
  5. You review audit
  6. IF approved:
       Mark complete
       Move to next ticket
     ELSE:
       Send back to builder with fixes
```

---

## 📋 Orchestrator Responsibilities

### Before Starting Each Ticket
1. ✅ Read ticket file thoroughly
2. ✅ Check dependencies (blocking issues?)
3. ✅ Verify database state (migrations applied?)
4. ✅ Update `/INDEX/NORTH_STAR.md` (mark as IN PROGRESS)

### During Implementation (Builder Agent Working)
1. ✅ Monitor for questions
2. ✅ Provide context if builder asks
3. ✅ Review handoff when complete

### During Audit (Auditor Agent Working)
1. ✅ Wait for audit report
2. ✅ Review audit thoroughly
3. ✅ Make decision (APPROVED/FIXES/REJECTED)

### After Each Ticket Completes
1. ✅ Update `/INDEX/NORTH_STAR.md`
2. ✅ Archive handoff and audit
3. ✅ Move to next ticket
4. ✅ Commit changes to git

---

## 🚨 Critical Rules

### Golden Rules
1. **NEVER skip the audit step** - Quality gates prevent bugs
2. **ALWAYS update `/INDEX/NORTH_STAR.md`** - Single source of truth
3. **ALWAYS read handoffs before deciding** - Builder may have insights
4. **NEVER move to next ticket before audit** - Prevents cascading failures

### Quality Standards
- **Idempotent migrations** - Can run multiple times safely
- **Schema comments** - Every column must have purpose documented
- **Indexes** - Every foreign key and search field must be indexed
- **Constraints** - Validate data at database level (never trust frontend)

### Communication Pattern
- **Tickets** = Specs (what to build)
- **Handoffs** = Results (what was built)
- **Audits** = Quality (was it built correctly?)
- **NORTH_STAR.md** = Truth (current state)

---

## 🎓 Context You Should Know

### Why Phase 0 Exists
The original build plan had **167 frontend features** planned, but the Cognition Wheel AI team (3 models) found **14 critical database gaps** that would cause bugs from day 1.

**Original Plan:** Build UI → Encounter bugs → Fix database → Rebuild UI (slow, expensive)

**Phase 0 Plan:** Fix database → Build UI on solid foundation (fast, stable)

### Why Multi-Agent Pattern
**Problem:** Single agent loses context after 100+ tool calls, makes mistakes

**Solution:** 
- **Orchestrator** (you) = Strategic thinking, decision making
- **Builder** (helper) = Tactical execution, implementation
- **Auditor** (helper) = Quality assurance, verification

**Result:** Each agent stays focused, files preserve context, no mistakes

### Competition Context
This frontend build is part of a **Cursor vs Replit competition**:
- **Cursor:** Uses this multi-agent orchestration workflow
- **Replit:** Traditional single-agent approach
- **Goal:** See which produces better code faster

**Your Advantage:** 
- Structured workflow
- Quality gates (audits)
- File-based context preservation
- Access to 50+ pre-built SQL functions

---

## 📖 Key Files to Reference

### Always Have Open
1. `/INDEX/NORTH_STAR.md` - Current progress
2. Current ticket file
3. Latest handoff/audit

### Reference As Needed
1. `/DOCUMENTATION/FRONTEND_BUILD_START_HERE.md` - Gap analysis
2. API guides (absolute paths above)
3. Memory Bank (absolute paths above)

### Update After Every Step
1. `/INDEX/NORTH_STAR.md` - Mark progress
2. Git commit messages - Document changes

---

## 🔮 After Phase 0: What's Next?

### Phase 1: Core UI Components (Estimated: 2 weeks)
1. Restaurant discovery (search, filters)
2. Restaurant detail page (menu, hours, delivery zones)
3. Cart system (add items, modifiers)
4. Checkout flow (guest + authenticated)
5. Order tracking (real-time status)

### Phase 2: Admin Dashboard (Estimated: 3 weeks)
1. Restaurant management
2. Menu editing
3. Order management
4. Analytics dashboard

### Phase 3: Advanced Features (Estimated: 2 weeks)
1. Real-time notifications
2. Geospatial delivery zones
3. Multi-language support
4. SEO optimization

**But first:** Complete Phase 0 (fix database gaps)

---

## 💾 How to Resume If Context Lost

**Everything is in files - you don't need chat history:**

1. Open `/Frontend-build/` as workspace
2. Read this file (`ORCHESTRATOR_CONTEXT.md`)
3. Read `/INDEX/NORTH_STAR.md`
4. Read latest handoff or audit
5. Continue from current status

**For new orchestrator agent:**
1. Read `START_HERE.md` (quick overview)
2. Read this file (full context)
3. Read `/DOCUMENTATION/FRONTEND_BUILD_START_HERE.md` (why Phase 0 exists)
4. Check `/INDEX/NORTH_STAR.md` (current ticket status)
5. Continue orchestrating

---

## 🎯 Success Criteria

### Phase 0 Complete When:
- ✅ All 5 tickets implemented
- ✅ All 5 tickets audited and approved
- ✅ All migrations deployed to production
- ✅ `/INDEX/NORTH_STAR.md` shows 100% complete
- ✅ No critical issues remaining

### Ready for Phase 1 When:
- ✅ Phase 0 complete
- ✅ Database schema solid (no gaps)
- ✅ All security holes patched
- ✅ Frontend can be built without database changes

---

**Current Status:** Ticket 01 implemented, awaiting audit

**Next Action:** Start Auditor Agent with prompt above

**Your Role:** Strategic orchestration, quality decisions, context preservation

**Remember:** Files preserve context, not chat history. Everything documented = nothing forgotten.

