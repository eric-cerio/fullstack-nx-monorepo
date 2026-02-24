---
name: jwt-auth-patterns
description: Provider-agnostic JWT authentication patterns for the full stack. Covers NestJS Passport guards, role-based access (6 roles), token refresh flow, Next.js middleware, React Native SecureStore, and WebSocket auth.
---

# JWT Authentication Patterns

## Role Definitions

```typescript
// packages/shared/src/types/roles.types.ts
export type UserRole = 'super_admin' | 'admin' | 'editor' | 'moderator' | 'support_staff' | 'viewer'

export const ROLES = {
  SUPER_ADMIN: 'super_admin' as const,
  ADMIN: 'admin' as const,
  EDITOR: 'editor' as const,
  MODERATOR: 'moderator' as const,
  SUPPORT_STAFF: 'support_staff' as const,
  VIEWER: 'viewer' as const,
}

export const ROLE_HIERARCHY: Record<UserRole, number> = {
  super_admin: 6,
  admin: 5,
  editor: 4,
  moderator: 3,
  support_staff: 2,
  viewer: 1,
}

// Helper: check if role has sufficient access level
export function hasMinimumRole(userRole: UserRole, requiredRole: UserRole): boolean {
  return ROLE_HIERARCHY[userRole] >= ROLE_HIERARCHY[requiredRole]
}
```

## JWT Token Structure

```typescript
// packages/shared/src/types/auth.types.ts
export interface JwtPayload {
  sub: string         // User ID
  email: string
  role: UserRole
  iat: number         // Issued at
  exp: number         // Expires at
}

export interface TokenPair {
  access_token: string   // Short-lived (15 min)
  refresh_token: string  // Long-lived (7 days), stored in Redis
}
```

## NestJS Backend Auth

### JWT Strategy (Passport)

```typescript
// apps/api/src/modules/auth/strategies/jwt.strategy.ts
import { Injectable, UnauthorizedException } from '@nestjs/common'
import { PassportStrategy } from '@nestjs/passport'
import { ExtractJwt, Strategy } from 'passport-jwt'
import type { JwtPayload } from '@my-org/shared'

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET,
    })
  }

  async validate(payload: JwtPayload) {
    if (!payload.sub || !payload.role) {
      throw new UnauthorizedException('Invalid token payload')
    }
    return { userId: payload.sub, email: payload.email, role: payload.role }
  }
}
```

### Auth Guard

```typescript
// apps/api/src/modules/auth/guards/jwt-auth.guard.ts
import { Injectable, ExecutionContext } from '@nestjs/common'
import { AuthGuard } from '@nestjs/passport'
import { Reflector } from '@nestjs/core'
import { IS_PUBLIC_KEY } from '../decorators/public.decorator'

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super()
  }

  canActivate(context: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ])
    if (isPublic) return true
    return super.canActivate(context)
  }
}
```

### Roles Guard + Decorator

```typescript
// apps/api/src/modules/auth/decorators/roles.decorator.ts
import { SetMetadata } from '@nestjs/common'
import type { UserRole } from '@my-org/shared'

export const ROLES_KEY = 'roles'
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles)

// apps/api/src/modules/auth/decorators/public.decorator.ts
import { SetMetadata } from '@nestjs/common'
export const IS_PUBLIC_KEY = 'isPublic'
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true)

// apps/api/src/modules/auth/guards/roles.guard.ts
import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common'
import { Reflector } from '@nestjs/core'
import { ROLES_KEY } from '../decorators/roles.decorator'
import type { UserRole } from '@my-org/shared'

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<UserRole[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ])
    if (!requiredRoles) return true

    const { user } = context.switchToHttp().getRequest()
    if (!requiredRoles.includes(user.role)) {
      throw new ForbiddenException(`Role '${user.role}' does not have access. Required: ${requiredRoles.join(', ')}`)
    }
    return true
  }
}
```

### Global Guard Registration

```typescript
// apps/api/src/app.module.ts
import { APP_GUARD } from '@nestjs/core'
import { JwtAuthGuard } from './modules/auth/guards/jwt-auth.guard'
import { RolesGuard } from './modules/auth/guards/roles.guard'

@Module({
  providers: [
    { provide: APP_GUARD, useClass: JwtAuthGuard },   // All routes protected by default
    { provide: APP_GUARD, useClass: RolesGuard },      // Role checking on decorated routes
  ],
})
export class AppModule {}
```

### Usage in Controllers

```typescript
@Controller('events')
export class EventsController {
  @Get()
  @Public()                              // No auth required
  findAll() {}

  @Post()
  @Roles('admin', 'editor')             // Admin or Editor can create
  create(@Body() dto: CreateEventDto) {}

  @Patch(':id')
  @Roles('admin', 'editor')             // Admin or Editor can update
  update(@Param('id') id: string, @Body() dto: UpdateEventDto) {}

  @Delete(':id')
  @Roles('admin')                        // Only Admin can delete
  remove(@Param('id') id: string) {}

  @Get('analytics')
  @Roles('admin', 'viewer')             // Admin + Viewer can see analytics
  getAnalytics() {}
}
```

### Token Issuance + Refresh

```typescript
// apps/api/src/modules/auth/auth.service.ts
import { JwtService } from '@nestjs/jwt'
import { Injectable, UnauthorizedException } from '@nestjs/common'
import { RedisService } from '../redis/redis.service'
import { randomUUID } from 'crypto'

@Injectable()
export class AuthService {
  constructor(
    private jwtService: JwtService,
    private redis: RedisService,
  ) {}

  async generateTokens(user: { id: string; email: string; role: UserRole }): Promise<TokenPair> {
    const accessToken = this.jwtService.sign(
      { sub: user.id, email: user.email, role: user.role },
      { expiresIn: '15m' },
    )

    const refreshToken = randomUUID()
    // Store refresh token in Redis with 7-day TTL
    await this.redis.set(`refresh:${refreshToken}`, user.id, 60 * 60 * 24 * 7)

    return { access_token: accessToken, refresh_token: refreshToken }
  }

  async refreshTokens(refreshToken: string): Promise<TokenPair> {
    const userId = await this.redis.get(`refresh:${refreshToken}`)
    if (!userId) throw new UnauthorizedException('Invalid refresh token')

    // Rotate: delete old refresh token
    await this.redis.del(`refresh:${refreshToken}`)

    const user = await this.usersService.findById(userId)
    return this.generateTokens(user)
  }

  async revokeRefreshToken(refreshToken: string): Promise<void> {
    await this.redis.del(`refresh:${refreshToken}`)
  }
}
```

## Next.js Middleware (CMS + Landing Page)

```typescript
// apps/cms/src/middleware.ts
import { NextRequest, NextResponse } from 'next/server'
import { jwtVerify } from 'jose'

const PUBLIC_ROUTES = ['/sign-in', '/sign-up', '/api/auth/refresh']
const JWT_SECRET = new TextEncoder().encode(process.env.JWT_SECRET)

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Skip public routes
  if (PUBLIC_ROUTES.some((route) => pathname.startsWith(route))) {
    return NextResponse.next()
  }

  const token = request.cookies.get('access_token')?.value
  if (!token) {
    return NextResponse.redirect(new URL('/sign-in', request.url))
  }

  try {
    const { payload } = await jwtVerify(token, JWT_SECRET)

    // CMS requires at least editor role
    const allowedRoles = ['super_admin', 'admin', 'editor', 'moderator', 'support_staff']
    if (!allowedRoles.includes(payload.role as string)) {
      return NextResponse.redirect(new URL('/unauthorized', request.url))
    }

    return NextResponse.next()
  } catch {
    return NextResponse.redirect(new URL('/sign-in', request.url))
  }
}

export const config = {
  matcher: ['/((?!_next|static|favicon.ico).*)'],
}
```

## React Native Auth Context

```typescript
// apps/mobile/src/providers/AuthProvider.tsx
import { createContext, useContext, useEffect, useState } from 'react'
import { getAccessToken, setTokens, clearTokens } from '@/lib/storage'
import { apiClient } from '@/lib/api'
import { router } from 'expo-router'
import type { UserRole } from '@my-org/shared'

interface AuthState {
  isAuthenticated: boolean
  isLoading: boolean
  user: { id: string; email: string; role: UserRole } | null
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthState | null>(null)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthState['user']>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    checkAuth()
  }, [])

  async function checkAuth() {
    const token = await getAccessToken()
    if (token) {
      try {
        const res = await apiClient<{ user: AuthState['user'] }>('/auth/me')
        setUser(res.data?.user ?? null)
      } catch {
        await clearTokens()
      }
    }
    setIsLoading(false)
  }

  async function signIn(email: string, password: string) {
    const res = await apiClient<{ access_token: string; refresh_token: string; user: AuthState['user'] }>('/auth/sign-in', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    })
    if (res.data) {
      await setTokens(res.data.access_token, res.data.refresh_token)
      setUser(res.data.user)
      router.replace('/(tabs)')
    }
  }

  async function signOut() {
    await clearTokens()
    setUser(null)
    router.replace('/(auth)/sign-in')
  }

  return (
    <AuthContext.Provider value={{ isAuthenticated: !!user, isLoading, user, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}
```

## WebSocket Auth on Connection

```typescript
// apps/api/src/gateways/events.gateway.ts — auth on handshake
import { WebSocketGateway, OnGatewayConnection } from '@nestjs/websockets'
import { JwtService } from '@nestjs/jwt'
import { Socket } from 'socket.io'

@WebSocketGateway({ cors: { origin: '*' } })
export class EventsGateway implements OnGatewayConnection {
  constructor(private jwtService: JwtService) {}

  handleConnection(client: Socket) {
    const token = client.handshake.auth?.token
    if (!token) {
      client.disconnect()
      return
    }

    try {
      const payload = this.jwtService.verify(token)
      client.data.user = { userId: payload.sub, role: payload.role }
    } catch {
      client.disconnect()
    }
  }
}
```

## Environment Variables

```bash
# Backend API
JWT_SECRET=your-256-bit-secret-key-here
JWT_EXPIRY=15m
REFRESH_TOKEN_EXPIRY=7d

# CMS (Next.js)
JWT_SECRET=same-secret-as-api
NEXT_PUBLIC_API_URL=http://localhost:4000

# Mobile (Expo)
EXPO_PUBLIC_API_URL=http://localhost:4000
```

## Security Rules

1. Access tokens: 15-minute expiry, never stored in localStorage (use httpOnly cookies for web, SecureStore for mobile)
2. Refresh tokens: 7-day expiry, stored in Redis, rotated on every use
3. Never include sensitive data in JWT payload (no passwords, no PII beyond email)
4. Always validate token on WebSocket connection (not just on events)
5. Rate limit auth endpoints: 5 attempts per minute per IP
6. Use `jose` library for Next.js middleware (Edge Runtime compatible)
