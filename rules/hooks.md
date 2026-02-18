# Hooks System

## Hook Types

- **PreToolUse**: Before tool execution (validation, blocking, warnings)
- **PostToolUse**: After tool execution (auto-format, checks, reminders)
- **Stop**: When session ends (final verification)

## Current Hooks

### PreToolUse
- **tmux enforcement**: Block dev servers outside tmux (`nx serve`, `pnpm dev`)
- **pnpm enforcement**: Block npm/yarn/bun install commands
- **shared lib warning**: Warn when editing `libs/shared/` (affects all apps)
- **env blocker**: Block writing to `.env` files
- **SQL safety**: Block destructive SQL operations (DROP, TRUNCATE)
- **migration warning**: Warn about naming conventions when creating migrations
- **git push review**: Pause before git push for review
- **doc blocker**: Block unnecessary `.md/.txt` file creation
- **nx run-many tmux**: Warn about `nx run-many` outside tmux

### PostToolUse
- **Prettier**: Auto-format JS/TS files after edit
- **TypeScript check**: Run tsc after editing `.ts/.tsx`
- **console.log warning**: Warn about console.log in edited files
- **ESLint config**: Remind to lint all projects after ESLint changes
- **Nx config**: Warn about Nx cache after `nx.json`/`project.json` changes
- **Migration edit**: Warn about editing existing migrations
- **PR creation**: Log PR URL after `gh pr create`
- **Clerk auth**: Remind to verify roles after auth file changes

### Stop
- **console.log audit**: Check modified files for console.log
- **env leak check**: Check for `.env` file modifications
- **feature doc reminder**: Remind to run `/document-feature` if new files created without matching docs
