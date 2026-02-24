# Changelog

All notable changes to the Turborepo Fullstack Monorepo Governance Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-02-24

### Added
- 5 new technology skill libraries: React Native/Expo, JWT Auth, PostgreSQL, Redis, WebSocket patterns
- 4 new senior-level agents: mobile-specialist, realtime-architect, database-architect, api-designer (all Opus)
- 4 new slash commands: /mobile-review, /api-design, /realtime-review, /db-review
- 6 new hooks: Expo config warning, SQL-in-controller warning, cache invalidation reminder, WebSocket event naming, shared package mobile warning
- 2 new conditional pipeline stages: mobile-review, realtime-review in full-review pipeline
- Example workspace apps: cms, landing-page, mobile (with app.json Expo config)
- Mobile-specific overrides in config/overrides.yml (development profile)

### Changed
- Auth system updated from Clerk to provider-agnostic JWT (access + refresh token rotation)
- Roles expanded from 3 (admin, partner, resident) to 6 (super_admin, admin, editor, moderator, support_staff, viewer)
- Apps updated from admin/partner/resident/landing-page to landing-page/cms/mobile/api
- Stack expanded: added postgresql, redis, websockets, react-native-expo to config.yml
- Framework version bumped to 1.2.0

### Enhanced
- planner.md: Added tri-platform planning, WebSocket event planning, database schema planning, Redis cache planning
- architect.md: Added real-time architecture, PostgreSQL schema design, caching layer, mobile-web API sharing
- code-reviewer.md: Added JWT auth, React Native/Expo, WebSocket, Redis cache, PostgreSQL checklist sections
- security-reviewer.md: Added JWT token, WebSocket, mobile app, Redis session, CORS, rate limiting sections
- full-reviewer.md: Added conditional Stage 4 (Mobile Review) and Stage 5 (Real-Time Review)

## [1.1.0] - 2026-02-19

### Changed
- **BREAKING**: Migrated from Nx to Turborepo as the monorepo orchestrator
- Replaced `nx.json` with `turbo.json` for task pipeline configuration
- Replaced `project.json` per project with `package.json` scripts per package
- Renamed `libs/` directory convention to `packages/` (Turborepo standard)
- Replaced `@nx/enforce-module-boundaries` with `eslint-plugin-boundaries`
- All CLI commands updated: `pnpm nx <cmd>` → `turbo <cmd> --filter=<package>`
- Affected commands: `pnpm nx affected --target=<task>` → `turbo <task> --filter=...[HEAD~1]`
- Cache directory: `.nx/cache` → `.turbo/`
- Workspace detection: `nx.json` → `turbo.json` in `bin/init.sh`
- Init script suggests `npx create-turbo` instead of `npx create-nx-workspace`

### Renamed
- `agents/nx-dependency-analyzer.md` → `agents/dependency-analyzer.md`
- `rules/nx-boundaries.md` → `rules/boundaries.md`
- `commands/nx-graph.md` → `commands/dep-graph.md`
- `skills/nx-monorepo-patterns.md` → `skills/turborepo-patterns.md`

### Updated
- All 12 agents rewritten for Turborepo commands and concepts
- All 13 commands updated with Turborepo CLI equivalents
- All 10 rules updated (`libs/` → `packages/`, Nx → Turborepo references)
- All 7 skills updated for Turborepo workspace patterns
- `hooks/hooks.json` matchers updated for Turborepo commands
- `pipelines/full-review.yml` checks updated
- `config.yml` monorepo field changed to `turborepo`
- Example workspace fully restructured with `turbo.json` and per-package `package.json`
- README.md and CLAUDE.md fully rewritten

## [1.0.0] - 2026-02-19

### Added
- 12 AI agent prompt templates (planner, architect, tdd-guide, code-reviewer, security-reviewer, build-error-resolver, e2e-runner, nx-dependency-analyzer, migration-reviewer, feature-documenter, status-reporter, full-reviewer)
- 13 slash commands (/plan, /tdd, /code-review, /build-fix, /e2e, /test-coverage, /refactor-clean, /nx-graph, /migrate, /document-feature, /update-docs, /status, /full-review)
- 7 technology skill/pattern libraries (NestJS, Next.js, Clerk, shadcn/Tailwind, SQL migrations, Nx monorepo, coding standards)
- 10 governance rules (coding style, security, testing, git workflow, Nx boundaries, performance, patterns, documentation, agents, hooks)
- 29 Claude Code hooks (PreToolUse, PostToolUse, Stop)
- `config.yml` for stack configuration and thresholds
- `config/overrides.yml` for environment-based rule relaxation
- `pipelines/full-review.yml` for agent chaining
- `bin/init.sh` scaffolding script for installing into Nx workspaces
- `bin/validate.sh` framework validation/linting script
- Example CLAUDE.md for target projects
- Minimal workspace example in `examples/minimal-workspace/`
- Auto-generated `docs/features/INDEX.md` via PostToolUse hook
- Session summary logging via Stop hook
- README with full documentation
