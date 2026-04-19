# Insights — Running Intelligence Log

## Key Decisions

### 2026-04-19 — Conductor activated
- Profile: production-lite [user-stated]
- Domain: other (B2B SaaS) [user-stated]
- Scenario: team iterating [user-stated]
- Roles wired: engineering-architect, engineering-backend, engineering-frontend, engineering-database, engineering-security, engineering-devops, engineering-ai, product, design, testing, project-management, marketing, sales [user-stated]
- Intelligence domains in scope: api, backend, frontend, database, integration, ai-usage, release-readiness [user-stated]
- Repo scan: 14 facts extracted, 12 approved, 2 corrected (supabase region details, deploy target) [system-generated]

### 2026-04-08 — No "decisions inbox" in v1
- Rationale: too close to Slack's territory; would dilute the "shared truth" positioning. [user-stated]
- Revisit: Q4 2026 after Notion integration ships. [user-stated]

### 2026-03-02 — Single AI provider
- Chose OpenAI-only for the AI proxy. [user-stated]
- Rationale: keeps bounded-use architecture simple; switching cost is acceptable later. [user-stated]
- Revisit: if OpenAI pricing shifts materially or reliability drops below 99.5%. [user-stated]

### 2026-02-14 — Inngest over BullMQ
- Chose Inngest for async job orchestration. [user-stated]
- Rationale: observability + dashboard story; no ops burden. [user-stated]

## User Patterns

- Prefers terse answers with explicit "more if you want" offers. [user-implied, session-002]
- Reliably reads ADRs; skims long PRD-style docs. [user-implied, session-005]
- Will push back on speculative refactors even when the win is clear — wants the existing code preserved. [user-stated, session-002]

## Competitive Intelligence

- Decisive raised a Series A in March 2026; price reportedly stable but SDR outreach has intensified. [external, user-shared-link]
- Linear Docs shipped "Projects" view in March that overlaps ~40% with our Team Digest surface. [user-stated]

## Market Observations

- Three prospects this quarter cited "SOC 2 required" as a blocker; this turns into opportunity when Type II lands. [user-stated]
- Partner-integration installs from Slack App Directory grew 22% MoM in March. [system-generated, from analytics]

## Routing Improvements

- 2026-04-10: Multi-role activation on "add a pricing page" worked well — frontend + marketing + product — when we loaded `market.md` first. Without `market.md`, the role missed competitor pricing context. [user-implied]
