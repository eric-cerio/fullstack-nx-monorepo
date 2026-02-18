---
name: nestjs-patterns
description: NestJS 11 patterns for the Nx monorepo API. Covers modules, controllers, services, guards, interceptors, DTOs with class-validator, and Clerk auth integration.
---

# NestJS 11 Patterns

## Module Structure

```typescript
// apps/api/src/modules/users/users.module.ts
@Module({
  imports: [DatabaseModule],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService], // Only if other modules need it
})
export class UsersModule {}
```

## Controller Pattern

```typescript
// apps/api/src/modules/users/users.controller.ts
@Controller('users')
@UseGuards(ClerkAuthGuard, RolesGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @Roles('admin')
  async findAll(@Query() query: PaginationDto): Promise<ApiResponse<User[]>> {
    const { data, total } = await this.usersService.findAll(query)
    return {
      success: true,
      data,
      meta: { total, page: query.page, limit: query.limit },
    }
  }

  @Get(':id')
  @Roles('admin', 'partner')
  async findOne(@Param('id', ParseIntPipe) id: number): Promise<ApiResponse<User>> {
    const user = await this.usersService.findOne(id)
    if (!user) throw new NotFoundException('User not found')
    return { success: true, data: user }
  }

  @Post()
  @Roles('admin')
  async create(@Body() dto: CreateUserDto): Promise<ApiResponse<User>> {
    const user = await this.usersService.create(dto)
    return { success: true, data: user }
  }
}
```

## Service Pattern

```typescript
// apps/api/src/modules/users/users.service.ts
@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name)

  constructor(private readonly db: DatabaseService) {}

  async findAll(query: PaginationDto): Promise<{ data: User[]; total: number }> {
    const { page = 1, limit = 10 } = query
    const offset = (page - 1) * limit

    const data = await this.db.query<User>(
      'SELECT * FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2',
      [limit, offset]
    )

    const [{ count }] = await this.db.query<{ count: number }>(
      'SELECT COUNT(*) as count FROM users'
    )

    return { data, total: count }
  }

  async findByClerkId(clerkId: string): Promise<User | null> {
    const [user] = await this.db.query<User>(
      'SELECT * FROM users WHERE clerk_id = $1',
      [clerkId]
    )
    return user || null
  }
}
```

## DTO with class-validator

```typescript
// apps/api/src/modules/users/dto/create-user.dto.ts
import { IsString, IsEmail, IsIn, IsOptional } from 'class-validator'

export class CreateUserDto {
  @IsString()
  clerkId: string

  @IsEmail()
  email: string

  @IsIn(['admin', 'partner', 'resident'])
  role: string

  @IsOptional()
  @IsString()
  name?: string
}
```

## Clerk Auth Guard

```typescript
// apps/api/src/modules/auth/clerk-auth.guard.ts
@Injectable()
export class ClerkAuthGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest()
    const token = request.headers.authorization?.replace('Bearer ', '')

    if (!token) throw new UnauthorizedException('Missing token')

    try {
      const session = await clerkClient.verifyToken(token)
      request.auth = session
      return true
    } catch {
      throw new UnauthorizedException('Invalid token')
    }
  }
}
```

## Roles Guard & Decorator

```typescript
// apps/api/src/modules/auth/roles.decorator.ts
export const Roles = (...roles: string[]) => SetMetadata('roles', roles)

// apps/api/src/modules/auth/roles.guard.ts
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.get<string[]>('roles', context.getHandler())
    if (!requiredRoles) return true

    const request = context.switchToHttp().getRequest()
    const userRole = request.auth?.sessionClaims?.metadata?.role

    if (!requiredRoles.includes(userRole)) {
      throw new ForbiddenException('Insufficient permissions')
    }

    return true
  }
}
```

## Global Configuration

```typescript
// apps/api/src/main.ts
async function bootstrap() {
  const app = await NestFactory.create(AppModule)

  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,        // Strip unknown properties
    forbidNonWhitelisted: true, // Throw on unknown properties
    transform: true,        // Auto-transform types
  }))

  // CORS
  app.enableCors({
    origin: [
      'http://localhost:3000', // admin
      'http://localhost:3001', // partner
      'http://localhost:3002', // resident
    ],
  })

  // Helmet
  app.use(helmet())

  await app.listen(4000)
}
```

## Error Response Pattern

```typescript
// All errors return consistent format
{
  "success": false,
  "error": "User not found",
  "statusCode": 404
}
```

**Android Comparison**: NestJS modules are like Android's Hilt modules. Controllers are like Activities/Fragments handling requests. Services are like ViewModels containing business logic. Guards are like Android's permission checks. DTOs with class-validator are like Android's data classes with validation.
