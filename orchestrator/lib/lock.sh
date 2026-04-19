#!/usr/bin/env bash
# File-locking primitives for the conductor.
#
# Two concurrent runners can collide:
#   - The interactive IDE agent session (parent agent)
#   - The cron resumer
#
# We protect:
#   1. state.jsonl writes  (with_state_lock) -- fine-grained, per-append
#   2. The whole orchestrator loop (lock_master_acquire) -- coarse, per-run
#
# Stale locks (older than LOCK_STALE_SECS) are detected and broken.

readonly LOCK_DIR="${SCRIPT_DIR}/locks"
readonly LOCK_STATE_FILE="${LOCK_DIR}/state.lock"
readonly LOCK_MASTER_FILE="${LOCK_DIR}/master.lock"
readonly LOCK_STALE_SECS="${LOCK_STALE_SECS:-1800}"  # 30 min default

mkdir -p "${LOCK_DIR}"

# Break a lock file if its mtime is older than LOCK_STALE_SECS.
_break_stale_lock() {
  local lock_file="$1"
  [[ -f "${lock_file}" ]] || return 0
  local mtime now age
  if [[ "$(uname)" == "Darwin" ]]; then
    mtime="$(stat -f %m "${lock_file}" 2>/dev/null || echo 0)"
  else
    mtime="$(stat -c %Y "${lock_file}" 2>/dev/null || echo 0)"
  fi
  now="$(date +%s)"
  age=$((now - mtime))
  if (( age > LOCK_STALE_SECS )); then
    log_warn "lock" "Stale lock detected (${lock_file}, age=${age}s) -- breaking"
    rm -f "${lock_file}"
  fi
}

# Acquire master lock for the orchestrator loop.
# Returns 0 on acquire, 1 if another live orchestrator holds it.
lock_master_acquire() {
  _break_stale_lock "${LOCK_MASTER_FILE}"
  if [[ -f "${LOCK_MASTER_FILE}" ]]; then
    local owner_pid
    owner_pid="$(cat "${LOCK_MASTER_FILE}" 2>/dev/null || echo 0)"
    if [[ "${owner_pid}" != "$$" ]] && kill -0 "${owner_pid}" 2>/dev/null; then
      log_warn "lock" "Another orchestrator is running (pid=${owner_pid}) -- refusing to start"
      return 1
    fi
    log_warn "lock" "Orphaned master lock (pid=${owner_pid} not alive) -- reclaiming"
  fi
  echo "$$" > "${LOCK_MASTER_FILE}"
  log_info "lock" "Master lock acquired (pid=$$)"
  trap lock_master_release EXIT INT TERM
  return 0
}

lock_master_release() {
  if [[ -f "${LOCK_MASTER_FILE}" ]]; then
    local owner_pid
    owner_pid="$(cat "${LOCK_MASTER_FILE}" 2>/dev/null || echo 0)"
    if [[ "${owner_pid}" == "$$" ]]; then
      rm -f "${LOCK_MASTER_FILE}"
      log_info "lock" "Master lock released"
    fi
  fi
}

# Run a command holding the state lock. Falls back to mkdir-mutex if flock is absent.
with_state_lock() {
  _break_stale_lock "${LOCK_STATE_FILE}"
  if command -v flock >/dev/null 2>&1; then
    (
      flock -x -w 30 9 || { log_error "lock" "Could not acquire state lock within 30s"; exit 1; }
      "$@"
    ) 9>"${LOCK_STATE_FILE}"
  else
    local tries=0
    while ! mkdir "${LOCK_STATE_FILE}.d" 2>/dev/null; do
      tries=$((tries + 1))
      if (( tries > 60 )); then
        log_error "lock" "State mkdir-lock unobtainable after 60 tries -- proceeding without lock"
        break
      fi
      sleep 0.5
    done
    "$@"
    rmdir "${LOCK_STATE_FILE}.d" 2>/dev/null || true
  fi
}
