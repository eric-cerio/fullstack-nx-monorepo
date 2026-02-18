---
description: Restate requirements, assess Nx project graph impact, and create step-by-step implementation plan for the monorepo. WAIT for user CONFIRM before touching any code.
---

# Plan Command

Invokes the **planner** agent to create a comprehensive implementation plan for the Nx monorepo.

## What This Command Does

1. **Restate Requirements** — Clarify what needs to be built
2. **Identify Affected Nx Projects** — Which apps/libs are impacted
3. **Assess Nx Graph Impact** — Module boundary and dependency analysis
4. **Create Step Plan** — Phases: shared libs → migrations → API → frontends
5. **Wait for Confirmation** — MUST receive user approval before coding

## When to Use

- Starting a new feature that spans multiple apps
- Adding new NestJS modules or API endpoints
- Changes that affect `libs/shared`
- Database migration creation
- Any change touching more than one Nx project

## Integration

After planning:
- Use `/tdd` to implement with tests
- Use `/build-fix` if Nx build errors occur
- Use `/code-review` to review implementation
- Use `/document-feature` to create feature documentation

## Related Agent

`~/.claude/agents/planner.md`
