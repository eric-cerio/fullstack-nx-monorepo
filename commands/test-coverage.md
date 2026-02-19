---
description: Analyze test coverage per workspace package and generate missing tests. Ensure 80%+ coverage across all packages.
---

# Test Coverage Command

Analyze coverage per workspace package and fill gaps.

## What This Command Does

1. Run tests with coverage per package:

   ```bash
   turbo test --filter=@my-org/api -- --coverage
   turbo test --filter=@my-org/admin -- --coverage
   turbo test --filter=@my-org/shared -- --coverage
   ```

2. Analyze coverage reports per package

3. Identify files below 80% threshold

4. Generate missing tests (unit, integration, E2E)

5. Show before/after coverage metrics per package

## Targets

- 80% minimum for all packages
- 100% for auth guards, role checks, shared utils
- Check: `turbo test -- --coverage`
