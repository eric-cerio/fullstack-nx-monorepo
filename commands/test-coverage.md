---
description: Analyze test coverage per Nx project and generate missing tests. Ensure 80%+ coverage across all projects.
---

# Test Coverage Command

Analyze coverage per Nx project and fill gaps.

## What This Command Does

1. Run tests with coverage per project:
   ```bash
   pnpm nx test api --coverage
   pnpm nx test admin --coverage
   pnpm nx test shared --coverage
   ```

2. Analyze coverage reports per project

3. Identify files below 80% threshold

4. Generate missing tests (unit, integration, E2E)

5. Show before/after coverage metrics per project

## Targets

- 80% minimum for all projects
- 100% for auth guards, role checks, shared utils
- Check: `pnpm nx run-many --target=test -- --coverage`
