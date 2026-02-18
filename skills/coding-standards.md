---
name: coding-standards
description: TypeScript coding standards for Nx monorepo. Covers path aliases, barrel exports, immutability, naming conventions, and shared library patterns.
---

# Coding Standards for Nx Monorepo

## TypeScript Standards

### Path Aliases (Nx)
```typescript
// ✅ GOOD: Use Nx path aliases
import { UserType } from '@shared/types'
import { formatDate } from '@shared/utils'

// ❌ BAD: Relative imports crossing project boundaries
import { UserType } from '../../../libs/shared/src/types'
```

Path aliases defined in `tsconfig.base.json`:
```json
{
  "paths": {
    "@shared/*": ["libs/shared/src/*"]
  }
}
```

### Barrel Exports (Shared Lib)
```typescript
// libs/shared/src/types/index.ts
export * from './user.types'
export * from './api-response.types'
export * from './roles.types'

// libs/shared/src/index.ts (main entry)
export * from './types'
export * from './utils'
export * from './constants'
```

### Immutability (CRITICAL)
```typescript
// ✅ ALWAYS: Spread operator
const updatedUser = { ...user, name: 'New' }
const updatedList = [...items, newItem]

// ❌ NEVER: Direct mutation
user.name = 'New'
items.push(newItem)
```

### Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Files | kebab-case | `user-profile.component.tsx` |
| Components | PascalCase | `UserProfile` |
| Functions | camelCase | `getUserById` |
| Constants | UPPER_SNAKE | `MAX_RETRY_COUNT` |
| Types/Interfaces | PascalCase | `UserProfile`, `ApiResponse` |
| NestJS modules | PascalCase + suffix | `UsersModule`, `UsersService` |
| DTOs | PascalCase + Dto | `CreateUserDto`, `UpdateUserDto` |

### File Organization
- 200-400 lines typical, 800 max
- One component/service/module per file
- Organize by feature/domain, not by type
- Co-locate tests next to source files

### Error Handling
```typescript
// NestJS: Use built-in exceptions
throw new NotFoundException('User not found')
throw new ForbiddenException('Insufficient permissions')
throw new BadRequestException('Invalid input')

// Next.js: Return proper responses
return NextResponse.json({ success: false, error: 'Not found' }, { status: 404 })
```

### No console.log
```typescript
// ❌ Never in production code
console.log('debug:', data)

// ✅ Use NestJS Logger
import { Logger } from '@nestjs/common'
private readonly logger = new Logger(UsersService.name)
this.logger.log('User created')
this.logger.error('Failed to create user', error.stack)
```
