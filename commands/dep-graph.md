---
description: Analyze workspace dependency graph. Detect circular deps, boundary violations, and orphaned packages. Essential before restructuring.
---

# Dependency Graph Command

Invokes the **dependency-analyzer** agent to analyze the workspace dependency graph.

## What This Command Does

1. List workspace packages with `turbo ls`
2. Analyze dependency relationships via `package.json` files
3. Check for circular dependencies
4. Validate module boundary rules (`eslint-plugin-boundaries`)
5. Identify orphaned or misconfigured packages
6. Report findings with recommendations

## When to Use

- Before adding a new package to the monorepo
- After restructuring apps or packages
- When debugging unexpected build failures
- During architectural reviews

## Commands

```bash
turbo ls                           # List all workspace packages
turbo build --graph                # Visualize build graph
turbo lint                         # Check boundary violations
```

## Related Agent

`agents/dependency-analyzer.md`
