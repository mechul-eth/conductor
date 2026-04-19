PHASE 2 — WRITE PATHS WIRED
Pipeline: {YOUR PIPELINE NAME} | Read conductor-core/canonical_prompt.md first.

══════════════════════════════════════════════════════════════════
MISSION
══════════════════════════════════════════════════════════════════
Wire every P0 write path to real persistence. After Phase 2, user-triggered
actions that MUTATE state actually land in the database (or the canonical
write layer) — not in mocks.

Read paths may still be mocked. That's Phase 3.

══════════════════════════════════════════════════════════════════
ROSTER
══════════════════════════════════════════════════════════════════
  - engineering-architect (contract per write)
  - engineering-backend   (endpoint implementation)
  - engineering-frontend  (consume + handle success/error)
  - engineering-database  (schema confirmation, migrations if needed)
  - engineering-security  (auth + input validation for every write)
  - testing               (happy-path + failure-mode tests per write)

══════════════════════════════════════════════════════════════════
STEPS
══════════════════════════════════════════════════════════════════
1. Re-run PREFLIGHT. Load Phase 0 + Phase 1 artifacts.
2. List every P0 write action (from design inventory + product spec).
3. For each write:
   a. Contract review with engineering-architect (request/response shape).
   b. Migration review with engineering-database (if schema changes).
   c. Security review with engineering-security (auth, validation, PII).
   d. Backend implementation — minimal, follows existing patterns.
   e. Frontend integration — handles success, error, and in-flight states.
   f. Test coverage — happy path, auth failure, validation failure,
      concurrent write if applicable.
4. Update api-intelligence/endpoint-architecture.md with the new writes.
5. No regressions on Phase 1 scaffolding — all UI states still render.

══════════════════════════════════════════════════════════════════
EXIT CRITERIA
══════════════════════════════════════════════════════════════════
[ ] Every P0 write lands in canonical storage (not a mock)
[ ] Every write has auth + validation + error handling
[ ] Every write has at least 1 integration test
[ ] api-intelligence/endpoint-architecture.md lists every new write
[ ] No Phase 1 regression (all scaffolding states still render)
[ ] pipeline-state.json shows phase 2 as GREEN

══════════════════════════════════════════════════════════════════
REGRESSION RULES
══════════════════════════════════════════════════════════════════
- A write that bypasses auth = BLOCKED, security review.
- A write that doesn't validate input = BLOCKED, engineering-security review.
- A write without a test = BLOCKED, testing.
- Changing Phase 1 scaffold structure to fit a write = SURFACE-TO-USER
  (the scaffold is the contract; the write adapts to it).
