# Project CLAUDE.md — Nx Full-Stack Monorepo

Place this file in the root of your Nx monorepo project.

## Project Overview

Full-stack monorepo built with Nx, serving multiple Next.js 15 frontend apps and a NestJS 11 REST API, unified by Clerk authentication with role-based access control.

### Tech Stack
- **Monorepo**: Nx + pnpm (v10.20.0)
- **Frontend**: Next.js 15 (admin, partner, resident, landing-page) + shadcn/ui + Tailwind CSS
- **Backend**: NestJS 11 REST API
- **Auth**: Clerk (role-based via `sessionClaims.metadata.role`)
- **Database**: SQL with migrations in `database/migrations/`
- **Testing**: Jest via `@nx/jest`, Playwright for E2E
- **Linting**: ESLint 9 flat config + Prettier + Husky + lint-staged

## Monorepo Structure

```
apps/
├── admin/          # Next.js 15 — Admin dashboard (role: admin)
├── partner/        # Next.js 15 — Partner portal (role: partner)
├── resident/       # Next.js 15 — Resident portal (role: resident)
├── landing-page/   # Next.js 15 — Public marketing site
└── api/            # NestJS 11 — REST API
libs/
└── shared/         # Shared types, utils, constants
database/
└── migrations/     # SQL migration files (YYYYMMDDHHMMSS_name.sql)
docs/
└── features/       # Living feature documentation (Claude's memory)
```

## Critical Rules

### 1. Nx Module Boundaries
- Apps CANNOT import from other apps
- Apps CAN import from `libs/shared`
- `libs/shared` CANNOT import from apps
- Enforced by ESLint `@nx/enforce-module-boundaries`

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
- 80% minimum coverage per Nx project
- `pnpm nx test <project> --coverage`

### 6. Feature Documentation (MANDATORY)
After every feature implementation, run `/document-feature` to create docs in `docs/features/`. Claude reads these before reviewing code.

## Key Commands

```bash
# Serve
pnpm nx serve admin           # Admin app
pnpm nx serve api             # NestJS API

# Build
pnpm nx build admin           # Build specific app
pnpm nx affected --target=build # Build affected only

# Test
pnpm nx test api              # Test API
pnpm nx test shared           # Test shared lib
pnpm nx affected --target=test # Test affected only

# Lint
pnpm nx lint admin            # Lint specific app
pnpm nx run-many --target=lint # Lint all

# E2E
pnpm nx e2e admin-e2e         # E2E admin app

# Cache
pnpm nx reset                 # Clear Nx cache
```

## Available Slash Commands

| Command | Purpose |
|---------|---------|
| `/plan` | Create implementation plan (Nx-aware) |
| `/tdd` | Test-driven development per project |
| `/code-review` | Review with Nx boundary + Clerk auth checks |
| `/build-fix` | Fix Nx build errors |
| `/e2e` | Generate/run Playwright E2E per app |
| `/test-coverage` | Coverage analysis per project |
| `/refactor-clean` | Dead code removal across monorepo |
| `/nx-graph` | Analyze Nx dependency graph |
| `/migrate` | Create/review SQL migrations |
| `/document-feature` | Create feature documentation |
| `/update-docs` | Sync all documentation |

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
- CI: `pnpm nx affected --target=test,build,lint`
