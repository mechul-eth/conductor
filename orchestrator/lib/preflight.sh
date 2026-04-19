#!/usr/bin/env bash
# Preflight checks -- environment readiness.
#
# basic: cheap, fast checks run on every conductor.sh invocation.
# deep:  expensive checks; run via `./conductor.sh preflight` before kickoff.

preflight_basic() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required. Install via 'brew install jq' or 'apt install jq'." >&2
    exit 1
  fi
}

preflight_deep() {
  log_info "preflight" "Running deep preflight"

  local errors=0

  # 1. Required CLIs
  for cmd in jq bash; do
    if command -v "${cmd}" >/dev/null 2>&1; then
      log_info "preflight" "  found: ${cmd}"
    else
      log_error "preflight" "  MISSING: ${cmd}"
      errors=$((errors + 1))
    fi
  done

  # 2. tasks.json present and valid JSON
  if [[ -f "${TASKS_FILE}" ]]; then
    if jq empty "${TASKS_FILE}" >/dev/null 2>&1; then
      local task_count
      task_count="$(jq '.tasks | length' "${TASKS_FILE}")"
      log_info "preflight" "  tasks.json: ${task_count} tasks declared"
    else
      log_error "preflight" "  tasks.json: NOT VALID JSON"
      errors=$((errors + 1))
    fi
  else
    log_error "preflight" "  tasks.json: NOT FOUND (copy tasks.example.json)"
    errors=$((errors + 1))
  fi

  # 3. roles/manifest.json present and valid
  local manifest="${ROLES_DIR}/manifest.json"
  if [[ -f "${manifest}" ]] && jq empty "${manifest}" >/dev/null 2>&1; then
    local role_count
    role_count="$(jq '.roles | length' "${manifest}")"
    log_info "preflight" "  roles/manifest.json: ${role_count} role keys mapped"
  else
    log_error "preflight" "  roles/manifest.json: missing or invalid"
    errors=$((errors + 1))
  fi

  # 4. lib/ scripts present
  for f in log lock state notify gates dispatch blocker compact world_standard; do
    if [[ -f "${LIB_DIR}/${f}.sh" ]]; then
      log_info "preflight" "  lib/${f}.sh: present"
    else
      log_error "preflight" "  lib/${f}.sh: MISSING"
      errors=$((errors + 1))
    fi
  done

  # 5. Optional CLIs
  if command -v flock >/dev/null 2>&1; then
    log_info "preflight" "  flock: present (preferred lock mechanism)"
  else
    log_warn "preflight" "  flock: not present (mkdir-mutex fallback active)"
  fi
  if command -v claude >/dev/null 2>&1; then
    log_info "preflight" "  claude CLI: present (cli dispatch mode available)"
  else
    log_warn "preflight" "  claude CLI: not present (parent_agent dispatch mode required)"
  fi
  if command -v shellcheck >/dev/null 2>&1; then
    log_info "preflight" "  shellcheck: present"
  fi

  # 6. State integrity (if state.jsonl exists)
  if [[ -f "${STATE_FILE}" ]]; then
    if state_validate; then
      log_info "preflight" "  state.jsonl: valid"
    else
      log_error "preflight" "  state.jsonl: corrupt"
      errors=$((errors + 1))
    fi
  fi

  echo ""
  if (( errors == 0 )); then
    log_info "preflight" "PREFLIGHT: PASS"
    return 0
  else
    log_error "preflight" "PREFLIGHT: ${errors} ERROR(S)"
    return 1
  fi
}
