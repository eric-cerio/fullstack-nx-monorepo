# CLAUDE.md — Turborepo Fullstack Monorepo Governance Framework

This repository is a governance framework for AI-assisted fullstack Turborepo monorepo development. It is NOT an application — it is a collection of agents, rules, hooks, skills, and commands designed to be dropped into a Turborepo monorepo.

## Repository Structure

```
agents/       — 12 AI agent prompt templates (planner, reviewer, TDD, etc.)
rules/        — 10 governance rules (coding style, security, testing, etc.)
commands/     — 13 slash command definitions (/plan, /tdd, /code-review, etc.)
skills/       — 7 technology pattern libraries (NestJS, Next.js, Clerk, etc.)
hooks/        — Claude Code hook definitions (hooks.json) — ~29 hooks
bin/          — Scripts (init.sh, validate.sh)
config/       — Extended configuration (overrides.yml)
config.yml    — Framework configuration (stack, thresholds, conventions)
pipelines/    — Agent chaining definitions (full-review.yml)
examples/     — Example CLAUDE.md + minimal workspace skeleton
docs/         — Session logs directory
CHANGELOG.md  — Version history
```

## Configuration

The framework is configured via `config.yml` at the project root. This file defines:

- Stack technologies (auth provider, frontend, backend, etc.)
- Quality thresholds (coverage, file size limits)
- App names and Clerk roles
- Naming conventions

Agents and validation scripts read `config.yml` to adapt behavior. Modify it to match your project's stack.

## Rule Overrides

Environment-specific rule relaxation is configured in `config/overrides.yml`. The active profile (`development`/`staging`/`production`) determines which rules are relaxed. Production enforces all rules at full strictness.

## Target Stack

- **Monorepo**: Turborepo + pnpm workspaces
- **Frontend**: Next.js 15 + shadcn/ui + Tailwind CSS (multiple apps)
- **Backend**: NestJS 11 REST API
- **Auth**: Clerk (role-based: admin, partner, resident)
- **Database**: SQL with timestamp-named migrations
- **Testing**: Jest (unit/integration) + Playwright (E2E)
- **Linting**: ESLint 9 flat config + Prettier

## When Editing This Repository

### Rules for Modifying Framework Files

1. **Agents** (`agents/*.md`): Each agent has YAML frontmatter with `name`, `description`, `tools`, and `model`. Preserve this structure. Agents must reference specific Turborepo commands and Clerk patterns.

2. **Rules** (`rules/*.md`): Rules are prescriptive — they define MUST/MUST NOT requirements. Keep language imperative. Cross-reference other rules where relevant.

3. **Commands** (`commands/*.md`): Each command maps to an agent. The command file defines the user-facing interface; the agent file defines the behavior.

4. **Skills** (`skills/*.md`): Pattern libraries with code examples. Keep examples copy-pasteable and aligned with the rules.

5. **Hooks** (`hooks/hooks.json`): Follow the existing matcher syntax. Blocking hooks use `exit 1`. Warning hooks print to stderr and pass through with `echo "$input"`.

6. **Config** (`config.yml`, `config/overrides.yml`): YAML format. Agents read these for thresholds and active profile.

7. **Pipelines** (`pipelines/*.yml`): Declarative stage definitions that agents interpret. Each stage references an agent and its checks.

### Key Conventions

- pnpm is the only allowed package manager
- All code patterns assume Turborepo workspace with `apps/` and `packages/` directories
- Clerk auth is assumed on every endpoint — guards are mandatory
- TDD workflow is mandatory: RED → GREEN → REFACTOR
- 80% test coverage minimum per workspace package (configurable via overrides)
- Conventional commits: `type(scope): description`
- Feature docs go in `docs/features/` with an auto-generated INDEX.md
- Session summaries auto-saved to `docs/session-logs/` on session end

### Hook Matcher Syntax

```
tool == "Bash" && tool_input.command matches "pattern"
tool == "Edit" && tool_input.file_path matches "pattern"
tool == "Write" && tool_input.file_path matches "\\.ext$"
```

Matchers use regex for the `matches` operator. Escape backslashes in JSON.

## Workflow

The standard feature workflow this framework enforces:

```
/plan → /tdd → implement → /code-review → /document-feature → commit
```

Additional quality commands:

- `/status` — Project health dashboard (coverage, boundaries, compliance)
- `/full-review` — Chained pipeline: code review → security review → test coverage

## Agent Model Guidelines

| Model | Use For |
|-------|---------|
| Opus | Complex reasoning: planning, architecture, dependency analysis, documentation, full review |
| Sonnet | Main work: code review, TDD, testing, security review, migrations, status reporting |
| Haiku | Lightweight: build error resolution, quick fixes |

## File Naming Conventions

- Agents: `agents/<role>.md` (e.g., `planner.md`, `code-reviewer.md`)
- Rules: `rules/<topic>.md` (e.g., `security.md`, `testing.md`)
- Commands: `commands/<command-name>.md` (e.g., `plan.md`, `tdd.md`)
- Skills: `skills/<technology>-patterns.md` (e.g., `nestjs-patterns.md`)
- Pipelines: `pipelines/<name>.yml` (e.g., `full-review.yml`)
- Config: `config/<purpose>.yml` (e.g., `overrides.yml`)
- Migrations: `YYYYMMDDHHMMSS_description.sql`
- Session logs: `docs/session-logs/session_YYYYMMDD_HHMMSS.md`

## Validation

Run the framework validator to check consistency:

```bash
bash bin/validate.sh
```

This checks agent frontmatter, command definitions, hook JSON syntax, and config files.

## Testing Changes

After modifying any framework file:

1. Run `bash bin/validate.sh` to check for errors
2. Review that cross-references between agents, rules, and commands remain consistent
3. Verify hook matchers use valid regex
4. Ensure agent YAML frontmatter is valid
5. Check that code examples in skills follow the rules
