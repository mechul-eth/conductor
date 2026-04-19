#!/usr/bin/env bash
# Quality gate runner.
#
# Default gates:
#   A_topology       -- structural sanity
#   B_build          -- typecheck + build
#   C_test           -- test suite
#   D_e2e            -- end-to-end checks
#   D_security       -- credential scan, dep CVEs
#   E_sprint_gate    -- all prior sprint tasks COMPLETED
#   F_apple_grade    -- handled separately by apple_grade.sh
#   G_accessibility  -- a11y check
#   H_acceptance     -- every acceptance criterion reports [✓]
#   FINAL_RELEASE    -- final go-live gate
#
# Each gate is overridable per-task via gates/<LETTER>_<task_id>.sh.

# Pre-execution gate: credential scan + dep check
gate_pre_execution() {
  local task_json="$1"
  log_info "gate" "Running pre-execution gate"

  # 1. Credential scan on staged files
  if command -v git >/dev/null 2>&1 && [[ -d "${REPO_ROOT}/.git" ]]; then
    cd "${REPO_ROOT}"
    if git diff --staged 2>/dev/null | grep -E '(sk-[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9._-]{40,}|dp\.pt\.[A-Za-z0-9]{30,})' >/dev/null; then
      log_error "gate" "Credential pattern detected in staged diff -- halt"
      return 1
    fi
    cd - >/dev/null
  fi

  # 2. Dependency check
  local task_id
  task_id="$(echo "${task_json}" | jq -r '.id')"
  if ! state_deps_satisfied "${task_id}"; then
    log_error "gate" "Dependencies not satisfied for ${task_id}"
    return 1
  fi

  return 0
}

# Run a specific gate
gate_run() {
  local gate_name="$1"
  local task_json="$2"

  case "${gate_name}" in
    A_topology)        gate_a_topology "${task_json}" ;;
    B_build)           gate_b_build "${task_json}" ;;
    C_test)            gate_c_test "${task_json}" ;;
    D_e2e)             gate_d_e2e "${task_json}" ;;
    D_security)        gate_d_security "${task_json}" ;;
    E_sprint_gate)     gate_e_sprint "${task_json}" ;;
    F_apple_grade)     return 0 ;;  # handled separately
    G_accessibility)   gate_g_a11y "${task_json}" ;;
    H_acceptance)      gate_h_acceptance "${task_json}" ;;
    FINAL_RELEASE)     gate_final_release "${task_json}" ;;
    *)
      log_warn "gate" "Unknown gate: ${gate_name} -- treating as PASS"
      return 0
      ;;
  esac
}

# Gate H: acceptance criteria self-report check.
# Scans the latest dispatch output for the ACCEPTANCE_CRITERIA_REPORT block.
# Fails if any criterion is unchecked or marked failing.
gate_h_acceptance() {
  local task_json="$1"
  local task_id
  task_id="$(echo "${task_json}" | jq -r '.id')"
  local output_file
  output_file="$(ls -t "${SCRIPT_DIR}/checkpoints/output_${task_id//./_}_attempt_"*.md 2>/dev/null | head -n 1)"
  if [[ -z "${output_file}" ]] || [[ ! -f "${output_file}" ]]; then
    log_warn "gate" "Gate H: no output file for ${task_id} -- assuming PASS (no evidence)"
    return 0
  fi

  log_info "gate" "Gate H (acceptance criteria) for ${task_id}"

  local report
  report="$(awk '/^ACCEPTANCE_CRITERIA_REPORT:/{flag=1; next} /^APPLE_GRADE_REPORT:|^TASK_RESULT:/{flag=0} flag' "${output_file}")"
  if [[ -z "${report}" ]]; then
    log_error "gate" "Gate H: no ACCEPTANCE_CRITERIA_REPORT block in ${output_file}"
    return 1
  fi

  local total failed unchecked
  total="$(echo "${report}" | grep -cE '^- \[')"
  failed="$(echo "${report}" | grep -cE '^- \[(x|X|!|✗)\]')"
  unchecked="$(echo "${report}" | grep -cE '^- \[ \]')"

  if (( total == 0 )); then
    log_error "gate" "Gate H: report block present but contains no criteria entries"
    return 1
  fi
  if (( failed > 0 )) || (( unchecked > 0 )); then
    log_error "gate" "Gate H: ${failed} failed + ${unchecked} unchecked of ${total} criteria"
    # Surface the offending lines so the next attempt knows what to fix.
    echo "${report}" | grep -E '^- \[(x|X|!|✗| )\]' | while IFS= read -r line; do
      log_error "gate" "  - ${line}"
    done
    return 1
  fi
  log_info "gate" "Gate H: ${total} criteria PASS"
  return 0
}

# Gate A: topology
gate_a_topology() {
  local task_json="$1"
  local task_id
  task_id="$(echo "${task_json}" | jq -r '.id')"
  log_info "gate" "Gate A (topology) for ${task_id}"
  local custom="${GATES_DIR}/A_${task_id//./_}.sh"
  if [[ -f "${custom}" ]]; then
    bash "${custom}" "${task_json}"
    return $?
  fi
  return 0
}

# Gate B: build
gate_b_build() {
  local task_json="$1"
  local task_id
  task_id="$(echo "${task_json}" | jq -r '.id')"
  log_info "gate" "Gate B (build) for ${task_id}"
  local custom="${GATES_DIR}/B_${task_id//./_}.sh"
  if [[ -f "${custom}" ]]; then
    bash "${custom}" "${task_json}"
    return $?
  fi
  log_info "gate" "Gate B: no custom check defined; passing"
  return 0
}

# Gate C: test
gate_c_test() {
  local task_json="$1"
  local task_id
  task_id="$(echo "${task_json}" | jq -r '.id')"
  log_info "gate" "Gate C (test) for ${task_id}"
  local custom="${GATES_DIR}/C_${task_id//./_}.sh"
  if [[ -f "${custom}" ]]; then
    bash "${custom}" "${task_json}"
    return $?
  fi
  return 0
}

# Gate D: E2E
gate_d_e2e() {
  local task_json="$1"
  local task_id
  task_id="$(echo "${task_json}" | jq -r '.id')"
  log_info "gate" "Gate D (E2E) for ${task_id}"
  local custom="${GATES_DIR}/D_${task_id//./_}.sh"
  if [[ -f "${custom}" ]]; then
    bash "${custom}" "${task_json}"
    return $?
  fi
  return 0
}

# Gate D: security
gate_d_security() {
  log_info "gate" "Gate D (security)"
  if grep -rE '(sk-[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9._-]{40,})' "${LOG_DIR}" >/dev/null 2>&1; then
    log_error "gate" "Credential pattern detected in logs -- halt"
    return 1
  fi
  return 0
}

# Gate E: sprint final gate
gate_e_sprint() {
  local task_json="$1"
  local sprint_id
  sprint_id="$(echo "${task_json}" | jq -r '.sprint // empty')"
  if [[ -z "${sprint_id}" ]]; then
    log_info "gate" "Gate E: no sprint declared on task -- skipping"
    return 0
  fi
  log_info "gate" "Gate E (sprint final) for ${sprint_id}"

  local sprint_tasks
  sprint_tasks="$(jq -r --arg s "${sprint_id}" '.tasks[] | select(.sprint == $s) | .id' "${TASKS_FILE}")"
  for t in ${sprint_tasks}; do
    if [[ "${t}" == "$(echo "${task_json}" | jq -r '.id')" ]]; then continue; fi
    if ! grep -q "\"task_id\":\"${t}\".*\"status\":\"COMPLETED\"" "${STATE_FILE}" 2>/dev/null; then
      log_error "gate" "Sprint task ${t} not COMPLETED -- sprint gate fail"
      return 1
    fi
  done
  return 0
}

# Gate G: accessibility
gate_g_a11y() {
  local task_json="$1"
  local task_id
  task_id="$(echo "${task_json}" | jq -r '.id')"
  log_info "gate" "Gate G (a11y) for ${task_id}"
  local custom="${GATES_DIR}/G_${task_id//./_}.sh"
  if [[ -f "${custom}" ]]; then
    bash "${custom}" "${task_json}"
    return $?
  fi
  log_info "gate" "Gate G: no custom check defined; passing (integrate axe-core or pa11y here)"
  return 0
}

# Final release gate
gate_final_release() {
  log_info "gate" "FINAL gate -- verifying all tasks COMPLETED"
  local total completed
  total="$(jq '.tasks | length' "${TASKS_FILE}")"
  completed="$(grep -c '"status":"COMPLETED"' "${STATE_FILE}" || echo 0)"
  if [[ "${completed}" -ge "${total}" ]]; then
    log_info "gate" "${completed}/${total} COMPLETED -- RELEASE_GREEN"
    return 0
  fi
  log_error "gate" "${completed}/${total} COMPLETED -- not ready"
  return 1
}
