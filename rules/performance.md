# Performance Optimization

## Model Selection Strategy

**Haiku 4.5** (Fast, cost-effective):
- Lightweight per-project agents
- Pair programming and code generation
- Simple file edits

**Sonnet 4.6** (Best coding):
- Main development work
- Orchestrating multi-agent workflows
- Complex feature implementation

**Opus 4.6** (Deepest reasoning):
- Architectural decisions for monorepo
- Complex cross-app refactoring
- Security reviews

## Nx Caching

Leverage Nx caching to avoid redundant work:
```bash
pnpm nx affected --target=test    # Only test what changed
pnpm nx affected --target=build   # Only build what changed
pnpm nx reset                     # Clear stale cache
```

## Context Window Management

Avoid last 20% of context window for:
- Large-scale cross-app refactoring
- Full monorepo analysis
- Multi-file feature implementation

Lower context sensitivity:
- Single-project edits
- Migration file creation
- Documentation updates

## Build Troubleshooting

1. Use **build-error-resolver** agent
2. Start with `pnpm nx reset` to clear cache
3. Then `pnpm nx build <project>` for specific project
4. Then `pnpm nx affected --target=build` for ripple effects
