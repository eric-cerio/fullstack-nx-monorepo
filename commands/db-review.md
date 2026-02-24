---
description: Review PostgreSQL schema design, migrations, query performance, Redis caching strategy, and data integrity patterns. Invokes the database-architect agent.
---

# Database Review Command

Invokes the **database-architect** agent to review PostgreSQL schema design, migrations, query performance, and Redis caching strategy.

## What This Command Does

1. **Review Schema Design** — Validate table structure, column types, naming conventions, and normalization
2. **Audit Constraints & Integrity** — Check NOT NULL, UNIQUE, CHECK, foreign key, and exclusion constraints
3. **Validate Indexes** — Ensure foreign keys are indexed, WHERE clauses have supporting indexes, no redundant indexes
4. **Review Migration Safety** — Check for table locks, data loss risks, idempotency, and rollback capability
5. **Analyze Query Performance** — Detect N+1 patterns, missing indexes, sequential scans, and unoptimized JOINs
6. **Evaluate Caching Strategy** — Review Redis cache keys, TTL policy, invalidation logic, and stampede prevention
7. **Check Connection Pooling** — Verify pool configuration, idle timeouts, and exhaustion monitoring
8. **Review Transaction Boundaries** — Ensure transactions are short, wrap related operations, and don't contain I/O
9. **Assess Backup & Recovery** — Verify backup automation, PITR configuration, and restore testing
10. **Validate Soft Delete Pattern** — Confirm `deleted_at TIMESTAMP NULL` with partial indexes for active records

## Steps

1. Read all migration files in `database/migrations/` in order
2. Reconstruct the current schema from migrations
3. Check every table for: primary key, timestamps, soft delete, foreign keys, indexes
4. Cross-reference indexes with query patterns in repository/service files
5. Review each migration for safety: locks, data loss, idempotency, DOWN section
6. Scan for N+1 patterns in service layer code (loops with queries)
7. Review Redis usage: cache keys, TTL, invalidation points
8. Check connection pool configuration in the NestJS database module
9. Review transaction usage in service layer
10. Produce a categorized review with CRITICAL, HIGH, and MEDIUM findings

## When to Use

- After creating or modifying database migrations
- When adding new tables or changing existing schema
- Before deploying migrations to staging or production
- When investigating slow API endpoints (query performance)
- When designing the caching layer for a new feature
- During periodic database health reviews

## Usage Examples

```
/db-review
```

Review all database migrations, schema, and query patterns.

```
/db-review database/migrations/20250615120000_create_events.sql
```

Review a specific migration for safety and correctness.

```
/db-review --focus=performance
```

Focus the review on query performance, N+1 detection, and index optimization.

```
/db-review --focus=caching
```

Focus the review on Redis caching strategy, TTL, and invalidation patterns.

```
/db-review --focus=migration-safety
```

Focus the review on migration safety: locks, rollback, and data preservation.

## Integration

After database review:

- Fix CRITICAL issues (missing indexes, unsafe migrations) before deploying
- Use `/api-design` if schema changes affect API endpoint structure
- Use `/realtime-review` if caching changes affect real-time features
- Use `/code-review` for general code quality on repository/service layer
- Use `/tdd` to implement fixes with proper test coverage

## Related Agent

`agents/database-architect.md`
