# business/release-readiness-intelligence/ — Release Readiness Intelligence

> Loaded on every release. Owns the truth about what "ready to ship" means, the gates, and the rollback posture.

## What Lives Here

| File | Purpose | Required? |
|------|---------|-----------|
| `README.md` | This file | Yes |
| `foundation.md` | Release philosophy — cadence, environments, who signs off | Yes (start here) |
| `go-live-gate-taxonomy.md` | All gate letters/names + when they run | Yes when releases ship |
| `deterministic-release-controls.md` | The non-negotiable release controls | Yes when releases ship |
| `evidence-contract-registry.md` | What evidence each role must produce pre-release | Yes when releases ship |
| `rollback-and-fallback-governance.md` | Rollback triggers, decision authority | Yes when releases ship |
| `release-risk-classification.md` | How to classify release risk (P0-P4) | Yes when releases ship |
| `release-window-and-change-freeze.md` | Release windows, freeze policy | When the team has cadence |
| `incident-and-escalation-protocol.md` | Who does what when an incident fires during a release | Yes when releases ship |
| `compatibility-gate.md` | Umbrella release gate — references every other domain's gate | Yes when releases ship |
| `context-efficiency.md` | Context Conductor must load for release work | Recommended |

Add only when referenced from `ROUTING.md` or a gate.

## Wiring

Referenced from: `business/README.md`, `business/ROUTING.md`, `business/FRAME_CONTROL_ALGORITHM.md` (cross-domain changes require linkage here), every other `*-intelligence/compatibility-gate.md`, `roles/project-management.md`, `roles/engineering-devops.md`, `roles/engineering-security.md`.

References: `core.md`, every other `*-intelligence/` directory.

## Foundation Template

Suggested `foundation.md` sections:

```
1. Mission           — what "release readiness" means here
2. Cadence           — weekly? continuous? on-demand?
3. Environments      — dev / stg / prod (or just dev → prod)
4. Sign-off          — who signs off at each gate
5. Gate letters      — A through H (or whatever you use); map each to a doc
6. Risk classes      — P0, P1, P2, P3 with examples
7. Rollback          — triggers, decision authority, execution
8. Incident bridge   — where the team gathers when something fires
9. Decision log      — non-obvious release choices
```

## Maintenance

- Add a row to `ROUTING.md` when creating a new file here.
- `evidence-contract-registry.md` and `compatibility-gate.md` are load-bearing — changes here affect every release.
- Run orphan-prevention before merging.
