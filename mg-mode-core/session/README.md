# Session — Cross-Role State Persistence

> Persists across all role switches within a session. Every role reads what prior roles decided and produced. Cleared only on explicit user reset.

## Design Advisors (Layer 1 — do not rebuild)
- `agency-agents/integrations/mcp-memory/README.md` — MCP memory protocol (remember/recall/rollback/search)
- `agency-agents/examples/workflow-with-memory.md` — cross-agent state continuity pattern
- `agency-agents/specialized/zk-steward.md` — Luhmann 4-principle validation for knowledge artifacts
- `promptfoo/src/redteam/plugins/agentic/memoryPoisoning.ts` — state write validation
- `promptfoo/src/redteam/plugins/crossSessionLeak.ts` — session isolation validation

## Core Guarantees

1. **Persistent across role switches.** Every role reads what prior roles decided and produced.
2. **State carries context.** Task IDs, decisions made, artifacts delivered, open constraints, handoff history.
3. **Cleared only on explicit reset.** Session state survives role transitions. Only a user reset clears it.
4. **Adversarial write validation.** State writes are not trusted passively. MemoryPoisoning and CrossSessionLeak checks run on every write.
5. **Session isolation.** Two concurrent sessions cannot share resolvable context.

---

## State Schema

```yaml
session:
  id: <unique session ID>
  project: <project name>
  profile: <learning|MVP|production-lite|production-strict>
  domain: <declared domain or "none">
  scenario: <startup|iterating|enterprise|incident>
  started_at: <ISO-8601>
  
  # Graph status
  graph_status: <ready|degraded|failed>
  graph_fallback: <null|"file-based">
  
  # Identity registry
  active_agents: [<agent tokens currently valid>]
  
  # Task history (append-only within session)
  tasks:
    - task_id: <id>
      intent: <original user intent>
      role: <role that executed>
      status: <DONE|DONE_WITH_CONCERNS|BLOCKED|NEEDS_CONTEXT|INCIDENT>
      artifacts: [<files created/modified>]
      decisions: [<key decisions made>]
      scope_drift: <CLEAN|SCOPE_CREEP|REQUIREMENTS_MISSING>
      cost_usd: <cost for this task>
      duration_ms: <time taken>
      started_at: <ISO-8601>
      completed_at: <ISO-8601>
  
  # Handoff chain
  handoffs: [<handoff schemas in order>]
  
  # Open constraints (carried across roles)
  constraints:
    budget_remaining_usd: <remaining budget>
    blocked_items: [<items that need resolution>]
    deferred_items: [<items pushed to TODOS.md>]
    open_questions: [<questions for user>]
  
  # Checkpoints (for rollback)
  checkpoints:
    - checkpoint_id: <id>
      created_at: <ISO-8601>
      reason: <"before multi-step: <description>">
      state_snapshot: <path to snapshot file>
  
  # Optimizer data
  cost_summary:
    total_usd: <running total>
    calls_made: <count>
    primary_model: <most used>
    circuit_breaker_trips: <count>
```

## Default Backend: JSONL File State

By default, session state is stored as JSONL at:
```
~/.conductor/sessions/<session_id>/state.jsonl
```

Each write appends a new line with the full state diff:
```jsonl
{"timestamp":"2026-03-20T12:00:00Z","action":"init","data":{"session_id":"sess_001","profile":"MVP","domain":"none"}}
{"timestamp":"2026-03-20T12:01:00Z","action":"task_start","data":{"task_id":"t001","intent":"Build auth module","role":"engineering-backend-architect"}}
{"timestamp":"2026-03-20T12:15:00Z","action":"task_complete","data":{"task_id":"t001","status":"DONE","artifacts":["src/auth/"],"decisions":["JWT with refresh tokens"]}}
```

---

## Optional MCP Memory Backend (G53)

When an MCP server exposing `remember`, `recall`, `rollback`, and `search` tools is detected:

```
Session/ can use MCP memory as an alternative or supplement to JSONL.

When MCP memory is active, session/ injects a Memory Integration instruction
block into each agent's activation prompt:

  1. RECALL — at session start, search by agent_name + project_name
     for relevant prior context
  2. REMEMBER — after key decisions and deliverables, store with
     descriptive tags (agent_name + project + topic + artifact_type)
  3. ROLLBACK — on QA failure, roll back to last known-good state
     rather than rebuilding from scratch

Benefits:
  - Cross-session continuity (state persists across days/weeks)
  - Eliminates cross-agent copy-paste
  - QA failures recover from last good checkpoint, not from zero

MCP backend is declared at profile setup.
Silently inactive when no MCP server detected.
```

---

## Adversarial Write Validation (Promptfoo Wiring)

State writes are validated on every write:

### MemoryPoisoning
```
Validates that no injected false information has contaminated session context.

A role CANNOT write a fact into session state that no prior step established.
Example blocked: writing "the production database is at localhost" when no
  prior task established any database connection information.

Implementation: compare incoming state write against the evidence chain
  in the session's task history. Unsupported facts are blocked.
```

### CrossSessionLeak
```
Confirms that context from one user's session cannot resolve into
another user's session state.

Two concurrent session IDs must NOT share resolvable context.
Session isolation is testable: session_001 state must not appear
  in session_002 queries.

Implementation: session state is scoped by session_id in all
  storage backends (JSONL and MCP). Cross-session queries return empty.
```

**On validation failure:** Block the state write. Escalate to BLOCKED status. Log the attempted write for audit.

---

## Checkpoint and Rollback (G7)

Before any multi-step operation:

```
1. session/ saves a checkpoint:
   - Snapshot current state
   - Record all modified file paths
   - Store checkpoint_id + timestamp + reason

2. On failure during multi-step:
   - Offer user: "Operation failed at step N. Rollback to checkpoint? [Y/N]"
   - If yes: restore state from checkpoint snapshot
   - If no: keep current state, mark as BLOCKED

3. Checkpoint retention:
   - Keep last 5 checkpoints per session
   - Auto-delete older checkpoints on session close
   - checkpoint files at: ~/.conductor/sessions/<session_id>/checkpoints/
```

---

## Session Close

On session close:
1. Write final state to JSONL (or MCP memory)
2. optimizer/ writes cost summary
3. If observability opted in: write to `~/.conductor/analytics/session-usage.jsonl`
4. Merge gstack analytics (read-only from `~/.gstack/analytics/skill-usage.jsonl`)
5. Clear active agent tokens from identity/
6. Checkpoint files cleaned up (keep last snapshot for recovery)

---

## Integration Points

| Component | How session/ interacts |
|-----------|----------------------|
| `identity/` | Agent tokens stored in session state; validated on access |
| `graph/` | Graph status recorded in session state |
| `map/` | map/ reads session state for prior context; writes handoff context |
| `optimizer/` | Cost tracking reads/writes budget remaining |
| `governance/` | Gate decisions stored in session state |
| `profiles/` | Profile config stored in session state at init |
| `activation/` | Activation status stored in session state |
| All roles | Every role reads session state before acting and writes results after |
