# Agent Orchestration Workflow - MenuCA V3 Frontend Build

**Created:** October 22, 2025  
**Purpose:** Standardized multi-agent workflow for building MenuCA V3 frontend  
**Status:** ✅ ACTIVE - Use this workflow for all frontend development

---

## 🎯 WORKFLOW OVERVIEW

This workflow ensures **quality**, **context preservation**, and **accountability** through a multi-agent pipeline with clear handoffs and audit checkpoints.

### **The Pipeline:**

```
┌─────────────────────────────────────────────────────────┐
│  STAGE 0: PLANNING                                       │
│  Agent: Orchestrator (Claude Sonnet 4.5)                │
│  Human: Project Manager (You)                           │
│  ─────────────────────────────────────────────          │
│  - Review requirements                                   │
│  - Create detailed tickets                               │
│  - Prioritize tasks                                      │
│  - Make strategic decisions                              │
│  - Always in the loop                                    │
│                                                          │
│  Output: TICKET file with acceptance criteria           │
└─────────────────┬───────────────────────────────────────┘
                  │
                  ▼
          📋 TICKET CREATED
          (/TICKETS/PHASE_X_##_FEATURE_NAME_TICKET.md)
                  │
                  ▼
┌─────────────────────────────────────────────────────────┐
│  STAGE 1: IMPLEMENTATION                                 │
│  Agent: Builder (Claude Sonnet 4.5 via Cursor Composer) │
│  Human: Developer (You supervising)                     │
│  ─────────────────────────────────────────────          │
│  - Read ticket requirements                              │
│  - Implement feature code                                │
│  - Write tests                                           │
│  - Create handoff documentation                          │
│  - List all files changed                                │
│  - Explain key decisions made                            │
│                                                          │
│  Output: HANDOFF file with implementation details       │
└─────────────────┬───────────────────────────────────────┘
                  │
                  ▼
          📄 HANDOFF CREATED
          (/HANDOFFS/PHASE_X_##_FEATURE_NAME_HANDOFF.md)
                  │
                  ▼
┌─────────────────────────────────────────────────────────┐
│  STAGE 2: QUALITY AUDIT                                  │
│  Agent: Auditor (Gemini 2.0 or Claude Opus)            │
│  Human: Quality reviewer (You)                          │
│  ─────────────────────────────────────────────          │
│  - Read handoff + ticket                                 │
│  - Review all code changes                               │
│  - Check against acceptance criteria                     │
│  - Test edge cases                                       │
│  - Verify security best practices                        │
│  - Check performance implications                        │
│  - Rate: PASS / FAIL / NEEDS_REVISION                   │
│                                                          │
│  Output: AUDIT_REPORT with findings                     │
└─────────────────┬───────────────────────────────────────┘
                  │
                  ▼
          📊 AUDIT REPORT CREATED
          (/AUDITS/PHASE_X_##_FEATURE_NAME_AUDIT.md)
                  │
                  ▼
┌─────────────────────────────────────────────────────────┐
│  STAGE 3: DECISION & INTEGRATION                         │
│  Agent: Orchestrator (Claude Sonnet 4.5)                │
│  Human: Project Manager (You)                           │
│  ─────────────────────────────────────────────          │
│  - Review audit report                                   │
│  - Decide: ACCEPT / REVISE / REJECT                     │
│                                                          │
│  If ACCEPT:                                              │
│    → Update NORTH_STAR.md index                         │
│    → Mark ticket complete                                │
│    → Move to next ticket                                 │
│                                                          │
│  If REVISE:                                              │
│    → Create revision ticket                              │
│    → Back to STAGE 1 with fixes                         │
│                                                          │
│  If REJECT:                                              │
│    → Document why                                        │
│    → Create new approach ticket                          │
│    → Back to STAGE 0 for replanning                     │
└─────────────────────────────────────────────────────────┘
```

---

## 🤖 AGENT RECOMMENDATIONS

### **Stage 0: Orchestrator Agent**

**Recommended Model:** **Claude Sonnet 4.5** ✅

**Why:**
- ✅ Excellent at understanding complex requirements
- ✅ Great at creating structured documentation
- ✅ Strong at maintaining context across conversations
- ✅ Good at strategic planning and prioritization
- ✅ Reliable at following established patterns

**Responsibilities:**
1. Create detailed tickets with acceptance criteria
2. Break down complex features into manageable tasks
3. Prioritize work based on dependencies
4. Review audit reports and make decisions
5. Maintain NORTH_STAR.md index file
6. Coordinate between builder and auditor

**Prompt Template:**
```
You are the Orchestrator Agent for MenuCA V3 frontend build.

Your role:
- Create detailed implementation tickets
- Review audit reports and make decisions
- Update project index files
- Maintain the big picture

Current Context: [brief project status]
Current Phase: [phase name]
Next Task: [what needs to be done]

Please create a ticket for: [feature description]
```

---

### **Stage 1: Builder Agent**

**Recommended Model:** **Claude Sonnet 4.5 via Cursor Composer** ✅

**Why:**
- ✅ Excellent at writing production-quality code
- ✅ Great TypeScript/React/Next.js knowledge
- ✅ Follows best practices
- ✅ Good at creating tests
- ✅ Can handle multi-file changes via Composer
- ✅ Supabase MCP integration for database awareness

**Alternative:** Could use **Claude Opus** for very complex features requiring deep reasoning

**Responsibilities:**
1. Read and understand ticket requirements
2. Implement feature with clean, tested code
3. Follow security best practices
4. Write unit/integration tests
5. Create comprehensive handoff documentation
6. List all files changed and why

**Prompt Template:**
```
You are the Builder Agent implementing a feature for MenuCA V3.

Read the ticket: /TICKETS/[ticket-name].md

Requirements:
1. Implement all acceptance criteria
2. Write tests for critical logic
3. Follow STATE_MANAGEMENT_RULES.md
4. Follow SECURITY_CHECKLIST.md
5. Create HANDOFF.md when done

Use Cursor Composer for multi-file changes.
```

---

### **Stage 2: Auditor Agent**

**Recommended Model:** **Gemini 2.0 Pro** ⭐ or **Claude Opus** ✅

**Why Gemini 2.0:**
- ✅ Excellent at analytical tasks
- ✅ Great at spotting edge cases
- ✅ Strong at security review
- ✅ Different perspective from Claude (catches different issues)
- ✅ Proven in Cognition Wheel review (found critical gaps!)

**Why Claude Opus (Alternative):**
- ✅ Deepest reasoning capability
- ✅ Excellent at finding subtle bugs
- ✅ Great at architectural review
- ✅ Strong at security analysis

**Recommendation:** **Use Gemini 2.0** for most audits, escalate to **Claude Opus** for critical/complex features

**Responsibilities:**
1. Read ticket + handoff + changed files
2. Verify all acceptance criteria met
3. Review code quality and best practices
4. Check for security vulnerabilities
5. Test edge cases and error handling
6. Rate: PASS / FAIL / NEEDS_REVISION
7. Provide specific, actionable feedback

**Prompt Template:**
```
You are the Auditor Agent for MenuCA V3 frontend build.

Your role: Quality control and security review

Review Materials:
- Ticket: /TICKETS/[ticket-name].md
- Handoff: /HANDOFFS/[handoff-name].md
- Code changes: [list of files]

Audit Checklist:
1. ✅ All acceptance criteria met?
2. ✅ Code quality (TypeScript, React best practices)?
3. ✅ Security (no XSS, CSRF, SQL injection risks)?
4. ✅ Tests present and comprehensive?
5. ✅ Performance implications acceptable?
6. ✅ Error handling robust?
7. ✅ Edge cases covered?

Provide rating: PASS / FAIL / NEEDS_REVISION
List specific issues with line numbers and suggestions.
```

---

## 🎯 PROOF: Multi-Model Review Works!

**Evidence from Cognition Wheel (October 22, 2025):**

We used **3 AI models** to review our frontend build plan:
- Claude Opus 4
- Gemini 2.0
- GPT-4 (o3)

**Result:** Found **14 critical gaps** we missed!
- Guest checkout missing (50% conversion killer!)
- Server-side price validation missing (security hole!)
- Real-time inventory missing (orders fail!)
- Testing strategy completely missing!

**Conclusion:** Different models catch different issues. **Using multiple perspectives = Higher quality.**

---

## 📁 FILE STRUCTURE

### **Directory Layout:**

```
/TICKETS/
  ├── README.md (explains ticket format)
  ├── PHASE_0_01_GUEST_CHECKOUT_TICKET.md
  ├── PHASE_0_02_INVENTORY_SYSTEM_TICKET.md
  ├── PHASE_0_03_PRICE_VALIDATION_TICKET.md
  └── [PHASE]_[NUMBER]_[FEATURE]_TICKET.md

/HANDOFFS/
  ├── README.md (explains handoff format)
  ├── PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md
  ├── PHASE_0_02_INVENTORY_SYSTEM_HANDOFF.md
  └── [PHASE]_[NUMBER]_[FEATURE]_HANDOFF.md

/AUDITS/
  ├── README.md (explains audit format)
  ├── PHASE_0_01_GUEST_CHECKOUT_AUDIT.md
  ├── PHASE_0_02_INVENTORY_SYSTEM_AUDIT.md
  └── [PHASE]_[NUMBER]_[FEATURE]_AUDIT.md

/INDEX/
  ├── NORTH_STAR.md (master index - ALWAYS UP TO DATE)
  ├── PHASE_STATUS.md (current phase progress)
  ├── COMPLETED_TASKS.md (audit trail)
  └── BLOCKERS.md (current issues)
```

---

## 📋 FILE TEMPLATES

### **TICKET Template:**

```markdown
# TICKET: [Phase] - [Feature Name]

**Ticket ID:** PHASE_X_##_FEATURE_NAME  
**Priority:** 🔴 CRITICAL / 🟡 HIGH / 🟢 MEDIUM / ⚪ LOW  
**Estimated Time:** X hours  
**Dependencies:** [List any blockers]  
**Assignee:** Builder Agent (via Cursor Composer)

---

## Requirement

[Clear description of what needs to be built]

---

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
- [ ] Tests written and passing
- [ ] Documentation updated

---

## Technical Details

### Database Changes
[SQL if needed]

### API Changes
[Endpoint changes if needed]

### Frontend Changes
[Component/page changes]

---

## Security Considerations

[Any security implications]

---

## Testing Requirements

- [ ] Unit tests for [specific logic]
- [ ] Integration tests for [API calls]
- [ ] E2E tests for [user flows]

---

## Expected Outcome

[What success looks like]

---

## References

- Related documentation: [links]
- Related tickets: [ticket IDs]
```

---

### **HANDOFF Template:**

```markdown
# HANDOFF: [Feature Name]

**Ticket:** PHASE_X_##_FEATURE_NAME  
**Implemented By:** Builder Agent (Claude Sonnet 4.5)  
**Date:** YYYY-MM-DD  
**Status:** ✅ READY FOR AUDIT

---

## Summary

[2-3 sentence summary of what was implemented]

---

## Files Changed

### Created
- `path/to/new/file.tsx` - [purpose]
- `path/to/test.test.ts` - [test coverage]

### Modified
- `path/to/existing/file.tsx` - [changes made]

### Deleted
- `path/to/old/file.tsx` - [reason for deletion]

---

## Implementation Details

### Approach
[Explain the implementation approach]

### Key Decisions
1. **Decision:** [what was decided]
   **Rationale:** [why]

2. **Decision:** [another decision]
   **Rationale:** [why]

### Challenges Encountered
[Any issues faced and how resolved]

---

## Acceptance Criteria Status

- [x] Criterion 1 - Implemented in [file]
- [x] Criterion 2 - Implemented in [file]
- [x] Criterion 3 - Implemented in [file]
- [x] Tests written - See [test file]
- [x] Documentation updated - See [doc file]

---

## Testing Performed

### Unit Tests
- ✅ Test 1: [description] - PASSING
- ✅ Test 2: [description] - PASSING

### Manual Testing
- ✅ Scenario 1: [description] - WORKS
- ✅ Scenario 2: [description] - WORKS

---

## Known Limitations

[Any known issues or future improvements needed]

---

## Security Review

[Any security considerations for auditor]

---

## Next Steps

[What should happen after audit approval]

---

## Questions for Auditor

[Anything specific you want auditor to focus on]
```

---

### **AUDIT Template:**

```markdown
# AUDIT REPORT: [Feature Name]

**Ticket:** PHASE_X_##_FEATURE_NAME  
**Handoff:** PHASE_X_##_FEATURE_NAME_HANDOFF.md  
**Audited By:** [Model name]  
**Date:** YYYY-MM-DD  
**Rating:** 🟢 PASS / 🟡 NEEDS_REVISION / 🔴 FAIL

---

## Executive Summary

[2-3 sentence summary of audit findings]

**Recommendation:** APPROVE / REVISE / REJECT

---

## Acceptance Criteria Review

- [x] ✅ Criterion 1 - VERIFIED
- [x] ✅ Criterion 2 - VERIFIED
- [ ] ❌ Criterion 3 - NOT MET (see issue #1)

---

## Code Quality Review

### ✅ Strengths
1. [Positive finding]
2. [Positive finding]

### ⚠️ Issues Found

#### Issue #1: [Issue Title] - 🔴 CRITICAL / 🟡 HIGH / 🟢 LOW
**File:** `path/to/file.tsx`  
**Line:** 42-45  
**Problem:** [Description of issue]  
**Impact:** [Why this matters]  
**Recommendation:** [How to fix]

```typescript
// Current code (problematic):
const bad = clientTotal // ❌ Trusts client!

// Suggested fix:
const { data } = await supabase.rpc('calculate_order_total', {
  p_items: items
})
const total = data.total // ✅ Server calculated!
```

---

## Security Review

### ✅ Passed Security Checks
- [Security aspect checked]
- [Security aspect checked]

### ⚠️ Security Concerns

#### Security Issue #1: [Title] - 🔴 CRITICAL
[Detailed security issue and fix]

---

## Performance Review

- **Bundle Impact:** [estimated size increase]
- **Database Queries:** [N+1 issues?]
- **Rendering Performance:** [any concerns?]

---

## Test Coverage Review

- **Unit Test Coverage:** XX% (target: 80%+)
- **Integration Tests:** Present / Missing
- **E2E Tests:** Present / Missing

### Missing Tests
1. [Test that should exist]
2. [Test that should exist]

---

## Edge Cases Review

### ✅ Covered
- [Edge case handled]

### ❌ Not Covered
- [Edge case missing - needs handling]

---

## Documentation Review

- **Code Comments:** Adequate / Needs improvement
- **README Updated:** Yes / No
- **API Docs Updated:** Yes / No

---

## Overall Rating: [PASS / NEEDS_REVISION / FAIL]

### If PASS:
- ✅ Ready to merge
- ✅ All criteria met
- ✅ No blocking issues

### If NEEDS_REVISION:
- ⚠️ [Number] issues must be fixed
- ⚠️ See issue #[numbers] above
- ⚠️ Re-audit after fixes

### If FAIL:
- ❌ Critical issues found
- ❌ Requires significant rework
- ❌ See critical issues above

---

## Next Actions

1. [Specific action for developer]
2. [Specific action for orchestrator]
3. [Any follow-up needed]
```

---

## 🎯 WORKFLOW IN PRACTICE

### **Example: Phase 0 - Guest Checkout**

**Day 1 Morning: Planning (Orchestrator)**
```
1. Orchestrator creates PHASE_0_01_GUEST_CHECKOUT_TICKET.md
2. Human reviews and approves ticket
3. Ticket assigned to Builder Agent
```

**Day 1 Afternoon: Implementation (Builder)**
```
1. Builder reads ticket
2. Cursor Composer implements:
   - Alters orders table
   - Updates types
   - Creates guest checkout flow
   - Writes tests
3. Builder creates PHASE_0_01_GUEST_CHECKOUT_HANDOFF.md
4. Human reviews implementation
```

**Day 2 Morning: Audit (Auditor)**
```
1. Start new chat with Gemini 2.0
2. Share ticket + handoff + files
3. Gemini audits code
4. Gemini creates PHASE_0_01_GUEST_CHECKOUT_AUDIT.md
5. Rating: PASS / NEEDS_REVISION / FAIL
```

**Day 2 Afternoon: Decision (Orchestrator)**
```
1. Human shares audit report with Orchestrator
2. Orchestrator reviews findings

If PASS:
  - Updates NORTH_STAR.md (mark ticket complete)
  - Moves to next ticket

If NEEDS_REVISION:
  - Creates revision ticket with fixes
  - Back to Builder with specific issues

If FAIL:
  - Documents failure reason
  - Replans approach
  - Creates new ticket
```

---

## 🚨 CRITICAL RULES

### **1. Never Skip Stages**
- ❌ DON'T go straight from ticket to production
- ✅ ALWAYS go: Ticket → Implementation → Audit → Decision

### **2. Always Update Index**
- ✅ NORTH_STAR.md must reflect current status
- ✅ Update after every completed ticket
- ✅ Future agents rely on this!

### **3. Document Everything**
- ✅ Every decision gets documented
- ✅ Every change gets explained in handoff
- ✅ Every issue gets noted in audit

### **4. Human in the Loop**
- ✅ Human reviews before moving to next stage
- ✅ Human makes final accept/reject decision
- ✅ Agents recommend, human decides

### **5. Quality Over Speed**
- ✅ Better to revise and get it right
- ✅ Failed audits are okay - they catch bugs!
- ✅ 2 extra days for quality = Weeks saved in production

---

## 📊 SUCCESS METRICS

Track these to measure workflow effectiveness:

- **Audit Pass Rate:** Target 80%+ (some revisions expected)
- **Critical Issues Found:** Higher is better (catching bugs early!)
- **Time from Ticket to Merge:** Track average
- **Revision Cycles:** Track how many revisions per ticket
- **Test Coverage:** Target 90%+ for critical paths

---

## 🎯 WHEN TO USE WHICH MODEL

| Task | Recommended Model | Alternative | Reasoning |
|------|------------------|-------------|-----------|
| **Creating Tickets** | Claude Sonnet 4.5 | - | Best at structured docs |
| **Simple Features** | Claude Sonnet 4.5 | - | Fast, reliable |
| **Complex Features** | Claude Opus | Claude Sonnet 4.5 | Deepest reasoning |
| **Testing Code** | Claude Sonnet 4.5 | - | Good at test writing |
| **Security Audit** | Gemini 2.0 | Claude Opus | Different perspective |
| **Architecture Review** | Claude Opus | Gemini 2.0 | Deepest analysis |
| **Quick Audits** | Gemini 2.0 | Claude Sonnet 4.5 | Fast, analytical |
| **Critical Feature Audit** | Cognition Wheel (3 models!) | Claude Opus | Multiple perspectives |

---

## 💡 PRO TIPS

### **For Orchestrator:**
- Keep tickets small (1-2 days max)
- Clear acceptance criteria
- Reference existing patterns
- Link to relevant docs

### **For Builder:**
- Read ticket twice before starting
- Ask questions if unclear
- Document key decisions
- Write tests first (TDD)
- Create detailed handoff

### **For Auditor:**
- Read ticket first (understand intent)
- Check acceptance criteria line-by-line
- Look for edge cases
- Think like an attacker (security)
- Be specific in feedback (line numbers!)

### **For Human:**
- Trust the process
- Don't skip audits (even if you're confident)
- Failed audits are good (catching bugs!)
- Update index files religiously

---

## 🔗 RELATED DOCUMENTS

- `/MEMORY_BANK/ETL_METHODOLOGY.md` - For database migrations
- `/MEMORY_BANK/FRONTEND_COMPETITION_STATUS.md` - Competition setup
- `/FRONTEND_BUILD_START_HERE.md` - Gap analysis
- `/CUSTOMER_ORDERING_APP_BUILD_PLAN.md` - Feature requirements

---

**Last Updated:** 2025-10-22  
**Status:** ✅ ACTIVE - Use for all frontend development  
**Next Review:** After completing 5 tickets (evaluate effectiveness)

