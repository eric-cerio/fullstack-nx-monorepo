---
name: shadcn-tailwind-patterns
description: shadcn/ui component customization and Tailwind CSS patterns for multi-app Nx monorepo. Covers per-app UI setup, design system consistency, and theming.
---

# shadcn/ui + Tailwind CSS Patterns

## Per-App UI Setup

Each Next.js app has its own shadcn/ui installation:

```
apps/admin/src/components/ui/     # Admin UI components
apps/partner/src/components/ui/   # Partner UI components
apps/resident/src/components/ui/  # Resident UI components
```

### Install Components Per App

```bash
# Navigate to app directory first
cd apps/admin
npx shadcn@latest init
npx shadcn@latest add button card dialog table form input

cd apps/partner
npx shadcn@latest init
npx shadcn@latest add button card dialog

cd apps/resident
npx shadcn@latest init
npx shadcn@latest add button card
```

## Tailwind Configuration

Each app has its own `tailwind.config.ts`:

```typescript
// apps/admin/tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/**/*.{ts,tsx}',
    // Include shared components if needed
    '../../libs/shared/src/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        // Admin-specific theme
        primary: { DEFAULT: '#1a1a2e', foreground: '#ffffff' },
        secondary: { DEFAULT: '#16213e', foreground: '#ffffff' },
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}

export default config
```

## Component Usage Pattern

```typescript
// apps/admin/src/app/users/page.tsx
import { Button } from '@/components/ui/button'
import { Card, CardHeader, CardContent } from '@/components/ui/card'
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow
} from '@/components/ui/table'

export default function UsersPage() {
  return (
    <Card>
      <CardHeader>
        <h2 className="text-2xl font-bold">Users</h2>
        <Button variant="default">Add User</Button>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Role</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {users.map(user => (
              <TableRow key={user.id}>
                <TableCell>{user.name}</TableCell>
                <TableCell>{user.email}</TableCell>
                <TableCell>{user.role}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  )
}
```

## Design System Consistency

To keep consistent theming across apps, define shared CSS variables:

```css
/* apps/admin/src/app/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    /* ... shadcn/ui CSS variables */
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    /* ... dark mode variables */
  }
}
```

## Shared Patterns (NOT Shared Components)

Don't share shadcn/ui components across apps via `libs/shared`. Instead, share:
- **Types**: `libs/shared/src/types/` — shared data types
- **Utils**: `libs/shared/src/utils/` — formatting, validation
- **Constants**: `libs/shared/src/constants/` — shared config values

Each app owns its own UI components to allow independent customization.

**Android Comparison**: shadcn/ui is like Android's Material Design components — pre-built but customizable. Tailwind is like Android's XML style attributes but inline. Each app having its own UI directory is like each Android module having its own `res/` directory. CSS variables are like Android's `colors.xml` theme attributes.
