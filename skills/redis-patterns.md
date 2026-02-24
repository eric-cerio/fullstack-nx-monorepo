---
name: redis-patterns
description: Redis caching and real-time patterns for the NestJS backend. Covers cache-aside, write-through, TTL strategies, session storage, pub/sub for WebSocket scaling, cache invalidation, and NestJS CacheModule integration.
---

# Redis Patterns

## NestJS Redis Setup

```typescript
// apps/api/src/modules/redis/redis.module.ts
import { Module, Global } from '@nestjs/common'
import { RedisService } from './redis.service'

@Global()
@Module({
  providers: [RedisService],
  exports: [RedisService],
})
export class RedisModule {}

// apps/api/src/modules/redis/redis.service.ts
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common'
import { createClient, RedisClientType } from 'redis'

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private client: RedisClientType

  async onModuleInit() {
    this.client = createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379',
    })
    this.client.on('error', (err) => console.error('Redis error:', err))
    await this.client.connect()
  }

  async onModuleDestroy() {
    await this.client.quit()
  }

  async get(key: string): Promise<string | null> {
    return this.client.get(key)
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    if (ttlSeconds) {
      await this.client.setEx(key, ttlSeconds, value)
    } else {
      await this.client.set(key, value)
    }
  }

  async del(key: string): Promise<void> {
    await this.client.del(key)
  }

  async delPattern(pattern: string): Promise<void> {
    const keys = await this.client.keys(pattern)
    if (keys.length > 0) {
      await this.client.del(keys)
    }
  }

  // Pub/Sub for WebSocket scaling
  async publish(channel: string, message: string): Promise<void> {
    await this.client.publish(channel, message)
  }

  getClient(): RedisClientType {
    return this.client
  }
}
```

## Cache Key Naming Convention

```
resource:id:field
```

| Pattern | Example | TTL |
|---------|---------|-----|
| `event:{id}` | `event:abc123` | 5 min |
| `event:{id}:sessions` | `event:abc123:sessions` | 5 min |
| `event:{id}:attendance` | `event:abc123:attendance` | 30 sec |
| `event:{id}:poll:{pollId}` | `event:abc123:poll:xyz` | No cache (real-time) |
| `user:{id}:profile` | `user:def456:profile` | 15 min |
| `schedule:{eventId}` | `schedule:abc123` | 10 min |
| `refresh:{token}` | `refresh:uuid-here` | 7 days |

## Cache-Aside Pattern (Read)

```typescript
// apps/api/src/modules/events/events.service.ts

async findById(id: string): Promise<Event> {
  const cacheKey = `event:${id}`

  // 1. Check cache first
  const cached = await this.redis.get(cacheKey)
  if (cached) return JSON.parse(cached)

  // 2. Cache miss → query database
  const event = await this.eventRepo.findOne({
    where: { id },
    relations: ['sessions'],
  })
  if (!event) throw new NotFoundException(`Event ${id} not found`)

  // 3. Store in cache with TTL
  await this.redis.set(cacheKey, JSON.stringify(event), 300) // 5 min

  return event
}
```

## Write-Through Pattern (Write)

```typescript
async update(id: string, dto: UpdateEventDto): Promise<Event> {
  // 1. Update database
  await this.eventRepo.update(id, dto)
  const event = await this.eventRepo.findOne({ where: { id }, relations: ['sessions'] })

  // 2. Update cache immediately
  await this.redis.set(`event:${id}`, JSON.stringify(event), 300)

  // 3. Invalidate related caches
  await this.redis.del(`schedule:${id}`)
  await this.redis.del(`event:${id}:sessions`)

  return event
}

async remove(id: string): Promise<void> {
  await this.eventRepo.softDelete(id)

  // Invalidate all caches for this event
  await this.redis.delPattern(`event:${id}*`)
  await this.redis.del(`schedule:${id}`)
}
```

## Real-Time Attendance (Low TTL)

```typescript
// Attendance changes frequently — use very short TTL
async getAttendanceCount(eventId: string): Promise<{ registered: number; checked_in: number; remaining: number }> {
  const cacheKey = `event:${eventId}:attendance`
  const cached = await this.redis.get(cacheKey)
  if (cached) return JSON.parse(cached)

  const event = await this.eventRepo.findOneBy({ id: eventId })
  const checkedIn = await this.attendeeRepo.count({
    where: { event_id: eventId, status: 'checked_in' },
  })

  const result = {
    registered: event.registered_count,
    checked_in: checkedIn,
    remaining: event.capacity - event.registered_count,
  }

  // 30-second TTL for near-real-time
  await this.redis.set(cacheKey, JSON.stringify(result), 30)
  return result
}

// Invalidate on check-in
async onCheckIn(eventId: string): Promise<void> {
  await this.redis.del(`event:${eventId}:attendance`)
}
```

## Session Storage (Refresh Tokens)

```typescript
// Store refresh token → userId mapping
async storeRefreshToken(token: string, userId: string): Promise<void> {
  await this.redis.set(`refresh:${token}`, userId, 60 * 60 * 24 * 7) // 7 days
}

async validateRefreshToken(token: string): Promise<string | null> {
  return this.redis.get(`refresh:${token}`)
}

async revokeRefreshToken(token: string): Promise<void> {
  await this.redis.del(`refresh:${token}`)
}

// Revoke all refresh tokens for a user (on password change, etc.)
async revokeAllUserTokens(userId: string): Promise<void> {
  await this.redis.delPattern(`refresh:*`) // Note: scan for user-specific tokens in production
}
```

## Pub/Sub for WebSocket Scaling

```typescript
// When running multiple API instances behind a load balancer,
// use Redis pub/sub so all instances broadcast to their connected clients.

// apps/api/src/gateways/events.gateway.ts
import { IoAdapter } from '@nestjs/platform-socket.io'
import { createAdapter } from '@socket.io/redis-adapter'
import { createClient } from 'redis'

// Custom adapter for multi-instance scaling
export class RedisIoAdapter extends IoAdapter {
  private adapterConstructor: ReturnType<typeof createAdapter>

  async connectToRedis(): Promise<void> {
    const pubClient = createClient({ url: process.env.REDIS_URL })
    const subClient = pubClient.duplicate()
    await Promise.all([pubClient.connect(), subClient.connect()])
    this.adapterConstructor = createAdapter(pubClient, subClient)
  }

  createIOServer(port: number, options?: any) {
    const server = super.createIOServer(port, options)
    server.adapter(this.adapterConstructor)
    return server
  }
}

// apps/api/src/main.ts
async function bootstrap() {
  const app = await NestFactory.create(AppModule)

  const redisIoAdapter = new RedisIoAdapter(app)
  await redisIoAdapter.connectToRedis()
  app.useWebSocketAdapter(redisIoAdapter)

  await app.listen(4000)
}
```

## Cache Invalidation Rules

| When This Happens | Invalidate These Keys |
|-------------------|----------------------|
| Event updated | `event:{id}`, `event:{id}:sessions`, `schedule:{id}` |
| Event deleted | `event:{id}*` (pattern), `schedule:{id}` |
| Attendee registers | `event:{eventId}:attendance` |
| Attendee checks in | `event:{eventId}:attendance` |
| Session updated | `event:{eventId}:sessions`, `schedule:{eventId}` |
| Poll created/closed | `event:{eventId}:poll:{pollId}` |
| User profile updated | `user:{id}:profile` |

## Environment Variables

```bash
REDIS_URL=redis://localhost:6379
# Or with auth:
REDIS_URL=redis://:password@redis-host:6379
```

## TTL Strategy Summary

| Resource Type | TTL | Reason |
|--------------|-----|--------|
| Event details | 5 min | Changes infrequently |
| Schedule | 10 min | Updated from CMS, not real-time |
| Attendance count | 30 sec | Near-real-time, changes often during event |
| Poll results | No cache | Must be real-time via WebSocket |
| User profile | 15 min | Changes rarely |
| Refresh token | 7 days | Session duration |
| Rate limit counter | 1 min | Per-window rate limiting |
