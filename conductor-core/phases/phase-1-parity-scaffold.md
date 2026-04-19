PHASE 1 — PARITY / SCAFFOLD
Pipeline: {YOUR PIPELINE NAME} | Read conductor-core/canonical_prompt.md first.

══════════════════════════════════════════════════════════════════
MISSION
══════════════════════════════════════════════════════════════════
Bring the project to a known baseline that matches the design source of
truth structurally. No business logic wiring yet — that's Phase 2.

For UI pipelines:
  - Every visible unit from Phase 0's design inventory has a rendered
    counterpart in the live app at first-time parity.
  - Empty / loading / error / success states exist for each unit.
  - Visual parity verified by rendered comparison (headless browser
    screenshot diff, not code read).

For backend-only pipelines:
  - Every module / service scaffolded with the agreed structure.
  - Health-check endpoints return the declared shape.
  - Test harness runs on the scaffold.

══════════════════════════════════════════════════════════════════
ROSTER
══════════════════════════════════════════════════════════════════
  - engineering-architect (contract decisions)
  - engineering-frontend  (UI scaffolding, if applicable)
  - engineering-backend   (service scaffolding, if applicable)
  - design                (visual parity review)
  - testing               (baseline smoke + screenshot diffs)

══════════════════════════════════════════════════════════════════
STEPS
══════════════════════════════════════════════════════════════════
1. Re-run PREFLIGHT from canonical_prompt.md.
2. Load Phase 0 artifacts (design-inventory, codebase-map, deletion-candidates).
3. For each MATCH or PARTIAL row in the codebase map:
   a. Implement the scaffold (structure, props, layout) with NO logic wiring.
   b. Provide each state (empty / loading / error / success).
   c. Use existing design-system primitives (no new primitives — SURFACE if needed).
4. For each MISSING row:
   a. Create the scaffold at the agreed location.
   b. Add to codebase-map with status = SCAFFOLDED.
5. Visual parity verification: rendered comparison at a fixed viewport per
   the team's visual-regression tool.
6. Baseline smoke tests: every scaffolded route / endpoint returns its
   scaffold without 5xx.

══════════════════════════════════════════════════════════════════
EXIT CRITERIA
══════════════════════════════════════════════════════════════════
[ ] Every design-inventory row has MATCH or SCAFFOLDED status
[ ] Every scaffolded unit has empty / loading / error / success states
[ ] Visual regression snapshot updated for each scaffolded unit
[ ] Baseline smoke tests pass
[ ] No deletion-candidate has been deleted (Phase 5 will decide)
[ ] pipeline-state.json shows phase 1 as GREEN

══════════════════════════════════════════════════════════════════
REGRESSION RULES
══════════════════════════════════════════════════════════════════
- Deleting a design-inventory row in code = regression, BLOCKED.
- Removing a state (empty/loading/error/success) = regression, BLOCKED.
- Adding logic wiring = scope creep, SURFACE-TO-USER (belongs in Phase 2).
