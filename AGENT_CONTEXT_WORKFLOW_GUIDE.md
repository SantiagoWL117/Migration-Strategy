# Agent Context & Workflow Guide - Phase 3: Backend Verification

**Last Updated:** October 22, 2025 | **Phase:** Backend API Development | **For:** Santiago + AI Agents

---

## 🎯 PURPOSE

**Solve:** Context window overload, inconsistent workflows, lost progress  
**How:** Minimal context loading → Verify backend objects → Document → Update memory bank

---

## 📊 PROJECT STATE

| Phase | Status | Progress |
|-------|--------|----------|
| **Phase 1 & 2: Database** | ✅ Complete | 100% - All 10 entities migrated & optimized |
| **Phase 3: Backend** | 🚀 In Progress | 1/10 - Restaurant Mgmt complete, Users & Access in progress |
| **Frontend** | 🚀 In Progress | Brian building Customer Ordering App |

**Key Metrics:** 192 RLS policies, 105 SQL functions, 621 indexes deployed

---

## 🗺️ KEY FILES

| File | Purpose | When to Read |
|------|---------|--------------|
| `MEMORY_BANK/PROJECT_STATUS.md` | ⭐ Single source of truth | Start of every session |
| `MEMORY_BANK/NEXT_STEPS.md` | Current entity & roadmap | Start of every session |
| `SANTIAGO_MASTER_INDEX.md` | Backend specifications | Reference only |
| `BRIAN_MASTER_INDEX.md` | Frontend handoff docs | Update after completion |
| `documentation/{Entity}/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md` | Entity-specific specs | When working on that entity |

---

## 🔄 4-STEP WORKFLOW (Repeat for Each Entity)

### **STEP 1: LOAD CONTEXT** (5 min)

**Read in order:**
1. `/MEMORY_BANK/PROJECT_STATUS.md` → Which entity is in progress?
2. `/MEMORY_BANK/NEXT_STEPS.md` → What needs to be built?
3. `/documentation/{Entity}/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md` → Full specs

**Agent Prompt:**
```
I'm starting [ENTITY NAME] (Entity X/10).

Read these 3 files:
1. /MEMORY_BANK/PROJECT_STATUS.md
2. /MEMORY_BANK/NEXT_STEPS.md  
3. /documentation/{Entity}/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md

Summarize:
- Current progress (X/10 complete)
- SQL Functions & Edge Functions to verify
- Dependencies
```

---

### **STEP 2: VERIFY & BUILD BACKEND**

#### **2.1: Verify SQL Objects** (Using Supabase MCP)

**Verify Checklist:**
- [ ] SQL functions exist
- [ ] Indexes exist
- [ ] Triggers exist
- [ ] Views exist
- [ ] RLS policies exist

**MCP Commands:**
```sql
-- Check SQL functions
mcp_supabase_execute_sql: 
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'menuca_v3' AND routine_name LIKE '%{entity}%';

-- Check indexes
SELECT indexname, tablename FROM pg_indexes 
WHERE schemaname = 'menuca_v3' AND tablename IN (...);

-- Check triggers
SELECT trigger_name, event_object_table FROM information_schema.triggers 
WHERE trigger_schema = 'menuca_v3';
```

**Create Missing Objects:**
```
mcp_supabase_apply_migration:
  name: "add_{entity}_functions"
  query: "[SQL from integration guide]"
```

**Test:**
```sql
SELECT {function_name}(test_params);
EXPLAIN ANALYZE SELECT * FROM {table} WHERE {indexed_column} = 'value';
```

**🚨 CHECKPOINT:** Report verification results → Wait for approval

**Agent Prompt:**
```
Verify database objects for [ENTITY]:
1. List SQL functions mentioned in guide
2. Check which exist using mcp_supabase_execute_sql
3. Show missing objects (don't create yet)
4. Show test plan

Wait for approval before creating anything.
```

---

#### **2.2: Verify Edge Functions** (Using Supabase MCP)

**MCP Commands:**
```
mcp_supabase_list_edge_functions
mcp_supabase_get_edge_function: function_slug="function-name"
```

**Deploy Missing:**
```
mcp_supabase_deploy_edge_function:
  name: "function-name"
  entrypoint_path: "index.ts"
  files: [{ name: "index.ts", content: "..." }]
```

**Test:** Call each function with valid/invalid data, test auth

**🚨 CHECKPOINT:** Report Edge Functions status → Wait for approval

**Agent Prompt:**
```
Verify Edge Functions for [ENTITY]:
1. List all Edge Functions from guide
2. Check which are deployed using mcp_supabase_list_edge_functions
3. Show missing functions (don't deploy yet)
4. Show test plan

Wait for approval before deploying.
```

---

#### **2.3: Document Frontend Integration** (After Approval)

**🚨 CRITICAL CONSTRAINT: MAX 500 LINES PER DOCUMENT**

All documentation created after Step 2.2 MUST be optimized for agent consumption:
- **BRIAN_MASTER_INDEX.md entity sections:** MAX 150 lines per entity
- **SANTIAGO_BACKEND_INTEGRATION_GUIDE.md:** MAX 500 lines total
- **Memory bank updates:** Concise summaries only

**Current Status Audit:**
- ✅ `BRIAN_MASTER_INDEX.md`: 366 lines (GOOD)
- ❌ `Marketing & Promotions/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`: 519 lines (EXCEEDS LIMIT)
- ❌ `Service Configuration/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`: 563 lines (EXCEEDS LIMIT)
- ❌ `backend implementation/BACKEND_IMPLEMENTATION_GUIDE.md`: 704 lines (EXCEEDS LIMIT)
- ✅ `Users & Access/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`: 404 lines (GOOD)
- ✅ `Orders & Checkout/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`: 226 lines (GOOD)
- ✅ `Devices & Infrastructure/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`: 196 lines (GOOD)

**Architecture:**
```
Frontend → supabase.rpc('function_name', params)        [SQL Functions]
Frontend → supabase.functions.invoke('fn', { body })   [Edge Functions]
```

**When to Use What:**

| Type | Use For |
|------|---------|
| **SQL Functions** | CRUD operations, simple queries, single-table ops, performance-critical |
| **Edge Functions** | Auth/authz logic, 3rd-party APIs, webhooks, complex multi-step ops, rate limiting, cron jobs |

**CONDENSED Documentation Template (Keep Under 500 Lines):**
```markdown
## {Entity Name} Backend Integration

### Quick Reference
- SQL Functions: {count}
- Edge Functions: {count}
- Tables: {count}

### Core Operations
{Group by functionality - 3-5 groups max}

#### 1. {Operation Group Name}
**Functions:**
- `function_1(params)` - One-line description
- `function_2(params)` - One-line description

**Frontend Usage:**
```typescript
// Show ONLY most common pattern
const { data } = await supabase.rpc('function_name', { p_param: value });
```

#### 2. {Next Operation Group}
...

### Authentication & Security
- Auth: {brief summary}
- RLS: {brief summary}

### Error Handling
{Common errors only - 3-5 max}

### Performance Notes
{Only critical performance considerations}
```

**Optimization Strategies:**
1. **Remove verbose explanations** - Keep descriptions to 1-2 lines max
2. **Group similar functions** - Don't document each function separately
3. **Show patterns, not repetition** - One example per pattern type
4. **Remove duplicate context** - Entity overview should be 10 lines max
5. **Use tables instead of prose** - More information density
6. **Link to external docs** - For deep dives, don't embed everything
7. **Remove historical context** - Agents don't need "why we migrated"
8. **Consolidate examples** - Show one comprehensive example, not 10 similar ones

**Agent Prompt:**
```
Document frontend integration for [ENTITY] with MAX 500 LINES:

1. Check existing SANTIAGO_BACKEND_INTEGRATION_GUIDE.md line count
2. If > 500 lines, condense using optimization strategies above
3. Create BRIAN_MASTER_INDEX.md section (MAX 150 lines)
4. Focus: Function reference + usage patterns, not explanations
5. Use tables and compact formatting
6. Group functions by operation type

Show proposed content BEFORE writing.
```

---

### **STEP 3: UPDATE BRIAN_MASTER_INDEX.md** (10 min)

**🚨 CONSTRAINT: MAX 150 LINES PER ENTITY SECTION**

**Update Entity Section (Compact Format):**
```markdown
## X. {Entity Name}
**Priority:** X | **Status:** ✅ BACKEND COMPLETE | **Date:** 2025-XX-XX

### Quick Stats
- SQL Functions: {count} | Edge Functions: {count} | Tables: {count}

### Core Operations

#### {Operation Group 1} ({function count})
```typescript
// Pattern example
const { data } = await supabase.rpc('primary_function', { p_param: value });
```
Functions: `func1`, `func2`, `func3`

#### {Operation Group 2} ({function count})
```typescript
// Pattern example
const { data } = await supabase.functions.invoke('edge-function', { body });
```
Functions: `edge-fn-1`, `edge-fn-2`

### Security
- Auth: JWT via Supabase Auth
- RLS: {brief policy summary}

### Common Errors
| Code | Solution |
|------|----------|
| `23503` | Check foreign key exists |
| `42501` | Insufficient permissions |
```

**Formatting Rules:**
1. **Use tables** - More compact than lists
2. **Group functions** - Don't list each individually unless < 10 total
3. **Show patterns** - One code example per operation type
4. **No verbose descriptions** - 1 line max per item
5. **Collapse similar operations** - "6 CRUD functions" instead of listing all 6
6. **Remove boilerplate** - No "how to install Supabase" repeated in every section

**Agent Prompt:**
```
Update /documentation/Frontend-Guides/BRIAN_MASTER_INDEX.md for [ENTITY]:

CONSTRAINT: Keep entity section under 150 lines

1. Check current BRIAN_MASTER_INDEX.md total line count
2. Add entity section using compact format above
3. Group functions by operation type (3-5 groups max)
4. Use tables for error codes, parameters, etc.
5. Show one code pattern per operation type
6. Mark status "✅ BACKEND COMPLETE" with date

Show proposed section BEFORE adding.
```

---

### **STEP 4: UPDATE MEMORY BANK** (5 min)

**Update 3 Files:**

| File | Change |
|------|--------|
| `PROJECT_STATUS.md` | [ENTITY] IN PROGRESS → COMPLETE, update metrics (X/10) |
| `NEXT_STEPS.md` | Mark [ENTITY] complete, set next entity to IN PROGRESS |
| `PROJECT_CONTEXT.md` | Check off [ENTITY] in Phase 3 checklist |

**Agent Prompt:**
```
Update Memory Bank for [ENTITY] completion:

1. /MEMORY_BANK/PROJECT_STATUS.md
   - Change [ENTITY] to COMPLETE
   - Update "X/10 entities complete"
   - Move focus to next entity

2. /MEMORY_BANK/NEXT_STEPS.md
   - Mark [ENTITY] COMPLETE with date
   - Change next entity to IN PROGRESS

3. /MEMORY_BANK/PROJECT_CONTEXT.md
   - Check off [ENTITY] in Phase 3

Show changes before writing.
```

**Then:** Git commit → Move to next entity

---

## 🚨 CONTEXT MANAGEMENT

### **When Context Reaches 70%:**
1. Checkpoint progress
2. Update BRIAN_MASTER_INDEX.md
3. Update MEMORY_BANK
4. Git commit
5. Close chat

### **Starting Fresh Chat:**
```
Continuing MenuCA V3 backend development.

Read:
1. /MEMORY_BANK/PROJECT_STATUS.md
2. /MEMORY_BANK/NEXT_STEPS.md

Tell me:
- Last completed entity
- Current entity to work on
- What to verify/build next
```

---

## 📋 QUICK TEMPLATES

### **Starting Entity:**
```
I'm starting [ENTITY NAME] Backend (Entity X/10).

STEP 1: Read context files (PROJECT_STATUS, NEXT_STEPS, integration guide)
STEP 2.1: Verify SQL objects - show what exists/missing (don't create yet)

Wait for approval.
```

### **After Approval:**
```
✅ Approved - create missing SQL objects

[Create using mcp_supabase_apply_migration]
[Test all functions]

STEP 2.2: Verify Edge Functions - show status (don't deploy yet)

Wait for approval.
```

### **Completing Entity:**
```
✅ [ENTITY NAME] Backend Complete (Entity X/10)

STEP 2.3: Create integration docs (MAX 500 lines)
STEP 3: Update BRIAN_MASTER_INDEX.md (MAX 150 lines per entity)
STEP 4: Update MEMORY_BANK (PROJECT_STATUS, NEXT_STEPS, PROJECT_CONTEXT)

Verify line counts before committing:
- Integration guide: < 500 lines ✓
- BRIAN section: < 150 lines ✓

Show changes before writing.
```

### **Check Documentation Line Counts (PowerShell):**
```powershell
# Check specific file
(Get-Content "documentation\[Entity]\SANTIAGO_BACKEND_INTEGRATION_GUIDE.md" | Measure-Object -Line).Lines

# Check BRIAN_MASTER_INDEX.md
(Get-Content "documentation\Frontend-Guides\BRIAN_MASTER_INDEX.md" | Measure-Object -Line).Lines

# Audit all integration guides
Get-ChildItem "documentation" -Recurse -Filter "SANTIAGO_BACKEND_INTEGRATION_GUIDE.md" | 
  ForEach-Object { 
    "$($_.Directory.Name): $((Get-Content $_.FullName | Measure-Object -Line).Lines) lines" 
  }
```

---

## 📏 DOCUMENTATION SIZE MANAGEMENT

### **Current Over-Limit Documents (Remediation Needed)**

| Document | Current Lines | Target | Action Required |
|----------|--------------|--------|-----------------|
| `Service Configuration/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md` | 563 | 500 | Condense by 63 lines |
| `Marketing & Promotions/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md` | 519 | 500 | Condense by 19 lines |
| `backend implementation/BACKEND_IMPLEMENTATION_GUIDE.md` | 704 | 500 | Condense by 204 lines |

### **Remediation Strategy (Run Once)**

**Agent Prompt for Cleanup:**
```
DOCUMENTATION CLEANUP TASK:

Condense these over-limit documents to < 500 lines:

1. Service Configuration/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md (563 → 500)
2. Marketing & Promotions/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md (519 → 500)
3. backend implementation/BACKEND_IMPLEMENTATION_GUIDE.md (704 → 500)

For each file:
1. Read full file
2. Apply optimization strategies from Step 2.3:
   - Remove verbose explanations (1-2 lines max)
   - Group similar functions (don't list individually)
   - Remove duplicate context/boilerplate
   - Convert prose to tables
   - Remove historical/migration context
   - Keep only: Quick reference + Function patterns + Security + Errors
3. Verify line count < 500
4. Show diff before writing

DO NOT change functionality, only formatting/verbosity.
```

### **Prevention (For Future Entities)**

**Before Writing Any Documentation:**
1. Check line count target (500 for integration guides, 150 for BRIAN sections)
2. Use compact templates from Step 2.3 and Step 3
3. Group functions, don't list individually
4. One code example per pattern type
5. Tables > prose
6. Verify line count after writing

---

## ✅ SUCCESS CHECKLIST

**Per Entity:**
- [ ] Context loaded (3 files: STATUS, NEXT_STEPS, integration guide)
- [ ] SQL objects verified/created and tested
- [ ] Edge Functions verified/deployed and tested
- [ ] Frontend integration documented **(<500 lines)**
- [ ] BRIAN_MASTER_INDEX.md updated **(<150 lines per entity)**
- [ ] Line counts verified (use `Measure-Object -Line`)
- [ ] MEMORY_BANK updated (3 files)
- [ ] Git commit

**Overall Progress:**
- [ ] 10/10 entities complete
- [ ] BRIAN_MASTER_INDEX.md fully populated
- [ ] All integration guides < 500 lines
- [ ] All BRIAN sections < 150 lines
- [ ] Brian can build frontend with all backend functions documented

---

## 🎯 BEST PRACTICES

1. **Minimal Context:** Only load 3 files per session (STATUS, NEXT_STEPS, entity guide)
2. **Wait for Approval:** Never create/deploy without explicit approval
3. **Test Everything:** Verify functions work before documenting
4. **Document Immediately:** Update BRIAN_MASTER_INDEX.md right after completion
5. **Checkpoint Often:** At 70% context, save progress and start fresh
6. **One Entity at a Time:** Complete 100% before moving to next
7. **🆕 Documentation Size Limits:** Integration guides < 500 lines, BRIAN sections < 150 lines
8. **🆕 Verify Line Counts:** Always check with `Measure-Object -Line` before committing
9. **🆕 Optimize for Agents:** Use compact formatting, tables, grouped functions, minimal prose

---

## 📊 CURRENT STATUS

**Completed:** 1/10 (Restaurant Management ✅)  
**In Progress:** 2/10 (Users & Access 🚀)  
**Next:** 3/10 (Menu & Catalog)

**Next Session:** Read PROJECT_STATUS.md → Verify Users & Access backend objects

---

**Version:** 3.0 (Optimized)  
**Last Updated:** October 22, 2025  
**Status:** ✅ ACTIVE
