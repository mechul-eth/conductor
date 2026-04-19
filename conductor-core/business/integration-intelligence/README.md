# business/integration-intelligence/ — Cross-Layer Integration Intelligence

> Loaded when a role works on the seams between API, backend, frontend, database, and external services. Owns the truth about how layers handshake.

## What Lives Here

| File | Purpose | Required? |
|------|---------|-----------|
| `README.md` | This file | Yes |
| `foundation.md` | The integration philosophy — boundaries, contracts, failure modes | Yes (start here) |
| `canonical-envelope.md` | Standard message/event envelope shape | When you do async messaging |
| `ownership-boundaries.md` | Who owns each seam | Yes — prevents finger-pointing |
| `e2e-handshake-matrix.md` | Every cross-layer handshake, with success + failure cases | When you have > 3 layers |
| `failure-propagation-policy.md` | How errors propagate across layers | Yes when you have layers |
| `retry-idempotency-contract.md` | Retry rules, idempotency keys | When async or at-least-once delivery is in play |
| `compatibility-gate.md` | Release gate for cross-layer changes | Yes when releases ship |
| `context-efficiency.md` | Context Conductor must load | Recommended |

Add only when referenced from `ROUTING.md` or a gate.

## Wiring

Referenced from: `business/README.md`, `business/ROUTING.md`, `business/FRAME_CONTROL_ALGORITHM.md` (cross-domain changes require linkage to this domain), `roles/engineering-architect.md`, `roles/project-management.md`.

References: `core.md`, `api-intelligence/`, `backend-intelligence/`, `frontend-intelligence/`, `database-intelligence/`, `release-readiness-intelligence/`.

## Foundation Template

Suggested `foundation.md` sections:

```
1. Mission           — why this domain exists
2. Layers            — list each layer (API, backend, frontend, DB, externals)
3. Boundaries        — who owns each seam
4. Sync vs async     — which integrations are which, and why
5. Envelope          — common request/event envelope (or link to canonical-envelope.md)
6. Failure modes     — typical failures per seam, recovery pattern
7. Idempotency       — when keys are required, how they're generated
8. Decision log      — non-obvious cross-layer choices
```

## Maintenance

- Add a row to `ROUTING.md` when creating a new file here.
- Update `ownership-boundaries.md` whenever team structure changes.
- Run orphan-prevention before merging.
