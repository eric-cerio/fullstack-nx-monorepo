---
description: Review or design REST API endpoints for proper structure, DTOs, pagination, error handling, role-based access, and OpenAPI documentation. Invokes the api-designer agent.
---

# API Design Command

Invokes the **api-designer** agent to review or design REST API endpoints in the NestJS backend.

## What This Command Does

1. **Review Endpoint Structure** — Validate RESTful naming, HTTP method semantics, and status code usage
2. **Audit DTO Validation** — Ensure every request body has a DTO with `class-validator` decorators
3. **Check Response DTOs** — Verify internal fields (deleted_at, password hashes) are not exposed
4. **Validate Pagination** — Confirm list endpoints paginate with consistent metadata shape
5. **Review Error Handling** — Ensure all errors follow the standard response format with actionable messages
6. **Audit Role-Based Access** — Verify `@Roles()` decorators match the 6-role system (super_admin, admin, editor, moderator, support_staff, viewer)
7. **Check OpenAPI/Swagger** — Ensure endpoints have `@ApiOperation`, `@ApiResponse`, and `@ApiBody` decorators
8. **Review Rate Limiting** — Confirm per-endpoint rate limits with proper 429 responses
9. **Evaluate Webhook Design** — Check signature verification, retry policy, idempotency keys
10. **Assess API Versioning** — Verify version in URL path and backward compatibility strategy

## Steps

1. Read all controller files to map the endpoint landscape
2. Cross-reference controllers with DTO files — every body param needs a DTO
3. Check `@Roles()` on every endpoint against the role permission matrix
4. Verify OpenAPI decorators on all public-facing endpoints
5. Review error handling in service layer — NestJS exceptions vs plain throws
6. Check pagination implementation on list endpoints
7. Review webhook endpoints for signature verification and retry logic
8. Produce a categorized review with CRITICAL, HIGH, and MEDIUM findings

## When to Use

- When designing new API endpoints before implementation
- After implementing a new NestJS module with controllers
- Before opening a PR that adds or modifies API endpoints
- When adding webhook or third-party integration endpoints
- When reviewing role-based access control across the API
- When preparing the API for external consumption or documentation

## Usage Examples

```
/api-design
```

Review all API endpoints across the NestJS backend.

```
/api-design apps/api/src/modules/events/events.controller.ts
```

Review a specific controller for API design patterns.

```
/api-design --focus=roles
```

Focus the review on role-based access control across all endpoints.

```
/api-design --design events
```

Design the endpoint structure for a new events module before implementation.

## Integration

After API design review:

- Fix CRITICAL issues (missing auth, exposed internal fields) immediately
- Use `/tdd` to implement fixes with tests
- Use `/code-review` for general code quality on the implementation
- Use `/db-review` if schema changes are needed to support API improvements
- Use `/document-feature` to update API documentation

## Related Agent

`agents/api-designer.md`
