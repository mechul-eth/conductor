# First Run — Step-by-Step Runbook

> The agent (Claude Code, Copilot Chat, Cursor, etc.) follows this runbook the first time someone activates Conductor in a project. The user only answers questions — the agent does the work.

## Zero-Assumptions Principle

Conductor ships **without any knowledge** of the project's industry, business model, or terminology. It learns these from the user, in real time, through this runbook. Any industry list shown in this document (or in `QUESTIONS.md`) is a menu of choices — never a default Conductor assumes silently.

If the user picks "other" or skips a question, Conductor stays neutral until the next signal arrives. Never invent the business.

## Pre-flight (agent does this silently)

1. Detect the IDE/agent environment (read `.cursorrules`, `CLAUDE.md`, `.github/copilot-instructions.md` — whichever is present).
2. Confirm that `conductor-core/` is present.
3. Check whether `business/core.md` has any user-stated content. If yes → this is a return visit, skip to "Resume" at the bottom.

If we made it here, this is the first activation. Continue.

---

## Step 1 — Greet and explain (60 seconds)

Say to the user, in this exact spirit (paraphrase as needed):

> I'm activating Conductor for this project. To make every future session smarter, I'll learn what your business does, who you are, and how your team is structured. I'll do as much of the work as I can by scanning your repo, then I'll ask a few short questions to fill the gaps. Every fact I write to `business/` will be shown to you for approval first. Nothing leaves this repository.

Wait for acknowledgment. If they say "skip onboarding," go straight to Step 4 with empty `business/` files.

---

## Step 2 — Scan the existing repo

Run the Scan Checklist from `SCAN_CHECKLIST.md`. The agent reads (read-only, never modifies during the scan):

1. `README.md` / `README` — extract project description, tech stack, purpose.
2. `package.json` / `Cargo.toml` / `pyproject.toml` / `go.mod` / `Gemfile` — extract project name, dependencies, scripts.
3. `.env.example` / `docker-compose.yml` / infra configs — extract services used, deployment targets.
4. Top-level directory structure (2 levels deep) — extract organization pattern (monorepo, service-based, etc.).
5. `CONTRIBUTING.md` / `CODE_OF_CONDUCT.md` / `LICENSE` — team conventions, license type.
6. `docs/` or `wiki/` (first 5 files) — product docs, API docs.
7. (production-lite+) `.github/workflows/` / `.gitlab-ci.yml` — pipeline shape.
8. (production-strict) `SECURITY.md`, `COMPLIANCE.md`, schema files — compliance posture.

For each finding, build a single batch with:

- The proposed `business/` write (which file, which section, which content).
- The source file the finding came from.
- A confidence tag — `[system-generated]` or `[external]`.

---

## Step 3 — Present the scan as a batch

Show the user every proposed write as one approval moment, formatted like:

```
I scanned your repo and learned this. Approve, correct, or skip each:

→ business/core.md  Business Overview  [system-generated, from README.md]
  "{extracted text}"

→ business/core.md  Architecture Decisions  [system-generated, from package.json]
  "{extracted text}"

→ business/user-profile.md  Preferences  [system-generated, from CONTRIBUTING.md]
  "{extracted text}"

Reply: approve all | approve A,B / skip C | corrections inline
```

Apply approved writes to `business/` files. Tag every line with the source (e.g. `[system-generated, source: README.md L3-12]`).

---

## Step 4 — Ask the gap questions

Use the question bank from `QUESTIONS.md`. Ask only the gaps the scan didn't fill. Profile-aware:

| Profile | Mandatory questions |
|---------|---------------------|
| `learning` | Just one — "What are you building?" (skip rest, fill opportunistically) |
| `MVP` | Three — what, for whom, competitors |
| `production-lite` | Three + constraints + compliance scope |
| `production-strict` | All MVP + domain + regulatory + data sensitivity (mandatory) |

After each answer, propose the write. The user approves before it lands in `business/`.

---

## Step 5 — Wire `ROUTING.md` to their team

Ask:

> Who's on the team for this project? Pick from the list — I'll wire the role-to-context table accordingly. You can change this later in `business/ROUTING.md`.

Default options:

```
[ ] engineering-architect          [ ] product
[ ] engineering-backend            [ ] strategy
[ ] engineering-frontend           [ ] design
[ ] engineering-database           [ ] marketing
[ ] engineering-security           [ ] sales
[ ] engineering-devops             [ ] support
[ ] engineering-ai                 [ ] testing
                                   [ ] project-management
```

For each selected role, confirm the corresponding row in `business/ROUTING.md` exists. Remove rows for unselected roles (so the table stays honest).

---

## Step 6 — Wire intelligence domains (only what they need)

Ask:

> Which contracts matter for this project right now? I'll create the foundation file for each. Skip any you don't need — you can add them later.

```
[ ] api-intelligence            (you have an API surface)
[ ] backend-intelligence        (you have services / workers)
[ ] frontend-intelligence       (you have a UI)
[ ] database-intelligence       (you have persistence)
[ ] integration-intelligence    (you have cross-layer handshakes)
[ ] ai-usage-intelligence       (you use LLMs / ML)
[ ] release-readiness-intelligence (you ship to production)
```

For each selected domain: open the directory's `README.md`, prompt the user to fill in `foundation.md` (or fill it in jointly based on what the scan found). Don't force this — leaving `foundation.md` empty is fine; Conductor will ask again when a role activation needs it.

---

## Step 7 — Confirm activation and save the session

Write to `business/insights.md` under "Key Decisions":

```
### {YYYY-MM-DD} — Conductor activated
- Profile: {profile}                          [user-stated]
- Domain: {domain}                            [user-stated]
- Scenario: {scenario}                        [user-stated]
- Roles wired in ROUTING.md: {list}           [user-stated]
- Intelligence domains in scope: {list}       [user-stated]
- Repo scan: {N} facts extracted, {M} approved [system-generated]
```

Initialize session state per `CONDUCTOR.md` §Session Persistence Format.

Tell the user:

> Conductor is active. From now on every session loads what you just told me. To change anything, edit the files under `conductor-core/business/` directly — the structure is documented in each directory's README. To run a multi-phase pipeline, fill in `conductor-core/canonical_prompt.md` and pick a phase under `conductor-core/phases/`.

---

## Resume (return visit)

If `business/core.md` already has content:

1. Load the latest session state.
2. Skim `insights.md` for the most recent decisions.
3. Skim `business/ROUTING.md` to refresh role wiring.
4. Greet briefly: "Conductor is active. Last session: {short summary}. What's next?"

Skip the scan + question bank. The user can still trigger a re-scan anytime by saying "rescan" — useful when the codebase has changed significantly.

---

## Cross-References

This runbook is referenced from:

- `conductor-core/activation/README.md` (the human-readable activation overview)
- Every IDE-specific instructions file (`.github/copilot-instructions.md`, `CLAUDE.md`, etc. — generated by `bootstrap.sh`)
- `conductor-core/CONDUCTOR.md` §SESSION LIFECYCLE — Activation
- `conductor-core/conductor/README.md` — first-run detection logic
