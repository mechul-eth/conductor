# Insights — Running Intelligence Log

> Patterns, key decisions, and observations captured during every session. This file grows continuously and is the primary source for routing intelligence.

## How This Works

Every significant observation is appended to the relevant section below with:
- A timestamp
- A confidence tag: `[user-stated]`, `[user-implied]`, `[system-generated]`, `[external]`
- Context about why it matters or how it should influence future decisions

Conductor reads this file during map/ pre-execution to inject relevant intelligence into role selection and prompt generation. The older the entry, the lower its routing weight — unless it's a foundational decision.

---

## Key Decisions

<!-- Architecture, product, and strategic decisions the user has made. These inform everything. -->
<!-- Format: ### YYYY-MM-DD — {decision title} -->
<!-- Include: what was decided, what was rejected, why. -->

<!-- ### 2026-03-21 — Initial activation -->
<!-- - Profile selected: {profile} [user-stated] -->
<!-- - Domain: {domain} [user-stated] -->
<!-- - Scenario: {scenario} [user-stated] -->

---

## User Patterns

<!-- Recurring behaviors, preferences, and working style observations. -->
<!-- These calibrate explanation depth, technical level, and decision speed. -->
<!-- Example: User rarely reads long plans — prefers short bullet formats [user-implied, session-005] -->

---

## Competitive Intelligence

<!-- Insights learned about competitors from interactions. -->
<!-- Cross-reference with market.md#competitors for full profiles. -->
<!-- Example: Competitor X lowered pricing Q1 2026 — likely pressure from Competitor Y [external, user-shared-link] -->

---

## Market Observations

<!-- Trends, shifts, and signals about the market from interactions. -->
<!-- Cross-reference with market.md for the structured picture. -->
<!-- Example: 3 separate user mentions of EU regulation changes — likely important constraint [user-implied] -->

---

## Routing Improvements

<!-- Cases where a routing decision worked especially well or poorly. -->
<!-- This helps optimizer/ learn the user's typical task patterns. -->
<!-- Example: User prefers planning roles before coding roles, even on small tasks [user-implied, session-008] -->

---

## Session Log

<!-- Raw chronological log. Append new entries at the bottom. -->
<!-- Use this for anything that doesn't fit a structured section above. -->

<!-- ### 2026-03-21 — Session 001 -->
<!-- - Business intelligence directory initialized [system-generated] -->
