# Agent Tasks - Database Migration

**Created:** October 10, 2025  
**Purpose:** Agent-executable database migration tickets for MenuCA V3 schema optimization  
**Total Tasks:** 11 sequential tickets  
**Estimated Duration:** 6-8 hours (staging + production)

---

## Overview

This directory contains **atomic, sequential ticket files** designed for AI agent execution. Each ticket is self-contained with exact commands, validation criteria, and rollback procedures.

### What This Migration Does

1. **Adds 45+ Performance Indexes** - Speeds up menu queries from 500ms → 50ms
2. **Deploys Row Level Security (RLS)** - Enforces tenant isolation at database level
3. **Fixes Combo System** - Repairs 99.8% orphaned combo groups
4. **Validates Everything** - Comprehensive test suite ensures success

### Expected Outcome

- ✅ **Query Performance:** 10x faster menu loads
- ✅ **Security:** Multi-tenant data isolation enforced
- ✅ **Data Integrity:** Combo orphan rate < 5%
- ✅ **Production Ready:** Fully validated and monitored

---

## Execution Flow

### For AI Agents

```
Start → 00_PRE_FLIGHT_CHECK.md
        ↓
        01_STAGING_BACKUP.md
        ↓
        02_STAGING_INDEXES.md
        ↓
        03_STAGING_RLS.md
        ↓
        04_STAGING_COMBOS.md
        ↓
        05_STAGING_VALIDATION.md
        ↓ (Wait 4+ hours for staging stability)
        ↓
        06_PRODUCTION_BACKUP.md
        ↓
        07_PRODUCTION_INDEXES.md
        ↓
        08_PRODUCTION_RLS.md
        ↓
        09_PRODUCTION_COMBOS.md
        ↓
        10_PRODUCTION_VALIDATION.md
        ↓
      Done ✅
```

**Key Rules for Agents:**

1. **Execute tickets sequentially** - Do NOT skip ahead
2. **Validate after each step** - All checks must PASS
3. **Log to EXECUTION_LOG.md** - Record all results and decisions
4. **Stop on failure** - Do NOT proceed if validation fails
5. **Context preservation** - Read previous ticket results from EXECUTION_LOG.md

---

## Files in This Directory

### Ticket Files (Execute in Order)
- `00_PRE_FLIGHT_CHECK.md` - Verify prerequisites
- `01_STAGING_BACKUP.md` - Backup staging database
- `02_STAGING_INDEXES.md` - Deploy performance indexes to staging
- `03_STAGING_RLS.md` - Deploy RLS policies to staging
- `04_STAGING_COMBOS.md` - Fix combo system in staging
- `05_STAGING_VALIDATION.md` - Validate staging deployment
- `06_PRODUCTION_BACKUP.md` - Backup production database
- `07_PRODUCTION_INDEXES.md` - Deploy indexes to production
- `08_PRODUCTION_RLS.md` - Deploy RLS to production
- `09_PRODUCTION_COMBOS.md` - Fix combos in production
- `10_PRODUCTION_VALIDATION.md` - Final validation

### Supporting Files
- `EXECUTION_LOG.md` - **Agent writes here** - Progress tracking
- `ROLLBACK_GUIDE.md` - Emergency rollback procedures
- `README.md` - **You are here**

---

## Ticket Template Structure

Each ticket follows this format:

```markdown
# TICKET [N]: [Task Name]

## CONTEXT
- Current Step
- Prerequisites
- Duration

## TASK
What to do

## COMMANDS TO RUN
Exact commands with expected outputs

## VALIDATION CRITERIA
- [ ] Check 1
- [ ] Check 2

## SUCCESS CONDITIONS
What PASS looks like

## FAILURE CONDITIONS
What to do if FAIL

## ROLLBACK
How to undo if needed

## CONTEXT FOR NEXT STEP
What next ticket needs to know
```

---

## For Human Operators

### Before Starting

1. **Review Prerequisites** - See `00_PRE_FLIGHT_CHECK.md`
2. **Access Required:**
   - Supabase staging database credentials
   - Supabase production database credentials
   - MCP Supabase tools configured
3. **Team Availability:**
   - Brian Lapp (lead) available
   - Santiago (backup) available
   - Rollback plan reviewed

### During Execution

- **Monitor:** Watch EXECUTION_LOG.md for agent progress
- **Communicate:** Update team in Slack (#database-migrations)
- **Intervene:** Stop agent if any validation fails

### After Completion

- Review EXECUTION_LOG.md for full audit trail
- Post-deployment report (template in 10_PRODUCTION_VALIDATION.md)
- Monitor for 24 hours

---

## Success Criteria

### Staging (Ticket 05)
- [ ] All indexes created (45+)
- [ ] RLS tests 100% pass
- [ ] Combo orphan rate < 5%
- [ ] No errors for 4+ hours
- [ ] Query performance improved

### Production (Ticket 10)
- [ ] All staging criteria met
- [ ] Zero customer incidents
- [ ] Performance baseline maintained
- [ ] 24-hour stability confirmed

---

## Rollback Procedures

If anything goes wrong, see `ROLLBACK_GUIDE.md` for:
- Full database restore (15 minutes)
- Partial rollbacks (indexes, RLS, combos separately)
- Emergency contacts
- Post-rollback actions

**When to Rollback:**
- Data corruption detected
- Error rate > 5%
- Performance degradation > 50%
- Combo orphan rate still > 20%
- Security breach detected

---

## Progress Tracking

### Check Status
```bash
# View agent progress
tail -f /Users/brianlapp/Documents/GitHub/Migration-Strategy/Database/Agent_Tasks/EXECUTION_LOG.md

# Count completed tickets
grep -c "STATUS: COMPLETE" EXECUTION_LOG.md
```

### Current Ticket
The agent should always log which ticket it's executing in EXECUTION_LOG.md

---

## Source Documentation

These tickets were generated from:
- `/Database/DEPLOYMENT_CHECKLIST.md` - Full deployment guide
- `/Database/QUICK_START_SANTIAGO.md` - 3-day sprint overview
- `/Database/GAP_ANALYSIS_REPORT.md` - Schema analysis
- `/Database/SCHEMA_AUDIT_ACTION_PLAN.md` - Action plan
- `/Database/Performance/add_critical_indexes.sql` - Index script
- `/Database/Security/create_rls_policies.sql` - RLS policies
- `/Database/Security/test_rls_policies.sql` - RLS tests
- `/Database/Menu & Catalog Entity/combos/fix_combo_items_migration.sql` - Combo fix
- `/Database/Menu & Catalog Entity/combos/validate_combo_fix.sql` - Combo validation

---

## Support & Escalation

### Primary Contact
**Brian Lapp** - Database Migration Lead  
Slack: @brian | Email: brian@worklocal.com

### Backup Contact
**Santiago** - Database Admin  
Slack: @santiago | Email: santiago@worklocal.com

### Emergency
- Slack: #database-migrations
- Escalate to: James Walker (CTO)

---

## Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| **Day 1** | 6 hours | ✅ Complete (Scripts Created) |
| **Day 2** | 3 hours | ⏳ Pending (Staging Deployment) |
| **Day 3** | 3 hours | ⏳ Pending (Production Deployment) |

**Target Completion:** October 13, 2025

---

## Notes for Agents

### Context Preservation
- Read EXECUTION_LOG.md before each ticket
- Log all outputs, decisions, errors
- Include timestamps for all actions

### Error Handling
- If command fails → Log error details
- If validation fails → Log which check failed
- DO NOT proceed on failure → Stop and alert human

### Communication
- Log verbose output (agent can handle it)
- Include actual vs expected results
- Explain why validation passed/failed

---

**Document Version:** 1.0  
**Last Updated:** October 10, 2025  
**Next Review:** After production deployment

