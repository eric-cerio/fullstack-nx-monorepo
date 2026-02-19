# Common Patterns

## API Response Format (Shared Type)

```typescript
// packages/shared/src/types/api-response.types.ts
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  meta?: {
    total: number
    page: number
    limit: number
  }
}
```

## NestJS DTO Pattern

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
}
```

## Repository Pattern (NestJS Service)

```typescript
// Each service acts as a repository
interface UserRepository {
  findAll(filters?: PaginationDto): Promise<{ data: User[]; total: number }>
  findById(id: number): Promise<User | null>
  findByClerkId(clerkId: string): Promise<User | null>
  create(data: CreateUserDto): Promise<User>
  update(id: number, data: UpdateUserDto): Promise<User>
  delete(id: number): Promise<void>
}
```

## Pagination Pattern

```typescript
// packages/shared/src/types/pagination.types.ts
export class PaginationDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  page?: number = 1

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 10
}
```

## Error Handling Pattern

```typescript
// NestJS: Use built-in exceptions
throw new NotFoundException('User not found')
throw new BadRequestException('Invalid input')
throw new ForbiddenException('Insufficient permissions')
throw new UnauthorizedException('Authentication required')
```
