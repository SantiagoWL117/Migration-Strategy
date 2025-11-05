# Plans - MenuCA V3 Project

This directory contains implementation plans and strategic documents for features and improvements.

## 📂 Contents

### 🚨 **ACTIVE PLANS** (Pending Decision/Implementation)

#### **Menu & Catalog Refactoring** (October 30, 2025)
**Status:** 📋 Awaiting Santiago's decision  
**Complexity:** ⭐⭐⭐⭐ High  
**Timeline:** 3 weeks  
**Impact:** Critical - Affects all Menu APIs

**Files:**
1. [`MENU_CATALOG_REFACTORING_PLAN.md`](MENU_CATALOG_REFACTORING_PLAN.md) - **Full 14-phase plan**
   - Detailed SQL migrations
   - 22-day timeline
   - Complete transformation roadmap
   
2. [`MENU_CATALOG_REFACTORING_SUMMARY.md`](MENU_CATALOG_REFACTORING_SUMMARY.md) - **Executive summary**
   - Key statistics
   - Before/after comparison
   - Quick wins
   
3. [`MENU_CATALOG_BEFORE_AFTER.md`](MENU_CATALOG_BEFORE_AFTER.md) - **Visual comparison**
   - Schema diagrams
   - Query examples
   - Performance impact
   
4. [`SANTIAGO_DECISION_MEMO.md`](SANTIAGO_DECISION_MEMO.md) - **Decision framework**
   - Two paths (refactor vs build now)
   - Cost/benefit analysis
   - Recommendation

**Read First:** Start with `SANTIAGO_DECISION_MEMO.md`, then read the full plan.

---

### API Implementation Plans
- `API-ROUTE-IMPLEMENTAITON.md` - API route implementation strategy

### Data Storage Plans
- `PAYMENT_DATA_STORAGE_PLAN.md` - Payment data storage architecture

### Fix Plans
- `PRICING_FIX_IMMACULATE_PLAN.md` - Pricing system fix strategy

---

## 📝 Plan Structure

Each plan typically includes:
- **Problem Statement** - What needs to be solved
- **Current State Analysis** - Data-driven evidence
- **Proposed Solution** - How to solve it
- **Implementation Steps** - Step-by-step approach with SQL
- **Risks & Considerations** - Things to watch out for
- **Success Criteria** - How to know it's done
- **Timeline** - Estimated effort and duration

## 🎯 How to Use Plans

### For Developers
1. **Read decision memo** (if available) to understand options
2. **Review full plan** to understand approach
3. **Check current state** using Supabase MCP
4. **Follow implementation steps** phase by phase
5. **Run verification queries** after each phase
6. **Check off success criteria** as you go
7. **Create completion report** when done (in `/reports/implementation/`)

### For AI Agents
1. Read the relevant plan before coding
2. Use Supabase MCP for all database operations
3. Follow the proposed solution
4. Implement step-by-step
5. Verify each phase before continuing
6. Update project status when complete

## 🔄 Plan Lifecycle

```
Problem Identified
    ↓
Investigation (Supabase MCP)
    ↓
Plan Created (with data evidence)
    ↓
Decision (approve/modify/reject)
    ↓
Implementation (phase by phase)
    ↓
Testing & Validation
    ↓
Completion Report (/reports/implementation/)
    ↓
Memory Bank Update
```

---

## 🚨 Active Decision Points

### Menu & Catalog Refactoring
**Decision Needed:** Should we refactor before building APIs?  
**Decision Maker:** Santiago  
**Deadline:** Before starting Menu & Catalog backend APIs  
**Files:** See "Menu & Catalog Refactoring" section above

---

## 🤖 For AI Agents

When creating a new plan:
1. Investigate using Supabase MCP first (data-driven!)
2. Include current state analysis with actual numbers
3. Provide detailed SQL for each step
4. Include verification queries
5. Estimate timeline realistically
6. Assess risks and provide mitigation
7. Create decision framework if multiple paths exist

When implementing a plan:
1. Read the full plan first
2. Use Supabase MCP for all operations
3. Test each phase before proceeding
4. Document progress in memory bank
5. Create completion report when done

