# Minimal Workspace Example

This is a skeleton Turborepo workspace showing the expected directory structure when using the governance framework.

## Structure

```
├── turbo.json                  # Turborepo task configuration
├── package.json                # Root dependencies and scripts
├── pnpm-workspace.yaml         # pnpm workspace packages
├── tsconfig.base.json          # Base TypeScript config with path aliases
├── apps/
│   ├── landing-page/package.json   # Next.js 15 public landing page (SSR/SSG)
│   ├── cms/package.json            # Next.js 15 CMS admin dashboard
│   ├── mobile/package.json         # React Native (Expo) mobile app
│   ├── mobile/app.json             # Expo configuration
│   └── api/package.json            # NestJS 11 API (REST + WebSocket)
├── packages/
│   └── shared/package.json     # Shared types, utils, constants
├── database/
│   └── migrations/             # SQL migration files
├── docs/
│   ├── features/               # Feature documentation
│   └── session-logs/           # Auto-generated session summaries
└── .env.example                # Environment variable template
```

## Usage

This is a reference skeleton, not a runnable project. To create a real workspace:

```bash
npx create-turbo@latest my-monorepo
cd my-monorepo
bash /path/to/governance-framework/bin/init.sh .
```

## Key Configuration

- **Workspace packages**: Each app/package has its own `package.json` with build/test/lint scripts
- **Path aliases**: `@my-org/shared` maps to `packages/shared/src/index.ts`
- **Package manager**: pnpm 10.20.0 (enforced by hooks)
- **Module boundaries**: Enforced via `eslint-plugin-boundaries`

## Platform-Specific Notes

- **Landing Page** (`:3002`): SSR/SSG, public-facing, WebSocket client for live attendance
- **CMS** (`:3001`): Admin panel with 6 role-based access levels
- **Mobile**: Run with `pnpm dev:mobile` (Expo CLI), uses SecureStore for JWT tokens
- **API** (`:4000`): NestJS with REST endpoints + WebSocket Gateway for real-time features
