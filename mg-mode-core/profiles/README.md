# Profiles — Stage-Aware Onboarding and Budget Profile Manager

> Four modes: learning, MVP, production-lite, production-strict. Each activates a specific subset of Layer 1 validations and budget caps. Profile chosen at first setup. Any profile can escalate to a stricter mode without reinstalling.

## Onboarding Flow

At first activation, ask three questions:

### Q1: Project Stage
```
What stage is this project?
  (a) Learning — exploring, prototyping, no users yet
  (b) MVP — building toward first users, speed matters
  (c) Production-lite — live users, moderate risk tolerance
  (d) Production-strict — production system, compliance matters, full safety
```

### Q2: Regulated Domain
```
Does this project touch any regulated domain?
  (a) None
  (b) Financial
  (c) Medical
  (d) E-commerce
  (e) Legal
  (f) Telecom
  (g) Real estate
  (h) Other: ___
```
The domain answer activates matching vertical plugins automatically at Security-Deep Group or above.

### Q3: Project Scenario
```
What describes this project?
  (a) Startup moving fast
  (b) Established team shipping iteratively
  (c) Enterprise feature with compliance review
  (d) Production incident response
```
The scenario sets map/'s context for risk tolerance, agent activation speed, and quality gate strictness.

---

## Profile Definitions

### Learning Profile

| Aspect | Setting |
|--------|---------|
| NEXUS mode | NEXUS-Micro (5–10 agents, 1–5 days) |
| Validation group | Baseline Group only |
| Budget cap | $5/session (soft warning, suggestion at cap) |
| Governance gate | Advisory only — surfaces recommendations |
| Safety hooks | /careful only (ask before destructive commands) |
| Review tiers | Eng: optional, all others: off |
| Observability | Off by default, opt-in |
| Tool assessment | Optional |
| Optimizer shadow testing | Off |
| Auto-promotion | May opt-in |

### MVP Profile

| Aspect | Setting |
|--------|---------|
| NEXUS mode | NEXUS-Sprint (15–25 agents, 2–6 weeks) |
| Validation group | Baseline Group only |
| Budget cap | $25/session (hard warning at 70%, hard stop at 100%) |
| Governance gate | Advisory only — Q1/Q2/Q3 surfaced, not blocking |
| Safety hooks | /careful + /freeze on ship |
| Review tiers | Eng: required, CEO/Design: optional |
| Observability | Off by default, opt-in |
| Tool assessment | Recommended but not blocking |
| Optimizer shadow testing | 5% sample |
| Auto-promotion | User confirmation required |

### Production-Lite Profile

| Aspect | Setting |
|--------|---------|
| NEXUS mode | NEXUS-Sprint (15–25 agents, 2–6 weeks) |
| Validation group | Security-Deep Group |
| Budget cap | $100/session (alerts at 70%, hard stop at 100%) |
| Governance gate | Active — all three questions enforced |
| Safety hooks | /careful + /freeze on ship + blast radius gate |
| Review tiers | Eng: required, CEO: optional, Design: auto for frontend |
| Observability | Opt-in at setup |
| Tool assessment | Required — blocks adoption without assessment |
| Optimizer shadow testing | 5% sample |
| Auto-promotion | User confirmation required |
| Multi-turn simulation | Active (SimulatedUser, maxTurns 10) |

### Production-Strict Profile

| Aspect | Setting |
|--------|---------|
| NEXUS mode | NEXUS-Full (all agents, 12–24 weeks) |
| Validation group | Security-Deep Group + domain plugins + tracing assertions |
| Budget cap | $500/session (automatic stop, governance approval for override) |
| Governance gate | Active — all three questions + tool assessment mandatory |
| Safety hooks | /guard (careful + freeze combined = maximum safety) |
| Review tiers | Eng: required, Codex: required (cross-model comparison), Design: auto for frontend |
| Observability | Opt-in at setup (Tier 1 + Tier 2 OTel) |
| Tool assessment | Required — blocks adoption without assessment |
| Optimizer shadow testing | 5% sample + LLM-as-Judge scoring |
| Auto-promotion | Never — user confirmation always required |
| Multi-turn simulation | Active (SimulatedUser, maxTurns 10, stateful) |
| Cross-model review | Claude + Codex → agreement rate % |
| Codex challenge | Adversarial mode active |
| Reality Checker | 5-step mandatory process |
| SRE SLO framework | Active — burn rate alerts, error budgets |
| Threat detection | Active post-deployment (Sigma rules, MITRE ATT&CK) |
| Compliance auditor | Active for regulated domains |

---

## Validation Groups

### Baseline Group (learning + MVP)

**Structure:** `is-json`, `is-xml`, `contains`, `not-contains`, `regex`, `starts-with`, `levenshtein`, `word-count`
**Quality:** `llm-rubric`, `factuality`, `answer-relevance`, `similar`, `g-eval`, `pi`
**Reliability:** `overreliance`, `hijacking`, `excessive-agency`, `hallucination`, `finish-reason`
**Tool calls:** `is-valid-openai-tool-call`, `tool-call-f1`, `is-valid-function-call`
**Cost:** `cost`, `latency`
**Custom:** `javascript`, `python`, `ruby`, `webhook`

### Security-Deep Group (production-lite + production-strict)

All Baseline Group assertions PLUS:

**Authorization:** `rbac`, `bola`, `bfla`
**Injection:** `prompt-injection`, `indirect-prompt-injection`, `sql-injection`, `shell-injection`, `debug-access`, `ssrf`
**Data leakage:** `pii` (all variants), `cross-session-leak`, `prompt-extraction`, `rag-document-exfiltration`, `rag-source-attribution`
**Agentic:** `agentic/memory-poisoning`, `excessive-agency` (full), `goal-misalignment`, `tool-discovery`
**Harmful content:** All OWASP LLM Top 10 harmful categories
**Jailbreak:** `aegis`, `harmbench`, `toxicChat`, `donotanswer`, `beavertails`, `vlguard`, `pliny`, `xstest`, `unsafebench`, `cyberseceval`
**Multi-turn adversarial:** `crescendo`, `goat`, `best-of-n`, `iterative`, `hydra`, `simba`, `mischievous-user`, `authoritative-markup-injection`
**Obfuscation:** `base64`, `rot13`, `leetspeak`, `hex`, `homoglyph`, `ascii-smuggling`, `multilingual`, `math-prompt`, `citation`
**Moderation:** `moderation`, `is-refusal`, `guardrails`, `not-guardrails`
**Policy:** `policy`, `contracts`, `politics`, `religion`, `competitors`, `imitation`, `unverifiable-claims`
**RAG:** `context-faithfulness`, `context-recall`, `context-relevance`
**Risk scoring:** Composite score per plugin (impact × exploitability × human_factor × strategy_weight)

### Domain Plugins (activate by declaration)

| Domain | Plugins Activated |
|--------|------------------|
| Financial | 11 plugins (hallucination, misconduct, sox-compliance, data-leakage, etc.) |
| Medical | 6 plugins (hallucination, sycophancy, anchoring-bias, etc.) |
| Pharmacy | 3 plugins (drug-interaction, dosage-calculation, controlled-substance) |
| Insurance | 4 plugins (phi-disclosure, data-disclosure, coverage-discrimination, etc.) |
| Telecom | 12 plugins (cpni-disclosure, tcpa-violation, e911-misinformation, etc.) |
| Real estate | 8 plugins (fair-housing, lending-discrimination, valuation-bias, etc.) |
| E-commerce | 4 plugins (price-manipulation, order-fraud, pci-dss, compliance-bypass) |
| Legal | 2 plugins (coppa, ferpa) |

---

## Profile Escalation

Any profile can escalate to a stricter mode without reinstalling:

```
learning → MVP → production-lite → production-strict

Escalation triggers:
  1. User explicitly requests a stricter profile
  2. Map/ recommends escalation (e.g., going to production)
  3. Governance/ detects high-risk automation at a low profile

De-escalation: user must explicitly request. Not automatic.
```

---

## Profile Storage

```yaml
# ~/.conductor/projects/$SLUG/profile.yaml
project: my-project
profile: MVP
domain: financial
scenario: startup
created_at: 2026-03-20T12:00:00Z
escalated_from: null
budget_cap_usd: 25
observability_opt_in: false
jira_integration: false
```

---

## Integration Points

| Component | How profiles/ interacts |
|-----------|------------------------|
| `session/` | Profile stored in session state at initialization |
| `optimizer/` | Profile determines budget cap and shadow testing behavior |
| `governance/` | Profile determines gate enforcement level |
| `map/` | Profile determines NEXUS mode and validation scope |
| `activation/` | Profile selection is part of first activation flow |
| All validation | Profile determines which promptfoo assertions/plugins activate |
