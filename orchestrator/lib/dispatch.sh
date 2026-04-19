#!/usr/bin/env bash
# Dispatch a task to the assigned role(s).
#
# Two execution modes:
#   parent_agent  -- conductor writes DISPATCH_REQUESTED marker; parent IDE
#                    picks it up and runs the Task tool. Output lands in
#                    checkpoints/output_<task>_attempt_<n>.md.
#   cli           -- conductor invokes `claude --print` directly.
#
# Auto-detect: if CONDUCTOR_USE_CLI=1 and `claude` is installed, use cli;
# otherwise parent_agent.

readonly DISPATCH_WAIT_SECS="${DISPATCH_WAIT_SECS:-1800}"

dispatch_to_role() {
  local task_json="$1"
  local attempt="$2"
  local task_id role title
  task_id="$(echo "${task_json}" | jq -r '.id')"
  role="$(echo "${task_json}" | jq -r '.primary_role')"
  title="$(echo "${task_json}" | jq -r '.title')"

  log_info "dispatch" "Dispatching ${task_id} to role: ${role} (attempt ${attempt})"

  # 1. Resolve role bundle
  local role_bundle role_file
  role_bundle="$(resolve_role_bundle "${role}")"
  if [[ -z "${role_bundle}" ]]; then
    log_warn "dispatch" "Role ${role} not in manifest -- using generic"
    role_bundle="$(cat "${ROLES_DIR}/_generic.md")"
  fi
  role_file="$(mktemp -t "role_${role}_XXXX" 2>/dev/null || mktemp "/tmp/role_${role}_XXXX")"
  printf '%s\n' "${role_bundle}" > "${role_file}"

  # 2. Resolve task prompt body (optional -- pulls from prompts/ if present)
  local prompt_body_file="${SCRIPT_DIR}/prompts/task_${task_id//./_}.md"
  if [[ ! -f "${prompt_body_file}" ]] || [[ ! -s "${prompt_body_file}" ]]; then
    # Synthesize a minimal body from tasks.json if no pre-extracted prompt exists.
    prompt_body_file="$(mktemp -t "prompt_${task_id//./_}_XXXX" 2>/dev/null || mktemp "/tmp/prompt_${task_id//./_}_XXXX")"
    {
      echo "## Task Body (synthesized from tasks.json)"
      echo ""
      echo "$(echo "${task_json}" | jq -r '.description // .title')"
    } > "${prompt_body_file}"
  fi

  # 3. Build envelope
  local envelope output_file
  envelope="${SCRIPT_DIR}/checkpoints/dispatch_${task_id//./_}_attempt_${attempt}.md"
  output_file="${SCRIPT_DIR}/checkpoints/output_${task_id//./_}_attempt_${attempt}.md"
  build_dispatch_envelope "${task_json}" "${role_file}" "${prompt_body_file}" "${attempt}" > "${envelope}"
  log_info "dispatch" "Envelope: ${envelope}"
  rm -f "${role_file}"

  # 4. Pick execution path
  local mode="${CONDUCTOR_DISPATCH_MODE:-auto}"
  if [[ "${mode}" == "auto" ]]; then
    if [[ "${CONDUCTOR_USE_CLI:-0}" == "1" ]] && command -v claude >/dev/null 2>&1; then
      mode="cli"
    else
      mode="parent_agent"
    fi
  fi

  case "${mode}" in
    cli)          _dispatch_via_cli "${envelope}" "${output_file}" "${task_id}" ;;
    parent_agent) _dispatch_via_parent_agent "${envelope}" "${output_file}" "${task_id}" ;;
    *)
      log_error "dispatch" "Unknown CONDUCTOR_DISPATCH_MODE=${mode}"
      return 1
      ;;
  esac
}

_dispatch_via_cli() {
  local envelope="$1" output_file="$2" task_id="$3"
  log_info "dispatch" "Mode=cli -- invoking claude --print"
  if claude --print --dangerously-skip-permissions < "${envelope}" > "${output_file}" 2>&1; then
    _parse_dispatch_output "${output_file}" "${task_id}"
  else
    log_error "dispatch" "Claude CLI exited non-zero (output: ${output_file})"
    return 1
  fi
}

_dispatch_via_parent_agent() {
  local envelope="$1" output_file="$2" task_id="$3"
  local marker="${SCRIPT_DIR}/checkpoints/DISPATCH_REQUESTED"

  cat <<EOF > "${marker}"
TASK_ID: ${task_id}
ENVELOPE: ${envelope}
OUTPUT_FILE: ${output_file}
REQUESTED_AT: $(date -u +%Y-%m-%dT%H:%M:%SZ)
TIMEOUT_SECS: ${DISPATCH_WAIT_SECS}

The parent agent must:
  1. Read the envelope at the path above.
  2. Invoke the appropriate subagent via the Task tool, passing the envelope
     contents as the prompt. Default subagent_type: 'general-purpose'.
  3. Write the subagent's full response to OUTPUT_FILE.
  4. Delete this DISPATCH_REQUESTED marker.

The conductor will block (polling) until the marker is deleted OR
TIMEOUT_SECS elapses.
EOF

  log_warn "dispatch" "Mode=parent_agent -- waiting for parent to handle ${marker} (timeout ${DISPATCH_WAIT_SECS}s)"

  local elapsed=0 poll=10
  while [[ -f "${marker}" ]]; do
    sleep "${poll}"
    elapsed=$((elapsed + poll))
    if (( elapsed % 60 == 0 )); then
      log_info "dispatch" "Still waiting on parent agent (${elapsed}s elapsed)"
    fi
    if (( elapsed >= DISPATCH_WAIT_SECS )); then
      log_error "dispatch" "Parent agent did not respond within ${DISPATCH_WAIT_SECS}s"
      rm -f "${marker}"
      return 1
    fi
  done

  if [[ ! -f "${output_file}" ]] || [[ ! -s "${output_file}" ]]; then
    log_error "dispatch" "Parent removed marker but no output file at ${output_file}"
    return 1
  fi

  _parse_dispatch_output "${output_file}" "${task_id}"
}

_parse_dispatch_output() {
  local output_file="$1" task_id="$2"
  if grep -q "^TASK_RESULT: PASS" "${output_file}"; then
    log_info "dispatch" "Role returned PASS for ${task_id}"
    return 0
  elif grep -q "^TASK_RESULT: FAIL" "${output_file}"; then
    log_warn "dispatch" "Role returned explicit FAIL for ${task_id}"
    return 1
  else
    log_error "dispatch" "No TASK_RESULT marker in ${output_file} -- refusing to assume PASS"
    return 1
  fi
}

# Build the dispatch envelope -- role activation + context + task + output schema.
build_dispatch_envelope() {
  local task_json="$1" role_file="$2" prompt_body_file="$3" attempt="$4"
  local task_id sprint
  task_id="$(echo "${task_json}" | jq -r '.id')"
  sprint="$(echo "${task_json}" | jq -r '.sprint // "no-sprint"')"

  # Recent context for role continuity
  local recent_summary
  if declare -F state_get_completed_summary >/dev/null 2>&1; then
    recent_summary="$(state_get_completed_summary 3 2>/dev/null || echo '(none)')"
  else
    recent_summary="(state.sh not loaded)"
  fi
  [[ -z "${recent_summary}" ]] && recent_summary="(no prior COMPLETED tasks)"

  local max_retries
  max_retries="$(jq -r '.global_constraints.max_retries_per_task // 3' "${TASKS_FILE}")"

  cat <<EOF
# DISPATCH ENVELOPE -- TASK ${task_id} (attempt ${attempt})

## 0. MANDATORY RE-GROUNDING

Read these files before doing anything else:
1. \`${REPO_ROOT}/conductor-core/CONDUCTOR.md\` -- supreme policy
2. \`${REPO_ROOT}/conductor-core/business/ROUTING.md\` -- role-context routing
3. \`${REPO_ROOT}/conductor-core/business/core.md\` -- project context (always first)

## 1. ROLE ACTIVATION

$(cat "${role_file}")

## 2. COLLABORATORS

You may consult these roles via the Task tool if you need a second opinion:
$(echo "${task_json}" | jq -r '.collaborators[]?' | sed 's/^/- /')

## 3. CONTEXT

- Task ID:   ${task_id}
- Sprint:    ${sprint}
- Title:     $(echo "${task_json}" | jq -r '.title')
- Repo root: ${REPO_ROOT}
- Attempt:   ${attempt} of ${max_retries}

### Recent completed tasks (for continuity)

\`\`\`jsonl
${recent_summary}
\`\`\`

## 4. TASK BODY

$(cat "${prompt_body_file}")

## 5. ACCEPTANCE CRITERIA (verify each one)

$(echo "${task_json}" | jq -r '.acceptance_criteria[]?' | sed 's/^/- [ ] /')

You MUST report on each criterion individually in section 8 below.

## 6. WORLD-CLASS THINKING

Before declaring success, answer these:
1. What would a top-tier team ship for this?
2. What CRUD/lifecycle actions does a real user need? (add/edit/delete/archive/assign/share/export/duplicate)
3. What states exist? (empty/loading/error/success)
4. What essential small details? (keyboard shortcuts, accessibility, optimistic UI, undo)

If any answer reveals a gap, FIX IT before reporting success.

## 7. FAILURE POLICY

- On error, do NOT proceed past the failure point
- Do NOT assume -- verify against codebase or DB
- Do NOT bypass any quality gate
- If blocked, write detailed blocker context to \`${BLOCKER_DIR}/${task_id}.md\`
- If you detect credentials in any output, REDACT immediately and halt

## 8. OUTPUT FORMAT (REQUIRED -- machine-parsed)

End your response with this exact structure on its own lines:

For each acceptance criterion, replace the leading marker with either:
  \`[✓]\` (met) or \`[x]\` (failed). Do NOT leave \`[ ]\` (empty brackets).

\`\`\`
ACCEPTANCE_CRITERIA_REPORT:
$(echo "${task_json}" | jq -r '.acceptance_criteria[]?' | sed 's/^/- [ ] /')

WORLD_STANDARD_REPORT:
- Q1 (top-tier ship): <answer or "n/a (infrastructure)">
- Q2 (CRUD lifecycle): <answer or "n/a">
- Q3 (states):         <answer or "n/a">
- Q4 (small details):  <answer or "n/a">
\`\`\`

Then EXACTLY ONE of these lines:

\`\`\`
TASK_RESULT: PASS
\`\`\`

OR

\`\`\`
TASK_RESULT: FAIL
REASON: <one-sentence explanation>
NEXT_ACTION: <retry|consensus|escalate>
\`\`\`

Begin now.
EOF
}

# Resolve a role key from manifest.json into a concatenated role bundle.
# Supports local canonical files (internal roles) + external URLs (supplemental).
resolve_role_bundle() {
  local role_key="$1"
  local manifest="${ROLES_DIR}/manifest.json"
  [[ -f "${manifest}" ]] || return 1

  local role_json
  role_json="$(jq --arg k "${role_key}" '.roles[$k] // empty' "${manifest}")"
  if [[ -z "${role_json}" ]] || [[ "${role_json}" == "null" ]]; then return 1; fi

  local local_canonical supplemental_list external_url notes priority
  local_canonical="$(echo "${role_json}" | jq -r '.local_canonical // empty')"
  supplemental_list="$(echo "${role_json}" | jq -r '.supplemental // [] | .[]')"
  external_url="$(echo "${role_json}" | jq -r '.external_url // empty')"
  notes="$(echo "${role_json}" | jq -r '.notes // empty')"
  priority="$(echo "${role_json}" | jq -r '.priority // "P2"')"

  echo "## ROLE: ${role_key} (priority: ${priority})"
  echo ""
  echo "Resolution: local_canonical=${local_canonical:-none}; external_url=${external_url:-none}"
  if [[ -n "${notes}" ]]; then
    echo ""
    echo "**Notes for this task context:** ${notes}"
  fi
  echo ""
  echo "---"
  echo ""

  # Resolve local canonical path relative to orchestrator/roles/ (then relative to orchestrator/ itself)
  local resolved_local=""
  if [[ -n "${local_canonical}" ]]; then
    if [[ -f "${ROLES_DIR}/${local_canonical}" ]]; then
      resolved_local="${ROLES_DIR}/${local_canonical}"
    elif [[ -f "${SCRIPT_DIR}/${local_canonical}" ]]; then
      resolved_local="${SCRIPT_DIR}/${local_canonical}"
    elif [[ -f "${REPO_ROOT}/${local_canonical}" ]]; then
      resolved_local="${REPO_ROOT}/${local_canonical}"
    fi
  fi

  if [[ -n "${resolved_local}" ]]; then
    echo "### Canonical Role Definition"
    echo ""
    cat "${resolved_local}"
    echo ""
  fi

  for supp in ${supplemental_list}; do
    local resolved_supp=""
    if [[ -f "${ROLES_DIR}/${supp}" ]]; then
      resolved_supp="${ROLES_DIR}/${supp}"
    elif [[ -f "${SCRIPT_DIR}/${supp}" ]]; then
      resolved_supp="${SCRIPT_DIR}/${supp}"
    elif [[ -f "${REPO_ROOT}/${supp}" ]]; then
      resolved_supp="${REPO_ROOT}/${supp}"
    fi
    if [[ -n "${resolved_supp}" ]]; then
      echo "### Supplemental: ${supp##*/}"
      echo ""
      cat "${resolved_supp}"
      echo ""
    fi
  done

  if [[ -n "${external_url}" ]]; then
    echo "### External Reference"
    echo ""
    echo "Source: ${external_url}"
    echo ""
    echo "External role definitions are referenced by URL. Conductor policies"
    echo "(from CONDUCTOR.md) apply unconditionally -- external roles obey"
    echo "deterministic-first, minimum-role-set, and no-silent-scope-expansion."
    echo ""
  fi
}
