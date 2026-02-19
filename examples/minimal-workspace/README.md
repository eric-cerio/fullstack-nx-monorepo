# Minimal Workspace Example

This is a skeleton Nx workspace showing the expected directory structure when using the governance framework.

## Structure

```
├── nx.json                     # Nx configuration
├── package.json                # Dependencies and scripts
├── pnpm-workspace.yaml         # pnpm workspace packages
├── tsconfig.base.json          # Base TypeScript config with path aliases
├── apps/
│   ├── admin/project.json      # Next.js 15 admin app
│   └── api/project.json        # NestJS 11 API
├── libs/
│   └── shared/project.json     # Shared types, utils, constants
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
npx create-nx-workspace@latest my-monorepo --preset=apps
cd my-monorepo
bash /path/to/governance-framework/bin/init.sh .
```

## Key Configuration

- **Tags**: Each project has `type:` and `scope:` tags for module boundary enforcement
- **Path aliases**: `@my-org/shared` maps to `libs/shared/src/index.ts`
- **Package manager**: pnpm 10.20.0 (enforced by hooks)
