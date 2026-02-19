# Changelog

All notable changes to the Turborepo Fullstack Monorepo Governance Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
