# business/roles/ — Role Definitions (Internal Team)

> One file per internal role on your team. Conductor loads the role's file when the role is activated, in the order defined by `business/ROUTING.md`. **External roles** (from a connected library like agency-agents) live as references inside the orchestrator runtime, not here.

## How This Wires Into Conductor

```
User request
   │
   ▼
CONDUCTOR.md  ─── decides which role(s) to activate (per ROUTING POLICY)
   │
   ▼
ROUTING.md    ─── says: "for role X, load these files in this order"
   │
   ▼
business/roles/{role}.md  ─── this file — the role's actual definition
   │
   ▼
Role executes with: core.md + role file + any supplemental context from ROUTING.md
```

If a role is referenced in `ROUTING.md` but the matching file in this directory is missing, Conductor fails closed (`NEEDS_CONTEXT`) per `FRAME_CONTROL_ALGORITHM.md`. Add the file or remove the row.

---

## Internal vs. External Roles

Conductor supports both. The distinction is operational, not philosophical:

| Type | Lives at | Authoritative? | When to use |
|------|----------|----------------|-------------|
| **Internal** | `business/roles/{role}.md` (this directory) | Yes — local roles always take precedence | When the role has team-specific context, your conventions, or proprietary knowledge |
| **External** | A URL or library reference (e.g. agency-agents) | No — supplemental context only | When a generic specialist role from a community library is good enough for the task |

Internal role files override external references with the same name. External references are appended as supplemental context if both exist.

The role manifest at `orchestrator/roles/manifest.json` (when the runtime is used) maps a `role_key` (e.g. `engineering-backend`) to:

- `local_canonical:` path to the internal file in this directory
- `external_url:` URL to an external role definition (optional)
- `supplemental:` array of additional internal files to load with the role

Both are first-class. Both obey `CONDUCTOR.md` policies unconditionally.

---

## File Structure Standard

Every file in this directory follows this section order. This is an invariant — agents loading any role file expect this structure.

1. **Mission** — one to two sentences. What does this role do for the team?
2. **Scope** — what's in scope, what's explicitly out of scope.
3. **Deliverables** — concrete artifacts this role produces (PRs, designs, plans, docs).
4. **Decision authority** — what this role can decide alone vs. what requires escalation.
5. **Quality gates** — gates that always run for this role's outputs.
6. **Handoff format** — how this role hands off to the next role in a multi-role flow.
7. **Example invocations** — 2-3 concrete examples of when this role gets activated.

Keep each file under 200 lines. Conductor loads role files into every prompt — bloat costs on every invocation.

---

## Provided Templates

This directory ships with templates for common product-team roles. Edit them to match your team. Add new files for roles unique to your context. Remove files for roles you don't have.

| File | Default role | Edit when |
|------|--------------|-----------|
| `_template.md` | (template only — never loaded) | Always — copy this when adding a new role |
| `engineering-architect.md` | System design, architecture decisions | You have a dedicated architect or senior engineer who owns architecture |
| `engineering-backend.md` | Backend implementation | You have backend developers |
| `engineering-frontend.md` | Frontend implementation | You have frontend developers |
| `engineering-database.md` | Database design, schema, migrations | You have a DBA, database engineer, or backend engineer who owns the DB |
| `engineering-security.md` | Security review, threat modeling | You have a security owner |
| `engineering-devops.md` | Deploy pipelines, infrastructure, observability | You ship to production yourself |
| `engineering-ai.md` | AI/ML model integration, prompt engineering | Your product uses LLMs or ML models |
| `product.md` | Product management, prioritization, specs | You have a PM or are wearing the PM hat |
| `strategy.md` | Strategic positioning, OKRs, long-range planning | You think in quarters, not sprints |
| `design.md` | UX, UI, brand, design systems | You have a designer or are owning design yourself |
| `marketing.md` | Positioning, content, growth, channels | You have a marketing function |
| `sales.md` | Pipeline, deals, customer development | You have a sales function or are doing sales yourself |
| `support.md` | Customer support, knowledge base, escalations | You have a support function |
| `testing.md` | QA, test plans, coverage, regression | You have a tester or own QA yourself |
| `project-management.md` | Coordination, dependencies, status reporting | You have a PM/project lead |

After editing, update `business/ROUTING.md` so Conductor knows which files to load for which role.

---

## Adding a New Role

1. Copy `_template.md` to `your-role.md`.
2. Fill in all 7 sections.
3. Add a row to `business/ROUTING.md` with the load sequence.
4. (Optional) If you use the runtime orchestrator, add an entry to `orchestrator/roles/manifest.json` mapping the role key to this file.
5. Run the **Orphan Prevention Rule** check from `FRAME_CONTROL_ALGORITHM.md` — confirm the role is referenced from `business/README.md`, `ROUTING.md`, and at least one gate.

---

## Removing a Role

1. Remove the file from this directory.
2. Remove the row from `business/ROUTING.md`.
3. Remove the entry from `orchestrator/roles/manifest.json` (if present).
4. Search for inbound references — `core.md`, `insights.md`, other role files — and update them.

---

## Cross-References (the orphan-prevention manifest for this directory)

This directory is referenced from:

- `business/README.md` — directory map
- `business/ROUTING.md` — every routing row points to one or more files here
- `business/FRAME_CONTROL_ALGORITHM.md` — pre-execution frame lock requires role files
- `conductor-core/CONDUCTOR.md` — routing policy and minimum-role-set algorithm
- `conductor-core/conductor/README.md` — role transition format
- `orchestrator/roles/manifest.json` (if runtime orchestrator is used) — role key resolution

If you add a file here, add the cross-reference to `ROUTING.md` and `business/README.md` in the same change.
