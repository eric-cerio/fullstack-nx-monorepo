# Hooks System

## Hook Types

- **PreToolUse**: Before tool execution (validation, blocking, warnings)
- **PostToolUse**: After tool execution (auto-format, checks, reminders)
- **Stop**: When session ends (final verification)

## Current Hooks

### PreToolUse
- **tmux enforcement**: Block dev servers outside tmux (`turbo dev`, `pnpm dev`)
- **pnpm enforcement**: Block npm/yarn/bun install commands
- **shared package warning**: Warn when editing `packages/shared/` (affects all apps)
- **env blocker**: Block writing to `.env` files
- **SQL safety**: Block destructive SQL operations (DROP, TRUNCATE)
- **migration warning**: Warn about naming conventions when creating migrations
- **git push review**: Pause before git push for review
- **doc blocker**: Block unnecessary `.md/.txt` file creation
- **turbo run tmux**: Warn about `turbo` multi-package tasks outside tmux

### PostToolUse
- **Prettier**: Auto-format JS/TS files after edit
- **TypeScript check**: Run tsc after editing `.ts/.tsx`
- **console.log warning**: Warn about console.log in edited files
- **ESLint config**: Remind to lint all projects after ESLint changes
- **Turbo config**: Warn about Turbo cache after `turbo.json`/`package.json` changes
- **Migration edit**: Warn about editing existing migrations
- **PR creation**: Log PR URL after `gh pr create`
- **Clerk auth**: Remind to verify roles after auth file changes
- **INDEX auto-generator**: Regenerate `docs/features/INDEX.md` when a new feature doc is created

### Stop
- **console.log audit**: Check modified files for console.log
- **env leak check**: Check for `.env` file modifications
- **feature doc reminder**: Remind to run `/document-feature` if new files created without matching docs
- **session summary**: Save session summary (branch, modified files, untracked files) to `docs/session-logs/`
