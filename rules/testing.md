# Testing Requirements

## Minimum Coverage: 80% Per Nx Project

Test per project, not globally:
```bash
pnpm nx test api --coverage
pnpm nx test admin --coverage
pnpm nx test shared --coverage
pnpm nx affected --target=test
```

## Test Types (ALL required)

1. **Unit Tests** — Functions, services, utilities
2. **Integration Tests** — NestJS controllers, API endpoints
3. **E2E Tests** — Critical user flows per app (Playwright)

## TDD Workflow (MANDATORY)

1. Write test first (RED)
2. Run test — it should FAIL
3. Write minimal implementation (GREEN)
4. Run test — it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Agent Support

- **tdd-guide** — TDD enforcement per Nx project
- **e2e-runner** — Playwright E2E per app

## 100% Coverage Required For

- Clerk auth guards
- Role-based access checks
- Shared utility functions in `libs/shared`
- Database query functions
- Migration rollback logic
