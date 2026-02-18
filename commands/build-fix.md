---
description: Incrementally fix Nx build and TypeScript errors. Uses pnpm nx build, handles tsconfig paths, module boundaries, and NestJS/Next.js specific errors. Minimal diffs only.
---

# Build Fix Command

Invokes the **build-error-resolver** agent to fix Nx build errors.

## What This Command Does

1. Run `pnpm nx build <project>` or `pnpm nx run-many --target=build`
2. Parse error output and group by Nx project
3. Fix one error at a time with minimal changes
4. Re-run build after each fix
5. Verify with `pnpm nx affected --target=build`

## Common Fix Targets

```bash
pnpm nx build admin            # Next.js admin build
pnpm nx build api              # NestJS API build
pnpm nx build shared           # Shared lib build
pnpm nx run-many --target=build # All projects
pnpm nx reset                  # Clear Nx cache if stale
```

## Stop Conditions

- Fix introduces new errors → rollback
- Same error persists after 3 attempts → escalate
- User requests pause

## Related Agent

`~/.claude/agents/build-error-resolver.md`
