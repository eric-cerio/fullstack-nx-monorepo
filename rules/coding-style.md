# Coding Style

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate:
```typescript
// ✅ CORRECT
const updated = { ...user, name: 'New' }
const newList = [...items, newItem]

// ❌ WRONG
user.name = 'New'
items.push(newItem)
```

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- 200-400 lines typical, 800 max
- One component/service/module per file
- Organize by feature/domain
- NestJS: one module folder per domain

## NestJS Conventions

- Modules: `[domain].module.ts`
- Controllers: `[domain].controller.ts`
- Services: `[domain].service.ts`
- DTOs: `dto/create-[domain].dto.ts`, `dto/update-[domain].dto.ts`
- Guards: `[name].guard.ts`
- Tests: `[name].spec.ts` (co-located)

## Next.js Conventions

- Pages: `app/[route]/page.tsx`
- Layouts: `app/[route]/layout.tsx`
- Components: `components/[ComponentName].tsx`
- Client components: `'use client'` directive at top
- Server components: default (no directive)

## Code Quality Checklist

- [ ] No console.log (use NestJS Logger)
- [ ] No `any` types
- [ ] Functions < 50 lines
- [ ] Files < 800 lines
- [ ] Immutable patterns used
- [ ] Proper error handling
- [ ] DTOs validated with class-validator
