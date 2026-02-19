---
description: Incrementally fix build and TypeScript errors. Uses turbo build, handles tsconfig paths, module boundaries, and NestJS/Next.js specific errors. Minimal diffs only.
---

# Build Fix Command

Invokes the **build-error-resolver** agent to fix build errors.

## What This Command Does

1. Run `turbo build --filter=<package>` or `turbo build`
2. Parse error output and group by workspace package
3. Fix one error at a time with minimal changes
4. Re-run build after each fix
5. Verify with `turbo build --filter=...[HEAD~1]`

## Common Fix Targets

```bash
turbo build --filter=@my-org/admin    # Next.js admin build
turbo build --filter=@my-org/api      # NestJS API build
turbo build --filter=@my-org/shared   # Shared package build
turbo build                           # All packages
turbo daemon clean && rm -rf .turbo   # Clear cache if stale
```

## Stop Conditions

- Fix introduces new errors → rollback
- Same error persists after 3 attempts → escalate
- User requests pause

## Related Agent

`agents/build-error-resolver.md`
