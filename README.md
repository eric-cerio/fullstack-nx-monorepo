# Turborepo Fullstack Monorepo — Claude Code Governance Framework

A production-ready governance framework for managing fullstack Turborepo monorepos with AI-assisted development. This toolkit provides rules, agents, hooks, skills, and slash commands that integrate with [Claude Code](https://claude.ai/claude-code) to enforce architectural standards, automate quality checks, and streamline team workflows.

## What This Is

This is **not** an application — it's a **framework and knowledge base** you drop into your Turborepo monorepo to get:

- **12 specialized AI agents** for planning, reviewing, testing, and documenting
- **13 slash commands** for common workflows (`/plan`, `/tdd`, `/code-review`, `/status`, etc.)
- **~29 automation hooks** that enforce standards in real-time
- **7 technology skill guides** covering NestJS, Next.js, Clerk, and more
- **10 governance rules** for code style, security, testing, and architecture
- **Configurable thresholds** with environment-based overrides
- **Agent chaining pipelines** for comprehensive review workflows

## Target Stack

| Layer | Technology |
|-------|-----------|
| Monorepo | Turborepo + pnpm workspaces |
| Frontend | Next.js 15 + shadcn/ui + Tailwind CSS |
| Backend | NestJS 11 REST API |
| Auth | Clerk (role-based access control) |
| Database | SQL with migration files |
| Testing | Jest + Playwright |
| Linting | ESLint 9 flat config + Prettier |

## Quick Start

### 1. Prerequisites

- [Claude Code CLI](https://claude.ai/claude-code) installed and authenticated
- An existing Turborepo monorepo (or create one with `npx create-turbo`)
- pnpm installed (`npm install -g pnpm`)

### 2. Install the Framework

Use the init script to install automatically:

```bash
# From your Turborepo monorepo root
bash <path-to-this-repo>/bin/init.sh .

# Or preview first with dry run
bash <path-to-this-repo>/bin/init.sh --dry-run .
```

The init script will:

- Detect your Turborepo workspace
- Copy all framework directories (agents, rules, commands, skills, hooks)
- Copy `config.yml` and `config/overrides.yml`
- Create required directories (`docs/features/`, `docs/session-logs/`, `database/migrations/`)
- Set up Claude Code hooks via symlink

### 3. Configure

```bash
# Adjust stack settings and thresholds
edit config.yml

# Set your environment profile (development/staging/production)
edit config/overrides.yml

# Customize the project CLAUDE.md
edit CLAUDE.md
```

### 4. Validate

```bash
# Verify the framework is installed correctly
bash bin/validate.sh
```

### 5. Start Using It

Open Claude Code in your monorepo and use the slash commands:

```
/plan          — Plan a new feature with workspace-aware dependency analysis
/tdd           — Start test-driven development on a specific package
/code-review   — Review code for boundary violations, auth gaps, and style
/status        — Project health dashboard
/full-review   — Comprehensive code + security + coverage review
```

## Project Structure

```
├── agents/           # 12 AI agent prompt templates
│   ├── planner.md            # Feature planning (Opus)
│   ├── architect.md          # System design (Opus)
│   ├── tdd-guide.md          # TDD enforcement (Sonnet)
│   ├── code-reviewer.md      # Code review (Sonnet)
│   ├── security-reviewer.md  # Security analysis (Sonnet)
│   ├── build-error-resolver.md  # Build fixes (Haiku)
│   ├── e2e-runner.md         # E2E testing (Sonnet)
│   ├── dependency-analyzer.md   # Dep graph (Opus)
│   ├── migration-reviewer.md # SQL migrations (Sonnet)
│   ├── feature-documenter.md # Documentation (Opus)
│   ├── status-reporter.md    # Health dashboard (Sonnet)
│   └── full-reviewer.md      # Chained pipeline (Opus)
│
├── rules/            # 10 governance rule files
│   ├── coding-style.md       # Code quality standards
│   ├── git-workflow.md       # Conventional commits, PR process
│   ├── boundaries.md         # Module boundary enforcement
│   ├── testing.md            # 80% coverage, TDD mandatory
│   ├── performance.md        # Model selection, caching
│   ├── patterns.md           # API response, DTO, pagination
│   ├── security.md           # Clerk guards, secrets, CORS
│   ├── documentation.md      # Feature doc requirements
│   ├── agents.md             # Agent orchestration workflow
│   └── hooks.md              # Hook types and descriptions
│
├── commands/         # 13 slash command definitions
│   ├── plan.md               # /plan
│   ├── tdd.md                # /tdd
│   ├── code-review.md        # /code-review
│   ├── build-fix.md          # /build-fix
│   ├── e2e.md                # /e2e
│   ├── test-coverage.md      # /test-coverage
│   ├── refactor-clean.md     # /refactor-clean
│   ├── dep-graph.md          # /dep-graph
│   ├── migrate.md            # /migrate
│   ├── document-feature.md   # /document-feature
│   ├── update-docs.md        # /update-docs
│   ├── status.md             # /status
│   └── full-review.md        # /full-review
│
├── skills/           # 7 technology pattern libraries
│   ├── turborepo-patterns.md
│   ├── nextjs-patterns.md
│   ├── nestjs-patterns.md
│   ├── clerk-auth-patterns.md
│   ├── shadcn-tailwind-patterns.md
│   ├── sql-migration-patterns.md
│   └── coding-standards.md
│
├── hooks/            # Claude Code hook definitions
│   └── hooks.json            # ~29 hooks (PreToolUse, PostToolUse, Stop)
│
├── bin/              # Scripts
│   ├── init.sh               # Install framework into Turborepo workspace
│   └── validate.sh           # Validate framework consistency
│
├── config.yml        # Framework configuration (stack, thresholds)
├── config/           # Extended configuration
│   └── overrides.yml         # Environment-based rule overrides
│
├── pipelines/        # Agent chaining definitions
│   └── full-review.yml       # Code + security + coverage pipeline
│
├── examples/         # Reference files
│   ├── CLAUDE.md             # Example CLAUDE.md for target projects
│   └── minimal-workspace/    # Skeleton Turborepo workspace structure
│
├── docs/
│   └── session-logs/         # Auto-generated session summaries
│
├── CHANGELOG.md      # Version history
├── .gitignore        # Git ignore rules
├── CLAUDE.md         # Claude Code project instructions
└── README.md         # This file
```

## Feature Development Workflow

The framework enforces a structured workflow for every feature:

```
/plan → /tdd → implement → /code-review → /document-feature → commit
```

| Step | Command | What Happens |
|------|---------|-------------|
| 1 | `/plan` | Planner agent analyzes the workspace, identifies affected packages, and creates a step-by-step plan |
| 2 | `/tdd` | TDD guide generates failing tests first (RED), then you implement (GREEN), then refactor (IMPROVE) |
| 3 | implement | Write code following the plan — hooks auto-format, type-check, and warn in real-time |
| 4 | `/code-review` | Reviewer checks module boundaries, Clerk guards, test coverage, and coding standards |
| 5 | `/document-feature` | Documenter creates living docs in `docs/features/` (INDEX.md auto-generated) |
| 6 | commit | Conventional commit format: `feat(admin): add user management dashboard` |

## Slash Commands Reference

| Command | Description | Agent Model |
|---------|-------------|------------|
| `/plan` | Workspace-aware implementation planning | Opus |
| `/tdd` | Test-driven development per package | Sonnet |
| `/code-review` | Monorepo code review with auth checks | Sonnet |
| `/build-fix` | Fix Turborepo build errors | Haiku |
| `/e2e` | Generate/run Playwright E2E tests | Sonnet |
| `/test-coverage` | Coverage analysis per workspace package | Sonnet |
| `/refactor-clean` | Dead code removal across monorepo | Sonnet |
| `/dep-graph` | Analyze workspace dependency graph | Opus |
| `/migrate` | Create/review SQL migrations | Sonnet |
| `/document-feature` | Create feature documentation | Opus |
| `/update-docs` | Sync all documentation | Sonnet |
| `/status` | Project health dashboard | Sonnet |
| `/full-review` | Chained code + security + coverage review | Opus |

## Hooks System

Hooks run automatically during Claude Code sessions to enforce standards:

### PreToolUse (Before Actions)

| Hook | Behavior |
|------|----------|
| Dev server outside tmux | **BLOCKED** — suggests `brew install tmux` if missing |
| npm/yarn/bun install | **BLOCKED** — shows pnpm equivalent command |
| Editing `packages/shared/` | **WARNING** — changes affect all apps |
| Writing `.env` files | **BLOCKED** — use `.env.example` templates |
| Destructive SQL (DROP, TRUNCATE) | **BLOCKED** — run manually if intentional |
| Migration naming | **WARNING** — shows correct example with timestamp |
| `git push` | **PAUSE** — review changes before pushing |
| Random `.md` creation | **BLOCKED** — use `docs/features/` or standard docs |

### PostToolUse (After Actions)

| Hook | Behavior |
|------|----------|
| Edit `.ts/.tsx/.js/.jsx` | Auto-format with Prettier |
| Edit `.ts/.tsx` | TypeScript type-checking |
| Edit source files | Warn about `console.log` |
| Edit ESLint config | Remind to lint all packages |
| Edit Turbo config | Warn about cache invalidation |
| Edit migration files | Warn about editing applied migrations |
| Edit auth files | Remind to test all Clerk roles |
| Create feature doc | Auto-regenerate `docs/features/INDEX.md` |

### Stop (Session End)

| Hook | Behavior |
|------|----------|
| Session ends | Audit for `console.log` in modified files |
| Session ends | Scan for `.env` file modifications |
| Session ends | Remind to document features if new files created |
| Session ends | Save session summary to `docs/session-logs/` |

## Configuration

### `config.yml`

Central configuration for stack, thresholds, and conventions:

```yaml
version: "1.0.0"
stack:
  auth_provider: clerk
  frontend: nextjs-15
  backend: nestjs-11
thresholds:
  test_coverage: 80
  max_file_lines: 800
```

### `config/overrides.yml`

Environment-based rule relaxation:

| Profile | Coverage | TDD | Console.log | Feature Docs |
| ------- | -------- | --- | ----------- | ----------- |
| `development` | 60% | Optional | Allowed | Optional |
| `staging` | 70% | Required | Blocked | Required |
| `production` | 80% | Required | Blocked | Required |

Set the active profile in `config/overrides.yml` under `active_profile`.

## Validation

Run the framework validator to check consistency:

```bash
bash bin/validate.sh
```

This checks:

- Agent YAML frontmatter (required fields, valid model values)
- Command definitions (frontmatter, description)
- `hooks.json` syntax and completeness
- Config files existence and version field
- Required directories

## Versioning

This framework follows [Semantic Versioning](https://semver.org/). See [CHANGELOG.md](CHANGELOG.md) for version history.

Current version is defined in `config.yml` under the `version` field.

## Customization

### Adapting to Your Stack

1. **Different auth provider?** — Edit [skills/clerk-auth-patterns.md](skills/clerk-auth-patterns.md) and [rules/security.md](rules/security.md)
2. **Different frontend?** — Edit [skills/nextjs-patterns.md](skills/nextjs-patterns.md) and update app structure in [examples/CLAUDE.md](examples/CLAUDE.md)
3. **Different backend?** — Edit [skills/nestjs-patterns.md](skills/nestjs-patterns.md) and update patterns in [rules/patterns.md](rules/patterns.md)
4. **Different DB?** — Edit [skills/sql-migration-patterns.md](skills/sql-migration-patterns.md)

### Adding Custom Hooks

Edit [hooks/hooks.json](hooks/hooks.json) following the pattern:

```json
{
  "matcher": "tool == \"Edit\" && tool_input.file_path matches \"your-pattern\"",
  "hooks": [{
    "type": "command",
    "command": "#!/bin/bash\necho '[Hook] Your message' >&2\necho \"$(cat)\""
  }],
  "description": "What this hook does"
}
```

### Adding Custom Agents

Create a new `.md` file in [agents/](agents/) with YAML frontmatter:

```markdown
---
name: my-agent
description: When to use this agent
tools: [Read, Grep, Glob, Bash]
model: sonnet
---

# Agent prompt instructions here...
```

### Example Workspace

See [examples/minimal-workspace/](examples/minimal-workspace/) for a skeleton Turborepo workspace showing the expected directory structure with `package.json` files per package, `turbo.json` pipeline config, and workspace dependencies.

## Key Rules Summary

| Rule | Requirement |
|------|------------|
| Module boundaries | Apps cannot import from other apps; use `packages/shared` |
| Auth guards | Every NestJS endpoint needs `ClerkAuthGuard` + `RolesGuard` |
| Package manager | pnpm only (enforced by hooks) |
| Test coverage | 80% minimum per workspace package (configurable) |
| TDD | Mandatory for new features (configurable per environment) |
| File size | < 800 lines per file, < 50 lines per function |
| Types | No `any` — use proper TypeScript types |
| Logging | No `console.log` — use NestJS Logger |
| Commits | Conventional format: `type(scope): description` |
| Documentation | Feature docs mandatory after implementation |

## License

MIT
