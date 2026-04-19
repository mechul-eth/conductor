PHASE 0 — PREFLIGHT + SCOPE MAP
Pipeline: {YOUR PIPELINE NAME} | Read conductor-core/canonical_prompt.md first.

══════════════════════════════════════════════════════════════════
MISSION
══════════════════════════════════════════════════════════════════
Before a single line of code changes:

  1. Confirm the full environment is healthy (all canonical_prompt.md CHECK
     items must PASS).
  2. Build an authoritative map from every visible piece of the design source
     of truth (mocks, spec, design file) to its actual location in the
     codebase — or mark it MISSING.
  3. Produce a deletion-candidate list for legacy / dead code paths and
     surface it to the user for approval. Do NOT delete anything in this
     phase.
  4. Establish a ground-truth baseline for Phase 1 (parity / scaffold) and
     Phase 2 (writes wiring).

This phase writes NO application code. It writes session state, maps, and
lists.

══════════════════════════════════════════════════════════════════
ROSTER
══════════════════════════════════════════════════════════════════
Local core (per business/ROUTING.md):
  - project-management   (coordination)
  - engineering-architect (codebase triage + section mapping)
  - engineering-frontend (UI surface inventory)
  - engineering-backend  (logic surface inventory)
  - engineering-database (schema snapshot)
  - testing              (baseline smoke + reality check)

External roles (optional, via orchestrator/roles/manifest.json):
  - any "rapid-prototyper" or "codebase-triage" specialist from a connected
    role library

Every external role activation emits the announcement block per
conductor-core/conductor/README.md §Role Transition Format.

══════════════════════════════════════════════════════════════════
STEP 1 — ENVIRONMENT PREFLIGHT
══════════════════════════════════════════════════════════════════
Run all CHECK items defined in canonical_prompt.md PHASE-SPECIFIC PREFLIGHT.
Log each as PREFLIGHT_PASS or PREFLIGHT_FAIL in the session JSONL.

If any check fails: stop, report, do not proceed to Step 2.
If AUTO-RECOVERY is configured for the failing check, run it once and
re-verify before reporting BLOCKED.

══════════════════════════════════════════════════════════════════
STEP 2 — DESIGN SOURCE-OF-TRUTH INVENTORY
══════════════════════════════════════════════════════════════════
Extract the canonical surface inventory from the design source of truth
named in canonical_prompt.md.

For each unit of the surface:
  - identifier (page, section, modal, component, action)
  - approximate location in the design source
  - type (page | section | modal | action | trigger | state)
  - acceptance shape (list of states required: empty | loading | error | success)

Output: a table at session/{project}/phase-0-design-inventory.md

══════════════════════════════════════════════════════════════════
STEP 3 — CODEBASE MAP
══════════════════════════════════════════════════════════════════
For each row in the design inventory, find the matching code:
  - exact file path(s)
  - matching component / function / route
  - parity status: MATCH | PARTIAL | MISSING | EXTRA

EXTRA items (code with no design counterpart) are deletion candidates.

Output: a table at session/{project}/phase-0-codebase-map.md

══════════════════════════════════════════════════════════════════
STEP 4 — DELETION CANDIDATES
══════════════════════════════════════════════════════════════════
Compile the EXTRA list into a deletion-candidate document:
  - file path
  - reason (no design counterpart, dead route, unused component)
  - blast radius (what depends on it, per `engineering:tech-debt` analysis)
  - recommendation: archive | delete | keep-with-reason

Output: session/{project}/phase-0-deletion-candidates.md

SURFACE the document to the user. Do NOT delete anything in Phase 0.

══════════════════════════════════════════════════════════════════
STEP 5 — DATABASE / DATA SHAPE SNAPSHOT
══════════════════════════════════════════════════════════════════
If the project has a database, snapshot:
  - tables / collections
  - row counts (if cheap to compute)
  - schema version

Output: session/{project}/phase-0-data-snapshot.md

══════════════════════════════════════════════════════════════════
EXIT CRITERIA
══════════════════════════════════════════════════════════════════
[ ] All preflight CHECK items PASS (or AUTO-RECOVERY ran successfully)
[ ] Design inventory written to session/{project}/phase-0-design-inventory.md
[ ] Codebase map written to session/{project}/phase-0-codebase-map.md
[ ] Deletion candidates written and SURFACED to user
[ ] Database snapshot written (if applicable)
[ ] No application code modified
[ ] pipeline-state.json shows phase 0 as GREEN

When all criteria GREEN, Conductor advances to Phase 1.

══════════════════════════════════════════════════════════════════
REGRESSION RULES
══════════════════════════════════════════════════════════════════
Phase 0 is foundational. The only "regression" is that the environment
becomes unhealthy mid-pipeline — re-run PREFLIGHT before continuing later
phases.
