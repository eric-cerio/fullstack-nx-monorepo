---
description: Visualize and validate the Nx project dependency graph. Detect circular deps, boundary violations, and orphaned projects. Essential before restructuring.
---

# Nx Graph Command

Invokes the **nx-dependency-analyzer** agent to analyze the project graph.

## What This Command Does

1. Run `pnpm nx graph --file=output.json`
2. Analyze dependency relationships
3. Check for circular dependencies
4. Validate module boundary rules
5. Identify orphaned or misconfigured projects
6. Report findings with recommendations

## When to Use

- Before adding a new library to the monorepo
- After restructuring apps or libs
- When debugging unexpected build failures
- During architectural reviews

## Commands

```bash
pnpm nx graph                           # Visual graph in browser
pnpm nx graph --file=graph.json         # JSON output
pnpm nx show projects                   # List all projects
pnpm nx show project admin              # Project details
pnpm nx run-many --target=lint          # Check boundary violations
```

## Related Agent

`~/.claude/agents/nx-dependency-analyzer.md`
