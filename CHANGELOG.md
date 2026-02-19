# Changelog

All notable changes to the Nx Fullstack Monorepo Governance Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
