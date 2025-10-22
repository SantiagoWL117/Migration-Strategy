# Frontend Build - Agent Start Here

## Workspace Setup

**Open `/Frontend-build/` as your workspace root.**

All documentation is now LOCAL in `/Frontend-build/GUIDES/` - you don't need the parent folder.

---

## Current Status

### What Just Happened
✅ **Phase 0 Ticket 01 - Guest Checkout** completed by Builder Agent
- Migration successfully implemented in production database
- Handoff created: `/HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md`

### What You Need To Do NOW
🔍 **AUDIT TICKET 01**

1. Read: `/TICKETS/PHASE_0_01_GUEST_CHECKOUT_TICKET.md`
2. Read: `/HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md`
3. Create: `/AUDITS/PHASE_0_01_GUEST_CHECKOUT_AUDIT.md`

---

## Workflow Overview

### Multi-Agent Pattern

**Orchestrator**
↓ Creates ticket
**Builder Agent (New chat)**
↓ Implements + Creates handoff
**Auditor Agent (New chat)**
↓ Reviews + Creates audit report
**Orchestrator (Back to original)**
→ Assigns next ticket or requests fixes

### Why This Matters
- Preserves context through files, not chat history
- Each agent documents their work
- No context loss when switching agents
- Everything tracked in `/INDEX/NORTH_STAR.md`

---

## Your Role as Orchestrator

### Responsibilities
1. ✅ Create tickets in `/TICKETS/`
2. ✅ Review handoffs from Builder Agent
3. ✅ Review audits from Auditor Agent
4. ✅ Decide: APPROVED → Next ticket, or NEEDS FIXES → Back to builder
5. ✅ Update `/INDEX/NORTH_STAR.md` after each step

### Current Phase 0 Status
- **Ticket 01:** IN PROGRESS (awaiting audit)
- **Ticket 02:** READY (Inventory System)
- **Ticket 03:** READY (Price Validation)
- **Ticket 04:** READY (Cancellation System)
- **Ticket 05:** READY (Modifier Validation)

---

## Folder Structure

```
Frontend-build/                       ← WORKSPACE ROOT
├── START_HERE.md                     ← You are here
├── INDEX/
│   └── NORTH_STAR.md                 ← Master progress tracker
├── TICKETS/                          ← All 5 Phase 0 tickets
│   ├── PHASE_0_01_GUEST_CHECKOUT_TICKET.md
│   ├── PHASE_0_02_INVENTORY_SYSTEM_TICKET.md
│   ├── PHASE_0_03_PRICE_VALIDATION_TICKET.md
│   ├── PHASE_0_04_CANCELLATION_SYSTEM_TICKET.md
│   └── PHASE_0_05_MODIFIER_VALIDATION_TICKET.md
├── HANDOFFS/                         ← Builder outputs
│   └── PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md
├── AUDITS/                           ← Auditor outputs
│   └── (Awaiting first audit)
└── GUIDES/                           ← ALL API DOCUMENTATION (LOCAL)
    ├── BRIAN_MASTER_INDEX.md         ← Master API hub
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

---

## Documentation Access (ALL LOCAL NOW)

All tickets reference `/GUIDES/` which contains:
- 50+ SQL functions with examples
- 29 Edge Functions with integration guides
- Complete Restaurant Management API docs
- Everything you need to implement features

**Example references in tickets:**
- `@GUIDES/BRIAN_MASTER_INDEX.md`
- `@GUIDES/Restaurant Management/06-PostGIS-Delivery-Zones.md`

---

## Next Step: Start Auditor Agent

### Prompt for Auditor Agent (New Chat):

```
You are the Auditor Agent for the Frontend Build project.

Your job:
1. Read the ticket: /TICKETS/PHASE_0_01_GUEST_CHECKOUT_TICKET.md
2. Read the handoff: /HANDOFFS/PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md
3. Verify the implementation meets all requirements
4. Create audit report: /AUDITS/PHASE_0_01_GUEST_CHECKOUT_AUDIT.md

Audit Checklist:
- [ ] All required columns added (is_guest_order, guest_email, guest_phone)
- [ ] user_id made nullable correctly
- [ ] CHECK constraint works (guest orders need email)
- [ ] Index created for guest email lookups
- [ ] Comments added to all columns
- [ ] Migration is idempotent (can run multiple times safely)

Verdict Options:
✅ APPROVED - Move to Ticket 02
⚠️ NEEDS FIXES - List specific issues
❌ REJECTED - Full rework needed

Create /AUDITS/PHASE_0_01_GUEST_CHECKOUT_AUDIT.md now.
```

---

## Critical Rules

1. **ALWAYS** update `/INDEX/NORTH_STAR.md` after changes
2. **ALWAYS** create handoff files after completing work
3. **NEVER** skip the audit step
4. **NEVER** move to next ticket before current audit completes
5. All documentation is in `/GUIDES/` - reference it constantly

---

## If You Need to Switch Agents

**Context is preserved in files, not chat history.**

Each new agent chat should start with:
1. Read `/INDEX/NORTH_STAR.md` (current status)
2. Read relevant ticket from `/TICKETS/`
3. Read previous handoff/audit if exists
4. Do your work
5. Create handoff file
6. Update `/INDEX/NORTH_STAR.md`

---

**Current Priority:** Pass Ticket 01 to Auditor Agent for review

**Workspace Root:** `/Frontend-build/` (self-contained, no parent folder needed)

**All Guides:** In `/GUIDES/` directory (local copies)
