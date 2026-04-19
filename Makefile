# Conductor — top-level shortcuts
# Run `make help` to see what's available.

# Force bash — several targets use process substitution which dash doesn't support.
SHELL := /bin/bash

.PHONY: help preflight start resume status halt validate-state lint lint-bash lint-json lint-md orphan-check test version

help:
	@echo "Conductor (v$$(cat VERSION)) — make targets:"
	@echo ""
	@echo "  make preflight       — run orchestrator deep preflight"
	@echo "  make start           — first-time pipeline kickoff (creates state.jsonl)"
	@echo "  make resume          — resume orchestrator from last checkpoint"
	@echo "  make status          — show orchestrator state"
	@echo "  make halt            — write HALT checkpoint"
	@echo "  make validate-state  — verify state.jsonl integrity"
	@echo ""
	@echo "  make lint            — run all linters (bash + json + markdown)"
	@echo "  make lint-bash       — shellcheck on orchestrator scripts"
	@echo "  make lint-json       — jq empty on every JSON file (excl. Layer 1)"
	@echo "  make lint-md         — markdownlint on conductor-core + orchestrator"
	@echo "  make orphan-check    — verify every business/ file is referenced"
	@echo "  make test            — run conductor-core/test suite if present"
	@echo "  make version         — print current version"
	@echo ""

# ---- Orchestrator commands -------------------------------------------------

preflight:
	./orchestrator/conductor.sh preflight

start:
	./orchestrator/conductor.sh start

resume:
	./orchestrator/conductor.sh resume

status:
	./orchestrator/conductor.sh status

halt:
	./orchestrator/conductor.sh halt

validate-state:
	./orchestrator/conductor.sh validate-state

# ---- Linters ---------------------------------------------------------------

lint: lint-bash lint-json lint-md orphan-check

lint-bash:
	@if command -v shellcheck >/dev/null 2>&1; then \
	  shellcheck -S warning orchestrator/conductor.sh orchestrator/lib/*.sh \
	    conductor-core/activation/bootstrap.sh; \
	else \
	  echo "shellcheck not installed — skipping (install via 'brew install shellcheck')"; \
	  for f in orchestrator/conductor.sh orchestrator/lib/*.sh conductor-core/activation/bootstrap.sh; do \
	    bash -n "$$f" || exit 1; \
	  done; \
	  echo "  bash -n: all scripts parse"; \
	fi

lint-json:
	@if ! command -v jq >/dev/null 2>&1; then \
	  echo "jq required — install via 'brew install jq'"; exit 1; \
	fi
	@for f in $$(find . -name "*.json" \
	    -not -path "./agency-agents/*" \
	    -not -path "./gstack/*" \
	    -not -path "./promptfoo/*" \
	    -not -path "./node_modules/*"); do \
	  jq empty "$$f" || (echo "INVALID JSON: $$f" && exit 1); \
	done
	@echo "  All JSON files valid"

lint-md:
	@if command -v markdownlint >/dev/null 2>&1; then \
	  markdownlint 'conductor-core/**/*.md' 'orchestrator/**/*.md' '*.md' \
	    --ignore conductor-core/test \
	    --disable MD013 MD033 MD041 MD024 MD036 MD040; \
	else \
	  echo "markdownlint not installed — install via 'npm install -g markdownlint-cli'"; \
	fi

orphan-check:
	@missing=0; \
	while IFS= read -r f; do \
	  base="$$(basename "$$f")"; \
	  case "$$base" in README.md|ROUTING.md|FRAME_CONTROL_ALGORITHM.md|_template.md|.gitkeep) continue ;; esac; \
	  if ! grep -rq --exclude="$$base" "$$base" conductor-core/business/; then \
	    echo "  ORPHAN: $$f"; \
	    missing=$$((missing + 1)); \
	  fi; \
	done < <(find conductor-core/business -type f -name "*.md"); \
	if [ "$$missing" -gt 0 ]; then \
	  echo "Orphan check FAIL: $$missing file(s) not referenced"; exit 1; \
	fi; \
	echo "  Orphan check PASS"

test:
	@if [ -f conductor-core/test/conductor-test-runner.sh ]; then \
	  bash conductor-core/test/conductor-test-runner.sh; \
	else \
	  echo "No test runner present at conductor-core/test/conductor-test-runner.sh"; \
	fi

version:
	@cat VERSION
