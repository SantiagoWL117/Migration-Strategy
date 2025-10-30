# MenuCA V3 - Project Navigation Guide

**Quick Index for AI Agents and Developers**

## 📍 Start Here

**First time?** Read these in order:
1. [`guides/project-overview/COMPLETE_PLATFORM_OVERVIEW.md`](guides/project-overview/COMPLETE_PLATFORM_OVERVIEW.md) - Understanding the system
2. [`guides/project-overview/AGENT_CONTEXT_WORKFLOW_GUIDE.md`](guides/project-overview/AGENT_CONTEXT_WORKFLOW_GUIDE.md) - **REQUIRED for AI agents**
3. [`MEMORY_BANK/PROJECT_STATUS.md`](MEMORY_BANK/PROJECT_STATUS.md) - Current project state

## 🗂️ Main Directories

### [`MEMORY_BANK/`](MEMORY_BANK/) - **START HERE FOR EVERY TASK**
Project memory and status tracking
- [`PROJECT_STATUS.md`](MEMORY_BANK/PROJECT_STATUS.md) - Overall progress
- [`NEXT_STEPS.md`](MEMORY_BANK/NEXT_STEPS.md) - What to do next
- [`ENTITIES/`](MEMORY_BANK/ENTITIES/) - Individual entity status (12 entities)
- [`ETL_METHODOLOGY.md`](MEMORY_BANK/ETL_METHODOLOGY.md) - Migration process
- [`COMPLETED/`](MEMORY_BANK/COMPLETED/) - Completion summaries

### [`reports/`](reports/) - All Project Reports
- [`database/`](reports/database/) - Database investigations and audits
- [`testing/`](reports/testing/) - API and feature test reports
- [`implementation/`](reports/implementation/) - Feature completion reports
- [`recovery/`](reports/recovery/) - Emergency fixes and recoveries
- [`migration/`](reports/migration/) - Migration status reports

### [`guides/`](guides/) - Documentation and Guides
- [`explanations/`](guides/explanations/) - How things work (auth, JWT, SQL functions)
- [`setup/`](guides/setup/) - Setup and configuration guides
- [`project-overview/`](guides/project-overview/) - High-level project docs

### [`plans/`](plans/) - Implementation Plans
Strategic documents for features and improvements

### [`agent-logs/`](agent-logs/) - AI Agent Conversations
Historical chat logs and debugging notes

### [`Database/`](Database/) - Database Work
All database migration work organized by entity

### [`documentation/`](documentation/) - Entity Documentation
Migration plans and field mappings by business entity

### [`supabase/`](supabase/) - Supabase Functions
Edge functions and database functions

### [`Frontend-build/`](Frontend-build/) - Frontend Application
Customer and admin frontend applications

## 🤖 For AI Agents - Quick Workflow

### Before Starting ANY Task:
```
1. Read MEMORY_BANK/PROJECT_STATUS.md
2. Read MEMORY_BANK/NEXT_STEPS.md
3. Read MEMORY_BANK/ENTITIES/<relevant_entity>.md
4. Check reports/ for existing work
```

### After Completing ANY Task:
```
1. Update MEMORY_BANK/ENTITIES/<entity>.md
2. Update MEMORY_BANK/NEXT_STEPS.md
3. Create report in reports/ if needed
```

### Golden Rule:
> **PLAN → READ → ACT → DOCUMENT**

## 🔍 Finding Information

### "Where is...?"

| Looking for | Check |
|-------------|-------|
| Current project status | `MEMORY_BANK/PROJECT_STATUS.md` |
| What to work on next | `MEMORY_BANK/NEXT_STEPS.md` |
| Database investigation | `reports/database/` |
| Test results | `reports/testing/` |
| How auth works | `guides/explanations/AUTH_VS_APP_USERS_EXPLAINED.md` |
| Migration methodology | `MEMORY_BANK/ETL_METHODOLOGY.md` |
| Agent workflow | `guides/project-overview/AGENT_CONTEXT_WORKFLOW_GUIDE.md` |
| Entity status | `MEMORY_BANK/ENTITIES/` |
| Backend integration | `Database/<Entity>/SANTIAGO_*.md` |

### "How do I...?"

| Task | Reference |
|------|-----------|
| Start a new task | Read [`guides/project-overview/AGENT_CONTEXT_WORKFLOW_GUIDE.md`](guides/project-overview/AGENT_CONTEXT_WORKFLOW_GUIDE.md) |
| Migrate an entity | Read [`MEMORY_BANK/ETL_METHODOLOGY.md`](MEMORY_BANK/ETL_METHODOLOGY.md) |
| Build the frontend | Read [`guides/project-overview/FULL_STACK_BUILD_GUIDE.md`](guides/project-overview/FULL_STACK_BUILD_GUIDE.md) |
| Understand auth | Read [`guides/explanations/AUTH_VS_APP_USERS_EXPLAINED.md`](guides/explanations/AUTH_VS_APP_USERS_EXPLAINED.md) |
| Check test results | Browse [`reports/testing/`](reports/testing/) |

## 📊 Project Organization

```
Migration-Strategy/
├── MEMORY_BANK/           ⭐ Current state, ALWAYS READ FIRST
├── reports/               📊 All reports (database, testing, implementation)
├── guides/                📚 How-to guides and explanations
├── plans/                 📋 Implementation plans
├── agent-logs/            💬 AI conversation archives
├── Database/              🗄️ Database migration work
├── documentation/         📖 Entity field mappings
├── supabase/              ☁️ Supabase functions
├── Frontend-build/        🎨 Frontend applications
├── netlify/               🌐 Netlify functions
└── types/                 📝 TypeScript type definitions
```

## 🎯 Quick Links by Role

### For Junior Developer (Migration Work)
1. [`MEMORY_BANK/PROJECT_STATUS.md`](MEMORY_BANK/PROJECT_STATUS.md)
2. [`MEMORY_BANK/NEXT_STEPS.md`](MEMORY_BANK/NEXT_STEPS.md)
3. [`MEMORY_BANK/ETL_METHODOLOGY.md`](MEMORY_BANK/ETL_METHODOLOGY.md)
4. [`documentation/`](documentation/) - Entity migration plans

### For Backend Developer
1. [`guides/explanations/`](guides/explanations/)
2. [`Database/<Entity>/SANTIAGO_*.md`](Database/)
3. [`guides/project-overview/FULL_STACK_BUILD_GUIDE.md`](guides/project-overview/FULL_STACK_BUILD_GUIDE.md)

### For AI Assistant
1. **REQUIRED:** [`guides/project-overview/AGENT_CONTEXT_WORKFLOW_GUIDE.md`](guides/project-overview/AGENT_CONTEXT_WORKFLOW_GUIDE.md)
2. [`MEMORY_BANK/PROJECT_STATUS.md`](MEMORY_BANK/PROJECT_STATUS.md)
3. [`MEMORY_BANK/NEXT_STEPS.md`](MEMORY_BANK/NEXT_STEPS.md)
4. [`reports/`](reports/) - Check existing work

## 🚀 Quick Start

### New to the Project?
```bash
# Read in this order:
1. This file (PROJECT_NAVIGATION.md)
2. guides/project-overview/COMPLETE_PLATFORM_OVERVIEW.md
3. MEMORY_BANK/PROJECT_STATUS.md
4. guides/project-overview/AGENT_CONTEXT_WORKFLOW_GUIDE.md
```

### Starting a Task?
```bash
# Always read these first:
1. MEMORY_BANK/NEXT_STEPS.md
2. MEMORY_BANK/ENTITIES/<relevant_entity>.md
3. Check reports/ for existing work on this topic
```

### Finishing a Task?
```bash
# Always update these:
1. MEMORY_BANK/ENTITIES/<entity>.md
2. MEMORY_BANK/NEXT_STEPS.md
3. Create report in reports/ if applicable
```

---

**Last Updated:** October 30, 2025  
**Maintained By:** Project Team  
**Status:** ✅ ACTIVE

**Remember:** The MEMORY_BANK is your source of truth. Always read it before starting work!

