---
description: Project health dashboard. Reports coverage gaps, module boundary violations, undocumented features, console.log counts, stale migrations, and governance compliance.
---

# Status Command

Invokes the **status-reporter** agent to generate a project health dashboard.

## What This Command Does

1. **Coverage Gaps** — Run coverage checks and identify packages below threshold
2. **Boundary Violations** — Lint for `eslint-plugin-boundaries` violations
3. **Undocumented Features** — Compare app source against `docs/features/` entries
4. **Console.log Audit** — Count console.log statements across all source files
5. **Stale Migrations** — Check for old migrations without recent activity
6. **Config Compliance** — Validate against `config.yml` thresholds

## Output Format

| Check | Status | Details |
|-------|--------|---------|
| Coverage | PASS/WARN/FAIL | X/Y packages above threshold |
| Boundaries | PASS/FAIL | N violations found |
| Documentation | WARN | X features undocumented |
| Console.log | WARN/PASS | N statements found |
| Migrations | OK/STALE | Last migration date |

## When to Use

- Sprint standup health checks
- Before starting a new feature (check current state)
- Before releases (ensure compliance)
- Periodically to track project health trends

## Related Agent

`agents/status-reporter.md`
