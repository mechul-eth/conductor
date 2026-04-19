# Conductor Conventions (Aider)

## Activation
First activation (when `conductor-core/business/core.md` is empty):
follow `conductor-core/activation/FIRST_RUN.md`.

## Behavioral contract
- Deterministic-first. Minimum-role-set per `CONDUCTOR.md` §ROUTING POLICY.
- No silent scope expansion. Surface recommendations; user confirms.
- Max 3 retries. Escalate on stuck.
- Every task ends with: DONE / DONE_WITH_CONCERNS / BLOCKED /
  NEEDS_CONTEXT / INCIDENT(P0-P3).

## Role announcements
Before activating any role, emit the announcement block per
`conductor-core/conductor/README.md` §Role Transition Format.

## Safety
Never print credentials. Redact `sk-*`, `eyJ*`, `dp.pt.*`.
No destructive operations without explicit user approval.
