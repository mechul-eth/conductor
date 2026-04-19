# User Profile

## Expertise

- Full-stack TypeScript — strongest in Next.js + Postgres. [user-stated]
- Has shipped two prior B2B SaaS products to ~$1M ARR each. [user-stated]
- Comfortable reading SQL EXPLAIN plans, writing migrations, debugging async jobs. [user-implied]
- Less confident on CSS animation, design system architecture, brand visuals. [user-implied]

## Gaps

- Wants a second pair of eyes on every customer-facing copy decision — not a designer by training. [user-stated]
- Less experienced with formal compliance work (SOC 2 is the first audit). [user-stated]
- Hasn't built a React Native app before; the Q4 mobile project is unfamiliar territory. [user-implied]

## Preferences

- Short answers by default; ask if more depth is wanted. [user-stated]
- Reviews PR-style diffs before applying changes — auto-apply only for trivial things (formatting, typos, sub-5-line refactors). [user-stated]
- Prefers ADRs for any decision that affects more than one component. [user-stated]
- Hates speculative refactors. "If it's not broken, don't move it" is a stated rule. [user-stated, session-002]

## Decision History

- 2026-02-14: Chose Inngest over BullMQ for async jobs because of the dashboard + observability story. [user-stated]
- 2026-03-02: Rejected adding a second LLM provider (Anthropic) — single-provider keeps the AI proxy simple, switching cost is acceptable later. [user-stated]
- 2026-04-08: Decided against a "decisions inbox" feed in v1 — too close to Slack's territory; would dilute the "shared truth" positioning. [user-stated]
