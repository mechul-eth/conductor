PHASE 6 — RELEASE GATE
Pipeline: {YOUR PIPELINE NAME} | Read conductor-core/canonical_prompt.md first.

══════════════════════════════════════════════════════════════════
MISSION
══════════════════════════════════════════════════════════════════
The release gate. Verify every contract every other phase made. Decide if
the pipeline is ready to go live. Sign off — or block.

This phase is a checklist phase. It produces:
  - A single release-readiness report
  - A gate verdict: GO_LIVE_GREEN | GO_LIVE_YELLOW | GO_LIVE_RED
  - The rollback plan for the first 24 hours after release

══════════════════════════════════════════════════════════════════
ROSTER
══════════════════════════════════════════════════════════════════
  - project-management    (gate coordinator)
  - engineering-architect (sign-off)
  - engineering-devops    (deploy + rollback readiness)
  - engineering-security  (security gate)
  - testing               (release-readiness verification)
  - product               (scope sign-off)

══════════════════════════════════════════════════════════════════
STEPS
══════════════════════════════════════════════════════════════════
1. Re-run PREFLIGHT.
2. Walk every phase exit criteria. Anything not GREEN → BLOCKED.
3. Execute every gate listed in
   release-readiness-intelligence/go-live-gate-taxonomy.md (when present)
   — typical gate letters:
     A_topology       — schema valid, files exist, FK ordering
     B_build          — typecheck + build pass everywhere
     C_test           — unit + integration suites pass
     D_e2e            — end-to-end happy paths verified
     D_security       — credential scan + dependency CVE check
     G_accessibility  — a11y score above threshold
     H_acceptance     — every acceptance criterion reports [✓]
4. Verify rollback plan:
   - rollback command documented per release-readiness-intelligence/
     rollback-and-fallback-governance.md
   - someone is on call for the first 24 hours
   - dashboards green; alerts armed
5. Generate the release-readiness report (single document, summary +
   per-gate evidence).
6. Issue the gate verdict.

══════════════════════════════════════════════════════════════════
EXIT CRITERIA
══════════════════════════════════════════════════════════════════
[ ] Every prior phase still GREEN (no regression)
[ ] Every gate listed in go-live-gate-taxonomy passes
[ ] Rollback plan reviewed + sign-off
[ ] On-call rota for first 24h confirmed
[ ] Release-readiness report written
[ ] Verdict issued: GO_LIVE_GREEN | GO_LIVE_YELLOW | GO_LIVE_RED
[ ] pipeline-state.json shows phase 6 as GREEN

When verdict = GO_LIVE_GREEN, Conductor advances to RELEASE_COMPLETE.

══════════════════════════════════════════════════════════════════
REGRESSION RULES
══════════════════════════════════════════════════════════════════
- A regression on any prior phase = BLOCKED, fix before re-running gate.
- A gate failure = BLOCKED, fix before re-running gate.
- A missing rollback plan = BLOCKED, do not ship.
- "Ship anyway" requires explicit user override per
  CONDUCTOR.md §BYPASS PREVENTION, with the reason logged.
