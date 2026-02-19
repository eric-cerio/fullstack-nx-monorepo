# Minimal Workspace Example

This is a skeleton Turborepo workspace showing the expected directory structure when using the governance framework.

## Structure

```
├── turbo.json                  # Turborepo task configuration
├── package.json                # Root dependencies and scripts
├── pnpm-workspace.yaml         # pnpm workspace packages
├── tsconfig.base.json          # Base TypeScript config with path aliases
├── apps/
│   ├── admin/package.json      # Next.js 15 admin app
│   └── api/package.json        # NestJS 11 API
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
