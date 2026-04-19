# Aider — Conductor Activation

Aider uses `.aider.conf.yml` for configuration and a convention file for per-session instructions.

## Setup

```bash
cp conductor-core/activation/aider/.aider.conf.yml .aider.conf.yml
cp conductor-core/activation/aider/CONVENTIONS.md CONVENTIONS.md
```

Launch aider in the repo root — it reads both files automatically:

```bash
aider
```

First time: say "Activate Conductor." Aider follows `conductor-core/activation/FIRST_RUN.md`.

## Cross-References

Referenced from `conductor-core/activation/README.md`.
