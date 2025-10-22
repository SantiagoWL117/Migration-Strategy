# Workflow Rules - Memory Bank Usage

**CRITICAL:** Follow these rules for EVERY task to maintain project continuity and avoid getting off track.

---

## 🔄 Standard Workflow

### ✅ BEFORE Starting ANY Task

**Step 1: Check Current Status**
- 📖 Read `/MEMORY_BANK/NEXT_STEPS.md` - What should I work on?
- 📖 Check `/MEMORY_BANK/PROJECT_STATUS.md` - What's the overall status?

**Step 2: Understand the Context**
- 📖 Read relevant backend integration guide in `/documentation/[Entity]/`
- 📖 Review SANTIAGO_MASTER_INDEX.md for entity overview
- 📖 Check dependencies - Are all required entities complete?

**Step 3: Plan the Work**
- 📝 Create TODO list with clear, actionable steps
- 📝 Identify what APIs need to be built
- 📝 Understand expected outcomes

---

### ✅ AFTER Completing ANY Task

**Step 1: Update Entity Status**
- ✏️ Update `/MEMORY_BANK/ENTITIES/XX_ENTITY_NAME.md` with:
  - Current status (in_progress → completed)
  - What was accomplished
  - Any issues encountered
  - Next steps for this entity

**Step 2: Update Next Steps**
- ✏️ Update `/MEMORY_BANK/NEXT_STEPS.md` with:
  - Mark completed tasks ✅
  - Add new tasks if discovered
  - Update recommendations for next entity

**Step 3: Update Project Status (if needed)**
- ✏️ Update `/MEMORY_BANK/PROJECT_STATUS.md` if:
  - Entity completed (update progress metrics)
  - Dependencies changed (update dependency chain)
  - Blockers removed (update what can start)

**Step 4: Create Completion Summary (if entity done)**
- ✏️ Create `/MEMORY_BANK/COMPLETED/ENTITY_NAME_SUMMARY.md` with:
  - What was migrated
  - Transformations applied
  - Verification results
  - Lessons learned
  - What this unblocked

**Step 5: Update AI Memory**
- ✏️ Update the AI's persistent memory with key learnings
- ✏️ Include any important discoveries or changes

---

## 🚨 Golden Rules

### 1. ALWAYS PLAN then ACT
- Never start coding without reading context
- Never make changes without understanding impact
- Never skip the "BEFORE" checklist

### 2. ALWAYS UPDATE then PROCEED
- Never move to next task without updating memory bank
- Never mark task complete without documentation
- Never skip the "AFTER" checklist

### 3. READ FULL CONTEXT
- When finishing a to-do, update the memory bank
- Read the full context before starting the next to-do
- Ensure you're not getting off track

---

## 📋 Quick Reference Checklist

### Starting a New Backend Entity?
- [ ] Read `/MEMORY_BANK/NEXT_STEPS.md`
- [ ] Read entity backend integration guide in `/documentation/[Entity]/`
- [ ] Review `/SANTIAGO_MASTER_INDEX.md` for entity overview
- [ ] Check dependencies in `/MEMORY_BANK/PROJECT_STATUS.md`
- [ ] Review SQL functions and Edge Functions available
- [ ] Create TODO list
- [ ] Begin work

### Completed an API Endpoint?
- [ ] Update TODO list (mark complete)
- [ ] Test endpoint thoroughly
- [ ] Document any issues
- [ ] Commit changes to git
- [ ] Read context before next endpoint

### Completed a Backend Entity?
- [ ] Update `/MEMORY_BANK/NEXT_STEPS.md` (mark entity complete)
- [ ] Update `/MEMORY_BANK/PROJECT_STATUS.md` (progress metrics)
- [ ] Test all endpoints for the entity
- [ ] Document completion
- [ ] Commit all changes
- [ ] Read context before choosing next entity

---

## 🎯 Why This Matters

**Without this workflow:**
- ❌ Work on wrong entity (blocked by dependencies)
- ❌ Duplicate effort (don't know what's done)
- ❌ Get off track (no context between tasks)
- ❌ Lose progress (no documentation)
- ❌ Break things (don't understand dependencies)

**With this workflow:**
- ✅ Always work on right priority
- ✅ Never duplicate work
- ✅ Stay focused and on track
- ✅ Build on previous work
- ✅ Maintain data integrity

---

## 📁 Memory Bank Files Quick Guide

| File | When to Read | When to Update |
|------|--------------|----------------|
| `README.md` | First time using memory bank | Never (reference only) |
| `WORKFLOW.md` | Every task start | Never (reference only) |
| `NEXT_STEPS.md` | **BEFORE every task** | **AFTER every task** |
| `PROJECT_STATUS.md` | Before starting entity | After completing entity |
| `PROJECT_CONTEXT.md` | For strategic overview | When phases complete |
| `ETL_METHODOLOGY.md` | Historical reference (Phase 1 & 2) | Never (Phase 1 & 2 complete) |
| `ENTITIES/XX_*.md` | Historical migration notes | Never (Phase 1 & 2 complete) |
| `COMPLETED/*.md` | Historical reference | Never (Phase 1 & 2 complete) |

---

## 🔁 Example Workflow (Phase 3: Backend APIs)

**Scenario:** Starting Users & Access Backend APIs

### BEFORE:
1. ✅ Read `NEXT_STEPS.md` → Confirms Users & Access is Priority 2
2. ✅ Read `/documentation/Users & Access/SANTIAGO_BACKEND_INTEGRATION_GUIDE.md`
3. ✅ Check `PROJECT_STATUS.md` → Confirm Restaurant Management APIs complete
4. ✅ Review `SANTIAGO_MASTER_INDEX.md` for Users & Access overview
5. ✅ Check available SQL functions and Edge Functions
6. ✅ Create TODO list → Plan API endpoints

### DURING:
- Implement authentication endpoints
- Build customer profile APIs
- Create address management endpoints
- Test each endpoint
- Document usage

### AFTER (each endpoint):
- ✅ Update TODO list
- ✅ Test endpoint
- ✅ Commit changes

### AFTER (entity complete):
1. ✅ Update `NEXT_STEPS.md` → Mark Users & Access complete, identify Menu & Catalog as next
2. ✅ Update `PROJECT_STATUS.md` → Update progress (2/10 entities complete)
3. ✅ Update `PROJECT_CONTEXT.md` → Update Phase 3 checklist
4. ✅ Test integration with Brian's frontend
5. ✅ Commit everything
6. ✅ Read context before next entity

---

**Remember: The memory bank is your project brain. Keep it updated and always consult it!**
