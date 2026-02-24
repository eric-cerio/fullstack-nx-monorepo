---
description: Review WebSocket gateway architecture, event naming, auth on connection, Redis pub/sub scaling, and real-time data flow patterns. Invokes the realtime-architect agent.
---

# Realtime Review Command

Invokes the **realtime-architect** agent to review WebSocket gateway architecture and real-time data flow patterns.

## What This Command Does

1. **Review Gateway Architecture** — Validate namespace separation, lifecycle hooks, and exception handling
2. **Audit WebSocket Authentication** — Verify JWT validation happens in `handleConnection` handshake, not after
3. **Check Event Naming** — Ensure consistent `domain:action` naming convention across all gateways
4. **Validate Room Structure** — Confirm rooms are namespaced by resource with proper join/leave lifecycle
5. **Review Redis Pub/Sub Setup** — Verify Redis adapter configuration for horizontal scaling across multiple server instances
6. **Check Connection Lifecycle** — Ensure `handleDisconnect` cleans up ALL state (rooms, presence, maps)
7. **Audit Event Flow Consistency** — Verify optimistic updates, conflict resolution, and idempotency patterns
8. **Evaluate Rate Limiting** — Confirm per-event and per-connection rate limits
9. **Review Real-Time Features** — Attendance tracking, live polling (vote deduplication), Q&A boards (upvote consistency)
10. **Assess Scaling Readiness** — Sticky sessions, connection limits, graceful shutdown, Redis failover

## Steps

1. Read all gateway files to understand the namespace and event structure
2. Verify JWT validation in every gateway's `handleConnection` method
3. Map all event names — check for consistency against the naming convention
4. Trace event flow: client emit -> handler -> Redis publish -> broadcast -> client receive
5. Check `handleDisconnect` in every gateway for complete state cleanup
6. Verify Redis adapter setup in the NestJS application bootstrap
7. Review vote and upvote handlers for idempotency (Redis SET membership checks)
8. Check connection lifecycle: ping/pong config, orphaned connection cleanup
9. Review rate limiting on event handlers
10. Produce a categorized review with CRITICAL, HIGH, and MEDIUM findings

## When to Use

- After implementing a new WebSocket gateway or event handler
- When adding real-time features (live polls, Q&A, attendance tracking)
- Before deploying real-time features to production (scaling readiness)
- When debugging "ghost users" or inconsistent real-time state
- When preparing for high-concurrency events (1000+ simultaneous connections)

## Usage Examples

```
/realtime-review
```

Review all WebSocket gateway code and Redis pub/sub configuration.

```
/realtime-review apps/api/src/gateways/polling.gateway.ts
```

Review a specific gateway for event naming, auth, and lifecycle patterns.

```
/realtime-review --focus=scaling
```

Focus the review on Redis adapter, horizontal scaling, and load readiness.

```
/realtime-review --focus=auth
```

Focus the review on WebSocket authentication and authorization patterns.

## Integration

After realtime review:

- Fix CRITICAL issues (missing auth, no disconnect cleanup) before merging
- Use `/db-review` if real-time features need schema or Redis caching changes
- Use `/mobile-review` if mobile app consumes WebSocket connections
- Use `/code-review` for general code quality on gateway implementations
- Use `/plan` to plan architectural changes for scaling issues

## Related Agent

`agents/realtime-architect.md`
