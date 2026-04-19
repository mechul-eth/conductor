# Repo Scan Checklist

> When the agent activates Conductor for the first time, it scans the existing codebase to pre-populate `business/`. This checklist tells the agent exactly what to read, what to extract, and where to propose writing it.

## Rules

1. **Read-only.** Never modify any source file during the scan. Only `business/` can be written, and only after user approval.
2. **Batch approval.** Present all findings to the user as one batch — never ask file-by-file.
3. **Source tracing.** Every proposed entry includes the source file (and line range when useful).
4. **No deep crawl.** Read top-level config files and docs, not source code internals. Business intelligence is about the business, not the implementation.
5. **Skip if user says skip.** A "skip — I'll tell you myself" cancels the entire scan.
6. **Idempotent.** If `business/` already has content, only propose additions — never overwrite without explicit user approval.

---

## Scan Sequence

### All Profiles (the baseline scan)

| Step | Read | Extract | Propose into |
|------|------|---------|--------------|
| 1 | `README.md` / `README` | Project description, tech stack, purpose, install instructions | `business/core.md` (Business Overview, Product, Stage) |
| 2 | `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` / `Gemfile` | Project name, dependencies, scripts, language ecosystem | `business/core.md` (Architecture Decisions) |
| 3 | `.env.example` / `docker-compose.yml` / infra configs | Services used, deployment targets, environment shape | `business/core.md` (Constraints, Architecture Decisions) |
| 4 | Top-level directory structure (2 levels deep) | Organization pattern (monorepo, service-based, layered) | `business/core.md` (Architecture Decisions) |
| 5 | `CONTRIBUTING.md` / `CODE_OF_CONDUCT.md` / `LICENSE` | Team conventions, OSS vs proprietary, license type | `business/user-profile.md` (Preferences) and `core.md` (Constraints) |
| 6 | `docs/` or `wiki/` (first 5 files) | Product documentation, API docs, user guides | `business/core.md` (Product) and `business/market.md` (Positioning) |

### `production-lite` adds:

| Step | Read | Extract | Propose into |
|------|------|---------|--------------|
| 7 | `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile` | Deploy pipeline, environments, test coverage requirements | `business/core.md` (Constraints, Architecture Decisions) |
| 8 | `jest.config.*`, `vitest.config.*`, `pytest.ini`, etc. | Test framework, coverage thresholds, test patterns | `business/core.md` (Architecture Decisions) |

### `production-strict` adds (all of production-lite, plus):

| Step | Read | Extract | Propose into |
|------|------|---------|--------------|
| 9 | `SECURITY.md`, `.snyk`, `.trivyignore`, `CODEOWNERS` | Security posture, vulnerability policies, code ownership | `business/core.md` (Constraints) and `business/market.md` (Risks) |
| 10 | `COMPLIANCE.md`, `GDPR.md`, `SOC2.md`, any `/compliance` dir | Regulatory requirements, data handling, audit trail needs | `business/core.md` (Constraints) and `business/market.md` (Risks) |
| 11 | Schema files, migration dirs, API specs / OpenAPI | Data model shape, API surface, integration points | `business/api-intelligence/foundation.md` and `business/database-intelligence/foundation.md` |

---

## Output Format

Present findings to the user like this:

```
I scanned your repo and learned the following. Please confirm or correct
before I save to business/:

[1] business/core.md → Business Overview
    Source: README.md (lines 1–4)
    Confidence: [system-generated]
    Proposed write:
      "{extracted text — usually a one-paragraph description}"

[2] business/core.md → Architecture Decisions
    Source: package.json (dependencies + scripts)
    Confidence: [system-generated]
    Proposed write:
      "{extracted text — e.g. 'Stack: Next.js 14 (App Router), Supabase, Vercel deploys'}"

[3] business/user-profile.md → Preferences
    Source: CONTRIBUTING.md (lines 12–18)
    Confidence: [system-generated]
    Proposed write:
      "{extracted text — e.g. 'Conventional commits, PRs require 1 review'}"

Reply with: approve all | approve 1,3 / skip 2 | corrections inline
```

---

## After the Scan

Run the gap detection from `FIRST_RUN.md` Step 4 — for each `business/` section that's still thin, pick a question from `QUESTIONS.md` and ask.

---

## Cross-References

Referenced from `FIRST_RUN.md`, `CONDUCTOR.md` §Existing Repo Bootstrap, and every IDE-specific instructions file.
