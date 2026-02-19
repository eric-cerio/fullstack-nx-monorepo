# Performance Optimization

## Model Selection Strategy

**Haiku 4.5** (Fast, cost-effective):

- Lightweight per-package agents
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

## Turborepo Caching

Leverage Turborepo caching to avoid redundant work:

```bash
turbo test --filter=...[HEAD~1]    # Only test what changed
turbo build --filter=...[HEAD~1]   # Only build what changed
turbo daemon clean && rm -rf .turbo  # Clear stale cache
```

## Context Window Management

Avoid last 20% of context window for:

- Large-scale cross-app refactoring
- Full monorepo analysis
- Multi-file feature implementation

Lower context sensitivity:

- Single-package edits
- Migration file creation
- Documentation updates

## Build Troubleshooting

1. Use **build-error-resolver** agent
2. Start with `turbo daemon clean` to clear cache
3. Then `turbo build --filter=<package>` for specific package
4. Then `turbo build --filter=...[HEAD~1]` for ripple effects
