# GEMINI.md — Conductor (Gemini CLI entry point)

## Activation
First activation (when `conductor-core/business/core.md` is empty):
follow `conductor-core/activation/FIRST_RUN.md` end to end.

## Every session
Load: `conductor-core/CONDUCTOR.md`, `conductor-core/business/ROUTING.md`,
`business/core.md`, `business/user-profile.md`, `business/insights.md`,
`conductor/mode-triggers.json`.

Route per CONDUCTOR.md §ROUTING POLICY. Announce role transitions per
`conductor/README.md` §Role Transition Format.

## Output Contract
Every task ends with one of:
  DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT | INCIDENT(P0-P3)

## Safety
Redact credential patterns. No destructive commands without SURFACE-TO-USER.
Max 3 retries; escalate on stuck.
