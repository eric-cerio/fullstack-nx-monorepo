---
name: turborepo-patterns
description: Turborepo workspace patterns for the monorepo. Covers task pipelines, package configuration, module boundaries, caching, and filtered commands.
---

# Turborepo Monorepo Patterns

## Workspace Structure

```
├── turbo.json                 # Turborepo task pipeline config
├── tsconfig.base.json         # Shared TypeScript config
├── pnpm-workspace.yaml        # pnpm workspace definition
├── eslint.config.js           # ESLint 9 flat config (root)
├── apps/
│   ├── admin/                 # Next.js 15 app
│   │   ├── package.json       # App-level scripts & deps
│   │   ├── tsconfig.json      # Extends tsconfig.base.json
│   │   └── next.config.js
│   ├── partner/
│   ├── resident/
│   ├── landing-page/
│   └── api/                   # NestJS 11 app
│       ├── package.json
│       ├── tsconfig.json
│       └── tsconfig.app.json
├── packages/
│   └── shared/
│       ├── package.json
│       ├── tsconfig.json
│       └── src/
│           └── index.ts       # Main barrel export
└── database/
    └── migrations/
```

## Package Configuration

Each app and package has its own `package.json` with scripts that Turborepo orchestrates:

```json
// apps/admin/package.json
{
  "name": "@my-org/admin",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev --port 3000",
    "build": "next build",
    "start": "next start",
    "test": "jest --coverage",
    "lint": "eslint . --max-warnings 0"
  },
  "dependencies": {
    "@clerk/nextjs": "^6.0.0",
    "@my-org/shared": "workspace:*",
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  }
}

// apps/api/package.json
{
  "name": "@my-org/api",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "dev": "nest start --watch",
    "build": "nest build",
    "start": "node dist/main",
    "test": "jest --coverage",
    "lint": "eslint . --max-warnings 0"
  },
  "dependencies": {
    "@clerk/backend": "^2.0.0",
    "@my-org/shared": "workspace:*",
    "@nestjs/core": "^11.0.0",
    "@nestjs/common": "^11.0.0"
  }
}

// packages/shared/package.json
{
  "name": "@my-org/shared",
  "version": "0.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "build": "tsc --build",
    "test": "jest --coverage",
    "lint": "eslint . --max-warnings 0"
  }
}
```

## Turborepo Task Pipeline

```json
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"]
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "e2e": {
      "dependsOn": ["build"],
      "cache": false
    }
  }
}
```

Key concepts:
- `dependsOn: ["^build"]` — run dependency builds first (topological)
- `outputs` — what to cache (build artifacts, coverage reports)
- `cache: false` — skip caching for dev servers and E2E tests
- `persistent: true` — mark long-running tasks (dev servers)

## Module Boundary Enforcement

Use `eslint-plugin-boundaries` to enforce import restrictions:

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
      'boundaries/ignore': ['**/*.test.*', '**/*.spec.*'],
    },
    rules: {
      'boundaries/element-types': ['error', {
        default: 'disallow',
        rules: [
          { from: 'app', allow: ['package'] },
          { from: 'package', allow: ['package'] },
        ],
      }],
      'boundaries/no-private': ['error'],
    },
  },
]
```

Rules:
- Apps can import from packages but NOT from other apps
- Packages can import from other packages but NOT from apps
- No cross-app imports ever

## Common Commands

```bash
# Dev
turbo dev --filter=@my-org/admin     # Start admin Next.js dev server
turbo dev --filter=@my-org/api       # Start NestJS API
turbo dev                            # Start all dev servers

# Build
turbo build --filter=@my-org/admin   # Build admin app
turbo build --filter=@my-org/api     # Build NestJS API
turbo build                          # Build all packages

# Test
turbo test --filter=@my-org/api      # Test API
turbo test --filter=@my-org/shared   # Test shared package
turbo test                           # Test all packages

# Lint
turbo lint --filter=@my-org/admin    # Lint admin app
turbo lint                           # Lint all packages

# Cache
turbo daemon clean && rm -rf .turbo  # Clear Turborepo cache
```

## Filtered Commands (CI / Affected)

```bash
# Only build/test/lint what changed since last commit
turbo build --filter=...[HEAD~1]
turbo test --filter=...[HEAD~1]
turbo lint --filter=...[HEAD~1]

# Changes since a specific branch
turbo build --filter=...[origin/main]
turbo test --filter=...[origin/main]

# Filter by package name
turbo build --filter=@my-org/admin
turbo test --filter=@my-org/api --filter=@my-org/shared

# Filter by directory
turbo build --filter=./apps/*
turbo test --filter=./packages/*

# Dry run (see what would execute)
turbo build --filter=...[HEAD~1] --dry-run
```

## Turborepo Caching

Turborepo caches task results. If inputs haven't changed, tasks are replayed from cache:
- Local cache: `.turbo/` directory
- Remote cache: Configure in `turbo.json` or via Vercel Remote Cache
- Reset: `turbo daemon clean && rm -rf .turbo`

## Workspace Dependencies

Packages reference each other via `workspace:*` in `package.json`:

```json
{
  "dependencies": {
    "@my-org/shared": "workspace:*"
  }
}
```

pnpm resolves `workspace:*` to the local package. Turborepo uses `dependsOn: ["^build"]` to ensure dependencies build first.

## Adding a New Package

1. Create directory under `packages/` (or `apps/` for apps)
2. Add `package.json` with name, scripts, and dependencies
3. Ensure it's covered by `pnpm-workspace.yaml` globs
4. Add `workspace:*` dependency in consumers
5. Run `pnpm install` to link
6. Verify with `turbo ls` and `turbo build --filter=@my-org/new-package`

## Listing Workspace Packages

```bash
turbo ls                             # List all workspace packages
turbo ls --filter=./apps/*           # List only apps
turbo ls --filter=./packages/*       # List only packages
```
