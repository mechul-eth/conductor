# Identity — Agentic Identity and Trust Layer

> Every agent proves identity before acting, verifies its authority scope, and produces tamper-evident action logs. No agent operates anonymously.

## Design Advisors (Layer 1 — do not rebuild)
- `agency-agents/specialized/agentic-identity-trust.md` — cryptographic identity architecture
- `agency-agents/specialized/identity-graph-operator.md` — entity deduplication pipeline

## Core Guarantees

1. **Identity before action.** Every agent has a verifiable identity token before any execution begins. No anonymous operations.
2. **Authority scope enforcement.** Each agent can only act within its declared capability fingerprint. Attempts to exceed scope are denied (fail-closed).
3. **Tamper-evident logging.** Every action produces a log entry with agent ID, timestamp, action type, and scope. Logs are append-only within a session.
4. **Entity deduplication.** When multiple agents encounter the same real-world entity (person, company, product, record), they resolve to the same canonical `entity_id` regardless of which agent asks or when.
5. **Tenant isolation.** Every query is scoped to a tenant. No cross-tenant entity leak.
6. **PII masked by default.** Raw PII is never exposed unless explicit admin authorization is granted.

## Agent Identity Token

```yaml
agent_token:
  agent_id: <deterministic hash of role_name + session_id>
  role: <role_name from registry>
  domain: <domain from capability fingerprint>
  authority_scope:
    can_read: [<resource patterns>]
    can_write: [<resource patterns>]
    can_execute: [<action patterns>]
    cannot: [<explicit denials>]
  session_id: <current session ID>
  issued_at: <ISO-8601>
  expires_at: <session end or explicit revocation>
  delegation_chain: [<parent agent IDs if delegated>]
```

## Authority Scope Rules

| Scope Level | Description | Example |
|-------------|-------------|---------|
| `read-only` | Can query graph, session state, and files | Code Reviewer reading code |
| `read-write-scoped` | Can modify files within declared scope | Frontend Dev modifying `src/components/` |
| `read-write-broad` | Can modify files across the project | Software Architect restructuring |
| `execute-safe` | Can run non-destructive commands | Test runner |
| `execute-destructive` | Can run destructive commands (requires lock) | Ship workflow |
| `admin` | Can grant/revoke authority to other agents | Agents Orchestrator only |

**Fail-closed:** If an agent's scope cannot be determined, it defaults to `read-only`. The agent must request escalation through governance/ to get broader permissions.

## Entity Resolution Pipeline

When agents encounter real-world entities:

```
1. BLOCK — Deterministic matching on strong identifiers
   (email, phone, government ID, external system ID)
   → If exact match found → return canonical entity_id

2. SCORE — Fuzzy matching on weak identifiers
   (name variants, address similarity, behavioral signals)
   → Compute similarity score per attribute pair
   → "Bill Smith" + "William Smith" at same email → same entity

3. CLUSTER — Group scored matches above threshold
   → Merge into canonical entity_id
   → Every merge produces evidence trail:
     { reason_code, confidence_score, matched_attributes, timestamp }

4. RESOLVE — Return canonical entity_id
   → Sort by external_id (stable), never internal UUID (random)
   → Same input → same canonical ID, always
```

### Concurrent Write Safety

- **Optimistic locking** for entity mutations
- Simulate mutation → validate constraints → apply if clean
- On conflict: retry with fresh state (max 3 attempts, then BLOCKED)

## Action Log Format

```jsonl
{"agent_id":"abc123","role":"engineering-code-reviewer","action":"read_file","target":"src/auth.ts","scope":"read-only","timestamp":"2026-03-20T12:00:00Z","session_id":"sess_001","result":"success"}
{"agent_id":"abc123","role":"engineering-code-reviewer","action":"write_review","target":"review-output.md","scope":"read-write-scoped","timestamp":"2026-03-20T12:01:00Z","session_id":"sess_001","result":"success"}
{"agent_id":"def456","role":"engineering-frontend-developer","action":"edit_file","target":"src/components/Button.tsx","scope":"read-write-scoped","timestamp":"2026-03-20T12:02:00Z","session_id":"sess_001","result":"success"}
```

## Promptfoo Validation Wiring

Identity is validated at runtime using these promptfoo plugins (automated health checks on every identity component deployment):

| Plugin | What It Tests |
|--------|--------------|
| `RBAC` | Role-level authorization boundaries enforced — users requesting admin actions without authorization are denied |
| `BOLA` | Agents do not access object-level resources outside their authorization |
| `BFLA` | Agents do not execute function-level calls outside their delegated scope |
| `DebugAccess` | Identity layer does not leak internal config, API keys, or agent architecture through debug-mode prompts |

## Bypass Prevention (G1)

identity/ is the enforcement point for G1 bypass prevention:

- Every action must carry a valid `agent_token`
- Actions without tokens are rejected at the entry point
- Tokens are validated against the current session's identity registry
- Revoked or expired tokens fail silently (no action taken, incident logged)

## Integration Points

| Component | How identity/ interacts |
|-----------|------------------------|
| `session/` | Identity tokens are stored in session state; valid for session duration |
| `governance/` | Governance gate bypass requires identity verification + logged approver |
| `graph/` | Graph queries carry agent_id for audit trail |
| `registry/` | Registry provides capability fingerprints that define authority scope |
| `optimizer/` | Model API calls carry agent identity for per-agent cost tracking |
