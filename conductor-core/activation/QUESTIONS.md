# Onboarding Question Bank

> The questions Conductor asks during first activation. The agent picks from this list based on profile and what the repo scan already filled. Never asks all of them — only the gaps.

## How to Use

1. Run the scan first (`SCAN_CHECKLIST.md`).
2. For each `business/` file, identify which sections are still empty.
3. Pick the matching question(s) from this bank.
4. Ask one or two at a time. Never interrogate.
5. Propose the write. User approves before it lands.

---

## Questions for `business/core.md`

### Business Overview
- "What are you building, in one sentence?"
- "What stage is this project at — exploring, MVP, growth, scale, or mature?"
- "What's your business model — SaaS, marketplace, service, product, hybrid?"
- "What domain — financial, medical, e-commerce, legal, telecom, real-estate, or general?"

### Product
- "Who is this product for? One specific persona or segment is fine."
- "What's the core value proposition — why would they choose this over the alternatives?"

### Revenue
- "How does this make money?"
- "What's your pricing approach — subscription, transaction fee, usage-based, freemium?"

### Constraints
- "What can't change about this project? Regulatory, technical, contractual?"
- "Is there legacy code or a vendor we have to live with?"

### Architecture Decisions
- "What's the stack — framework, database, hosting?"
- "Why this stack — anything I should preserve when proposing changes?"

### Roadmap
- "What's the next thing you want to ship?"
- "What's on the wish list for the quarter after that?"

---

## Questions for `business/user-profile.md`

### Expertise
- "What are you good at, technically?"
- "What's your day job — engineering, design, product, founder?"

### Gaps
- "Where do you want me to be more careful or more thorough?"
- "Any topics where you'd prefer extra explanation vs. just doing the work?"

### Preferences
- "Do you want short answers or thorough ones?"
- "Do you prefer to review every change before it's applied, or trust auto-apply for small stuff?"

---

## Questions for `business/market.md`

### Competitors (only if not skipped)
- "Who are your main competitors? Three names is enough."
- "What do they do well that you have to match?"
- "What do they do badly that you can beat them on?"

### Positioning
- "If a customer compares you to a competitor, what should they conclude?"

### Risks
- "What's the biggest market risk that keeps you up at night?"

---

## Questions for `business/ROUTING.md` wiring

- "Who's on the team — list each role you have. I'll wire the routing table."
- "Any external role libraries you want to plug in (e.g. agency-agents)? I'll add them as supplemental."

---

## Questions for intelligence domain selection

- "Which contracts matter for this project right now — API, backend, frontend, database, integration, AI usage, release readiness?"
- "Pick the ones that are load-bearing today. Skip the rest — you can add them later."

---

## Profile-Aware Question Limits

| Profile | Max gap-questions per session |
|---------|-------------------------------|
| `learning` | 1 (fill opportunistically) |
| `MVP` | 3 (per onboarding session) |
| `production-lite` | 5 (plus follow-ups on constraints, compliance) |
| `production-strict` | unlimited (mandatory: domain, regulatory, data sensitivity) |

---

## Cross-References

Referenced from `FIRST_RUN.md`, `CONDUCTOR.md` §BUSINESS INTELLIGENCE → Onboarding, and every IDE-specific instructions file.
