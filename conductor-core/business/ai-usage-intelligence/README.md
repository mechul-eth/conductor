# business/ai-usage-intelligence/ — AI Usage Intelligence

> Loaded when a role works on AI/LLM features, prompts, evals, or model selection. Owns the truth about where AI is allowed to act and where it must stay advisory.

## What Lives Here

| File | Purpose | Required? |
|------|---------|-----------|
| `README.md` | This file | Yes |
| `foundation.md` | The AI usage philosophy — model defaults, cost posture | Yes (start here) |
| `deterministic-protection-ladder.md` | What stays deterministic; AI-eligible levels | Yes when AI is used |
| `bounded-use-architecture.md` | Where AI is allowed to write vs. read; sandbox boundaries | Yes when AI is used |
| `customer-ai-preference-model.md` | Per-segment / per-user AI preferences | When users get to opt out |
| `failure-policy.md` | What to do when an AI call fails | Yes when AI is in the hot path |
| `compatibility-gate.md` | Release gate for AI changes | Yes when AI ships |
| `context-efficiency.md` | Context Conductor must load for AI roles | Recommended |

Add only when referenced from `ROUTING.md` or a gate.

## Wiring

Referenced from: `business/README.md`, `business/ROUTING.md`, `business/FRAME_CONTROL_ALGORITHM.md`, `roles/engineering-ai.md`, `roles/product.md`, `roles/engineering-security.md`.

References: `core.md`, `release-readiness-intelligence/`.

## Foundation Template

Suggested `foundation.md` sections:

```
1. Mission              — what AI is for in this product
2. Default model        — which model, why, cost per call
3. Escalation rules     — when to upgrade to a larger model
4. Bounded use          — what AI can write, what stays deterministic
5. Eval suite           — where it lives, pass-rate threshold
6. Failure policy       — fallbacks when AI calls fail
7. Cost posture         — budget caps per feature, alerting
8. Privacy              — what data is sent, what is excluded
9. Decision log         — non-obvious AI choices
```

## Maintenance

- Add a row to `ROUTING.md` when creating a new file here.
- Keep `bounded-use-architecture.md` aligned with reality — drift here causes real incidents.
- Run orphan-prevention before merging.
