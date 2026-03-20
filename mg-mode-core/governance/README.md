# Governance — Automation Value/Risk/Ownership Gate

> Every automation request passes a 3-question gate before touching execution: Does this need to exist? What is the risk? Who owns maintenance? Only after passing does it route to build roles. Governs at design time, not runtime.

## Design Advisors (Layer 1 — do not rebuild)
- `agency-agents/specialized/automation-governance-architect.md` — value/risk/ownership gate architecture
- `agency-agents/engineering/engineering-ai-data-remediation-engineer.md` — data anomaly routing
- `agency-agents/testing/testing-tool-evaluator.md` — TCO/ROI/security assessment
- `promptfoo/src/redteam/plugins/excessiveAgency.ts` — scope enforcement
- `promptfoo/src/redteam/plugins/goalMisalignment.ts` — proxy-metric detection
- `promptfoo/src/redteam/plugins/policy/index.ts` — custom policy assertions

## Core Guarantees

1. **Gate before build.** No automation is built without passing the 3-question gate.
2. **Bypass is logged.** Gate bypass requires explicit user pre-approval with timestamp, reason, and approver identity.
3. **Execution-time validation.** After build, ExcessiveAgency and GoalMisalignment plugins confirm the automation stays within scope.
4. **Data anomaly routing.** Data integrity issues route to the AI Data Remediation Engineer — not a general data engineer.
5. **Tool adoption assessment.** New tool/framework/infrastructure adoption requires a 5-dimension TCO/ROI/security assessment at production-strict.

---

## The 3-Question Gate

Every automation request answers these before routing to build roles:

### Q1: Does this automation need to exist?

```
Evaluate:
  - What problem does it solve?
  - How is the problem currently handled? (manual, existing tool, workaround)
  - What is the cost of NOT automating? (time, errors, frustration)
  - Is the problem frequent enough to justify automation?

Outcome:
  JUSTIFIED → proceed to Q2
  NOT_JUSTIFIED → surface recommendation: "This is better handled by <alternative>"
  UNCLEAR → request more context from user
```

### Q2: What is the risk?

```
Evaluate:
  - What happens if the automation fails? (blast radius)
  - Does it touch user data? (PII, financial, health)
  - Does it touch production systems? (databases, APIs, infrastructure)
  - Can it be reversed? (rollback capability)
  - What is the worst-case failure mode?

Risk levels:
  LOW → proceed to Q3
  MEDIUM → proceed to Q3 with risk mitigation requirements in handoff
  HIGH → surface to user: "High risk detected — <specifics>. Proceed? [Y/N]"
  CRITICAL → block: "This requires explicit governance review before proceeding"
```

### Q3: Who owns maintenance?

```
Evaluate:
  - Who will maintain this after the session ends?
  - Is there a clear owner with context?
  - Is the maintenance burden documented?
  - What happens when the owner is unavailable?

Outcome:
  OWNER_CLEAR → approve, route to build roles
  OWNER_UNCLEAR → surface: "Who will maintain this? Document the owner before building."
  NO_OWNER → block: "Unowned automation becomes tech debt. Assign an owner first."
```

---

## Gate Decision Matrix

| Q1 (Need) | Q2 (Risk) | Q3 (Owner) | Decision |
|-----------|-----------|-----------|----------|
| JUSTIFIED | LOW | CLEAR | ✅ APPROVE — route to build |
| JUSTIFIED | MEDIUM | CLEAR | ✅ APPROVE — add risk mitigations to handoff |
| JUSTIFIED | HIGH | CLEAR | ⚠️ USER APPROVAL — surface risk, user decides |
| JUSTIFIED | CRITICAL | CLEAR | 🛑 GOVERNANCE REVIEW — block until reviewed |
| JUSTIFIED | Any | UNCLEAR | ⚠️ OWNER REQUIRED — assign before building |
| NOT_JUSTIFIED | Any | Any | ❌ RECOMMEND ALTERNATIVE |
| UNCLEAR | Any | Any | ❓ REQUEST CONTEXT |

---

## Gate Bypass Protocol

When a user explicitly pre-approves bypassing the gate:

```yaml
bypass_record:
  timestamp: <ISO-8601>
  reason: <user-provided justification>
  approver_identity: <user ID from identity/>
  risk_acknowledged: <risk level that was bypassed>
  gate_questions_answered: [<which questions were answered, if any>]
  session_id: <current session>
```

Bypass records are append-only and stored in `~/.mg-mode/projects/$SLUG/governance-log.jsonl`.

---

## Execution-Time Validators (Promptfoo Wiring)

After any automation is built, governance/ closes the loop:

| Plugin | What It Validates |
|--------|------------------|
| `ExcessiveAgency` | Agent does not take more action than its stated scope |
| `GoalMisalignment` | Agent is not optimizing a proxy metric at the expense of the true goal |
| `Policy` | Any governance rule expressed as custom policy text becomes an automated assertion |

All three must pass before governance clearance is issued. Failure → BLOCKED status.

---

## Data Anomaly Routing (G63)

When any agent reports a data integrity anomaly:

```
Trigger conditions:
  - Rows missing from expected output
  - Schema drift detected
  - Source_Rows ≠ expected row count

Routing:
  → governance/ routes to AI Data Remediation Engineer
     (NOT a general data engineer)

Constraints:
  - "AI generates the logic that fixes data — never touches the data directly"
  - Remediation engineer receives cluster samples only (not raw PII rows)
  - SLM analysis via Ollama (local only, no cloud API calls for PII compliance)
  - Every batch: Source_Rows = Success_Rows + Quarantine_Rows (mismatch = Sev-1 INCIDENT(P0))
  - Outputs go to staging — NEVER production
```

---

## Tool Adoption Assessment (G72)

When governance/ approves an automation that requires a new tool, framework, or infrastructure component:

```
Route to: Tool Evaluator (agency-agents/testing/testing-tool-evaluator.md)

5-dimension assessment:
  1. TCO — total cost including hidden costs, scaling fees, training, migration
  2. Security — data handling, access controls, known CVEs, SOC 2/ISO 27001 status
  3. Integration — API reliability, webhook behavior, rate limits, failure modes
  4. Vendor stability — financial health, roadmap, exit strategy if vendor sunsets
  5. ROI — with sensitivity analysis

Storage: ~/.mg-mode/projects/$SLUG/tool-assessments/

Enforcement by profile:
  production-strict → REQUIRED (blocks adoption without assessment)
  production-lite → REQUIRED (blocks adoption without assessment)
  MVP → RECOMMENDED (surface but don't block)
  learning → OPTIONAL (skip unless user requests)
```

---

## Integration Points

| Component | How governance/ interacts |
|-----------|-------------------------|
| `identity/` | Bypass approver must be verified via identity token |
| `map/` | map/ routes automation requests through governance gate before build |
| `session/` | Gate decisions stored in session state |
| `profiles/` | Profile determines enforcement level for tool assessment (required vs. recommended) |
| `optimizer/` | Budget overrides at production-strict require governance approval |
| `registry/` | governance/ routes to specific specialist roles (Data Remediation, Tool Evaluator) |
