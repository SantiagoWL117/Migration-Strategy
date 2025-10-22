# Frontend Build - Agent Start Here

## ⚠️ CRITICAL: Workspace Setup

**You MUST open the parent folder, NOT this folder directly.**

❌ **WRONG:** Open `/Frontend-build/` as workspace root  
✅ **CORRECT:** Open `/Migration-Strategy/` as workspace root

### Why?

Every ticket and workflow references `@documentation/Frontend-Guides/` which contains:
- All 11 Restaurant Management API docs
- 50+ SQL functions documentation  
- 29 Edge Functions with examples
- Complete integration guides

**If you open `/Frontend-build/` only, you CANNOT access these files** (they're at `../documentation/Frontend-Guides/`)

---

## Current Status

### What Just Happened
✅ **Phase 0 Ticket 01 - Guest Checkout** completed by Builder Agent
- Migration successfully implemented in production database
- Handoff created: `/Frontend-build/HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md`

### What You Need To Do NOW
🔍 **AUDIT TICKET 01**

1. Read ticket: `/Frontend-build/TICKETS/PHASE_0_01_GUEST_CHECKOUT_TICKET.md`
2. Read handoff: `/Frontend-build/HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md`
3. Create audit: `/Frontend-build/AUDITS/PHASE_0_01_GUEST_CHECKOUT_AUDIT.md`

---

## Workflow Overview

### Multi-Agent Pattern

**Orchestrator (You Are Here)**
↓ Creates ticket
**Builder Agent (New chat)**
↓ Implements + Creates handoff
**Auditor Agent (New chat)**
↓ Reviews + Creates audit report
**Orchestrator (Back to you)**
→ Assigns next ticket or requests fixes

### Why This Matters
- Preserves context through files, not chat history
- Each agent documents their work
- No context loss when switching agents
- Everything tracked in `/Frontend-build/INDEX/NORTH_STAR.md`

---

## Your Role as Orchestrator

### Responsibilities
1. ✅ Create tickets in `/Frontend-build/TICKETS/`
2. ✅ Review handoffs from Builder Agent
3. ✅ Review audits from Auditor Agent
4. ✅ Decide: APPROVED → Next ticket, or NEEDS FIXES → Back to builder
5. ✅ Update `/Frontend-build/INDEX/NORTH_STAR.md` after each step

### Current Phase 0 Status
- **Ticket 01:** IN PROGRESS (awaiting audit)
- **Ticket 02:** READY (Inventory System)
- **Ticket 03:** READY (Price Validation)
- **Ticket 04:** READY (Cancellation System)
- **Ticket 05:** READY (Modifier Validation)

---

## Key Files (All in `/Frontend-build/`)

```
Frontend-build/
├── START_HERE.md                    ← You are here
├── INDEX/
│   └── NORTH_STAR.md                ← Master progress tracker
├── TICKETS/
│   ├── PHASE_0_01_GUEST_CHECKOUT_TICKET.md
│   ├── PHASE_0_02_INVENTORY_SYSTEM_TICKET.md
│   ├── PHASE_0_03_PRICE_VALIDATION_TICKET.md
│   ├── PHASE_0_04_CANCELLATION_SYSTEM_TICKET.md
│   └── PHASE_0_05_MODIFIER_VALIDATION_TICKET.md
├── HANDOFFS/
│   └── PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md  ← Latest from builder
└── AUDITS/
    └── (Awaiting first audit)
```

---

## Documentation Access (REQUIRES PARENT FOLDER)

All tickets reference these constantly:

```
Migration-Strategy/                   ← MUST BE WORKSPACE ROOT
├── Frontend-build/                   ← Your work folder
└── documentation/
    └── Frontend-Guides/
        ├── BRIAN_MASTER_INDEX.md     ← Referenced in every ticket
        ├── 01-Restaurant-Management-Frontend-Guide.md
        └── Restaurant Management/    ← 11 component guides
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

---

## Next Steps

### Option 1: Continue as Orchestrator (Recommended)
1. Open workspace: `/Migration-Strategy/` (parent folder)
2. Review `/Frontend-build/HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md`
3. Pass to Auditor Agent (new chat) with this prompt:

```
You are the Auditor Agent. Read these files:
- /Frontend-build/TICKETS/PHASE_0_01_GUEST_CHECKOUT_TICKET.md
- /Frontend-build/HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md

Audit the implementation and create:
- /Frontend-build/AUDITS/PHASE_0_01_GUEST_CHECKOUT_AUDIT.md

Use this template:
- [ ] Requirements met
- [ ] Schema correct
- [ ] Constraints working
- [ ] Issues found
- Verdict: APPROVED / NEEDS FIXES / REJECTED
```

### Option 2: Continue as Builder Agent
If you want to implement Ticket 02 next:
1. Open workspace: `/Migration-Strategy/` (parent folder)
2. Read `/Frontend-build/TICKETS/PHASE_0_02_INVENTORY_SYSTEM_TICKET.md`
3. Reference `@documentation/Frontend-Guides/BRIAN_MASTER_INDEX.md` constantly
4. Implement the migration
5. Create handoff file

---

## Critical Rules

1. **ALWAYS** work from `/Migration-Strategy/` workspace root
2. **ALWAYS** update `/Frontend-build/INDEX/NORTH_STAR.md` after changes
3. **ALWAYS** create handoff files after completing work
4. **NEVER** skip the audit step
5. **NEVER** move to next ticket before current audit completes

---

## If Cursor Keeps Crashing

1. Try VS Code instead: `code /Migration-Strategy`
2. Use Claude.ai web interface with file uploads
3. The files preserve all context - chat history is optional
4. Everything documented in `/Frontend-build/` folder

---

**Current Priority:** Pass Ticket 01 handoff to Auditor Agent for review

**Workspace Root:** `/Migration-Strategy/` (NOT `/Frontend-build/`)

