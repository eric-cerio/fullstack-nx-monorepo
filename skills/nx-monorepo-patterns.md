---
name: nx-monorepo-patterns
description: Nx workspace patterns for the monorepo. Covers project configuration, generators, executors, module boundaries, caching, and affected commands.
---

# Nx Monorepo Patterns

## Workspace Structure

```
├── nx.json                    # Nx workspace config
├── tsconfig.base.json         # Shared TypeScript config
├── pnpm-workspace.yaml        # pnpm workspace definition
├── eslint.config.js           # ESLint 9 flat config (root)
├── apps/
│   ├── admin/                 # Next.js 15 app
│   │   ├── project.json       # Nx project config
│   │   ├── tsconfig.json      # Extends tsconfig.base.json
│   │   └── next.config.js
│   ├── partner/
│   ├── resident/
│   ├── landing-page/
│   └── api/                   # NestJS 11 app
│       ├── project.json
│       ├── tsconfig.json
│       └── tsconfig.app.json
├── libs/
│   └── shared/
│       ├── project.json
│       ├── tsconfig.json
│       └── src/
│           └── index.ts       # Main barrel export
└── database/
    └── migrations/
```

## Project Configuration

```json
// apps/admin/project.json
{
  "name": "admin",
  "tags": ["type:app", "scope:admin"],
  "targets": {
    "build": { "executor": "@nx/next:build" },
    "serve": { "executor": "@nx/next:server" },
    "lint": { "executor": "@nx/eslint:lint" },
    "test": { "executor": "@nx/jest:jest" }
  }
}

// apps/api/project.json
{
  "name": "api",
  "tags": ["type:app", "scope:api"],
  "targets": {
    "build": { "executor": "@nx/webpack:webpack" },
    "serve": { "executor": "@nx/js:node" },
    "lint": { "executor": "@nx/eslint:lint" },
    "test": { "executor": "@nx/jest:jest" }
  }
}

// libs/shared/project.json
{
  "name": "shared",
  "tags": ["type:lib", "scope:shared"],
  "targets": {
    "build": { "executor": "@nx/js:tsc" },
    "lint": { "executor": "@nx/eslint:lint" },
    "test": { "executor": "@nx/jest:jest" }
  }
}
```

## Module Boundary Enforcement

```javascript
// eslint.config.js (root)
import { nxPlugin } from '@nx/eslint-plugin'

export default [
  ...nxPlugin.configs['flat/base'],
  {
    rules: {
      '@nx/enforce-module-boundaries': ['error', {
        depConstraints: [
          { sourceTag: 'type:app', onlyDependOnLibsWithTags: ['type:lib'] },
          { sourceTag: 'type:lib', onlyDependOnLibsWithTags: ['type:lib'] },
        ],
      }],
    },
  },
]
```

## Common Commands

```bash
# Serve
pnpm nx serve admin           # Start admin Next.js dev server
pnpm nx serve api             # Start NestJS API
pnpm nx serve partner         # Start partner app

# Build
pnpm nx build admin           # Build admin app
pnpm nx build api             # Build NestJS API
pnpm nx run-many --target=build # Build all

# Test
pnpm nx test api              # Test API
pnpm nx test shared           # Test shared lib
pnpm nx affected --target=test # Test only affected

# Lint
pnpm nx lint admin            # Lint admin app
pnpm nx run-many --target=lint # Lint all

# Cache
pnpm nx reset                 # Clear Nx cache
```

## Affected Commands (CI)

```bash
# Only build/test/lint what changed
pnpm nx affected --target=build --base=main
pnpm nx affected --target=test --base=main
pnpm nx affected --target=lint --base=main

# See what's affected
pnpm nx affected --target=build --base=main --dry-run
```

## Nx Caching

Nx caches task results. If inputs haven't changed, tasks are replayed from cache:
- Local cache: `.nx/cache/`
- Remote cache: Configure in `nx.json` for CI sharing
- Reset: `pnpm nx reset`

**Android Comparison**: Nx is like Gradle for the monorepo. `project.json` is like `build.gradle`. Module boundaries are like Gradle's project dependencies. `pnpm nx affected` is like Gradle's incremental builds. Nx caching is like Gradle's build cache.
