# 📊 AUDITS - Quality Control Reports

This folder contains audit reports created by the Auditor Agent (Gemini 2.0 or Claude Opus).

## Naming Convention

`PHASE_[X]_[##]_[FEATURE_NAME]_AUDIT.md`

Examples:
- `PHASE_0_01_GUEST_CHECKOUT_AUDIT.md`
- `PHASE_2_15_DISH_MODAL_AUDIT.md`

## Purpose

Audits provide:
- Verification of acceptance criteria
- Code quality review
- Security analysis
- Performance review
- Test coverage assessment
- Rating: PASS / NEEDS_REVISION / FAIL
- Specific, actionable feedback

## Auditor Models

- **Gemini 2.0:** Regular audits (different perspective from Claude)
- **Claude Opus:** Critical/complex feature audits
- **Cognition Wheel (3 models):** Super critical features only

## When to Create

Create audit after reading ticket + handoff + reviewing all code changes.

## Template

See `/MEMORY_BANK/AGENT_ORCHESTRATION_WORKFLOW.md` for full audit template.

