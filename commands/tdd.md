---
description: Enforce TDD workflow per Nx project. Write tests FIRST with Jest, then implement. Uses pnpm nx test for per-project testing. Ensure 80%+ coverage.
---

# TDD Command

Invokes the **tdd-guide** agent for test-driven development per Nx project.

## What This Command Does

1. **Identify Target Nx Project** — apps/api, apps/admin, libs/shared, etc.
2. **Scaffold Interfaces** — Define types/DTOs first
3. **Write Failing Tests** — RED phase using Jest
4. **Implement Minimal Code** — GREEN phase
5. **Refactor** — IMPROVE phase
6. **Verify Coverage** — `pnpm nx test <project> --coverage`

## Test Commands

```bash
pnpm nx test api                          # NestJS API tests
pnpm nx test admin                        # Admin app tests
pnpm nx test shared                       # Shared lib tests
pnpm nx test api --coverage               # With coverage
pnpm nx affected --target=test            # Only affected projects
```

## When to Use

- Implementing new NestJS services/controllers
- Adding Next.js components with logic
- Creating shared utility functions
- Fixing bugs (write reproducing test first)

## Related Agent

`~/.claude/agents/tdd-guide.md`
