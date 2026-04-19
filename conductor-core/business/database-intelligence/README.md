# business/database-intelligence/ — Database Intelligence

> Loaded when a role works on schema, queries, migrations, or data integrity.

## What Lives Here

| File | Purpose | Required? |
|------|---------|-----------|
| `README.md` | This file | Yes |
| `foundation.md` | Database choice, conventions, ownership | Yes (start here) |
| `schema-architecture.md` | Logical schema, naming, ownership boundaries | When schema gets non-trivial |
| `migration-governance.md` | Migration policy — order, rollback, deploy windows | When schema changes ship to prod |
| `query-reliability.md` | Query patterns, indexes, anti-patterns | When you have hot paths |
| `compatibility-gate.md` | Release gate for DB changes | Yes when releases ship |
| `context-efficiency.md` | Context Conductor must load for DB roles | Recommended |

Add only when referenced from `ROUTING.md` or a gate.

## Wiring

Referenced from: `business/README.md`, `business/ROUTING.md`, `business/FRAME_CONTROL_ALGORITHM.md`, `roles/engineering-database.md`, `roles/engineering-architect.md`.

References: `core.md`, `backend-intelligence/`, `api-intelligence/`, `release-readiness-intelligence/`.

## Foundation Template

Suggested `foundation.md` sections:

```
1. Engine          — name (Postgres, MySQL, SQLite, etc.) and version
2. Hosting         — managed (RDS, Supabase) vs. self-hosted
3. Naming          — table/column conventions, plural vs singular
4. Migrations      — tool, naming pattern, where they live
5. Indexes         — strategy — when to add, how to verify
6. Constraints     — FK enforcement, check constraints, RLS posture
7. Backups         — frequency, retention, restore drill cadence
8. Anti-patterns   — what's banned (e.g. raw SQL in app code)
9. Decision log    — non-obvious choices
```

## Maintenance

- Add a row to `ROUTING.md` when creating a new file here.
- `migration-governance.md` is the contract for what "safe migration" means — keep it tight.
- Run orphan-prevention before merging.
