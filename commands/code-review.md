---
description: Comprehensive code review for Nx monorepo. Checks Nx boundaries, Clerk auth guards, NestJS patterns, SQL safety, and security. Reads docs/features/ for context first.
---

# Code Review Command

Invokes the **code-reviewer** agent for comprehensive review of changes.

## What This Command Does

1. **Read Feature Docs** — Check `docs/features/` for context
2. **Get Changed Files** — `git diff --name-only HEAD`
3. **Categorize by Nx Project** — Group changes per app/lib
4. **Review Per Category**:
   - Nx boundary compliance
   - Clerk auth correctness
   - NestJS best practices
   - SQL injection prevention
   - Code quality standards
5. **Generate Report** — Organized by severity

## Review Priorities

| Priority | Check |
|----------|-------|
| CRITICAL | Nx boundary violations, missing auth guards, SQL injection |
| HIGH | Missing DTOs validation, cross-app data leakage |
| MEDIUM | Console.log, large files, missing tests |
| LOW | Naming conventions, code style |

## Related Agent

`~/.claude/agents/code-reviewer.md`
