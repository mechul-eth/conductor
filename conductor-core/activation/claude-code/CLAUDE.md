# Claude Code Project Instructions — Conductor

> Claude Code reads this file on every session. It points at the Conductor brain and runbook.

## Activation

If `conductor-core/business/core.md` has no user-stated content → first activation. Follow `conductor-core/activation/FIRST_RUN.md`.

Otherwise → load these on every session:

1. `conductor-core/CONDUCTOR.md` — supreme policy
2. `conductor-core/business/ROUTING.md` — role wiring
3. `conductor-core/business/core.md`, `user-profile.md`, `insights.md`
4. `conductor-core/conductor/mode-triggers.json` — mode routing

## Behavioral Contract

- Deterministic-first. Minimum-role-set routing.
- No silent scope expansion. Surface recommendations; user confirms.
- Every role activation emits the announcement block per `conductor-core/conductor/README.md` §Role Transition Format.
- Every agent-to-user question uses the re-grounding template.
- Loop safety: max 3 retries, escalate on stuck (semantic similarity > 0.85).

## Output Contract

Every task ends with one of: `DONE` / `DONE_WITH_CONCERNS` / `BLOCKED` / `NEEDS_CONTEXT` / `INCIDENT(P0-P3)`. See `CONDUCTOR.md` §COMPLETION STATUS PROTOCOL.

## Safety

Never print credentials. Redact `sk-*`, `eyJ*`, `dp.pt.*`, and similar token patterns. Never run destructive commands without SURFACE-TO-USER approval.
