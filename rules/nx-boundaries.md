# Nx Module Boundary Rules

## Dependency Direction

```
apps/admin       ──→ libs/shared  ✅
apps/partner     ──→ libs/shared  ✅
apps/resident    ──→ libs/shared  ✅
apps/api         ──→ libs/shared  ✅
apps/landing-page ──→ libs/shared ✅

apps/admin       ──→ apps/partner  ❌ FORBIDDEN
apps/partner     ──→ apps/api      ❌ FORBIDDEN
libs/shared      ──→ apps/*        ❌ FORBIDDEN
```

## ESLint Enforcement

```javascript
// eslint.config.js (root)
'@nx/enforce-module-boundaries': ['error', {
  depConstraints: [
    { sourceTag: 'type:app', onlyDependOnLibsWithTags: ['type:lib'] },
    { sourceTag: 'type:lib', onlyDependOnLibsWithTags: ['type:lib'] },
  ],
}]
```

## Project Tags

Each project must have tags in `project.json`:
```json
// apps/admin/project.json
{ "tags": ["type:app", "scope:admin"] }

// apps/api/project.json
{ "tags": ["type:app", "scope:api"] }

// libs/shared/project.json
{ "tags": ["type:lib", "scope:shared"] }
```

## What Goes Where

### `libs/shared` (Shared by ALL)
- TypeScript types/interfaces
- Pure utility functions (no side effects)
- Constants (roles, API routes, config values)
- Zod/class-validator schemas

### `apps/api` (Backend Only)
- NestJS modules, controllers, services
- Database queries
- Clerk JWT verification
- Business logic

### `apps/admin|partner|resident` (Frontend Only)
- React components
- shadcn/ui components (per-app)
- Next.js pages and layouts
- Clerk middleware (per-app)

## When Code Needs to Be Shared

If two apps need the same code:
1. Is it a **type/interface**? → Move to `libs/shared/src/types/`
2. Is it a **utility function**? → Move to `libs/shared/src/utils/`
3. Is it a **constant**? → Move to `libs/shared/src/constants/`
4. Is it a **React component**? → Keep separate per app (each app owns its UI)
5. Is it **business logic**? → Keep in `apps/api` (frontends call the API)

## Checking Boundaries

```bash
pnpm nx lint admin       # Check admin's imports
pnpm nx run-many --target=lint  # Check all projects
pnpm nx graph            # Visualize dependency graph
```

## Red Flags

- ❌ Importing from `apps/` in `libs/`
- ❌ Importing from one app in another app
- ❌ Frontend importing NestJS decorators
- ❌ Backend importing React components
- ❌ Missing tags in `project.json`
