# Module Boundary Rules

## Dependency Direction

```text
apps/admin       ──→ packages/shared  ✅
apps/partner     ──→ packages/shared  ✅
apps/resident    ──→ packages/shared  ✅
apps/api         ──→ packages/shared  ✅
apps/landing-page ──→ packages/shared ✅

apps/admin       ──→ apps/partner  ❌ FORBIDDEN
apps/partner     ──→ apps/api      ❌ FORBIDDEN
packages/shared  ──→ apps/*        ❌ FORBIDDEN
```

## ESLint Enforcement (eslint-plugin-boundaries)

```javascript
// eslint.config.js (root)
import boundaries from 'eslint-plugin-boundaries'

export default [
  {
    plugins: { boundaries },
    settings: {
      'boundaries/elements': [
        { type: 'app', pattern: 'apps/*' },
        { type: 'package', pattern: 'packages/*' },
      ],
    },
    rules: {
      'boundaries/element-types': ['error', {
        default: 'disallow',
        rules: [
          { from: 'app', allow: ['package'] },
          { from: 'package', allow: ['package'] },
        ],
      }],
    },
  },
]
```

## Workspace Dependencies

Each app declares its dependency on shared packages via `package.json`:

```json
// apps/admin/package.json
{
  "dependencies": {
    "@my-org/shared": "workspace:*"
  }
}
```

## What Goes Where

### `packages/shared` (Shared by ALL)

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

1. Is it a **type/interface**? → Move to `packages/shared/src/types/`
2. Is it a **utility function**? → Move to `packages/shared/src/utils/`
3. Is it a **constant**? → Move to `packages/shared/src/constants/`
4. Is it a **React component**? → Keep separate per app (each app owns its UI)
5. Is it **business logic**? → Keep in `apps/api` (frontends call the API)

## Checking Boundaries

```bash
turbo lint --filter=@my-org/admin  # Check admin's imports
turbo lint                          # Check all packages
```

## Red Flags

- ❌ Importing from `apps/` in `packages/`
- ❌ Importing from one app in another app
- ❌ Frontend importing NestJS decorators
- ❌ Backend importing React components
- ❌ Missing workspace dependency in `package.json`
