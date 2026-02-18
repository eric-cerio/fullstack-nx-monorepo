# Git Workflow

## Commit Message Format

```
<type>(<scope>): <description>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci
Scopes: admin, partner, resident, api, shared, migrations, landing-page

Examples:
```
feat(api): add user CRUD endpoints with Clerk auth
fix(admin): resolve role check in middleware
test(shared): add unit tests for date utils
chore(migrations): add users table migration
```

## Pre-Commit Hooks (Husky + lint-staged)

Automatically runs on commit:
- ESLint on staged `.ts/.tsx` files
- Prettier formatting
- TypeScript type checking

## Feature Workflow

1. **Plan First** — Use `/plan` to identify affected Nx projects
2. **TDD** — Use `/tdd` per affected project
3. **Code Review** — Use `/code-review` after implementation
4. **Document** — Use `/document-feature` to create feature docs
5. **Build Check** — `pnpm nx affected --target=build`
6. **Commit** — Conventional commits with scope

## CI with Nx Affected

```bash
# Only run what changed (for CI)
pnpm nx affected --target=lint --base=main
pnpm nx affected --target=test --base=main
pnpm nx affected --target=build --base=main
```

## Pull Request Requirements

- All affected tests pass
- All affected builds succeed
- Code review completed
- Feature documentation created in `docs/features/`
