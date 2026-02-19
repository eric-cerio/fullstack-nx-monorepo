---
name: clerk-auth-patterns
description: Clerk authentication patterns for multi-app Turborepo monorepo. Covers middleware per app, role-based access via sessionClaims.metadata.role, NestJS JWT verification, and cross-app auth strategy.
---

# Clerk Auth Patterns

## Multi-App Auth Strategy

Each Next.js app has its own Clerk middleware that enforces role-based access:

| App | Required Role | Clerk Publishable Key |
|-----|--------------|----------------------|
| admin | `admin` | `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` |
| partner | `partner` | Same key, different role check |
| resident | `resident` | Same key, different role check |
| landing-page | None (public) | Optional |

## Role Configuration in Clerk

Roles are stored in Clerk user metadata:
```json
// Clerk user publicMetadata
{
  "role": "admin"  // or "partner" or "resident"
}
```

Accessed via session claims:
```typescript
const role = sessionClaims?.metadata?.role
// or
const role = session?.publicMetadata?.role
```

## Next.js Middleware (Per App)

```typescript
// apps/admin/src/middleware.ts
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server'

const isPublicRoute = createRouteMatcher(['/sign-in(.*)', '/sign-up(.*)', '/api/webhook(.*)'])

export default clerkMiddleware(async (auth, req) => {
  if (isPublicRoute(req)) return

  // Protect all other routes
  await auth.protect()

  // Enforce admin role
  const { sessionClaims } = await auth()
  if (sessionClaims?.metadata?.role !== 'admin') {
    return new Response('Forbidden: Admin access required', { status: 403 })
  }
})
```

```typescript
// apps/partner/src/middleware.ts — same pattern, different role
export default clerkMiddleware(async (auth, req) => {
  if (isPublicRoute(req)) return
  await auth.protect()
  const { sessionClaims } = await auth()
  if (sessionClaims?.metadata?.role !== 'partner') {
    return new Response('Forbidden: Partner access required', { status: 403 })
  }
})
```

## NestJS API Auth (Backend)

```typescript
// apps/api/src/modules/auth/clerk-auth.guard.ts
import { clerkClient } from '@clerk/clerk-sdk-node'

@Injectable()
export class ClerkAuthGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest()
    const token = request.headers.authorization?.replace('Bearer ', '')

    if (!token) throw new UnauthorizedException()

    try {
      const payload = await clerkClient.verifyToken(token)
      request.auth = {
        userId: payload.sub,
        role: payload.metadata?.role,
        sessionClaims: payload,
      }
      return true
    } catch {
      throw new UnauthorizedException('Invalid Clerk token')
    }
  }
}

// apps/api/src/modules/auth/roles.decorator.ts
import { SetMetadata } from '@nestjs/common'
export const ROLES_KEY = 'roles'
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles)

// apps/api/src/modules/auth/roles.guard.ts
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ])
    if (!requiredRoles) return true

    const { auth } = context.switchToHttp().getRequest()
    return requiredRoles.includes(auth?.role)
  }
}
```

## Usage in Controllers

```typescript
@Controller('users')
@UseGuards(ClerkAuthGuard, RolesGuard)
export class UsersController {
  @Get()
  @Roles('admin')          // Only admins can list all users
  findAll() {}

  @Get(':id')
  @Roles('admin', 'partner') // Admins and partners can view a user
  findOne() {}

  @Post()
  @Roles('admin')          // Only admins can create users
  create() {}
}
```

## Clerk Webhook Handler

```typescript
// apps/api/src/modules/auth/webhook.controller.ts
@Controller('webhooks')
export class WebhookController {
  @Post('clerk')
  async handleClerkWebhook(@Req() req: Request, @Res() res: Response) {
    const svixHeaders = {
      'svix-id': req.headers['svix-id'],
      'svix-timestamp': req.headers['svix-timestamp'],
      'svix-signature': req.headers['svix-signature'],
    }

    // Verify webhook signature
    const wh = new Webhook(process.env.CLERK_WEBHOOK_SECRET)
    const payload = wh.verify(JSON.stringify(req.body), svixHeaders)

    // Handle events
    switch (payload.type) {
      case 'user.created':
        await this.usersService.syncFromClerk(payload.data)
        break
      case 'user.updated':
        await this.usersService.updateFromClerk(payload.data)
        break
    }

    return res.status(200).json({ received: true })
  }
}
```

## Shared Role Types

```typescript
// packages/shared/src/types/roles.types.ts
export type UserRole = 'admin' | 'partner' | 'resident'

export const ROLES = {
  ADMIN: 'admin' as const,
  PARTNER: 'partner' as const,
  RESIDENT: 'resident' as const,
}

export const ROLE_HIERARCHY: Record<UserRole, number> = {
  admin: 3,
  partner: 2,
  resident: 1,
}
```

## Environment Variables

```bash
# Each app needs these:
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...              # Server-side only!

# API needs:
CLERK_SECRET_KEY=sk_...
CLERK_WEBHOOK_SECRET=whsec_...
```

**Android Comparison**: Clerk middleware is like OkHttp's auth interceptor. Role guards are like Android's runtime permission checks. `sessionClaims.metadata.role` is like checking user roles from a JWT token in Retrofit. Webhooks are like Firebase Cloud Messaging — server-to-server events.
