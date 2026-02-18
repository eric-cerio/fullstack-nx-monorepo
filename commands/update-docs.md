---
description: Sync project documentation from source of truth. Updates READMEs, API docs, and environment variable docs across the Nx monorepo.
---

# Update Docs Command

Sync documentation from code source of truth.

## What This Command Does

1. Read each app's `package.json` scripts section
2. Read `.env.example` files per app
3. Read `database/migrations/` for schema docs
4. Update per-app READMEs
5. Generate API endpoint documentation from NestJS controllers
6. Update environment variable documentation
7. Verify `docs/features/` index is current

## Source of Truth

- `package.json` → Available scripts
- `.env.example` → Required environment variables
- NestJS controllers → API endpoints
- `database/migrations/` → Database schema
- `docs/features/` → Feature documentation
