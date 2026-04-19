# canonical_prompt.md — Pipeline Overlay (optional)
#
# This file is an OVERLAY, not a requirement. Conductor runs fine without it
# for ad-hoc work. Fill it in when you're running a real end-to-end pipeline
# (a multi-phase delivery with defined entry/exit criteria) so every session
# inherits scope, source-of-truth hierarchy, and phase sequence without
# restating them inline.
#
# When to fill it in:
#   - You're shipping a multi-phase project (MVP → production, a migration,
#     a release gate).
#   - Multiple collaborators are working the same pipeline and need aligned
#     scope.
#   - You want deterministic phase advancement via pipeline-state.json.
#
# When to ignore it:
#   - You're exploring, prototyping, or doing one-off work.
#   - Your project has a flat scope that lives fully inside business/core.md.
#
# If you ignore it, Conductor falls back to the generic flow defined in
# conductor-core/conductor/README.md.

ACTIVATE CONDUCTOR — binding, unconditional
Profile: {learning | MVP | production-lite | production-strict}
Domain:  {none | financial | medical | e-commerce | legal | telecom | real-estate | other}
Scenario: {startup-fast | team-iterating | enterprise-compliance | incident-response}
Project: {YOUR PROJECT NAME}
Pipeline: {YOUR PIPELINE NAME}
Branch: {git branch}
Date: {YYYY-MM-DD}

══════════════════════════════════════════════════════════════════
OWNERSHIP — Conductor runs this pipeline
══════════════════════════════════════════════════════════════════
This file is a pipeline OVERLAY. It declares scope, sequence, source-of-truth
hierarchy, and phase-specific exit criteria. It does NOT re-implement
Conductor behavior.

Conductor owns, unchanged from CONDUCTOR.md:
  • Role selection + minimum-role-set routing     (§ROUTING POLICY)
  • Mode routing — plan / ask / execute / review (§Mode Routing, mode-triggers.json)
  • Action classification — AUTO / SURFACE / BLAST (§ACTION CLASSIFICATION)
  • Session state format — JSONL, meta.json, state.json (§Session Persistence Format)
  • Completion status + Work Accuracy Score         (§COMPLETION STATUS PROTOCOL)
  • Re-grounding template for every user-facing question (§Re-grounding Template)
  • Loop safety, bypass prevention, investigation protocol
  • Business intelligence reads — ROUTING.md, role files, intelligence domains
  • Frame control — pre/during/post per FRAME_CONTROL_ALGORITHM.md

Phase files MUST NOT restate these. They reference Conductor and add only
phase-specific overlays.

══════════════════════════════════════════════════════════════════
MANDATORY STARTUP — every phase, in strict order
══════════════════════════════════════════════════════════════════
  1. conductor-core/CONDUCTOR.md
  2. conductor-core/business/ROUTING.md
  3. conductor-core/business/FRAME_CONTROL_ALGORITHM.md
  4. conductor-core/business/core.md
  5. conductor-core/business/user-profile.md
  6. conductor-core/business/roles/{active-role}.md (per ROUTING.md)
  7. conductor-core/business/{domain}-intelligence/README.md + foundation.md
     (for each domain relevant to the active phase, in fixed order:
        ai-usage -> api -> backend -> database -> frontend -> integration ->
        release-readiness)
  8. This file (canonical_prompt.md) — pipeline overlay
  9. conductor-core/phases/phase-<ACTIVE_PHASE>.md — single active phase file

Missing file: log NEEDS_CONTEXT and surface to user. Never silently skip.

══════════════════════════════════════════════════════════════════
PIPELINE CONTRACT — fill in for your project
══════════════════════════════════════════════════════════════════
Single objective: {one paragraph — what must ship when this pipeline completes}

Scope IN:
  - {list every directory / component that's in scope}

Scope OUT (Conductor surfaces any drift as SURFACE-TO-USER):
  - {list everything explicitly out of scope}

Design source of truth (VISUAL):
  {path or link — e.g. a Figma file, a design HTML, a mock app}

Logic source of truth:
  {backend, DB, or spec — whichever defines what the system CAN do}

══════════════════════════════════════════════════════════════════
SOURCE-OF-TRUTH HIERARCHY — binding, resolves every conflict
══════════════════════════════════════════════════════════════════
  LOGIC  → {logic source} WINS.
           The backend contract and DB schema are authoritative for what
           the system CAN do and what data shapes are valid.

  VISUAL → {visual source} WINS.
           Layout, components, states, and visual interactions are taken
           from the visual source without deviation.

Conflict rules:
  1. Visual shows a field the logic doesn't support → SURFACE-TO-USER.
  2. Logic exposes capability visual doesn't show → treat as "UI gap to fill."
  3. Visual implies a trigger the logic doesn't implement → SURFACE-TO-USER.
  4. Logic shape ≠ visual layout → UI adapts to logic. Visual is target, not schema.
  5. Naming: logic naming at the API boundary; visual-visible labels only at the
     component layer.

Every source-of-truth SURFACE-TO-USER carries the tag [source-of-truth-conflict].

══════════════════════════════════════════════════════════════════
PHASE PIPELINE — strict order, do not skip
══════════════════════════════════════════════════════════════════
 Phase 0 — PREFLIGHT + SCOPE MAP           → phases/phase-0-preflight-and-scope-map.md
 Phase 1 — PARITY / SCAFFOLD               → phases/phase-1-parity-scaffold.md
 Phase 2 — WRITE PATHS WIRED               → phases/phase-2-write-paths.md
 Phase 3 — READ PATHS + MOCK REPLACEMENT   → phases/phase-3-read-paths.md
 Phase 4 — REALTIME / TRIGGERS / AUDIT     → phases/phase-4-realtime-and-triggers.md
 Phase 5 — POLISH                          → phases/phase-5-polish.md
 Phase 6 — RELEASE GATE                    → phases/phase-6-release-gate.md

Advancement: Conductor advances active_phase ONLY when the current phase's
Exit Criteria are all GREEN in session state. No skipping, no parallel phases.

Each phase file is self-contained. An agent running a phase reads:
  1. MANDATORY STARTUP files (above)
  2. This overlay
  3. The single phase file under phases/
  4. Files the phase file explicitly names

Other phase files are NOT read in the current session to keep context tight.

══════════════════════════════════════════════════════════════════
PHASE-SPECIFIC PREFLIGHT — Conductor runs at every phase start
══════════════════════════════════════════════════════════════════
Fill these in for your environment. Keep the list short and deterministic.

CHECK 1 — {Frontend or UI surface is reachable}
CHECK 2 — {Backend or logic service is reachable}
CHECK 3 — {Database is reachable}
CHECK 4 — {Auth / session works end-to-end}
CHECK 5 — {Required env vars are set}

If any check fails: stop, report, do not proceed.

══════════════════════════════════════════════════════════════════
AUTO-RECOVERY (optional, for unattended-loop runs)
══════════════════════════════════════════════════════════════════
Define here which CHECK failures are eligible for automatic recovery and
which require SURFACE-TO-USER. Keep the recovery surface tiny — recovery
is not a silent fallback path. Every recovery action is logged.

══════════════════════════════════════════════════════════════════
PIPELINE-SPECIFIC CONSTRAINTS (overlay on CONDUCTOR defaults)
══════════════════════════════════════════════════════════════════
These apply on TOP of CONDUCTOR.md rules, never instead of them.

C-1  FILE SIZE LIMIT
     No source file > {N} lines. Splits that touch > 5 files trigger
     the BLAST RADIUS GATE per CONDUCTOR §ACTION CLASSIFICATION.

C-2  EXISTING FILES FIRST
     Prefer editing existing files over creating new ones. A new file
     requires a one-line justification in the session state.

C-3  NEVER REGRESS A PRIOR PHASE
     Every change must keep all prior-phase exit criteria GREEN.
     Regression = BLOCKED. Roll back, do not advance.

C-4  NEVER COMMIT, NEVER DELETE WITHOUT APPROVAL
     Agents report changes; you commit. Deletions of source files,
     routes, or components are always SURFACE-TO-USER.

C-5  {ADD YOUR OWN CONSTRAINTS HERE}

══════════════════════════════════════════════════════════════════
SESSION STATE — Conductor writes, pipeline overlay reads
══════════════════════════════════════════════════════════════════
Conductor persists per CONDUCTOR.md §Session Persistence Format.
This pipeline adds one pipeline-scoped state file alongside the JSONL:

  conductor-core/session/{project}/pipeline-state.json
  {
    "active_phase": "<0..6|RELEASE_COMPLETE>",
    "phase_exits": {
      "0": "PENDING|GREEN|BLOCKED",
      "1": "PENDING|GREEN|BLOCKED",
      "2": "PENDING|GREEN|BLOCKED",
      "3": "PENDING|GREEN|BLOCKED",
      "4": "PENDING|GREEN|BLOCKED",
      "5": "PENDING|GREEN|BLOCKED",
      "6": "PENDING|GREEN|BLOCKED"
    },
    "last_updated": "<ISO-8601>"
  }

Agents read this file to determine which phase to run. Conductor updates
it when a phase's exit criteria flip to all-GREEN.

══════════════════════════════════════════════════════════════════
START HERE
══════════════════════════════════════════════════════════════════
1. Conductor loads MANDATORY STARTUP files and asserts profile/domain/scenario.
2. Conductor runs PHASE-SPECIFIC PREFLIGHT — all checks must PASS.
3. Conductor reads pipeline-state.json → chooses ACTIVE_PHASE.
4. Conductor opens phases/phase-<ACTIVE_PHASE>-*.md and routes the minimum
   role set per CONDUCTOR §ROUTING POLICY.
5. Roles execute the phase protocol, writing session JSONL per CONDUCTOR rules.
6. On all-GREEN exit criteria: Conductor updates pipeline-state.json and
   writes the phase completion report per CONDUCTOR §COMPLETION STATUS PROTOCOL.
7. Any regression on a prior-phase element → BLOCKED → fix before advancing.
