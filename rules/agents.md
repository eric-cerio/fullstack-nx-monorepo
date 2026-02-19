# Agent Orchestration

## Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Workspace-aware implementation planning | Complex features, cross-app changes |
| architect | System design for monorepo | Architectural decisions, new modules |
| tdd-guide | TDD per workspace package | New features, bug fixes |
| code-reviewer | Monorepo-aware code review | After writing code (MANDATORY) |
| security-reviewer | Clerk + NestJS security analysis | Auth code, API endpoints |
| build-error-resolver | Fix build errors | When `turbo build` fails |
| e2e-runner | Playwright E2E per app | Critical user flows |
| dependency-analyzer | Dependency graph analysis | Restructuring, new packages |
| migration-reviewer | SQL migration safety | Creating/editing migrations |
| feature-documenter | Living feature documentation | After EVERY feature (MANDATORY) |
| status-reporter | Project health dashboard | Sprint checks, pre-release compliance |
| full-reviewer | Chained review pipeline | Before merging PRs, after major features |

## Mandatory Agent Usage

No user prompt needed — use these automatically:

1. Complex feature → **planner** agent first
2. Code written/modified → **code-reviewer** agent
3. Feature completed → **feature-documenter** agent (MANDATORY)
4. Bug fix or new feature → **tdd-guide** agent
5. Auth/security code → **security-reviewer** agent

## Feature Implementation Workflow

```text
/plan → /tdd → implement → /code-review → /document-feature → commit
```

## Parallel Execution

ALWAYS use parallel agents for independent operations:

```text
Agent 1: Security analysis of auth module
Agent 2: Build check on affected packages
Agent 3: Type checking shared package
```
