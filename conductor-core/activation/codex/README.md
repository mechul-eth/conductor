# Codex CLI — Conductor Activation

Codex reads `AGENTS.md` (or `codex.md`) at the repo root on every session.

## Setup

```bash
cp conductor-core/activation/codex/AGENTS.md AGENTS.md
```

## First Session

```bash
codex
> Activate Conductor
```

Codex follows `conductor-core/activation/FIRST_RUN.md` on first activation and the contract in `AGENTS.md` on every subsequent session.

## Cross-References

Referenced from `conductor-core/activation/README.md`.
