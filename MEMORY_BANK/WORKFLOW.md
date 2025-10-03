# Workflow Rules - Memory Bank Usage

**CRITICAL:** Follow these rules for EVERY task to maintain project continuity and avoid getting off track.

---

## 🔄 Standard Workflow

### ✅ BEFORE Starting ANY Task

**Step 1: Check Current Status**
- 📖 Read `/MEMORY_BANK/NEXT_STEPS.md` - What should I work on?
- 📖 Check `/MEMORY_BANK/PROJECT_STATUS.md` - What's the overall status?

**Step 2: Understand the Context**
- 📖 Read relevant entity file in `/MEMORY_BANK/ENTITIES/XX_ENTITY_NAME.md`
- 📖 Check dependencies - Are all required entities complete?
- 📖 Review blockers - Is anything preventing this work?

**Step 3: Review the Process**
- 📖 Read `/MEMORY_BANK/ETL_METHODOLOGY.md` - How do I execute this?
- 📖 Review previous completed entity in `/MEMORY_BANK/COMPLETED/` - Learn from examples

**Step 4: Plan the Work**
- 📝 Create TODO list with clear, actionable steps
- 📝 Identify what files need to be created/updated
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

### Starting a New Entity?
- [ ] Read `/MEMORY_BANK/NEXT_STEPS.md`
- [ ] Read `/MEMORY_BANK/ENTITIES/XX_ENTITY.md`
- [ ] Review `/MEMORY_BANK/ETL_METHODOLOGY.md`
- [ ] Check dependencies in `/MEMORY_BANK/PROJECT_STATUS.md`
- [ ] Review last completed entity in `/MEMORY_BANK/COMPLETED/`
- [ ] Create TODO list
- [ ] Begin work

### Completed a Migration Step?
- [ ] Update TODO list (mark complete)
- [ ] Update entity file with progress
- [ ] Commit changes to git
- [ ] Read context before next step

### Completed an Entity?
- [ ] Update entity file (status → completed)
- [ ] Create completion summary in `/MEMORY_BANK/COMPLETED/`
- [ ] Update `/MEMORY_BANK/NEXT_STEPS.md`
- [ ] Update `/MEMORY_BANK/PROJECT_STATUS.md`
- [ ] Update AI memory
- [ ] Commit all changes
- [ ] Check what's unblocked
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
| `ETL_METHODOLOGY.md` | Before creating migration plan | Never (reference only) |
| `ENTITIES/XX_*.md` | Before working on entity | During & after entity work |
| `COMPLETED/*.md` | For reference/learning | After completing entity |

---

## 🔁 Example Workflow

**Scenario:** Starting Users & Access entity

### BEFORE:
1. ✅ Read `NEXT_STEPS.md` → Confirms Users & Access is recommended
2. ✅ Read `ENTITIES/08_USERS_ACCESS.md` → Understand scope and dependencies
3. ✅ Check `PROJECT_STATUS.md` → Confirm Location & Geography complete (dependency ✅)
4. ✅ Read `ETL_METHODOLOGY.md` → Remember the process
5. ✅ Review `COMPLETED/LOCATION_GEOGRAPHY_SUMMARY.md` → Learn from example
6. ✅ Create TODO list → Plan the work

### DURING:
- Work on mapping document
- Work on migration plans
- Execute migrations
- Run verifications

### AFTER (each step):
- ✅ Update `ENTITIES/08_USERS_ACCESS.md` with progress
- ✅ Update TODO list
- ✅ Commit changes

### AFTER (entity complete):
1. ✅ Update `ENTITIES/08_USERS_ACCESS.md` → Status: COMPLETE ✅
2. ✅ Create `COMPLETED/USERS_ACCESS_SUMMARY.md` → Full summary
3. ✅ Update `NEXT_STEPS.md` → Mark complete, identify next entity
4. ✅ Update `PROJECT_STATUS.md` → Update metrics, unblock Orders & Checkout
5. ✅ Update AI memory → Key learnings
6. ✅ Commit everything
7. ✅ Read context before next entity

---

**Remember: The memory bank is your project brain. Keep it updated and always consult it!**
