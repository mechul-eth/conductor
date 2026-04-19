PHASE 5 — POLISH
Pipeline: {YOUR PIPELINE NAME} | Read conductor-core/canonical_prompt.md first.

══════════════════════════════════════════════════════════════════
MISSION
══════════════════════════════════════════════════════════════════
Make the product feel finished. world-class thinking — what would a top-tier
team ship for this?

Cover:
  - Accessibility (a11y to declared standard, usually WCAG AA)
  - Performance (web vitals, latency budgets per intelligence domain)
  - Copy (microcopy review, error messages, empty states, CTAs)
  - Edge cases (long strings, missing data, slow networks, large datasets)
  - Visual polish (alignment, spacing, motion, dark mode if applicable)

Also: now is the time to act on the Phase 0 deletion candidates that have
remained EXTRA throughout the pipeline.

══════════════════════════════════════════════════════════════════
ROSTER
══════════════════════════════════════════════════════════════════
  - design                (visual + copy review)
  - engineering-frontend  (a11y + performance fixes)
  - engineering-backend   (latency optimization for hot paths)
  - testing               (edge-case coverage, regression)
  - engineering-architect (sign-off on cleanup PRs)

══════════════════════════════════════════════════════════════════
STEPS
══════════════════════════════════════════════════════════════════
1. Re-run PREFLIGHT.
2. Accessibility audit per design:accessibility-review or equivalent.
3. Performance audit per frontend-intelligence/quality-benchmarks.md and
   backend-intelligence/quality-benchmarks.md (when present).
4. Copy review — every visible string, every error, every empty state.
5. Edge-case sweep — test data at the edges (empty, max, slow, broken).
6. Deletion-candidate cleanup — for each EXTRA from Phase 0 that's still
   unused: delete (with a SURFACE-TO-USER preview).
7. Visual polish — alignment, spacing, motion review.

══════════════════════════════════════════════════════════════════
EXIT CRITERIA
══════════════════════════════════════════════════════════════════
[ ] a11y score ≥ declared threshold on every shipped surface
[ ] Performance budgets met on every shipped surface
[ ] Copy review complete; no placeholder strings left
[ ] Edge cases covered with tests for the load-bearing ones
[ ] Deletion candidates resolved (deleted, archived, or kept-with-reason)
[ ] No earlier-phase regression
[ ] pipeline-state.json shows phase 5 as GREEN

══════════════════════════════════════════════════════════════════
REGRESSION RULES
══════════════════════════════════════════════════════════════════
- a11y regression on a previously-passing surface = BLOCKED.
- Performance regression beyond 10% of the budget = BLOCKED.
- Removing a Phase 1 state to "polish" = BLOCKED (states are required).
- Polish that introduces new functionality = scope creep, SURFACE-TO-USER.
