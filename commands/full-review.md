---
description: Comprehensive chained review pipeline. Runs code review, security review, and test coverage analysis in sequence, producing a unified report with an overall verdict.
---

# Full Review Command

Invokes the **full-reviewer** agent to execute a multi-stage review pipeline.

## Pipeline Stages

| Stage | Focus | Based On |
|-------|-------|----------|
| 1. Code Review | Nx boundaries, auth guards, code quality | code-reviewer agent |
| 2. Security Review | Auth bypass, SQL injection, secret leaks | security-reviewer agent |
| 3. Test Coverage | Per-project coverage, critical path gaps | tdd-guide agent |

## What This Command Does

1. Run complete code review checklist (Nx boundaries, Clerk auth, NestJS patterns)
2. Run security audit (Clerk bypass, SQL injection, CORS, secrets)
3. Run coverage analysis (per-project thresholds, critical path coverage)
4. Generate unified report with per-stage findings
5. Issue verdict: **APPROVE**, **BLOCK**, or **WARN**

## When to Use

- Before merging a PR
- After completing a major feature
- During sprint review / pre-release
- When you need a comprehensive quality gate

## Verdict Criteria

- **APPROVE**: No CRITICAL or HIGH issues in any stage, coverage above threshold
- **BLOCK**: Any CRITICAL issue in any stage
- **WARN**: HIGH issues only, or coverage marginally below threshold

## Pipeline Definition

See `pipelines/full-review.yml` for the stage configuration.

## Related Agent

`agents/full-reviewer.md`
