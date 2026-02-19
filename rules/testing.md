# Testing Requirements

## Minimum Coverage: 80% Per Workspace Package

Test per package, not globally:

```bash
turbo test --filter=@my-org/api -- --coverage
turbo test --filter=@my-org/admin -- --coverage
turbo test --filter=@my-org/shared -- --coverage
turbo test --filter=...[HEAD~1]
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

- **tdd-guide** — TDD enforcement per workspace package
- **e2e-runner** — Playwright E2E per app

## 100% Coverage Required For

- Clerk auth guards
- Role-based access checks
- Shared utility functions in `packages/shared`
- Database query functions
- Migration rollback logic
