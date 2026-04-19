# AGENTS.md — Conductor (Codex entry point)

## Activation
First activation (when `conductor-core/business/core.md` is empty): follow
`conductor-core/activation/FIRST_RUN.md` end to end.

## Every Session
Load: `conductor-core/CONDUCTOR.md`, `conductor-core/business/ROUTING.md`,
`business/core.md`, `business/user-profile.md`, `business/insights.md`,
`conductor/mode-triggers.json`.

Route per CONDUCTOR.md §ROUTING POLICY. Announce role transitions per
`conductor/README.md` §Role Transition Format.

## Output Contract
Every task ends with:
  DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT | INCIDENT(P0-P3)

Include evidence: requirement_coverage, evidence_quality, regression_safety,
scope_discipline, remediation_log.

## Safety
Redact credential patterns in all output. No destructive commands without
SURFACE-TO-USER. Max 3 retries. Loop safety enforced.

## Unattended runs
If running with the orchestrator, read `orchestrator/README.md`.
Use `./orchestrator/conductor.sh status` to inspect state,
`resume` to continue.
