# Feature Documentation Rules

## MANDATORY: Document Every Feature

After completing ANY feature implementation, you MUST run the **feature-documenter** agent (via `/document-feature`) to create living documentation.

## Why This Is Required

Claude has no memory between sessions. Feature documentation in `docs/features/` is Claude's only way to understand:
- What a feature does and why it was built
- Which Nx projects are involved
- What API endpoints exist and their auth requirements
- What database changes were made
- How to test the feature

## Documentation Location

```
docs/features/
├── INDEX.md               # Auto-generated index of all features
├── <feature-name>.md      # One doc per feature
└── ...
```

## Workflow Integration

```
1. /plan         — Plan the feature
2. /tdd          — Implement with TDD
3. /code-review  — Review the code
4. /document-feature — Create feature documentation  ← MANDATORY
5. Commit
```

## Code Review Pre-Requisite

The **code-reviewer** agent is instructed to read `docs/features/` BEFORE starting any review. If no feature doc exists for the code being reviewed, the reviewer should flag this.

## When to Update Existing Docs

- Feature modified significantly
- New API endpoints added
- Auth roles changed
- Database schema changed
- New edge cases discovered

## Documentation Quality

Each feature doc MUST include:
- [ ] Overview (what and why)
- [ ] Affected Nx projects
- [ ] Key files with paths
- [ ] API endpoints with auth roles
- [ ] Database changes
- [ ] Test commands
- [ ] Edge cases

## Related

- Agent: `~/.claude/agents/feature-documenter.md`
- Command: `/document-feature`
