---
description: Safely identify and remove dead code across the Nx monorepo with test verification. Uses knip, depcheck, and Nx dependency analysis.
---

# Refactor Clean Command

Safely identify and remove dead code across the monorepo.

## What This Command Does

1. Run dead code analysis tools per Nx project:
   - `knip` — unused exports and files
   - `depcheck` — unused dependencies
   - Nx graph — orphaned projects

2. Categorize by risk:
   - SAFE: Unused utilities, test helpers
   - CAUTION: Shared lib exports (might be used by other apps)
   - DANGER: Config files, NestJS modules, middleware

3. Before each deletion:
   - Run `pnpm nx affected --target=test`
   - Verify tests pass
   - Apply change
   - Re-run tests
   - Rollback if tests fail

4. Show summary of cleaned items

Never delete shared lib exports without checking ALL consuming apps!
