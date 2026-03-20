# Contributing to MG_MODE

MG_MODE has two layers, and contributions go to different places depending on which part you're working on. This guide tells you where.

---

## Code of Conduct

Please read and follow the [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

---

## Where things live

```
MG_MODE/
├── agency-agents/   ← Layer 1: 156+ role definitions (upstream: msitarzewski/agency-agents)
├── gstack/          ← Layer 1: 21 workflow skills (upstream: garrytan/gstack)
├── promptfoo/       ← Layer 1: 85+ validation plugins (upstream: promptfoo/promptfoo)
└── mg-mode-core/    ← Layer 2: The routing brain — this is what MG_MODE adds
```

**Layer 1 libraries are read-only in this repo.** They have their own maintainers and contribution processes. If you want to improve a gstack skill, submit that PR to garrytan/gstack. If you want a new agent role, submit it to msitarzewski/agency-agents.

**Layer 2 (`mg-mode-core/`) is where MG_MODE-specific contributions go.** Routing logic, session state, governance gates, profiles, registry, conductor — all of that lives here.

---

## Reporting a bug

Open a [GitHub issue](https://github.com/mustafaaksoz/MG_MODE/issues) with:

- What you were trying to do
- What happened instead
- Your IDE and agent (e.g. VS Code + Copilot, Claude Code, Cursor)
- Your profile (learning / MVP / production-lite / production-strict)
- Any error messages or unexpected output

The more specific you are, the faster it gets fixed.

---

## Suggesting something new

**New agent role:** Check [mg-mode-core/registry/README.md](mg-mode-core/registry/README.md) first — it probably already exists. If not, open an issue describing the use case. If it belongs in agency-agents (a general-purpose specialist), the contribution goes upstream.

**New gstack skill:** That goes to [garrytan/gstack](https://github.com/garrytan/gstack).

**New orchestration component** (routing rule, governance logic, session behavior): Open an issue first. Explain the problem it solves and what would break without it.

---

## Submitting a pull request

1. Fork the repo and create a branch from `main`
2. Make changes in `mg-mode-core/` only — do not modify Layer 1 directories
3. Run the test suite:
   ```bash
   bash mg-mode-core/test/mg-mode-test-runner.sh
   ```
   All 72 checks must pass.
4. Open a PR against `main` with a clear description of what changed and why

The PR template will walk you through the checklist.

---

## What we accept

- Bug fixes in routing, session state, governance gates, or conductor flow
- New registry entries with a real backing file in `agency-agents/`
- Profile improvements (budget thresholds, validation group tuning)
- Documentation improvements in `mg-mode-core/`
- IDE compatibility fixes in `activation/bootstrap.sh`
- Test coverage additions in `mg-mode-core/test/`

## What we don't accept

- Changes to Layer 1 files (`agency-agents/`, `gstack/`, `promptfoo/`) — those go upstream
- New compiled dependencies — MG_MODE is markdown-based by design
- Role additions without a demonstrated use case and a backing file in `agency-agents/`
- Changes that bypass governance gates or budget caps without explicit user consent

---

## Style notes

- Markdown files: match the existing heading structure and table format
- Registry entries: follow the fingerprint schema in [mg-mode-core/registry/README.md](mg-mode-core/registry/README.md)
- Shell scripts: `#!/usr/bin/env bash`, error handling, works on macOS and Linux
- Test files go in `mg-mode-core/test/`

---

## Security issues

Don't open a public issue for security vulnerabilities. See [SECURITY.md](SECURITY.md) for how to report them privately.

---

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE). Layer 1 projects keep their own licenses — see each subdirectory for details.
