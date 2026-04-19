#!/usr/bin/env bash
# Append-only checkpoint ledger (state.jsonl).
# Each line: {timestamp, task_id, status, attempt, gate_results, message}

state_init() {
  local first_task
  first_task="$(jq -r '.tasks[0].id' "${TASKS_FILE}")"
  state_append "${first_task}" "PENDING" 0 "{}" "Conductor initialized"
  log_info "state" "Initialized with first task: ${first_task}"
}

# Internal append (no idempotency) -- protected by file lock.
_state_append_unsafe() {
  local task_id="$1" status="$2" attempt="$3" gate_results="$4" message="$5"
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local entry
  entry=$(jq -nc \
    --arg ts "${ts}" \
    --arg task_id "${task_id}" \
    --arg status "${status}" \
    --argjson attempt "${attempt}" \
    --argjson gate_results "${gate_results}" \
    --arg message "${message}" \
    '{timestamp: $ts, task_id: $task_id, status: $status, attempt: $attempt, gate_results: $gate_results, message: $message}')

  if [[ -f "${STATE_FILE}" ]]; then
    cp "${STATE_FILE}" "${STATE_FILE}.bak"
  fi
  echo "${entry}" >> "${STATE_FILE}"
}

state_append() {
  local task_id="$1" status="$2" attempt="$3" gate_results="$4" message="$5"
  if declare -F with_state_lock >/dev/null 2>&1; then
    with_state_lock _state_append_unsafe "${task_id}" "${status}" "${attempt}" "${gate_results}" "${message}"
  else
    _state_append_unsafe "${task_id}" "${status}" "${attempt}" "${gate_results}" "${message}"
  fi
}

# Refuse to write the exact same (task_id, status, attempt) twice within 60s.
state_append_idempotent() {
  local task_id="$1" status="$2" attempt="$3" gate_results="$4" message="$5"
  if [[ -f "${STATE_FILE}" ]]; then
    local last_match now last_ts age
    last_match="$(grep "\"task_id\":\"${task_id}\"" "${STATE_FILE}" | grep "\"status\":\"${status}\"" | grep "\"attempt\":${attempt}" | tail -n 1)"
    if [[ -n "${last_match}" ]]; then
      last_ts="$(echo "${last_match}" | jq -r '.timestamp' 2>/dev/null || echo "")"
      if [[ -n "${last_ts}" ]]; then
        local last_epoch=0
        if last_epoch="$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "${last_ts}" +%s 2>/dev/null)"; then :; else
          last_epoch="$(date -u -d "${last_ts}" +%s 2>/dev/null || echo 0)"
        fi
        now="$(date -u +%s)"
        age=$((now - last_epoch))
        if (( age < 60 )); then
          log_warn "state" "Duplicate ${task_id}/${status}/${attempt} within ${age}s -- refusing (idempotency guard)"
          return 0
        fi
      fi
    fi
  fi
  state_append "${task_id}" "${status}" "${attempt}" "${gate_results}" "${message}"
}

# Determine the next task.
# Returns: task_id | "ALL_DONE" | "HALT" | "ESCALATED"
state_get_next_task() {
  if [[ ! -f "${STATE_FILE}" ]]; then
    jq -r '.tasks[0].id' "${TASKS_FILE}"
    return
  fi

  local last_status last_task
  last_status="$(tail -n 1 "${STATE_FILE}" | jq -r '.status')"
  last_task="$(tail -n 1 "${STATE_FILE}" | jq -r '.task_id')"

  case "${last_status}" in
    HALT)       echo "HALT"; return ;;
    ESCALATED)  echo "ESCALATED"; return ;;
    ALL_DONE)   echo "ALL_DONE"; return ;;
  esac

  if [[ "${last_status}" == "COMPLETED" ]]; then
    local next
    next="$(jq -r --arg id "${last_task}" '
      .tasks as $t |
      ($t | map(.id) | index($id)) as $idx |
      if ($idx + 1) < ($t | length) then $t[$idx + 1].id else "ALL_DONE" end
    ' "${TASKS_FILE}")"
    echo "${next}"
    return
  fi

  echo "${last_task}"
}

state_is_completed() {
  local task_id="$1"
  [[ -f "${STATE_FILE}" ]] || return 1
  grep -q "\"task_id\":\"${task_id}\".*\"status\":\"COMPLETED\"" "${STATE_FILE}"
}

state_get_attempt() {
  local task_id="$1"
  if [[ ! -f "${STATE_FILE}" ]]; then echo 0; return; fi
  grep "\"task_id\":\"${task_id}\"" "${STATE_FILE}" | jq -s 'map(.attempt) | max // 0'
}

state_deps_satisfied() {
  local task_id="$1"
  local deps
  deps="$(jq -r --arg id "${task_id}" '.tasks[] | select(.id == $id) | .depends_on[]?' "${TASKS_FILE}")"
  for dep in ${deps}; do
    if ! grep -q "\"task_id\":\"${dep}\".*\"status\":\"COMPLETED\"" "${STATE_FILE}" 2>/dev/null; then
      log_warn "state" "Dependency ${dep} not COMPLETED for task ${task_id}"
      return 1
    fi
  done
  return 0
}

state_validate() {
  [[ -f "${STATE_FILE}" ]] || return 0
  local line_no=0 bad=0
  while IFS= read -r line; do
    line_no=$((line_no + 1))
    [[ -z "${line}" ]] && continue
    if ! echo "${line}" | jq -e 'has("timestamp") and has("task_id") and has("status") and has("attempt")' >/dev/null 2>&1; then
      log_error "state" "Malformed JSONL line ${line_no}: ${line:0:120}"
      bad=$((bad + 1))
    fi
  done < "${STATE_FILE}"
  if (( bad > 0 )); then
    log_error "state" "${bad} malformed line(s) in state.jsonl"
    return 1
  fi
  log_info "state" "state.jsonl validate PASS (${line_no} entries)"
  return 0
}

# Last N COMPLETED checkpoints -- used by dispatch to give role continuity.
state_get_completed_summary() {
  local n="${1:-3}"
  [[ -f "${STATE_FILE}" ]] || return 0
  grep '"status":"COMPLETED"' "${STATE_FILE}" | tail -n "${n}" | jq -c '{task: .task_id, ts: .timestamp, msg: .message}'
}
