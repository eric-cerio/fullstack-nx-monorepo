---
description: Safely identify and remove dead code across the Turborepo monorepo with test verification. Uses knip, depcheck, and dependency analysis.
---

# Refactor Clean Command

Safely identify and remove dead code across the monorepo.

## What This Command Does

1. Run dead code analysis tools per workspace package:
   - `knip` — unused exports and files
   - `depcheck` — unused dependencies
   - Dependency analysis — orphaned packages

2. Categorize by risk:
   - SAFE: Unused utilities, test helpers
   - CAUTION: Shared package exports (might be used by other apps)
   - DANGER: Config files, NestJS modules, middleware

3. Before each deletion:
   - Run `turbo test --filter=...[HEAD~1]`
   - Verify tests pass
   - Apply change
   - Re-run tests
   - Rollback if tests fail

4. Show summary of cleaned items

Never delete shared package exports without checking ALL consuming apps!
