# Project CLAUDE.md — Turborepo Full-Stack Monorepo

Place this file in the root of your Turborepo monorepo project.

## Project Overview

Full-stack monorepo built with Turborepo, serving multiple Next.js 15 frontend apps and a NestJS 11 REST API, unified by Clerk authentication with role-based access control.

### Tech Stack
- **Monorepo**: Turborepo + pnpm workspaces
- **Frontend**: Next.js 15 (admin, partner, resident, landing-page) + shadcn/ui + Tailwind CSS
- **Backend**: NestJS 11 REST API
- **Auth**: Clerk (role-based via `sessionClaims.metadata.role`)
- **Database**: SQL with migrations in `database/migrations/`
- **Testing**: Jest (unit/integration), Playwright (E2E)
- **Linting**: ESLint 9 flat config + Prettier + Husky + lint-staged

## Monorepo Structure

```
apps/
├── admin/          # Next.js 15 — Admin dashboard (role: admin)
├── partner/        # Next.js 15 — Partner portal (role: partner)
├── resident/       # Next.js 15 — Resident portal (role: resident)
├── landing-page/   # Next.js 15 — Public marketing site
└── api/            # NestJS 11 — REST API
packages/
└── shared/         # Shared types, utils, constants
database/
└── migrations/     # SQL migration files (YYYYMMDDHHMMSS_name.sql)
docs/
└── features/       # Living feature documentation (Claude's memory)
```

## Critical Rules

### 1. Module Boundaries
- Apps CANNOT import from other apps
- Apps CAN import from `packages/shared`
- `packages/shared` CANNOT import from apps
- Enforced by ESLint `eslint-plugin-boundaries`

### 2. Clerk Auth — Every Endpoint Needs Guards
```typescript
@UseGuards(ClerkAuthGuard, RolesGuard)
@Roles('admin')
```

### 3. Package Manager — pnpm Only
```bash
pnpm install          # ✅
pnpm add <package>    # ✅
npm install           # ❌ BLOCKED by hook
yarn add              # ❌ BLOCKED by hook
```

### 4. Code Style
- No console.log (use NestJS Logger)
- No `any` types
- Immutable patterns (spread operator)
- Files < 800 lines, functions < 50 lines
- DTOs validated with class-validator

### 5. Testing
- TDD: Write tests FIRST
- 80% minimum coverage per workspace package
- `turbo test --filter=@my-org/<package> -- --coverage`

### 6. Feature Documentation (MANDATORY)
After every feature implementation, run `/document-feature` to create docs in `docs/features/`. Claude reads these before reviewing code.

## Key Commands

```bash
# Dev
turbo dev --filter=@my-org/admin      # Admin app
turbo dev --filter=@my-org/api        # NestJS API

# Build
turbo build --filter=@my-org/admin    # Build specific app
turbo build --filter=...[HEAD~1]      # Build affected only

# Test
turbo test --filter=@my-org/api       # Test API
turbo test --filter=@my-org/shared    # Test shared package
turbo test --filter=...[HEAD~1]       # Test affected only

# Lint
turbo lint --filter=@my-org/admin     # Lint specific app
turbo lint                            # Lint all

# E2E
turbo e2e --filter=@my-org/admin-e2e  # E2E admin app

# Cache
turbo daemon clean && rm -rf .turbo   # Clear Turbo cache
```

## Available Slash Commands

| Command | Purpose |
|---------|---------|
| `/plan` | Create implementation plan (workspace-aware) |
| `/tdd` | Test-driven development per package |
| `/code-review` | Review with boundary + Clerk auth checks |
| `/build-fix` | Fix build errors |
| `/e2e` | Generate/run Playwright E2E per app |
| `/test-coverage` | Coverage analysis per package |
| `/refactor-clean` | Dead code removal across monorepo |
| `/dep-graph` | Analyze workspace dependency graph |
| `/migrate` | Create/review SQL migrations |
| `/document-feature` | Create feature documentation |
| `/update-docs` | Sync all documentation |
| `/status` | Project health dashboard |
| `/full-review` | Chained code + security + coverage review |

## Feature Implementation Workflow

```
/plan → /tdd → implement → /code-review → /document-feature → commit
```

## Environment Variables

Each app needs its own `.env.local`:

```bash
# Frontend apps (admin, partner, resident)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...
NEXT_PUBLIC_API_URL=http://localhost:4000

# API (NestJS)
CLERK_SECRET_KEY=sk_...
CLERK_WEBHOOK_SECRET=whsec_...
DATABASE_URL=postgresql://...
PORT=4000
```

## Clerk Roles

| Role | App Access | API Access |
|------|-----------|------------|
| `admin` | Admin dashboard | All endpoints |
| `partner` | Partner portal | Partner endpoints |
| `resident` | Resident portal | Resident endpoints |

## Git Workflow

- Conventional commits: `feat(admin):`, `fix(api):`, `test(shared):`
- Scopes: admin, partner, resident, api, shared, migrations, landing-page
- PRs require: tests pass, build succeeds, code review, feature doc
- CI: `turbo lint --filter=...[origin/main] && turbo test --filter=...[origin/main] && turbo build --filter=...[origin/main]`
