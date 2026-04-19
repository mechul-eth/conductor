PHASE 4 — REALTIME / TRIGGERS / AUDIT
Pipeline: {YOUR PIPELINE NAME} | Read conductor-core/canonical_prompt.md first.

══════════════════════════════════════════════════════════════════
MISSION
══════════════════════════════════════════════════════════════════
Wire the downstream effects a feature requires to feel finished:
  - Realtime updates (push from server → client)
  - Triggers (a write fires a side effect — email, job, webhook)
  - Audit trail (who did what, when)

After Phase 4, the product doesn't feel static. Actions have consequences
and the system tells you about them.

══════════════════════════════════════════════════════════════════
ROSTER
══════════════════════════════════════════════════════════════════
  - engineering-architect (trigger contract + delivery guarantees)
  - engineering-backend   (trigger implementation + workers)
  - engineering-frontend  (realtime subscription + optimistic UI)
  - engineering-database  (audit columns, triggers if any)
  - engineering-security  (audit review: what's logged, what's redacted)
  - testing               (end-to-end trigger verification)

══════════════════════════════════════════════════════════════════
STEPS
══════════════════════════════════════════════════════════════════
1. Re-run PREFLIGHT.
2. For each realtime surface from the design inventory:
   a. Choose the mechanism (WebSocket, SSE, polling, managed realtime).
   b. Wire the subscription on the client, the push on the server.
   c. Verify state convergence (client state reflects server state within
      the declared budget).
3. For each trigger:
   a. Define the contract (what fires it, what it delivers, idempotency).
   b. Implement via the declared worker pattern.
   c. Add retry + DLQ per integration-intelligence/retry-idempotency-contract.md.
4. For audit:
   a. Decide what gets logged (not everything; cost adds up).
   b. Add audit columns or audit table per database-intelligence conventions.
   c. Ensure PII is redacted per engineering-security guidance.
5. End-to-end verification: trigger a write, observe realtime update,
   verify the side effect fired exactly once, verify the audit record.

══════════════════════════════════════════════════════════════════
EXIT CRITERIA
══════════════════════════════════════════════════════════════════
[ ] Every declared realtime surface converges to server state within budget
[ ] Every declared trigger fires, retries correctly, ends up in DLQ on
    permanent failure
[ ] Audit trail records the declared set of events with PII redacted
[ ] integration-intelligence/e2e-handshake-matrix.md updated with the new
    handshakes
[ ] No Phase 1/2/3 regression
[ ] pipeline-state.json shows phase 4 as GREEN

══════════════════════════════════════════════════════════════════
REGRESSION RULES
══════════════════════════════════════════════════════════════════
- A trigger with no retry = BLOCKED, integration-intelligence review.
- A trigger that's not idempotent = BLOCKED, can't ship.
- An audit entry that exposes PII = BLOCKED, security review.
- Realtime delivery worse than declared budget = BLOCKED, optimize.
