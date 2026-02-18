---
name: sql-migration-patterns
description: SQL migration best practices for the database/migrations/ directory. Covers naming, idempotency, rollbacks, data migrations, and safety patterns.
---

# SQL Migration Patterns

## Naming Convention

```
YYYYMMDDHHMMSS_descriptive_snake_case.sql
```

Examples:
```
20260218143000_create_users_table.sql
20260218144500_add_role_to_users.sql
20260219100000_create_partners_table.sql
20260219101500_add_index_on_users_email.sql
```

## File Structure Template

```sql
-- Migration: 20260218143000_create_users_table
-- Description: Create users table with Clerk integration
-- Author: [name]
-- Date: 2026-02-18

-- UP
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  clerk_id VARCHAR(255) UNIQUE NOT NULL,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  role VARCHAR(50) NOT NULL DEFAULT 'resident'
    CHECK (role IN ('admin', 'partner', 'resident')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_clerk_id ON users(clerk_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- DOWN
DROP INDEX IF EXISTS idx_users_role;
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_users_clerk_id;
DROP TABLE IF EXISTS users;
```

## Safety Patterns

### Adding Columns (Safe)
```sql
-- UP: Always use DEFAULT for existing tables with data
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- DOWN
ALTER TABLE users DROP COLUMN IF EXISTS is_active;
ALTER TABLE users DROP COLUMN IF EXISTS phone;
```

### Adding NOT NULL Column (Careful)
```sql
-- Step 1: Add nullable column
ALTER TABLE users ADD COLUMN IF NOT EXISTS department VARCHAR(100);

-- Step 2: Backfill data
UPDATE users SET department = 'general' WHERE department IS NULL;

-- Step 3: Add NOT NULL constraint
ALTER TABLE users ALTER COLUMN department SET NOT NULL;
ALTER TABLE users ALTER COLUMN department SET DEFAULT 'general';
```

### Creating Indexes (Large Tables)
```sql
-- Use CONCURRENTLY to avoid locking
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_department
  ON users(department);
```

### Foreign Keys
```sql
-- UP
ALTER TABLE partner_listings
  ADD CONSTRAINT fk_partner_listings_user
  FOREIGN KEY (user_id) REFERENCES users(id)
  ON DELETE CASCADE;

-- DOWN
ALTER TABLE partner_listings
  DROP CONSTRAINT IF EXISTS fk_partner_listings_user;
```

## Anti-Patterns to Avoid

```sql
-- ❌ No IF NOT EXISTS — fails on re-run
CREATE TABLE users (...);

-- ❌ Dropping column with data and no backup
ALTER TABLE users DROP COLUMN important_data;

-- ❌ Renaming column — breaks running application
ALTER TABLE users RENAME COLUMN name TO full_name;

-- ❌ Adding NOT NULL without DEFAULT to existing table
ALTER TABLE users ADD COLUMN status VARCHAR(50) NOT NULL;
-- This fails if table has existing rows!

-- ❌ No DOWN section
-- Makes rollback impossible
```

## Data Migrations

```sql
-- Migration: 20260220100000_split_name_into_first_last
-- Description: Split name column into first_name and last_name

-- UP
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name VARCHAR(255);

UPDATE users SET
  first_name = SPLIT_PART(name, ' ', 1),
  last_name = SPLIT_PART(name, ' ', 2)
WHERE name IS NOT NULL;

-- Keep old column until verified
-- ALTER TABLE users DROP COLUMN name; -- Do NOT drop yet

-- DOWN
UPDATE users SET name = CONCAT(first_name, ' ', last_name)
WHERE first_name IS NOT NULL;

ALTER TABLE users DROP COLUMN IF EXISTS last_name;
ALTER TABLE users DROP COLUMN IF EXISTS first_name;
```

**Android Comparison**: SQL migrations are like Android Room's migration system. The UP section is like `Migration(1, 2)`. The DOWN section is like having a reverse migration. Naming with timestamps is like Room's version numbers but more granular.
