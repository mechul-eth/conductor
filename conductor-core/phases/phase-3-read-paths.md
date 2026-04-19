PHASE 3 — READ PATHS + MOCK REPLACEMENT
Pipeline: {YOUR PIPELINE NAME} | Read conductor-core/canonical_prompt.md first.

══════════════════════════════════════════════════════════════════
MISSION
══════════════════════════════════════════════════════════════════
Replace every read mock with a real query. After Phase 3, the UI shows
real data — not the placeholder fixtures from Phase 1.

══════════════════════════════════════════════════════════════════
ROSTER
══════════════════════════════════════════════════════════════════
  - engineering-backend   (read endpoints)
  - engineering-frontend  (consume real data + edge cases)
  - engineering-database  (query patterns + indexes)
  - testing               (data-shape tests, large-set tests, empty-set tests)

══════════════════════════════════════════════════════════════════
STEPS
══════════════════════════════════════════════════════════════════
1. Re-run PREFLIGHT.
2. Inventory every mock read (search the codebase for fixture / mock /
   placeholder patterns and the Phase 0 codebase-map).
3. For each mock:
   a. Decide the real read source (DB query, cached read, derived value).
   b. Add the read endpoint (or reuse if it exists) per api-intelligence
      conventions.
   c. Add or verify the index that supports the query.
   d. Replace the mock at the call site.
   e. Verify empty / loading / error / success states with real data.
4. Update database-intelligence/query-reliability.md with new query patterns.

══════════════════════════════════════════════════════════════════
EXIT CRITERIA
══════════════════════════════════════════════════════════════════
[ ] Every mock read replaced with a real query
[ ] Every read has indexes that keep it under the team's latency budget
[ ] Empty-set states still render correctly with real data
[ ] No Phase 1 or Phase 2 regression
[ ] pipeline-state.json shows phase 3 as GREEN

══════════════════════════════════════════════════════════════════
REGRESSION RULES
══════════════════════════════════════════════════════════════════
- A read without a supporting index that exceeds the latency budget =
  BLOCKED, engineering-database review.
- A read that introduces N+1 = BLOCKED, refactor before merge.
- Removing a state (especially empty-set) = BLOCKED.
