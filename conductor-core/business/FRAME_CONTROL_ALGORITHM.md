# FRAME_CONTROL_ALGORITHM.md — Deterministic Frame Lock & Orphan Prevention

> Keep Conductor and every delegated role constrained to repository-defined product, business, and industry frames so execution cannot drift into hallucinated scope.

## Why This Exists

LLM-based agents drift. They invent fields, assume capabilities, answer questions that weren't asked, and produce work that sounds right but isn't grounded in your project. Frame Control is a deterministic-first mechanism that makes drift detectable, surfaceable, and — when caught — recoverable.

Three things the algorithm protects:

1. **Pre-execution scope** — roles can't start work without the required context files loaded.
2. **During-execution boundaries** — roles can't cross ownership boundaries without an explicit handoff.
3. **Post-execution accuracy** — every output claim must map to at least one loaded frame artifact.

---

## Control Loop — Pre → During → Post

### 1. Pre-Execution Frame Lock

Before any role executes, load the **mandatory frame files**:

- `core.md`
- `user-profile.md`
- `ROUTING.md`
- The role's row in `ROUTING.md` (all files listed, in order)
- Any `{domain}-intelligence/context-efficiency.md` and `{domain}-intelligence/compatibility-gate.md` relevant to the task

Build two manifests:

```
required_files[] — everything ROUTING.md says to load for this role + this task
loaded_files[]   — what actually loaded successfully
```

If `required_files[] != loaded_files[]`, fail closed as `NEEDS_CONTEXT`. Log the missing files and ask the user to either create them or remove the row from `ROUTING.md`. Do not proceed with partial context.

### 2. During-Execution Frame Enforcement

While a role is working, Conductor rejects actions that violate **deterministic ownership boundaries**:

- AI-generated code cannot own authentication, routing, write paths, or state transitions — those must be deterministic unless the user explicitly overrides per-task.
- No undeclared scope expansion beyond the task's declared acceptance criteria.
- Every boundary-sensitive decision (security, data flow, compliance) must cite a frame artifact as evidence.

Violations are classified:

- `FRAME_VIOLATION_SOFT` → surface to user as a recommendation; continue on approval.
- `FRAME_VIOLATION_HARD` → stop, write a `BLOCKED` checkpoint, escalate.

### 3. Post-Execution Frame Verification

After the role reports completion:

- Validate that all output claims map to at least one entry in `loaded_files[]`.
- Run compatibility gate references for affected intelligence domains (`{domain}-intelligence/compatibility-gate.md`).
- Produce a `scope_drift_verdict`:

  | Verdict | Meaning | Action |
  |---------|---------|--------|
  | `CLEAN` | Output matches intent, every claim cites a frame artifact | Accept, advance |
  | `SCOPE_CREEP` | Role delivered more than asked | Surface excess, require approval to keep it |
  | `REQUIREMENTS_MISSING` | Role delivered less than asked | Reject, retry with clarified scope |

---

## Mandatory Frame Invariants

These hold across every task, every role, every session:

1. **Deterministic-first policy is always on** unless the user explicitly overrides for a specific task.
2. **Default model policy** — a cheap/fast default unless insufficiency is proven; roles may not upgrade model tier silently.
3. **Cross-domain changes** require linkage to:
   - `integration-intelligence/compatibility-gate.md`
   - `release-readiness-intelligence/evidence-contract-registry.md`
   - `release-readiness-intelligence/compatibility-gate.md`
4. **No business intelligence leaves the repository** — the frame is local.

---

## Orphan Prevention Rule

Any new intelligence artifact you add under `business/` must be connected in **all three** of these places before it's considered live:

1. Listed in the relevant package `README.md` reading order.
2. Referenced from a row in `business/ROUTING.md`.
3. Linked to at least one active gate (`{domain}-intelligence/compatibility-gate.md`, `release-readiness-intelligence/evidence-contract-registry.md`, or a runtime `gates/*.sh` script).

If any of the three links is missing, the artifact's status is **`UNCONNECTED`**. Unconnected artifacts:

- Are not loaded by Conductor at runtime.
- Block release promotion if flagged during the release-readiness gate.
- Must be either connected or deleted before merging.

---

## Deletion Safety Rule

No intelligence artifact may be deleted unless **all four** conditions are true:

1. No inbound references from other `business/` files.
2. No references in `ROUTING.md`, `CONDUCTOR.md`, or `canonical_prompt.md`.
3. No current or upcoming phase dependency.
4. No compliance/audit retention requirement.

Archive simulation must pass compatibility checks before the actual deletion. Ship a deletion as its own commit so it's reviewable.

---

## Output Contract — Frame Audit Report

When the Frame Control Algorithm runs a full audit (manually, or as part of a release gate), it produces one record per artifact:

```yaml
artifact_path:        business/segments/enterprise.md
pre_stage_use:        loaded_by_roles=[sales, marketing, product]
current_stage_use:    referenced_in=[ROUTING.md row "Sales", market.md#positioning]
post_stage_use:       evidence_in=[release-readiness-intelligence/evidence-contract-registry.md]
inbound_references:   3
gate_linked:          true
decision:             keep
```

Possible decisions: `keep`, `archive`, `delete-candidate`.

---

## When to Run the Algorithm

- **Automatically** — before every role activation (pre-execution lock), during role work (boundary enforcement), after role completion (post-execution verification).
- **Manually** — when adding a new intelligence domain, when a release gate fails, when debugging scope drift.
- **On a schedule** — quarterly audit to purge orphans and verify frame invariants still hold.

---

## Integration with Other Files

| File | Relationship to Frame Control |
|------|-------------------------------|
| `CONDUCTOR.md` | Defines scope-drift verdicts and the action classification that Frame Control enforces |
| `ROUTING.md` | Source of truth for required files per role |
| `business/insights.md` | Frame violations are appended here under "Routing Improvements" |
| `release-readiness-intelligence/compatibility-gate.md` | Release gate calls the audit before promotion |
| `orchestrator/lib/gates.sh` (if orchestrator is used) | The runtime implementation of the frame check |

---

*The algorithm is deterministic on purpose. It's the cheapest way to catch the most common class of LLM failure: a confident-sounding answer that's grounded in nothing you actually said.*
