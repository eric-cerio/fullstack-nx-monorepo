---
name: websocket-patterns
description: WebSocket real-time patterns using NestJS Gateway and Socket.io. Covers room management, event naming, auth on connection, Redis adapter scaling, client-side patterns for React Native and Next.js, error handling, and rate limiting.
---

# WebSocket Patterns

## NestJS Gateway Setup

```typescript
// apps/api/src/gateways/events.gateway.ts
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets'
import { Server, Socket } from 'socket.io'
import { JwtService } from '@nestjs/jwt'
import { Logger } from '@nestjs/common'

@WebSocketGateway({
  cors: {
    origin: [
      process.env.LANDING_PAGE_URL || 'http://localhost:3000',
      process.env.CMS_URL || 'http://localhost:3001',
    ],
    credentials: true,
  },
  namespace: '/events',
})
export class EventsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server

  private readonly logger = new Logger(EventsGateway.name)

  constructor(private jwtService: JwtService) {}

  // ── Auth on Connection ────────────────────────
  handleConnection(client: Socket) {
    const token = client.handshake.auth?.token
    if (!token) {
      this.logger.warn(`Client ${client.id} rejected: no token`)
      client.disconnect()
      return
    }

    try {
      const payload = this.jwtService.verify(token)
      client.data.user = { userId: payload.sub, role: payload.role }
      this.logger.log(`Client ${client.id} connected (user: ${payload.sub})`)
    } catch {
      this.logger.warn(`Client ${client.id} rejected: invalid token`)
      client.disconnect()
    }
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client ${client.id} disconnected`)
  }

  // ── Room Management ───────────────────────────
  @SubscribeMessage('join:event')
  handleJoinEvent(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { eventId: string },
  ) {
    const room = `event:${data.eventId}`
    client.join(room)
    this.logger.log(`Client ${client.id} joined room ${room}`)
    return { status: 'joined', room }
  }

  @SubscribeMessage('leave:event')
  handleLeaveEvent(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { eventId: string },
  ) {
    const room = `event:${data.eventId}`
    client.leave(room)
    return { status: 'left', room }
  }

  // ── Server-Side Emit (called from services) ───
  emitAttendanceUpdate(eventId: string, data: { registered: number; checked_in: number; remaining: number }) {
    this.server.to(`event:${eventId}`).emit('attendance:update', data)
  }

  emitPollUpdate(eventId: string, pollId: string, results: Record<string, number>) {
    this.server.to(`event:${eventId}`).emit('poll:results', { pollId, results })
  }

  emitNewQuestion(eventId: string, question: { id: string; text: string; author: string; votes: number }) {
    this.server.to(`event:${eventId}`).emit('qa:new', question)
  }

  emitNotification(eventId: string, notification: { title: string; message: string; type: string }) {
    this.server.to(`event:${eventId}`).emit('notification:push', notification)
  }
}
```

## Event Naming Convention

```
namespace:action
```

| Event | Direction | Payload |
|-------|-----------|---------|
| `join:event` | Client → Server | `{ eventId }` |
| `leave:event` | Client → Server | `{ eventId }` |
| `attendance:update` | Server → Client | `{ registered, checked_in, remaining }` |
| `poll:vote` | Client → Server | `{ pollId, optionId }` |
| `poll:results` | Server → Client | `{ pollId, results }` |
| `qa:submit` | Client → Server | `{ eventId, text }` |
| `qa:new` | Server → Client | `{ id, text, author, votes }` |
| `qa:upvote` | Client → Server | `{ questionId }` |
| `qa:updated` | Server → Client | `{ questionId, votes }` |
| `notification:push` | Server → Client | `{ title, message, type }` |
| `reaction:send` | Client → Server | `{ sessionId, emoji }` |
| `reaction:burst` | Server → Client | `{ sessionId, emoji, count }` |

## Live Polling

```typescript
// apps/api/src/modules/polls/polls.gateway.ts
@SubscribeMessage('poll:vote')
async handleVote(
  @ConnectedSocket() client: Socket,
  @MessageBody() data: { pollId: string; optionId: string },
) {
  const userId = client.data.user.userId

  // Deduplicate: one vote per user per poll
  const voteKey = `poll:${data.pollId}:voter:${userId}`
  const alreadyVoted = await this.redis.get(voteKey)
  if (alreadyVoted) {
    return { error: 'Already voted' }
  }

  // Record vote
  await this.redis.set(voteKey, data.optionId)
  await this.pollsService.recordVote(data.pollId, data.optionId)

  // Get updated results and broadcast
  const results = await this.pollsService.getResults(data.pollId)
  const eventId = await this.pollsService.getEventId(data.pollId)
  this.eventsGateway.emitPollUpdate(eventId, data.pollId, results)

  return { status: 'voted' }
}
```

## Q&A Board

```typescript
@SubscribeMessage('qa:submit')
async handleQuestion(
  @ConnectedSocket() client: Socket,
  @MessageBody() data: { eventId: string; text: string },
) {
  const user = client.data.user
  const question = await this.qaService.create({
    event_id: data.eventId,
    text: data.text,
    author_id: user.userId,
  })

  // Broadcast to all clients in the event room
  this.eventsGateway.emitNewQuestion(data.eventId, {
    id: question.id,
    text: question.text,
    author: question.author_name,
    votes: 0,
  })

  return { status: 'submitted', questionId: question.id }
}

@SubscribeMessage('qa:upvote')
async handleUpvote(
  @ConnectedSocket() client: Socket,
  @MessageBody() data: { questionId: string },
) {
  const userId = client.data.user.userId

  // Deduplicate upvotes
  const upvoteKey = `qa:${data.questionId}:upvoter:${userId}`
  if (await this.redis.get(upvoteKey)) {
    return { error: 'Already upvoted' }
  }
  await this.redis.set(upvoteKey, '1')

  const updatedVotes = await this.qaService.upvote(data.questionId)
  const eventId = await this.qaService.getEventId(data.questionId)

  this.server.to(`event:${eventId}`).emit('qa:updated', {
    questionId: data.questionId,
    votes: updatedVotes,
  })

  return { status: 'upvoted' }
}
```

## React Native Client

```typescript
// apps/mobile/src/lib/socket.ts
import { io, Socket } from 'socket.io-client'
import { getAccessToken } from './storage'

let socket: Socket | null = null

export async function connectSocket(): Promise<Socket> {
  if (socket?.connected) return socket

  const token = await getAccessToken()
  socket = io(`${process.env.EXPO_PUBLIC_API_URL}/events`, {
    auth: { token },
    transports: ['websocket'],
    reconnection: true,
    reconnectionAttempts: 10,
    reconnectionDelay: 1000,
  })

  socket.on('connect_error', (err) => {
    console.error('Socket connection error:', err.message)
  })

  return socket
}

export function getSocket(): Socket | null {
  return socket
}

export function disconnectSocket(): void {
  socket?.disconnect()
  socket = null
}

// apps/mobile/src/providers/SocketProvider.tsx
import { createContext, useContext, useEffect, useState } from 'react'
import { Socket } from 'socket.io-client'
import { connectSocket, disconnectSocket } from '@/lib/socket'
import { useAuth } from './AuthProvider'

const SocketContext = createContext<Socket | null>(null)

export function SocketProvider({ children }: { children: React.ReactNode }) {
  const [socket, setSocket] = useState<Socket | null>(null)
  const { isAuthenticated } = useAuth()

  useEffect(() => {
    if (isAuthenticated) {
      connectSocket().then(setSocket)
    }
    return () => disconnectSocket()
  }, [isAuthenticated])

  return (
    <SocketContext.Provider value={socket}>
      {children}
    </SocketContext.Provider>
  )
}

export const useSocket = () => useContext(SocketContext)
```

## React Native Hook Usage

```typescript
// apps/mobile/src/hooks/useAttendance.ts
import { useEffect, useState } from 'react'
import { useSocket } from '@/providers/SocketProvider'

export function useAttendance(eventId: string) {
  const socket = useSocket()
  const [attendance, setAttendance] = useState({ registered: 0, checked_in: 0, remaining: 0 })

  useEffect(() => {
    if (!socket) return

    // Join event room
    socket.emit('join:event', { eventId })

    // Listen for updates
    socket.on('attendance:update', setAttendance)

    return () => {
      socket.emit('leave:event', { eventId })
      socket.off('attendance:update', setAttendance)
    }
  }, [socket, eventId])

  return attendance
}
```

## Next.js Client (Landing Page)

```typescript
// apps/landing-page/src/hooks/useAttendance.ts
'use client'

import { useEffect, useState } from 'react'
import { io } from 'socket.io-client'

export function useAttendance(eventId: string) {
  const [attendance, setAttendance] = useState({ registered: 0, checked_in: 0, remaining: 0 })

  useEffect(() => {
    const socket = io(`${process.env.NEXT_PUBLIC_API_URL}/events`, {
      transports: ['websocket'],
      // Landing page: no auth needed for public attendance data
    })

    socket.emit('join:event', { eventId })
    socket.on('attendance:update', setAttendance)

    return () => {
      socket.emit('leave:event', { eventId })
      socket.disconnect()
    }
  }, [eventId])

  return attendance
}
```

## Rate Limiting on Events

```typescript
// Simple in-memory rate limiter for WebSocket events
const rateLimits = new Map<string, { count: number; resetAt: number }>()

function checkRateLimit(clientId: string, event: string, maxPerMinute: number): boolean {
  const key = `${clientId}:${event}`
  const now = Date.now()
  const entry = rateLimits.get(key)

  if (!entry || now > entry.resetAt) {
    rateLimits.set(key, { count: 1, resetAt: now + 60000 })
    return true
  }

  if (entry.count >= maxPerMinute) return false
  entry.count++
  return true
}

// Usage in gateway
@SubscribeMessage('poll:vote')
handleVote(@ConnectedSocket() client: Socket, @MessageBody() data: any) {
  if (!checkRateLimit(client.id, 'poll:vote', 10)) {
    return { error: 'Rate limited' }
  }
  // ... handle vote
}
```

## Room Structure

```
/events namespace
├── event:{eventId}          # All clients watching this event
│   ├── attendance updates
│   ├── poll results
│   ├── Q&A updates
│   └── notifications
├── event:{eventId}:staff    # Staff-only room (moderators, support)
│   └── support tickets, moderation events
└── event:{eventId}:admin    # Admin-only room
    └── analytics updates, system events
```

## Error Handling

```typescript
// Server-side: catch and return structured errors
@SubscribeMessage('poll:vote')
async handleVote(@ConnectedSocket() client: Socket, @MessageBody() data: any) {
  try {
    // ... vote logic
    return { status: 'ok', data: results }
  } catch (error) {
    this.logger.error(`Vote error: ${error.message}`, error.stack)
    return { status: 'error', message: error.message }
  }
}

// Client-side: handle reconnection
socket.on('disconnect', (reason) => {
  if (reason === 'io server disconnect') {
    // Server kicked us — token might be expired
    socket.connect() // Won't auto-reconnect
  }
  // Other reasons: auto-reconnect handles it
})
```
