# business/ROUTING.md — Role-to-Context Routing Table

> Conductor reads this file before activating any role. It tells Conductor exactly which business-context files to load for each role, in what order. Filling this in correctly is what makes Conductor "know your team."

## Purpose

This is a **deterministic routing contract**. When Conductor activates a role, it walks the corresponding row in the table below from left to right, loading each file in order. This keeps role activation context predictable and auditable across sessions.

The contract is also consumed by:

- `conductor-core/CONDUCTOR.md` — the brain
- `conductor-core/conductor/README.md` — the entry point
- `conductor-core/map/README.md` — the pre-execution mapper
- The optional `orchestrator/` runtime, when used

This file defines **only business-context loading order**. It does not override execution policy, quality gates, or safety rules — those live in `CONDUCTOR.md`.

---

## How to Fill This In (the only step required to plug Conductor into a new project)

1. Decide which roles your team has — engineering, design, product, marketing, sales, support, etc. List them under **Roles** in `core.md` or here.
2. For each role, decide which `business/` files Conductor should pre-load when that role is invoked.
3. Add a row to the **Routing Table** below.
4. Make sure every file you list under that row actually exists. If it doesn't, create it as a stub or remove the reference. Conductor will fail closed (`NEEDS_CONTEXT`) if a referenced file is missing.

**Rule of thumb:** every row starts with `core.md` (always), then layers in role-specific context. Keep rows small — load only what the role actually needs to do its job. Loading everything makes prompts noisy and expensive.

---

## Role File Structure Standard

Every file in `business/roles/` follows this section order so any agent loading any role file gets a predictable structure:

1. **Mission** — one to two sentences on what this role does for the team.
2. **Scope** — what's in scope and what's explicitly out of scope.
3. **Deliverables** — the concrete artifacts this role produces.
4. **Decision authority** — what this role can decide alone vs. what requires escalation.
5. **Quality gates** — the gates that always run for this role's outputs.
6. **Handoff format** — how this role hands off to the next role in a multi-role flow.
7. **Example invocations** — 2-3 concrete examples of when this role gets activated.

Keep each role file under 200 lines. Conductor loads role files into every prompt — bloat costs money on every invocation.

---

## Routing Table — FILL IN FOR YOUR TEAM

The example rows below assume a small product team. Replace, add, or delete rows to match yours. Every row's first file should be `core.md`.

| Role | Load sequence |
|------|--------------|
| Engineering — Architect | `core.md` -> `roles/engineering-architect.md` |
| Engineering — Backend | `core.md` -> `roles/engineering-architect.md` -> `roles/engineering-backend.md` |
| Engineering — Frontend | `core.md` -> `roles/engineering-frontend.md` -> `frontend-intelligence/README.md` -> `frontend-intelligence/foundation.md` |
| Engineering — Database | `core.md` -> `roles/engineering-architect.md` -> `roles/engineering-database.md` -> `database-intelligence/README.md` |
| Engineering — Security | `core.md` -> `roles/engineering-security.md` |
| Engineering — DevOps / SRE | `core.md` -> `roles/engineering-devops.md` |
| Engineering — AI / ML | `core.md` -> `roles/engineering-ai.md` -> `ai-usage-intelligence/README.md` |
| Product — Manager | `core.md` -> `market.md` -> `roles/product.md` |
| Product — Strategy | `core.md` -> `market.md` -> `roles/strategy.md` |
| Design — UX | `core.md` -> `roles/product.md` -> `roles/design.md` |
| Design — UI | `core.md` -> `roles/design.md` -> `frontend-intelligence/README.md` |
| Marketing | `core.md` -> `market.md` -> `roles/marketing.md` |
| Sales | `core.md` -> `market.md` -> `roles/sales.md` |
| Support | `core.md` -> `roles/support.md` |
| Testing / QA | `core.md` -> `roles/testing.md` |
| Project Management | `core.md` -> `roles/project-management.md` |
| Default (unknown role) | `core.md` -> `README.md` |

The default row applies whenever Conductor encounters a role label it can't match — it falls back to `core.md` + the business/ overview, then asks the user to clarify the role before deeper execution.

---

## Multi-Role Activation

When more than one role is activated for a single task, Conductor merges their load sequences while preserving order and deduplicating files. For example, if a task activates Backend Engineer and Database Engineer:

```
core.md -> roles/engineering-architect.md -> roles/engineering-backend.md -> roles/engineering-database.md -> database-intelligence/README.md
```

`core.md` and `roles/engineering-architect.md` are loaded once even though both rows reference them.

---

## External Role Routing (optional)

If you connect an external role library (for example, the [Agency Agents](https://github.com/msitarzewski/agency-agents) library), Conductor maps external role labels to the closest local routing row and adds the external role definition as additional context.

Example bridge table:

| External Role | Maps to local row | Additional context |
|--------------|-------------------|---------------------|
| `engineering-software-architect` | Engineering — Architect | the external role file URL |
| `engineering-backend-developer`  | Engineering — Backend   | the external role file URL |
| `design-ux-architect`            | Design — UX             | the external role file URL |

External roles inherit `core.md` as mandatory first context — same as local roles. They obey all `CONDUCTOR.md` policies unconditionally (deterministic-first, minimum-role-set, no silent scope expansion).

---

## Routing Rules (binding)

1. **Local routing rows always take precedence over external role definitions.** If a row exists for the role you're activating, follow that row's sequence first; the external role file becomes supplemental context.
2. **`core.md` is always loaded** — even when not explicitly listed.
3. **If a referenced file is missing, fail closed** — Conductor logs `NEEDS_CONTEXT` and asks the user to create the missing file rather than silently activating the role with incomplete context.
4. **Routing changes are reviewable.** Any update to this table must be committed in a single change so reviewers can audit which roles now have which context.
5. **Do not duplicate `CONDUCTOR.md` content here.** This file is a routing contract; the brain file is the policy. They refer to each other but never restate.

---

## Maintenance

- Update this file whenever a new role is added under `business/roles/`.
- Update this file whenever a new intelligence domain is added under `business/{domain}-intelligence/`.
- Run the **Orphan Prevention Rule** check from `FRAME_CONTROL_ALGORITHM.md` before merging any change — every new artifact must be linked from `business/README.md`, `ROUTING.md`, and at least one active gate.

---

*This file is a deterministic routing contract. If you change it, every future role activation will see the new behavior. Test on a single role before bulk-editing.*
