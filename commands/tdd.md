---
description: Enforce TDD workflow per workspace package. Write tests FIRST with Jest, then implement. Uses turbo test for per-package testing. Ensure 80%+ coverage.
---

# TDD Command

Invokes the **tdd-guide** agent for test-driven development per workspace package.

## What This Command Does

1. **Identify Target Package** — apps/api, apps/admin, packages/shared, etc.
2. **Scaffold Interfaces** — Define types/DTOs first
3. **Write Failing Tests** — RED phase using Jest
4. **Implement Minimal Code** — GREEN phase
5. **Refactor** — IMPROVE phase
6. **Verify Coverage** — `turbo test --filter=@my-org/<package> -- --coverage`

## Test Commands

```bash
turbo test --filter=@my-org/api           # NestJS API tests
turbo test --filter=@my-org/admin         # Admin app tests
turbo test --filter=@my-org/shared        # Shared package tests
turbo test --filter=@my-org/api -- --coverage  # With coverage
turbo test --filter=...[HEAD~1]           # Only affected packages
```

## When to Use

- Implementing new NestJS services/controllers
- Adding Next.js components with logic
- Creating shared utility functions
- Fixing bugs (write reproducing test first)

## Related Agent

`agents/tdd-guide.md`
