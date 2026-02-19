---
description: Generate and run Playwright E2E tests for specific app (admin, partner, or resident). Tests with Clerk auth mocking, role-based access, and cross-app security.
---

# E2E Command

Invokes the **e2e-runner** agent for Playwright E2E testing per app.

## What This Command Does

1. Identify target app (admin, partner, or resident)
2. Generate Playwright tests using Page Object Model
3. Mock Clerk authentication for the target role
4. Run tests: `turbo e2e --filter=@my-org/<app>-e2e`
5. Capture artifacts (screenshots, videos, traces)
6. Test cross-role access denial

## Usage

```
/e2e admin — Test admin dashboard flows
/e2e partner — Test partner portal flows
/e2e resident — Test resident portal flows
```

## Commands

```bash
turbo e2e --filter=@my-org/admin-e2e
turbo e2e --filter=@my-org/partner-e2e
turbo e2e --filter=@my-org/resident-e2e
turbo e2e --filter=@my-org/admin-e2e -- --headed
turbo e2e --filter=...[HEAD~1]
```

## Related Agent

`agents/e2e-runner.md`
