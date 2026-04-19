# business/ — Per-Project Knowledge Store

> Conductor learns about your business, your market, your product, and your team through every interaction. This directory holds that intelligence. You own it. It never leaves your repository.

## What This Is

This directory is a living knowledge base. As you work with Conductor it captures and organizes what it learns about:

- **You** — your expertise, preferences, how you work
- **Your business** — what you're building, your model, your constraints
- **Your market** — competitors, positioning, trends, risks
- **Your product** — features, architecture, roadmap decisions
- **Your team** — internal roles, who owns what, how handoffs work
- **Your contracts** — API, backend, frontend, database, AI, integration, release

This intelligence makes every future interaction smarter. Instead of starting from scratch on each prompt, Conductor knows your context. Roles inherit it automatically.

---

## Files & Directories

### Always present (the baseline)

| File | Contains | Filled by |
|------|----------|-----------|
| `README.md` | This file | Always present |
| `core.md` | Business model, product vision, target audience, stage | Onboarding + ongoing |
| `market.md` | Competitors, market landscape, positioning, risks | When you share competitive data |
| `user-profile.md` | Your expertise, preferences, communication style | Progressively from interactions |
| `insights.md` | Key decisions, patterns, competitive learnings, session log | Every session |
| `ROUTING.md` | Role-to-context routing table — the wiring contract | You fill in for your team |
| `FRAME_CONTROL_ALGORITHM.md` | Deterministic frame lock & orphan prevention | Reference — read, don't edit |

### Roles — your team

| Directory | Contains |
|-----------|----------|
| `roles/` | One file per internal role (engineering-architect, product, design, etc.). External roles are referenced via the orchestrator runtime, not here. |

See `roles/README.md` for the file structure standard and the list of starter roles.

### Intelligence domains — your contracts

Each domain owns one slice of how the system works. Conductor loads the relevant domain when a role needs it. All seven are first-class control-plane dependencies once a release ships.

| Directory | Owns |
|-----------|------|
| `api-intelligence/` | API surface, contracts, versioning, security boundary |
| `backend-intelligence/` | Service architecture, runtime, conventions, worker reliability |
| `frontend-intelligence/` | UI architecture, design system, framework packs, performance budgets |
| `database-intelligence/` | Schema, migrations, query patterns, integrity rules |
| `integration-intelligence/` | Cross-layer handshakes, ownership boundaries, failure propagation |
| `ai-usage-intelligence/` | Where AI acts vs. advises, model defaults, eval suite, cost posture |
| `release-readiness-intelligence/` | Release gates, evidence registry, rollback governance |

### Growth (created when needed, per the Dynamic Growth rule)

| Directory | Created when |
|-----------|--------------|
| `competitors/{name}.md` | `market.md#competitors` exceeds 50 lines or you have 3+ named competitors with detail |
| `products/{name}.md` | You have 3+ distinct product lines that need separate context |
| `segments/{name}.md` | Multiple distinct customer segments with materially different needs (template at `segments/README.md`) |
| `research/{topic}.md` | The user shares 3+ external URLs/docs on the same topic (template at `research/README.md`) |
| `gtm/{channel}.md` | GTM section in `market.md` covers 3+ distinct distribution channels |

---

## How It Starts

Conductor detects whether it's being added to an existing codebase or a fresh project:

- **Existing codebase:** Scans `README`, package configs, docs, and directory structure. Presents extracted intelligence as a batch for your approval. Fills `business/` with what it learned — you correct or confirm.
- **Fresh project:** Asks 3 onboarding questions (what, for whom, competitors). You answer in detail or skip.

Either way, you approve every write. The system never assumes — it proposes.

---

## How to Plug Conductor In (the only step required for a new project)

If you cloned the Conductor repo and are setting it up for your team:

1. Edit `core.md` — what your business does, your stage, your model.
2. Edit `user-profile.md` — your expertise, preferences.
3. Edit `market.md` — your competitors and positioning (skip if you don't have data yet).
4. Edit `ROUTING.md` — make the role-to-context table match your team. This is the wiring step.
5. For each role you have, edit the matching file in `roles/` (or copy `roles/_template.md` for new ones).
6. For each intelligence domain that's load-bearing for your team, fill in `{domain}-intelligence/foundation.md`.
7. Activate Conductor in your IDE — it now knows your team and your context.

That's it. No code changes. The Conductor brain (`CONDUCTOR.md`) and the orchestration flow are generic — your business intelligence is what makes it yours.

---

## Reading Order by Role (default)

| You are | Start with | Then load |
|---------|-----------|-----------|
| New to this project | `README.md` → `core.md` | `market.md` |
| Engineering — Architect | `core.md` | `roles/engineering-architect.md` + relevant `*-intelligence/foundation.md` |
| Engineering — Backend | `core.md` | `roles/engineering-architect.md` + `roles/engineering-backend.md` + `backend-intelligence/foundation.md` |
| Engineering — Frontend | `core.md` | `roles/engineering-frontend.md` + `frontend-intelligence/README.md` + `frontend-intelligence/foundation.md` |
| Engineering — Database | `core.md` | `roles/engineering-database.md` + `database-intelligence/foundation.md` |
| Engineering — Security | `core.md` | `roles/engineering-security.md` |
| Engineering — DevOps / SRE | `core.md` | `roles/engineering-devops.md` + `release-readiness-intelligence/foundation.md` |
| Engineering — AI / ML | `core.md` | `roles/engineering-ai.md` + `ai-usage-intelligence/foundation.md` |
| Product Manager | `core.md` → `market.md` | `roles/product.md` |
| Strategy | `core.md` → `market.md` | `roles/strategy.md` |
| Design | `core.md` | `roles/design.md` + `frontend-intelligence/foundation.md` |
| Marketing | `core.md` → `market.md` | `roles/marketing.md` |
| Sales | `core.md` → `market.md` | `roles/sales.md` |
| Support | `core.md` | `roles/support.md` |
| Testing / QA | `core.md` | `roles/testing.md` + relevant `*-intelligence/quality-benchmarks.md` (when present) |
| Project Management | `core.md` | `roles/project-management.md` |
| Default (unknown role) | `README.md` | `core.md` |

The **canonical** routing table — what Conductor actually uses — lives in `ROUTING.md`. Edit that file when you change role wiring.

---

## Tagging Convention

Every fact in these files carries a source tag:

- `[user-stated]` — you said it directly
- `[user-implied]` — inferred from your behavior or decisions
- `[system-generated]` — derived by Conductor from a codebase scan
- `[external]` — from a shared link or reference document

Tag newly added facts. Untagged facts are treated as `[system-generated]` with low confidence.

---

## Rules

1. **You approve every write.** Conductor proposes changes. You confirm before they persist.
2. **Everything is tagged.** Source + confidence on every fact.
3. **You can edit or delete anything.** These are your files.
4. **Nothing leaves this repo.** No external transmission, no cross-project sharing, fully isolated.
5. **No orphans.** Per `FRAME_CONTROL_ALGORITHM.md`, every new file must be referenced from `README.md`, `ROUTING.md`, and at least one gate.

---

## Cross-References (orphan-prevention)

This directory is referenced from:

- `conductor-core/CONDUCTOR.md` — §BUSINESS INTELLIGENCE policy
- `conductor-core/conductor/README.md` — orchestration flow loads `business/` context every task
- `conductor-core/map/README.md` — pre-execution mapper consults `business/`
- `conductor-core/canonical_prompt.md` — pipeline overlays load `business/` files
- `orchestrator/lib/dispatch.sh` (when runtime is used) — dispatch envelope includes business context

## What "done" looks like

The `examples/filled-business/` directory at the repo root shows a fully filled-in `business/` for a fictional B2B SaaS called Northwind Notes. Reference it when you want to see what post-onboarding context looks like in practice.
