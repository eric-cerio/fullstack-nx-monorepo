---
name: postgresql-patterns
description: PostgreSQL database patterns for the NestJS backend. Covers TypeORM entity patterns, connection pooling, migrations, query optimization, transactions, soft deletes, audit columns, and seeding.
---

# PostgreSQL Patterns

## TypeORM Setup in NestJS

```typescript
// apps/api/src/app.module.ts
import { TypeOrmModule } from '@nestjs/typeorm'

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432'),
      username: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME || 'event_platform',
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: false,           // NEVER true in production
      migrationsRun: true,          // Auto-run migrations on start
      migrations: [__dirname + '/database/migrations/*{.ts,.js}'],
      // Connection pooling
      extra: {
        max: 20,                    // Max connections in pool
        connectionTimeoutMillis: 5000,
        idleTimeoutMillis: 30000,
      },
      logging: process.env.NODE_ENV === 'development' ? ['query', 'error'] : ['error'],
    }),
  ],
})
export class AppModule {}
```

## Base Entity (Audit Columns)

```typescript
// apps/api/src/database/base.entity.ts
import { PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, DeleteDateColumn } from 'typeorm'

export abstract class BaseEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @CreateDateColumn({ type: 'timestamptz' })
  created_at: Date

  @UpdateDateColumn({ type: 'timestamptz' })
  updated_at: Date

  @DeleteDateColumn({ type: 'timestamptz', nullable: true })
  deleted_at: Date | null    // Soft delete support
}
```

## Entity Patterns

```typescript
// apps/api/src/modules/events/entities/event.entity.ts
import { Entity, Column, OneToMany, Index } from 'typeorm'
import { BaseEntity } from '@/database/base.entity'
import { Session } from './session.entity'

@Entity('events')
export class Event extends BaseEntity {
  @Column({ type: 'varchar', length: 255 })
  title: string

  @Column({ type: 'text' })
  description: string

  @Column({ type: 'timestamptz' })
  @Index()
  date: Date

  @Column({ type: 'varchar', length: 500 })
  venue: string

  @Column({ type: 'int' })
  capacity: number

  @Column({ type: 'int', default: 0 })
  registered_count: number

  @Column({ type: 'varchar', length: 50, default: 'draft' })
  @Index()
  status: 'draft' | 'published' | 'live' | 'completed'

  @OneToMany(() => Session, (session) => session.event)
  sessions: Session[]
}

// apps/api/src/modules/events/entities/attendee.entity.ts
@Entity('attendees')
@Index(['event_id', 'email'], { unique: true })  // One registration per email per event
export class Attendee extends BaseEntity {
  @Column({ type: 'uuid' })
  @Index()
  event_id: string

  @Column({ type: 'varchar', length: 255 })
  @Index()
  email: string

  @Column({ type: 'varchar', length: 255 })
  name: string

  @Column({ type: 'varchar', length: 50, default: 'registered' })
  status: 'registered' | 'checked_in' | 'no_show'

  @Column({ type: 'timestamptz', nullable: true })
  checked_in_at: Date | null

  @Column({ type: 'varchar', length: 100, nullable: true })
  qr_code: string

  @ManyToOne(() => Event)
  @JoinColumn({ name: 'event_id' })
  event: Event
}
```

## Repository Pattern (Service Layer)

```typescript
// apps/api/src/modules/events/events.service.ts
import { Injectable, NotFoundException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { Event } from './entities/event.entity'

@Injectable()
export class EventsService {
  constructor(
    @InjectRepository(Event)
    private readonly eventRepo: Repository<Event>,
  ) {}

  async findAll(page = 1, limit = 10): Promise<{ data: Event[]; total: number }> {
    const [data, total] = await this.eventRepo.findAndCount({
      where: { status: 'published' },
      order: { date: 'ASC' },
      skip: (page - 1) * limit,
      take: limit,
      relations: ['sessions'],  // Eager load sessions
    })
    return { data, total }
  }

  async findById(id: string): Promise<Event> {
    const event = await this.eventRepo.findOne({
      where: { id },
      relations: ['sessions'],
    })
    if (!event) throw new NotFoundException(`Event ${id} not found`)
    return event
  }

  // ✅ GOOD: Use QueryBuilder for complex queries
  async findUpcoming(limit = 5): Promise<Event[]> {
    return this.eventRepo
      .createQueryBuilder('event')
      .where('event.date > :now', { now: new Date() })
      .andWhere('event.status = :status', { status: 'published' })
      .orderBy('event.date', 'ASC')
      .limit(limit)
      .getMany()
  }
}
```

## Migration Patterns

```sql
-- database/migrations/20260224120000_create_events_table.sql

-- UP
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  date TIMESTAMPTZ NOT NULL,
  venue VARCHAR(500) NOT NULL,
  capacity INT NOT NULL DEFAULT 0,
  registered_count INT NOT NULL DEFAULT 0,
  status VARCHAR(50) NOT NULL DEFAULT 'draft',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_events_date ON events (date);
CREATE INDEX IF NOT EXISTS idx_events_status ON events (status);

-- DOWN
DROP TABLE IF EXISTS events;
```

```sql
-- database/migrations/20260224120100_create_attendees_table.sql

-- UP
CREATE TABLE IF NOT EXISTS attendees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'registered',
  checked_in_at TIMESTAMPTZ,
  qr_code VARCHAR(100),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_attendees_event_email ON attendees (event_id, email);
CREATE INDEX IF NOT EXISTS idx_attendees_event_id ON attendees (event_id);
CREATE INDEX IF NOT EXISTS idx_attendees_email ON attendees (email);
CREATE INDEX IF NOT EXISTS idx_attendees_qr_code ON attendees (qr_code) WHERE qr_code IS NOT NULL;

-- DOWN
DROP TABLE IF EXISTS attendees;
```

## Query Optimization

```typescript
// ❌ BAD: N+1 query problem
const events = await eventRepo.find()
for (const event of events) {
  event.sessions = await sessionRepo.find({ where: { event_id: event.id } })
}

// ✅ GOOD: Eager load with relations
const events = await eventRepo.find({ relations: ['sessions'] })

// ✅ GOOD: Use QueryBuilder for complex joins
const events = await eventRepo
  .createQueryBuilder('event')
  .leftJoinAndSelect('event.sessions', 'session')
  .where('event.status = :status', { status: 'published' })
  .getMany()

// ✅ GOOD: Use select to fetch only needed columns
const counts = await eventRepo
  .createQueryBuilder('event')
  .select(['event.id', 'event.title', 'event.registered_count'])
  .getMany()
```

## Transaction Patterns

```typescript
// apps/api/src/modules/check-in/check-in.service.ts
import { DataSource } from 'typeorm'

@Injectable()
export class CheckInService {
  constructor(private dataSource: DataSource) {}

  async checkIn(attendeeId: string): Promise<void> {
    await this.dataSource.transaction(async (manager) => {
      // 1. Update attendee status
      await manager.update(Attendee, attendeeId, {
        status: 'checked_in',
        checked_in_at: new Date(),
      })

      // 2. Increment event checked-in count
      const attendee = await manager.findOneBy(Attendee, { id: attendeeId })
      await manager
        .createQueryBuilder()
        .update(Event)
        .set({ checked_in_count: () => 'checked_in_count + 1' })
        .where('id = :id', { id: attendee.event_id })
        .execute()
    })
  }
}
```

## Soft Delete Pattern

```typescript
// ✅ Soft delete (sets deleted_at, doesn't remove row)
await eventRepo.softDelete(id)

// ✅ Query excludes soft-deleted by default
await eventRepo.find() // Only non-deleted events

// ✅ Include soft-deleted if needed
await eventRepo.find({ withDeleted: true })

// ✅ Restore soft-deleted
await eventRepo.restore(id)
```

## Seeding (Development)

```typescript
// apps/api/src/database/seeds/seed.ts
import { DataSource } from 'typeorm'

export async function seed(dataSource: DataSource) {
  const eventRepo = dataSource.getRepository(Event)

  const exists = await eventRepo.count()
  if (exists > 0) return // Don't seed if data exists

  await eventRepo.save([
    {
      title: 'Tech Conference 2026',
      description: 'Annual technology conference',
      date: new Date('2026-06-15'),
      venue: 'Convention Center',
      capacity: 500,
      status: 'published',
    },
  ])
}
```

## Environment Variables

```bash
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your-secure-password
DB_NAME=event_platform
```

## Index Strategy

| Table | Column(s) | Type | Reason |
|-------|----------|------|--------|
| events | date | B-tree | Sort by upcoming |
| events | status | B-tree | Filter by status |
| attendees | event_id, email | Unique | One reg per email per event |
| attendees | event_id | B-tree | Find attendees for event |
| attendees | qr_code | B-tree (partial) | QR lookup at check-in |
| polls | event_id, status | Composite | Active polls per event |
