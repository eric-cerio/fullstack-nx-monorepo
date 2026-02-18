# Security Guidelines

## Mandatory Security Checks

Before ANY commit:
- [ ] No hardcoded secrets (API keys, passwords, Clerk keys)
- [ ] All user inputs validated (class-validator in NestJS, Zod in Next.js)
- [ ] SQL queries parameterized (no string concatenation)
- [ ] Clerk auth guards on all API endpoints
- [ ] Role checks match endpoint requirements
- [ ] CORS restricted to known app origins
- [ ] Error messages don't leak stack traces
- [ ] `.env` files in `.gitignore`

## Clerk-Specific Security

```typescript
// NEVER: Trust client-supplied role
const role = req.body.role // ❌ User can fake this

// ALWAYS: Read from Clerk session claims
const role = req.auth.sessionClaims.metadata.role // ✅ Server-verified
```

## NestJS Guards Required

Every controller MUST have:
```typescript
@UseGuards(ClerkAuthGuard, RolesGuard)
@Roles('admin') // Specific role required
```

## Secret Management

```typescript
// NEVER: Hardcoded secrets
const key = 'sk_live_xxxxx'

// ALWAYS: Environment variables
const key = process.env.CLERK_SECRET_KEY
if (!key) throw new Error('CLERK_SECRET_KEY not configured')
```

## Security Response Protocol

If security issue found:
1. STOP immediately
2. Use **security-reviewer** agent
3. Fix CRITICAL issues before continuing
4. Rotate any exposed secrets
5. Check all apps for similar issues (monorepo-wide)
