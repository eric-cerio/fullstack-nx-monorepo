---
description: Generate living documentation for a completed feature implementation. Creates structured docs in docs/features/ so Claude can reference them during future reviews and modifications. MUST RUN after every feature implementation.
---

# Document Feature Command

Invokes the **feature-documenter** agent to create per-feature documentation.

## What This Command Does

1. **Analyze Implementation** — Check git diff to identify what was built
2. **Identify Scope** — Which Nx projects, API endpoints, migrations were involved
3. **Write Feature Doc** — Create `docs/features/<feature-name>.md` with:
   - Overview and purpose
   - Architecture (affected apps/libs, data flow)
   - Key files with their roles
   - API endpoints (method, path, auth role, description)
   - Clerk role access matrix
   - Database changes and migration references
   - Testing commands and test file locations
   - Edge cases and known limitations
   - Feature dependencies
4. **Update Index** — Add entry to `docs/features/INDEX.md`

## When to Use

**MUST USE after:**
- Completing a new feature
- Significant modifications to an existing feature
- Adding new API endpoints
- Creating database migrations
- Adding new pages/routes to any app

## Why This Matters

Claude has no memory between sessions. These docs are Claude's memory. When you run `/code-review` or ask Claude to modify a feature later, it reads `docs/features/` first to understand the context.

## Usage

```
/document-feature user-authentication
/document-feature partner-onboarding
/document-feature admin-analytics-dashboard
```

## Output Location

```
docs/features/
├── INDEX.md                     # Auto-generated index
├── user-authentication.md       # Feature doc
├── partner-onboarding.md        # Feature doc
└── ...
```

## Related Agent

`~/.claude/agents/feature-documenter.md`
