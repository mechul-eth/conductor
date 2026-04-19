# business/backend-intelligence/ — Backend Intelligence

> Loaded when a role works on server-side implementation — endpoints, jobs, integrations. Owns the truth about your service architecture.

## What Lives Here

| File | Purpose | Required? |
|------|---------|-----------|
| `README.md` | This file | Yes |
| `foundation.md` | What backend is, services, runtimes, conventions | Yes (start here) |
| `service-architecture.md` | Service boundaries, deployment units, inter-service calls | When > 1 service |
| `api-boundary.md` | Where the API surface ends and internal code begins | Always useful |
| `worker-reliability.md` | Background job, queue, scheduler policy — retries, DLQ, idempotency | When you have workers |
| `compatibility-gate.md` | Release gate for backend changes | Yes when releases ship |
| `context-efficiency.md` | Context Conductor must load for backend roles | Recommended |

Add only when referenced from `business/ROUTING.md` or a gate (orphan-prevention rule).

## Wiring

Referenced from: `business/README.md`, `business/ROUTING.md`, `business/FRAME_CONTROL_ALGORITHM.md`, `roles/engineering-backend.md`, `roles/engineering-architect.md`.

References: `core.md`, `api-intelligence/`, `database-intelligence/`, `integration-intelligence/`, `release-readiness-intelligence/`.

## Foundation Template

Suggested `foundation.md` sections:

```
1. Mission         — what the backend exists to do
2. Services        — list each service, its owner, its runtime
3. Runtime         — language, framework, key libraries
4. Conventions     — errors, logging, config, secrets
5. Boundaries      — what crosses the API line vs. stays internal
6. Data            — how services talk to the database (shared vs. per-service)
7. Async           — jobs, queues, schedulers, back-pressure
8. Observability   — logs, metrics, traces — what's required vs. optional
9. Decision log    — non-obvious choices
```

## Maintenance

- Add a row to `ROUTING.md` when creating a new file here.
- Update `compatibility-gate.md` whenever you change what "safe to ship" means.
- Run orphan-prevention before merging.
