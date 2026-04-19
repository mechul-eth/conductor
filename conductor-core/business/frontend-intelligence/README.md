# business/frontend-intelligence/ — Frontend Intelligence

> Loaded when a role works on UI implementation — components, design system, performance. Owns the truth about your client-side architecture.

## What Lives Here

| File | Purpose | Required? |
|------|---------|-----------|
| `README.md` | This file | Yes |
| `foundation.md` | What frontend is, framework, design system | Yes (start here) |
| `interface-architecture.md` | Pages, layouts, routing, data flow | When the app has > 5 routes |
| `design-system-index.md` | Tokens, components, anchors to the design system | Critical when you have a DS |
| `compatibility-gate.md` | Release gate for frontend changes | Yes when releases ship |
| `context-efficiency.md` | Context Conductor must load for frontend roles | Recommended |
| `quality-benchmarks.md` | Performance budgets, a11y thresholds, visual-regression rules | When you have budgets |
| `{framework}-pack.md` | Framework-specific guidance (e.g. `nextjs-app-router.md`) | One per framework you use |

Add only when referenced from `ROUTING.md` or a gate.

## Wiring

Referenced from: `business/README.md`, `business/ROUTING.md`, `business/FRAME_CONTROL_ALGORITHM.md`, `roles/engineering-frontend.md`, `roles/design.md`.

References: `core.md`, `api-intelligence/` (consumes it), `release-readiness-intelligence/`.

## Foundation Template

Suggested `foundation.md` sections:

```
1. Mission           — what the frontend exists to do
2. Surfaces          — web, mobile web, native, embedded — list each
3. Framework         — name, version, why it was chosen
4. Design system     — tokens, primitives, where they live
5. State             — local, shared, server-state library
6. Routing           — pattern (file-based, declarative)
7. Data fetching     — convention (RSC, queries, SWR, etc.)
8. Performance budgets — bundle size, web vitals targets
9. Accessibility     — minimum standard, audit cadence
10. Decision log     — non-obvious choices
```

## Framework Packs

When you adopt a new framework, create `{framework-name}.md` in this directory and reference it from `ROUTING.md`. Example: `nextjs-app-router.md`, `react-component-architecture.md`. The accountable role stays `engineering-frontend` — packs are loaded as supplemental context, not new owners.

## Maintenance

- Add a row to `ROUTING.md` when creating a new pack or file.
- Keep `design-system-index.md` current — it's loaded on every UI task and saves real money on prompts.
- Run orphan-prevention before merging.
