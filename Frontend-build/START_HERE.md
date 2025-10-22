# Frontend Build - Agent Start Here

## 🚀 Quick Start

**Workspace:** Open `/Frontend-build/` as your project root in Cursor

**Current Task:** Audit Phase 0 Ticket 01 (Guest Checkout)

---

## Current Status

### ✅ Completed
- **Phase 0 Ticket 01 - Guest Checkout** implemented by Builder Agent
- Migration deployed to production database
- Handoff created: `/HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md`

### 🔍 Next Action: AUDIT TICKET 01

**Start Auditor Agent (new chat) with this prompt:**

```
You are the Auditor Agent.

Read these files:
1. /TICKETS/PHASE_0_01_GUEST_CHECKOUT_TICKET.md
2. /HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md

Verify implementation and create:
/AUDITS/PHASE_0_01_GUEST_CHECKOUT_AUDIT.md

Checklist:
- [ ] All columns added correctly
- [ ] user_id made nullable
- [ ] CHECK constraint works
- [ ] Index created
- [ ] Comments added
- [ ] Migration is idempotent

Verdict: APPROVED / NEEDS FIXES / REJECTED
```

---

## Folder Structure

```
Frontend-build/                       ← WORKSPACE ROOT (open this in Cursor)
├── START_HERE.md                     ← You are here
├── CURRENT_STATUS.md                 ← Quick status (outdated, use INDEX/NORTH_STAR.md)
│
├── INDEX/
│   └── NORTH_STAR.md                 ← Master progress tracker (UPDATE THIS ALWAYS)
│
├── DOCUMENTATION/                    ← Planning & setup docs
│   ├── FRONTEND_BUILD_START_HERE.md  ← Critical gaps analysis (Cognition Wheel)
│   ├── COMPETITION_ENVIRONMENT_SETUP.md  ← Cursor vs Replit setup
│   └── BRANCH_SETUP_GUIDE.md         ← Supabase branches guide
│
├── TICKETS/                          ← All 5 Phase 0 tickets
│   ├── README.md
│   ├── PHASE_0_01_GUEST_CHECKOUT_TICKET.md
│   ├── PHASE_0_02_INVENTORY_SYSTEM_TICKET.md
│   ├── PHASE_0_03_PRICE_VALIDATION_TICKET.md
│   ├── PHASE_0_04_CANCELLATION_SYSTEM_TICKET.md
│   └── PHASE_0_05_MODIFIER_VALIDATION_TICKET.md
│
├── HANDOFFS/                         ← Builder outputs
│   ├── README.md
│   └── PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md
│
└── AUDITS/                           ← Auditor outputs
    └── README.md
```

---

## 📚 External Documentation (Absolute Paths)

**All guides are accessible via absolute paths:**

### API Documentation (50+ SQL Functions, 29 Edge Functions)
```
/Users/brianlapp/Documents/GitHub/Migration-Strategy/documentation/Frontend-Guides/
├── BRIAN_MASTER_INDEX.md             ← Master API hub
├── 01-Restaurant-Management-Frontend-Guide.md
└── Restaurant Management/
    ├── 01-Franchise-Chain-Hierarchy.md
    ├── 02-Soft-Delete-Infrastructure.md
    ├── 03-Status-Online-Toggle.md
    ├── 04-Status-Audit-Trail.md
    ├── 05-Contact-Management.md
    ├── 06-PostGIS-Delivery-Zones.md
    ├── 07-SEO-Full-Text-Search.md
    ├── 08-Categorization-System.md
    ├── 09-Onboarding-Status-Tracking.md
    ├── 10-Restaurant-Onboarding-System.md
    └── 11-Domain-Verification-SSL.md
```

### Memory Bank (Project Context)
```
/Users/brianlapp/Documents/GitHub/Migration-Strategy/MEMORY_BANK/
├── README.md
├── PROJECT_CONTEXT.md
├── PROJECT_STATUS.md
├── ETL_METHODOLOGY.md
├── NEXT_STEPS.md
├── ENTITIES/                         ← Entity status files
└── COMPLETED/                        ← Completion summaries
```

**Access these files using absolute paths in Cursor:**
```
@/Users/brianlapp/Documents/GitHub/Migration-Strategy/documentation/Frontend-Guides/BRIAN_MASTER_INDEX.md
@/Users/brianlapp/Documents/GitHub/Migration-Strategy/MEMORY_BANK/PROJECT_STATUS.md
```

---

## 🔄 Multi-Agent Workflow

### Pattern
```
Orchestrator (You)
    ↓ Creates ticket
Builder Agent (New chat)
    ↓ Implements + Creates handoff
Auditor Agent (New chat)
    ↓ Reviews + Creates audit
Orchestrator (Back to you)
    → Assigns next ticket OR requests fixes
```

### Why This Works
- **Files preserve context** (not chat history)
- **Each agent documents work** (handoffs + audits)
- **No context loss** when switching agents
- **Everything tracked** in `/INDEX/NORTH_STAR.md`

---

## 📋 Phase 0 Tickets Status

1. ✅ **Guest Checkout** - AWAITING AUDIT
2. 📋 **Inventory System** - READY
3. 📋 **Price Validation** - READY
4. 📋 **Cancellation System** - READY
5. 📋 **Modifier Validation** - READY

---

## 🎯 Your Role as Orchestrator

### Responsibilities
1. ✅ Create tickets in `/TICKETS/`
2. ✅ Review handoffs from Builder Agent
3. ✅ Review audits from Auditor Agent
4. ✅ Decide: APPROVED → Next ticket, or NEEDS FIXES → Back to builder
5. ✅ **Update `/INDEX/NORTH_STAR.md` after EVERY step**

### Critical Rules
1. **ALWAYS** update `/INDEX/NORTH_STAR.md` after changes
2. **ALWAYS** create handoff files after completing work
3. **NEVER** skip the audit step
4. **NEVER** move to next ticket before audit completes

---

## 🆘 If Context is Lost

**Everything is in files - you don't need chat history:**

1. Open `/INDEX/NORTH_STAR.md` (current status)
2. Read latest handoff/audit
3. Continue from there

**For new agents:**
1. Read this `START_HERE.md`
2. Read `/INDEX/NORTH_STAR.md`
3. Read relevant ticket
4. Do work
5. Create handoff
6. Update `/INDEX/NORTH_STAR.md`

---

## 📖 Key Documents to Read

### Before Starting Work
- `/INDEX/NORTH_STAR.md` - Current progress
- `/DOCUMENTATION/FRONTEND_BUILD_START_HERE.md` - Critical gaps analysis
- Relevant ticket from `/TICKETS/`

### During Implementation
- API guides (absolute paths above)
- Previous handoffs/audits
- Memory bank for project context

### After Completing Work
- Create handoff file
- Update `/INDEX/NORTH_STAR.md`
- Notify orchestrator

---

**Current Priority:** Pass Ticket 01 to Auditor Agent

**Next Ticket After Audit:** Ticket 02 (Inventory System)

**Workspace:** `/Frontend-build/` (self-contained, uses absolute paths for external docs)
