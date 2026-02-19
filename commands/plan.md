---
description: Restate requirements, assess workspace dependency impact, and create step-by-step implementation plan for the monorepo. WAIT for user CONFIRM before touching any code.
---

# Plan Command

Invokes the **planner** agent to create a comprehensive implementation plan for the Turborepo monorepo.

## What This Command Does

1. **Restate Requirements** — Clarify what needs to be built
2. **Identify Affected Packages** — Which apps/packages are impacted
3. **Assess Dependency Impact** — Module boundary and dependency analysis
4. **Create Step Plan** — Phases: shared packages → migrations → API → frontends
5. **Wait for Confirmation** — MUST receive user approval before coding

## When to Use

- Starting a new feature that spans multiple apps
- Adding new NestJS modules or API endpoints
- Changes that affect `packages/shared`
- Database migration creation
- Any change touching more than one workspace package

## Integration

After planning:

- Use `/tdd` to implement with tests
- Use `/build-fix` if build errors occur
- Use `/code-review` to review implementation
- Use `/document-feature` to create feature documentation

## Related Agent

`agents/planner.md`
