# Agent Context & Workflow Guide
## How to Maintain Persistent Context Across AI Agents and Tasks

**Created:** October 21, 2025  
**For:** Santiago & Team Members  
**Purpose:** Share successful patterns for AI-assisted development with persistent context  
**Success Rate:** Proven effective across 6+ major entities, 200+ files, 40+ phases

---

## 🎯 THE PROBLEM WE SOLVED

**Common AI Agent Issues:**
- ❌ Agents forget previous work
- ❌ Duplicate effort across sessions
- ❌ Inconsistent approaches
- ❌ Lost context between tasks
- ❌ No visibility into what's already done
- ❌ Difficulty picking up where you left off

**Our Solution:**
- ✅ Memory Bank system for persistent knowledge
- ✅ Handoff files between agents/tasks
- ✅ Comprehensive documentation workflow
- ✅ Clear status tracking
- ✅ Entity-based organization
- ✅ Read context BEFORE acting

---

## 📚 CORE PRINCIPLE: PLAN → READ → ACT → DOCUMENT

### **The Golden Rule:**
> **"Always read the full context before starting any task. Update the memory bank when finishing."**

### **Every Task Follows This Pattern:**

```
1. PLAN
   └─ What am I trying to accomplish?
   └─ What context do I need?
   └─ Where is existing documentation?

2. READ (Context Loading)
   └─ Read MEMORY_BANK/PROJECT_STATUS.md
   └─ Read MEMORY_BANK/ENTITIES/<relevant_entity>.md
   └─ Read any handoff files for this task
   └─ Check Database/<Entity>/ for prior work

3. ACT (Execute Task)
   └─ Follow established patterns
   └─ Use existing methodology
   └─ Build on prior work, don't duplicate
   └─ Keep notes as you work

4. DOCUMENT (Preserve Knowledge)
   └─ Update completion reports
   └─ Update memory bank status
   └─ Create handoff files if needed
   └─ Commit documentation with code
```

---

## 🗂️ PROJECT STRUCTURE OVERVIEW

### **Key Directories:**

```
Migration-Strategy/
├── MEMORY_BANK/                    # ⭐ START HERE
│   ├── README.md                   # How to use memory bank
│   ├── PROJECT_STATUS.md           # Current state of project
│   ├── PROJECT_CONTEXT.md          # Overall project context
│   ├── WORKFLOW.md                 # Standard workflows
│   ├── ENTITIES/                   # Entity-specific knowledge
│   │   ├── 01_RESTAURANT_MANAGEMENT.md
│   │   ├── 02_MENU_CATALOG.md
│   │   ├── 03_SERVICE_CONFIG.md
│   │   ├── 04_USERS_ACCESS.md
│   │   ├── 05_LOCATION_GEOGRAPHY.md
│   │   ├── 06_ORDERS_CHECKOUT.md
│   │   └── [etc...]
│   └── COMPLETED/                  # Archive of finished phases
│
├── Database/                       # All database work
│   ├── <Entity Name>/              # One folder per entity
│   │   ├── PHASE_1_*.sql          # Migration scripts
│   │   ├── PHASE_1_*.md           # Documentation
│   │   ├── *_COMPLETION_REPORT.md # Final summary
│   │   └── SANTIAGO_*.md          # Backend handoff files
│   └── AUDIT_REPORTS/             # Quality audits
│
├── documentation/                  # User-facing docs
│   └── <Entity Name>/             # Entity documentation
│       ├── *_migration_plan.md
│       └── SANTIAGO_BACKEND_INTEGRATION_GUIDE.md
│
└── AGENT_*_PROMPT.md              # Agent-specific instructions
```

---

## 📖 STEP-BY-STEP: HOW TO START ANY TASK

### **Step 1: Read the Memory Bank (5 minutes)**

**Always start here:**

```bash
# Read these files FIRST, EVERY TIME
1. /MEMORY_BANK/README.md
2. /MEMORY_BANK/PROJECT_STATUS.md
3. /MEMORY_BANK/PROJECT_CONTEXT.md
4. /MEMORY_BANK/ENTITIES/<relevant_entity>.md
```

**Example Agent Prompt:**
```
"I'm about to work on [TASK]. Before I start, please read:
- /MEMORY_BANK/PROJECT_STATUS.md
- /MEMORY_BANK/ENTITIES/06_ORDERS_CHECKOUT.md
- /Database/Orders_&_Checkout/*_COMPLETION_REPORT.md

Then summarize what's already done and what I should focus on."
```

---

### **Step 2: Check for Existing Work (3 minutes)**

**Before creating anything new, search for existing files:**

```bash
# Example: Working on Orders entity
cd /Database/Orders_&_Checkout/

# Check what exists
ls -la

# Read completion reports
cat *_COMPLETION_REPORT.md

# Check for handoff files
cat SANTIAGO_*.md
```

**Agent Prompt:**
```
"List all files in /Database/Orders_&_Checkout/ and tell me:
1. What phases are complete?
2. What's the last completion report?
3. Are there any handoff files for backend?"
```

---

### **Step 3: Follow Established Patterns (Critical!)**

**Our Proven 7-Phase Methodology:**

Every entity follows this pattern:

```
Phase 1: Auth & Security (RLS Policies)
  ├─ Enable RLS on tables
  ├─ Create access control policies
  └─ Document security model

Phase 2: Performance & Core APIs (SQL Functions)
  ├─ Create business logic functions
  ├─ Add performance indexes
  └─ Benchmark query performance

Phase 3: Schema Optimization (Audit Trails)
  ├─ Add audit columns
  ├─ Implement soft delete
  └─ Create status history tracking

Phase 4: Real-Time Updates (Supabase Realtime)
  ├─ Enable Realtime on tables
  ├─ Create pg_notify triggers
  └─ Document WebSocket patterns

Phase 5: Payment/Language/Features (Entity-Specific)
  ├─ Add entity-specific features
  ├─ Integrate with other entities
  └─ Create specialized functions

Phase 6: Advanced Features
  ├─ Complex business logic
  ├─ Multi-table operations
  └─ Analytics functions

Phase 7: Testing & Validation
  ├─ Comprehensive test suite
  ├─ Performance benchmarks
  └─ Production readiness checklist
```

**Each Phase Produces:**
- ✅ `PHASE_X_MIGRATION_SCRIPT.sql` - Executable SQL
- ✅ `PHASE_X_BACKEND_DOCUMENTATION.md` - Implementation guide
- ✅ `PHASE_X_SUMMARY.md` (optional) - Quick overview

---

### **Step 4: Create Handoff Files for Backend (Santiago)**

**Every database entity needs a Santiago handoff file:**

**Template:** `SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`

```markdown
# [Entity] - Santiago Backend Integration Guide

## 🚨 Business Problem & Solution
[What problem does this solve?]

## 🧩 Complete Business Logic Components
[List all SQL functions created]

## 💻 Backend APIs to Implement
[Specific API endpoints with code examples]

## 🔄 Real-Time Integration
[WebSocket subscription examples]

## 🗄️ Complete Schema Modifications
[Tables, columns, relationships]

## ✅ Testing Checklist
[What to test]

## 📊 Summary Metrics
[Functions, policies, tables, etc.]

## 🎯 Implementation Priority
[Week 1, Week 2 breakdown]
```

**Location Pattern:**
- `/Database/<Entity>/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`
- `/documentation/<Entity>/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`

---

### **Step 5: Update Memory Bank When Done**

**After completing ANY task, update:**

1. **Entity Status File:**
```markdown
# Update: /MEMORY_BANK/ENTITIES/<entity>.md

## Status
- ✅ Phase X Complete (Date)
- 🔄 Phase Y In Progress
- ⏳ Phase Z Pending

## What We Built
[Summary of deliverables]

## Next Steps
[What comes next]
```

2. **Project Status:**
```markdown
# Update: /MEMORY_BANK/PROJECT_STATUS.md

## Current Progress
- Entity Name: Phase X/7 Complete (XX%)
```

3. **Completion Report:**
```markdown
# Create: /Database/<Entity>/<ENTITY>_COMPLETION_REPORT.md

# Executive Summary
# What Was Built
# Metrics
# Deliverables
# Backend Integration Guide
# Production Readiness
```

---

## 🎨 BEST PRACTICES FROM 60+ COMPLETED PHASES

### **1. Always Read Before Writing**

**Bad:**
```
Agent: "I'll create the orders schema now."
```

**Good:**
```
You: "Read /Database/Orders_&_Checkout/01_create_v3_order_schema.sql 
     and tell me what already exists."

Agent: "The schema exists with 7 tables. Should I enhance it 
        or start on Phase 2 (SQL functions)?"
```

---

### **2. Use Completion Reports as Checkpoints**

**Every entity should have a completion report:**

```
/Database/<Entity>/<ENTITY>_COMPLETION_REPORT.md
```

**Contents:**
- ✅ Executive Summary
- ✅ All 7 phases documented
- ✅ Complete deliverables list
- ✅ Metrics (tables, functions, policies, tests)
- ✅ Backend integration checklist
- ✅ Production readiness status

---

### **3. Follow Naming Conventions**

**Migration Scripts:**
```
PHASE_1_MIGRATION_SCRIPT.sql
PHASE_2_MIGRATION_SCRIPT.sql
[etc...]
```

**Documentation:**
```
PHASE_1_BACKEND_DOCUMENTATION.md
PHASE_2_BACKEND_DOCUMENTATION.md
[etc...]
```

**Summaries:**
```
<ENTITY>_COMPLETION_REPORT.md
<ENTITY>_SANTIAGO_GUIDE.md
SANTIAGO_BACKEND_INTEGRATION_GUIDE.md
```

---

### **4. Create Master Index Files**

**Example: Santiago Master Index**

```markdown
# SANTIAGO_MASTER_INDEX.md

## All Backend Integration Guides

### ✅ Complete Entities:
1. [Restaurant Management](Database/Restaurant Management/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)
2. [Menu & Catalog](Database/Menu & Catalog/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)
3. [Users & Access](documentation/Users & Access/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md)
[etc...]

### Entity Completion Summary:
- Restaurant Management: ✅ 100% (7/7 phases)
- Menu & Catalog: ✅ 100% (7/7 phases)
- Orders & Checkout: ✅ 100% (7/7 phases)
```

---

### **5. Use Agent-Specific Prompts**

**Create reusable prompt files:**

```
AGENT_1_ORDERS_CHECKOUT_PROMPT.md
AGENT_2_MARKETING_PROMOTIONS_PROMPT.md
[etc...]
```

**Include in prompt:**
- Entity scope
- Phase instructions
- Table lists
- Function requirements
- RLS policy patterns
- Testing requirements
- Handoff file template

---

## 🚀 AGENT PROMPT TEMPLATES

### **Starting a New Task:**

```markdown
I need to work on [ENTITY/TASK].

Before we start, please:
1. Read /MEMORY_BANK/PROJECT_STATUS.md
2. Read /MEMORY_BANK/ENTITIES/<entity>.md
3. Check /Database/<Entity>/ for existing files
4. Tell me:
   - What phases are complete?
   - What's the next logical step?
   - What files already exist that I should build on?

Then let's plan our approach together.
```

---

### **Finishing a Phase:**

```markdown
We just completed Phase X for [ENTITY].

Please:
1. Create PHASE_X_MIGRATION_SCRIPT.sql (if not exists)
2. Create PHASE_X_BACKEND_DOCUMENTATION.md
3. Update /MEMORY_BANK/ENTITIES/<entity>.md with completion status
4. If this was Phase 7, create <ENTITY>_COMPLETION_REPORT.md

Show me what you're updating before you write files.
```

---

### **Creating Backend Handoff:**

```markdown
Create a SANTIAGO_BACKEND_INTEGRATION_GUIDE.md for [ENTITY].

Please read these files first:
- /Database/<Entity>/PHASE_*_BACKEND_DOCUMENTATION.md (all phases)
- /Database/<Entity>/<ENTITY>_COMPLETION_REPORT.md

Then create a comprehensive guide including:
- Business problem & solution
- All SQL functions with examples
- API endpoints to implement (with TypeScript code)
- Real-time subscription patterns
- Schema overview
- Testing checklist
- Implementation priority (Week 1, Week 2)

Use existing guides as reference:
- /documentation/Users & Access/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md
```

---

## 📊 TRACKING PROGRESS

### **Daily Status Update Pattern:**

**At end of each session:**

```markdown
Today I completed:
- ✅ [Task 1]
- ✅ [Task 2]
- 🔄 [Task 3 - in progress]

Files created/updated:
- /Database/<Entity>/PHASE_X_*.sql
- /Database/<Entity>/PHASE_X_*.md
- /MEMORY_BANK/ENTITIES/<entity>.md

Next session should:
- [ ] Continue Phase X
- [ ] Create handoff file
- [ ] Update completion report
```

**Save this in:** `/MEMORY_BANK/COMPLETED/<date>_session_notes.md`

---

## 🎯 SANTIAGO'S QUICK START CHECKLIST

**First Time Setup:**

- [ ] Clone the repo: `git clone [repo_url]`
- [ ] Read `/MEMORY_BANK/README.md`
- [ ] Read `/MEMORY_BANK/PROJECT_STATUS.md`
- [ ] Read `/MEMORY_BANK/PROJECT_CONTEXT.md`
- [ ] Review `/SANTIAGO_MASTER_INDEX.md` (if exists)
- [ ] Scan entity folders in `/Database/`
- [ ] Note which entities have `SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`

**Every New Task:**

- [ ] Read relevant entity file in `/MEMORY_BANK/ENTITIES/`
- [ ] Check `/Database/<Entity>/` for completion reports
- [ ] Read any `SANTIAGO_*.md` files
- [ ] Ask agent to summarize what's done before starting
- [ ] Work in phases, don't skip ahead
- [ ] Update memory bank when done
- [ ] Create handoff files for backend work

**Before Each Cursor Session:**

- [ ] Pull latest: `git pull origin main`
- [ ] Read memory bank for entity you're working on
- [ ] Review last session's notes
- [ ] Tell agent what context to load

**After Each Cursor Session:**

- [ ] Update entity status in memory bank
- [ ] Create/update completion reports
- [ ] Commit with descriptive messages
- [ ] Push to main: `git push origin main`

---

## 💡 PRO TIPS FROM SUCCESSFUL PATTERN

### **1. Batch Read Context at Start**

**Instead of:**
```
Agent: Creates file
You: Wait, does this exist?
Agent: Let me check...
```

**Do this:**
```
You: "Read these 5 files first, then summarize what exists:
     - /MEMORY_BANK/ENTITIES/06_ORDERS_CHECKOUT.md
     - /Database/Orders_&_Checkout/*_COMPLETION_REPORT.md
     - /Database/Orders_&_Checkout/PHASE_*.md
     
     Then tell me what phase we should work on next."
```

---

### **2. Use Completion Reports as Single Source of Truth**

**Each entity's completion report contains:**
- Executive summary
- All phases documented
- Complete deliverables
- Metrics (tables, functions, policies)
- Backend integration checklist
- Production readiness status

**Pattern:**
```
"Read <ENTITY>_COMPLETION_REPORT.md and tell me if Phase 5 is done."
```

---

### **3. Create Handoff Files Early**

**Don't wait until end to document:**

**After Phase 2:**
```
Create: PHASE_2_BACKEND_DOCUMENTATION.md
  └─ SQL function examples
  └─ TypeScript integration code
  └─ API endpoint patterns
```

**After Phase 7:**
```
Consolidate: SANTIAGO_BACKEND_INTEGRATION_GUIDE.md
  └─ Combines all phase docs
  └─ Adds implementation priority
  └─ Includes testing checklist
```

---

### **4. Follow the 7-Phase Pattern Religiously**

**Why it works:**
- ✅ Security first (RLS in Phase 1)
- ✅ Performance built in (Indexes in Phase 2)
- ✅ Audit trails from start (Phase 3)
- ✅ Real-time ready (Phase 4)
- ✅ Feature completeness (Phase 5-6)
- ✅ Production quality (Phase 7 tests)

**Don't skip phases or do out of order!**

---

### **5. Use Grep to Find Existing Patterns**

**Before implementing anything:**

```bash
# Find how RLS was implemented elsewhere
grep -r "CREATE POLICY" Database/

# Find SQL function patterns
grep -r "CREATE FUNCTION" Database/

# Find backend documentation
find . -name "SANTIAGO_*.md"

# Find completion reports
find . -name "*_COMPLETION_REPORT.md"
```

**Agent Prompt:**
```
"Search for all files containing 'CREATE POLICY' and show me 
how RLS was implemented in Users & Access entity."
```

---

## 🔄 WORKFLOW COMPARISON

### **❌ Without This System:**

```
Session 1: Create schema
Session 2: Agent forgot, recreates schema differently
Session 3: Add functions, no documentation
Session 4: Agent doesn't know what functions exist
Session 5: Start over, lost context
Result: Chaos, duplication, inconsistency
```

### **✅ With This System:**

```
Session 1: Phase 1 (RLS) + PHASE_1_MIGRATION_SCRIPT.sql + docs + memory bank update
Session 2: Read memory bank → Phase 2 (Functions) + docs
Session 3: Read memory bank → Phase 3 (Audit) + docs
Session 4: Read memory bank → Continue Phase 4...
Result: Consistent, traceable, complete
```

---

## 📝 SAMPLE SESSION TRANSCRIPT

**Good Session Pattern:**

```
You: "I need to work on Orders & Checkout, Phase 3 (Audit Trails).
     First, read /MEMORY_BANK/ENTITIES/06_ORDERS_CHECKOUT.md 
     and /Database/Orders_&_Checkout/*_COMPLETION_REPORT.md.
     Tell me what phases are done."

Agent: "Phases 1-2 are complete. Phase 1 created 40+ RLS policies.
        Phase 2 created 9 SQL functions and 15+ indexes.
        Phase 3 (Audit Trails) is next. Shall we start?"

You: "Yes. Read PHASE_2_MIGRATION_SCRIPT.sql to see table structure,
     then create Phase 3 following the same patterns."

Agent: [Creates PHASE_3_MIGRATION_SCRIPT.sql with audit columns]

You: "Good! Now create PHASE_3_BACKEND_DOCUMENTATION.md explaining
     how to use the audit trail functions."

Agent: [Creates documentation with examples]

You: "Perfect! Now update /MEMORY_BANK/ENTITIES/06_ORDERS_CHECKOUT.md
     to show Phase 3 is complete."

Agent: [Updates memory bank]

You: "Great session! Let's commit."
```

---

## 🎓 LEARNING FROM MISTAKES

### **Common Pitfalls We Solved:**

**Pitfall 1: "Just start coding"**
- ❌ Results in duplicated work
- ✅ Solution: Always read memory bank first

**Pitfall 2: "Agent will remember"**
- ❌ Context resets between sessions
- ✅ Solution: Document everything, update memory bank

**Pitfall 3: "I'll document later"**
- ❌ Never happens, knowledge lost
- ✅ Solution: Document as you go, phase by phase

**Pitfall 4: "One big file for everything"**
- ❌ Overwhelming, hard to navigate
- ✅ Solution: One file per phase, clear naming

**Pitfall 5: "Backend can figure it out"**
- ❌ Wastes Santiago's time
- ✅ Solution: Create detailed handoff files with examples

---

## 📚 RECOMMENDED READING ORDER

**First Time Using This System:**

1. This file (you are here!)
2. `/MEMORY_BANK/README.md`
3. `/MEMORY_BANK/PROJECT_STATUS.md`
4. `/MEMORY_BANK/PROJECT_CONTEXT.md`
5. Pick one complete entity's completion report
6. Review that entity's SANTIAGO guide
7. Start applying the patterns

**Before Working on Specific Entity:**

1. `/MEMORY_BANK/ENTITIES/<entity>.md`
2. `/Database/<Entity>/*_COMPLETION_REPORT.md`
3. `/Database/<Entity>/SANTIAGO_*.md`
4. Latest PHASE_* files in entity folder

---

## 🎯 SUCCESS METRICS

**How You Know It's Working:**

✅ **Context Persistence:**
- Agent picks up where last session left off
- No duplicate work
- Consistent patterns across entities

✅ **Velocity:**
- Complete entity in 30-40 hours (7 phases)
- Backend integration guides ready immediately
- No "what did we decide?" questions

✅ **Quality:**
- 100% test pass rate in Phase 7
- Production-ready code
- Comprehensive documentation

✅ **Team Alignment:**
- Backend knows exactly what to implement
- Clear handoff points
- Fewer Slack messages asking "where's the docs?"

---

## 🔗 KEY FILES TO BOOKMARK

**Always Start Here:**
- `/MEMORY_BANK/PROJECT_STATUS.md`
- `/MEMORY_BANK/ENTITIES/`

**Reference These:**
- `/SANTIAGO_MASTER_INDEX.md`
- Any `*_COMPLETION_REPORT.md`
- Any `SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`

**Templates:**
- This file (for workflow)
- Any existing `PHASE_*` files (for patterns)

---

## 🚀 GETTING STARTED TODAY

### **Santiago's First Session Template:**

```markdown
I'm Santiago, working on [ENTITY/FEATURE] for MenuCA V3.

This is my first time using the context system. Please help me:

1. Read /MEMORY_BANK/PROJECT_STATUS.md
2. Read /AGENT_CONTEXT_WORKFLOW_GUIDE.md (this file)
3. List all entities and their completion status
4. Show me which entities have SANTIAGO_BACKEND_INTEGRATION_GUIDE.md
5. Recommend which entity I should start implementing first

Then let's review the handoff documentation for that entity together.
```

---

## 💪 YOU'VE GOT THIS!

**This system has successfully managed:**
- ✅ 6+ major entities (Restaurant, Menu, Users, Orders, Location, Service Config)
- ✅ 40+ phases (7 phases × 6 entities)
- ✅ 200+ files with perfect consistency
- ✅ Zero lost context between sessions
- ✅ Complete backend handoff documentation

**The secret:** 
1. Read context before acting
2. Follow established patterns
3. Document as you go
4. Update memory bank when done

**Welcome to the system!** 🎉

---

## 📞 NEED HELP?

**If you get stuck:**

1. Read this file again (seriously, it helps!)
2. Check `/MEMORY_BANK/README.md`
3. Look at a completed entity for reference patterns
4. Ask Brian - he built this system

**Remember:** The memory bank is your friend. Use it!

---

**Version:** 1.0  
**Last Updated:** October 21, 2025  
**Maintained By:** Brian (Agent Success Pattern Extraction)  
**Status:** ✅ ACTIVE - Use this for all work!

---

**Next Steps for Santiago:**
1. ✅ Read this file (you just did!)
2. ⏳ Read `/MEMORY_BANK/PROJECT_STATUS.md`
3. ⏳ Pick first entity to implement
4. ⏳ Read that entity's `SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`
5. ⏳ Start implementing APIs following the guide
6. ⏳ Update memory bank when done

**Let's build something amazing! 🚀**

