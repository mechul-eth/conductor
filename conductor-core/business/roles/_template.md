# Role: {ROLE NAME}

> Copy this file to `{role-slug}.md`, fill in every section, then add a row to `business/ROUTING.md` so Conductor knows when to load this role.

## Mission

<!-- One to two sentences describing what this role does for the team. -->
<!-- Example: -->
<!-- Owns the API contract between the web client and the backend. Decides endpoint shape, -->
<!-- versioning policy, and authentication flow. -->

## Scope

**In scope:**
<!-- Bullet list of what this role owns and decides. -->
<!-- Example: -->
<!-- - REST endpoint design -->
<!-- - Auth token format and refresh flow -->
<!-- - Request/response schemas -->
<!-- - Rate-limit policy -->

**Out of scope (handoff to another role):**
<!-- Bullet list of what this role does NOT decide. Name the role that does. -->
<!-- Example: -->
<!-- - Database schema → engineering-database -->
<!-- - Frontend state management → engineering-frontend -->
<!-- - Infrastructure / deploy → engineering-devops -->

## Deliverables

<!-- The concrete artifacts this role produces. -->
<!-- Example: -->
<!-- - OpenAPI spec changes -->
<!-- - PR with implementation + tests -->
<!-- - ADR for non-trivial design decisions -->
<!-- - Runbook updates when behavior changes -->

## Decision Authority

**Can decide alone:**
<!-- What this role can ship without escalation. -->
<!-- Example: -->
<!-- - Adding a new endpoint that follows existing patterns -->
<!-- - Refactoring response shapes that don't break clients -->
<!-- - Adding optional request fields -->

**Requires escalation:**
<!-- What this role must surface to the user or another role first. -->
<!-- Example: -->
<!-- - Breaking changes to existing endpoints → SURFACE-TO-USER -->
<!-- - Auth flow changes → SURFACE-TO-USER + engineering-security -->
<!-- - New external dependencies → governance gate -->

## Quality Gates

Gates that always run for this role's outputs (per `release-readiness-intelligence/`):

<!-- Example: -->
<!-- - `A_topology` — endpoint exists, schema valid -->
<!-- - `B_build` — typecheck + build pass -->
<!-- - `C_test` — unit + integration tests pass -->
<!-- - `D_security` — credential scan, no secrets in diffs -->
<!-- - `H_acceptance` — every acceptance criterion in the dispatch envelope reports `[✓]` -->

Custom per-task gates can be added at `orchestrator/gates/{gate-letter}_{task-id}.sh` (when the runtime is used).

## Handoff Format

When this role hands off to another role, use this YAML schema (subset of `CONDUCTOR.md` §HANDOFF SCHEMA):

```yaml
handoff:
  from: {this-role-slug}
  to: {next-role-slug}
  context:
    what_was_done: <one-line summary>
    files_touched: [<paths>]
    open_questions: [<questions for next role>]
  deliverable_request:
    what_is_needed: <description>
    acceptance_criteria: [<measurable items>]
```

Conductor automatically wraps the handoff in the role-transition announcement format defined in `conductor-core/conductor/README.md`.

## Example Invocations

<!-- 2-3 concrete examples of when Conductor activates this role. -->
<!-- Example: -->
<!-- 1. User: "Add an endpoint to update a user's profile picture" → Conductor activates this role solo. -->
<!-- 2. User: "Build a checkout flow" → Conductor activates this role + engineering-frontend + engineering-database. -->
<!-- 3. User: "Audit our API for breaking changes" → Conductor activates this role + engineering-security in review mode. -->

---

## Cross-References (orphan prevention)

This file is loaded when:

- `business/ROUTING.md` activates a role row that includes this file in its load sequence.
- `orchestrator/roles/manifest.json` resolves a role key whose `local_canonical` points here.
- Another role file's "Out of scope" section names this role for handoff.

This file references:

- `business/core.md` (always loaded first per ROUTING.md contract)
- `business/{domain}-intelligence/` files relevant to the role's scope
- `conductor-core/CONDUCTOR.md` (action classification, completion status protocol)
