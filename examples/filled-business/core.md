# Business Core

## Business Overview

Northwind Notes is a B2B SaaS that gives mid-market product teams (50-300 employees) a shared inbox for customer-facing decisions — what changed, why, who needs to know, and the receipts. It replaces the chain of "did we tell support about this?" Slack messages with a structured changelog every team can rely on. [user-stated]

**Stage:** growth (Series A, 2,400 paying companies)
**Domain:** other (B2B SaaS, no specific regulated industry)
**Model:** SaaS, per-seat pricing with usage-based add-ons

## Product

**What:** A shared decision-log app with tight integrations to Slack, Linear, GitHub, and Intercom.
**For whom:** Product managers and customer-facing engineers at companies in the 50-300 employee band who lose hours per week to "did anyone tell X about Y?"
**Core value:** Decisions get logged in one place, the right people get notified once, the audit trail is automatic.

## Revenue

- Subscription tiers: Free (5 users), Team ($12/seat/mo), Business ($24/seat/mo), Enterprise (custom). [user-stated]
- Usage-based add-on for retention beyond 1 year ($0.05/decision/month). [user-stated]
- Annual contracts get 15% discount. [user-stated]

## Constraints

- SOC 2 Type II in progress; renewal target Q3 2026. [user-stated]
- Data residency commitment to enterprise customers — EU and US regions only, no cross-region replication. [user-stated]
- Slack integration is the load-bearing surface; we cannot break parity with Slack's display semantics. [user-implied]

## Architecture Decisions

- Stack: Next.js 14 (App Router) on Vercel + Postgres on Supabase + Inngest for async jobs. [user-stated, session-001]
- Monorepo (Turborepo) with `web/`, `api/`, `packages/ui/`, `packages/db/`. [user-stated, session-001]
- Real-time updates via Supabase Realtime; no custom WebSocket layer. [user-stated, session-003]
- Authentication via Supabase Auth + magic link; SSO via WorkOS for Business+ tiers. [user-stated]
- AI features go through a single OpenAI proxy at `api/ai/` — bounded use only (summarization + tagging, never auth or writes). [user-stated, session-007]

## Roadmap

- Q2: Notion + Jira integrations; per-team default routing rules. [user-stated]
- Q3: SOC 2 Type II completion; SSO GA on Business tier. [user-stated]
- Q4: Mobile (React Native, read-only at first). [user-stated]
- Wishlist: AI-assisted decision-summarization for weekly digests. [user-stated]
