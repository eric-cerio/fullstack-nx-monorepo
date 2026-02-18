---
description: Create and review SQL migration files. Enforces naming conventions, rollback support, idempotency, and safety checks before applying.
---

# Migrate Command

Invokes the **migration-reviewer** agent for database migration work.

## What This Command Does

1. Create new migration file with timestamp prefix
2. Review existing migrations for safety
3. Enforce naming: `YYYYMMDDHHMMSS_description.sql`
4. Verify UP and DOWN sections exist
5. Check for destructive operations
6. Validate idempotency (`IF NOT EXISTS` / `IF EXISTS`)

## Usage

```
/migrate create add_phone_to_users — Create new migration
/migrate review                    — Review all pending migrations
/migrate review 20260218_*.sql     — Review specific migration
```

## Migration Location

All migrations live in: `database/migrations/`

## Related Agent

`~/.claude/agents/migration-reviewer.md`
