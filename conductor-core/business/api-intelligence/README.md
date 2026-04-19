# business/api-intelligence/ — API Intelligence

> Conductor loads this directory when a role works on API surface, contracts, or integrations. Owns the truth about every endpoint your product exposes.

## What Lives Here

| File | Purpose | Required? |
|------|---------|-----------|
| `README.md` | This file — directory overview, wiring, growth pattern | Yes |
| `foundation.md` | The opinionated foundation — what API is, who owns it, conventions | Yes (start here) |
| `endpoint-architecture.md` | Endpoint catalog, versioning policy, breaking-change policy | When the product has > 10 endpoints |
| `compatibility-gate.md` | The release gate — what must hold for an API change to ship | Yes when releases ship |
| `context-efficiency.md` | What context Conductor must load when invoking API roles | Recommended |
| `contract-registry-spec.md` | The shape of every contract, indexed | When you start versioning |
| `security-boundary.md` | Where auth ends and business logic begins | When auth gets non-trivial |

Add files here only when they're referenced from `business/ROUTING.md` or a `compatibility-gate` (per `business/FRAME_CONTROL_ALGORITHM.md` orphan-prevention rule).

## Wiring (orphan-prevention manifest)

This directory is referenced from:

- `business/README.md` — directory map
- `business/ROUTING.md` — Engineering — Architect, Engineering — Backend rows
- `business/FRAME_CONTROL_ALGORITHM.md` — pre-execution frame lock requires `compatibility-gate.md`
- `roles/engineering-architect.md` and `roles/engineering-backend.md` — coordinate with this domain

It references:

- `business/core.md` — the always-loaded baseline
- `backend-intelligence/` — for the implementation side of API contracts
- `database-intelligence/` — for shape decisions that touch persistence
- `release-readiness-intelligence/` — for the cross-domain release gate

## Foundation Template

Start with `foundation.md`. Suggested sections:

```
1. Mission        — what API exists for
2. Surface        — public, partner, internal — list each
3. Versioning     — how versions are introduced and retired
4. Contracts      — request/response shape conventions
5. Auth           — token format, refresh, rotation policy
6. Errors         — error envelope, HTTP semantics
7. Observability  — what gets logged, what gets traced
8. Decision log   — non-obvious choices with reasoning
```

Keep it under 300 lines. Long context costs on every role activation.

## Maintenance

- Update `endpoint-architecture.md` when adding endpoints.
- Update `compatibility-gate.md` when shipping behavior changes (the gate is the contract).
- Update `business/ROUTING.md` when adding a new file here so Conductor loads it.
- Run the orphan-prevention check from `FRAME_CONTROL_ALGORITHM.md` before merging changes.
