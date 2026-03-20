# Security

## Reporting a vulnerability

If you find a security issue in Conductor's orchestration layer (`mg-mode-core/`), please do not open a public GitHub issue.

Instead, use GitHub's private vulnerability reporting:
**[Report a vulnerability](https://github.com/mechul-eth/conductor/security/advisories/new)**

Or email the maintainer directly. Include:
- What you found and where (file, section, line if applicable)
- What the impact is or could be
- How to reproduce it, if possible
- Any suggested fix (optional)

We'll acknowledge within 72 hours and aim to resolve valid reports within 14 days.

---

## What belongs here vs. upstream

Conductor is an orchestration layer built on top of three open-source libraries. Routing issues, governance bugs, and session logic vulnerabilities are **Conductor's responsibility** — report them here.

Security issues in the underlying libraries should go to their maintainers:

| Library | Report Here |
|---------|-------------|
| [agency-agents](https://github.com/msitarzewski/agency-agents) | [msitarzewski/agency-agents issues](https://github.com/msitarzewski/agency-agents/issues) |
| [gstack](https://github.com/garrytan/gstack) | [garrytan/gstack issues](https://github.com/garrytan/gstack/issues) |
| [promptfoo](https://github.com/promptfoo/promptfoo) | [promptfoo/promptfoo security](https://github.com/promptfoo/promptfoo/security) |

---

## Scope

### In scope

- Routing logic that could allow unauthorized role escalation
- Session state handling that could leak data between sessions
- Governance gate bypass vulnerabilities
- Identity token issues that could allow privilege escalation
- Prompt injection paths in the conductor or map components
- The bootstrap script (`mg-mode-core/activation/bootstrap.sh`)

### Out of scope

- The AI model's behavior (hallucinations, bias) — that's a model-level concern, not Conductor
- Security of the IDE environment (VS Code, Cursor, etc.)
- Theoretical attacks with no practical exploitation path

---

## Disclosure policy

We follow responsible disclosure. Please give us a reasonable window to fix the issue before publishing publicly. We'll credit you in the changelog (or keep you anonymous if you prefer).

---

## Notes on AI-specific security

Conductor is a markdown-based orchestration system that runs inside an AI coding agent. A few things worth knowing:

- The orchestration runs inside the AI agent's context window — there is no server to attack
- Prompt injection is a real concern in any AI system. If you find a way to make the conductor bypass its own governance gates via a crafted prompt, that's worth reporting
- Session state is local to `~/.conductor/` — it doesn't leave your machine
