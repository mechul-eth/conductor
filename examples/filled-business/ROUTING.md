# business/ROUTING.md — Role-to-Context Routing Table (Northwind Notes)

Example routing — this is what a filled-in `ROUTING.md` for a mid-sized B2B SaaS team looks like. Study the load sequences, not the specific role names.

## Routing Table

| Role | Load sequence |
|------|--------------|
| Engineering — Architect | `core.md` -> `roles/engineering-architect.md` |
| Engineering — Backend | `core.md` -> `roles/engineering-architect.md` -> `roles/engineering-backend.md` -> `backend-intelligence/foundation.md` |
| Engineering — Frontend | `core.md` -> `roles/engineering-frontend.md` -> `frontend-intelligence/README.md` -> `frontend-intelligence/foundation.md` |
| Engineering — Database | `core.md` -> `roles/engineering-architect.md` -> `roles/engineering-database.md` -> `database-intelligence/foundation.md` |
| Engineering — Security | `core.md` -> `roles/engineering-security.md` -> `release-readiness-intelligence/foundation.md` |
| Engineering — DevOps | `core.md` -> `roles/engineering-devops.md` -> `release-readiness-intelligence/foundation.md` |
| Engineering — AI | `core.md` -> `roles/engineering-ai.md` -> `ai-usage-intelligence/foundation.md` -> `ai-usage-intelligence/bounded-use-architecture.md` |
| Product Manager | `core.md` -> `market.md` -> `roles/product.md` |
| Design | `core.md` -> `roles/design.md` -> `frontend-intelligence/foundation.md` |
| Marketing | `core.md` -> `market.md` -> `roles/marketing.md` |
| Sales | `core.md` -> `market.md` -> `roles/sales.md` |
| Testing / QA | `core.md` -> `roles/testing.md` |
| Project Management | `core.md` -> `roles/project-management.md` |
| Default (unknown role) | `core.md` -> `README.md` |

## Notes

- Northwind Notes doesn't have a standalone **Strategy** role — the CEO wears it. Merged into Product Manager routing.
- No **Support** role yet — CS is a single person using shared tools. Will add when headcount hits 3.
- **Engineering — AI** loads two AI-usage files because bounded-use architecture is load-bearing on every AI task.

## Cross-References

See `business/README.md` (directory map), `business/FRAME_CONTROL_ALGORITHM.md` (orphan-prevention rule), `conductor-core/CONDUCTOR.md` (supreme policy).
