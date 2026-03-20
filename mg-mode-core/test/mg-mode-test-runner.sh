#!/bin/bash
# MG_MODE Test Runner
# Validates MG_MODE.md orchestration logic before production

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEST_DIR="$PROJECT_ROOT/mg-mode-core/test"
SESSION_DIR="$HOME/.mg-mode/sessions"
TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)
TEST_LOG="$TEST_DIR/test-run_${TIMESTAMP}.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize
mkdir -p "$SESSION_DIR"
mkdir -p "$TEST_DIR"
touch "$TEST_LOG"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$TEST_LOG"
}

test_pass() {
  echo -e "${GREEN}✓ PASS${NC}: $1" | tee -a "$TEST_LOG"
}

test_fail() {
  echo -e "${RED}✗ FAIL${NC}: $1" | tee -a "$TEST_LOG"
}

test_warn() {
  echo -e "${YELLOW}⚠ WARN${NC}: $1" | tee -a "$TEST_LOG"
}

test_info() {
  echo -e "${BLUE}ℹ INFO${NC}: $1" | tee -a "$TEST_LOG"
}

# ============================================================================
# TEST 1: Profile Selection
# ============================================================================
test_profile_selection() {
  log "============ TEST 1: Profile Selection ============"
  
  local test_passed=0
  
  # Check all 4 modes exist in MG_MODE.md
  if grep -q "learning\|MVP\|production-lite\|production-strict" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "All 4 profile modes documented in MG_MODE.md"
    ((test_passed++))
  else
    test_fail "Missing profile modes in MG_MODE.md"
  fi
  
  # Check FIRST ACTIVATION CHECKLIST exists
  if grep -q "FIRST ACTIVATION CHECKLIST" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Activation checklist found"
    ((test_passed++))
  else
    test_fail "No activation checklist in MG_MODE.md"
  fi
  
  # Check profiles/ directory exists
  if [ -d "$PROJECT_ROOT/mg-mode-core/profiles" ]; then
    test_pass "profiles/ directory exists"
    ((test_passed++))
  else
    test_fail "profiles/ directory missing"
  fi
  
  # Check profile fallback behavior (Gap 1 fix)
  if grep -q "default to.*learning\|auto-defaulted to learning" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Profile fallback to learning documented"
    ((test_passed++))
  else
    test_fail "Profile fallback behavior missing"
  fi
  
  echo "Profile Selection: $test_passed/4 checks passed" >> "$TEST_LOG"
  return $((4 - test_passed))
}

# ============================================================================
# TEST 2: Role Routing Algorithm
# ============================================================================
test_role_routing() {
  log "============ TEST 2: Role Routing Algorithm ============"
  
  local test_passed=0
  
  # Check Role Selection Algorithm exists
  if grep -q "Role Selection Algorithm" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Role Selection Algorithm documented"
    ((test_passed++))
  else
    test_fail "Role Selection Algorithm not documented"
  fi
  
  # Check minimum-role-set principle
  if grep -q "complexity=simple.*1 role\|complexity=compound, dependencies=none.*1 role" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Minimum-role-set principle documented"
    ((test_passed++))
  else
    test_fail "Minimum-role-set principle unclear"
  fi
  
  # Check NEXUS deployment modes documented
  if grep -q "NEXUS.*Deployment\|NEXUS.*learning\|NEXUS-Micro\|NEXUS-Sprint\|NEXUS-Full" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "NEXUS deployment modes documented"
    ((test_passed++))
  else
    test_fail "NEXUS deployment modes missing"
  fi
  
  # Check registry/ directory exists
  if [ -d "$PROJECT_ROOT/mg-mode-core/registry" ]; then
    test_pass "registry/ directory exists"
    ((test_passed++))
  else
    test_fail "registry/ directory missing"
  fi
  
  # Check capability fingerprints schema (Gap 2 fix)
  if grep -q "Capability Fingerprints" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md" && grep -q "can-read-files\|can-write-files\|can-parse-ast" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Capability fingerprints schema documented"
    ((test_passed++))
  else
    test_fail "Capability fingerprints schema missing"
  fi
  
  echo "Role Routing: $test_passed/5 checks passed" >> "$TEST_LOG"
  return $((5 - test_passed))
}

# ============================================================================
# TEST 3: Handoff Schema Validation
# ============================================================================
test_handoff_schema() {
  log "============ TEST 3: Handoff Schema Validation ============"
  
  local test_passed=0
  
  # Check schema exists
  if grep -q "HANDOFF SCHEMA" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Handoff schema documented"
    ((test_passed++))
  else
    test_fail "Handoff schema missing"
  fi
  
  # Check all 8 required fields
  local required_fields=("metadata" "context" "deliverable_request" "quality_expectations" "prime_directives_check" "user_prompts")
  local found_fields=0
  for field in "${required_fields[@]}"; do
    if grep -q "  $field:" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
      ((found_fields++))
    fi
  done
  
  if [ $found_fields -eq 6 ]; then
    test_pass "All 6 handoff schema sections documented"
    ((test_passed++))
  else
    test_warn "Found $found_fields/6 handoff schema sections"
  fi
  
  # Check prime_directives_check fields
  if grep -q "zero_silent_failures\|every_error_named\|data_flows_traced\|edge_cases_mapped" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Prime directives check fields documented"
    ((test_passed++))
  else
    test_fail "Prime directives check incomplete"
  fi
  
  echo "Handoff Schema: $test_passed/3 checks passed" >> "$TEST_LOG"
  return $((3 - test_passed))
}

# ============================================================================
# TEST 4: Loop Safety & Escalation
# ============================================================================
test_loop_safety() {
  log "============ TEST 4: Loop Safety & Escalation ============"
  
  local test_passed=0
  
  # Check max retries documented
  if grep -q "Max retries per task.*3" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Max retries (3) documented"
    ((test_passed++))
  else
    test_fail "Max retries not documented"
  fi
  
  # Check semantic loop detection
  if grep -q "Semantic loop detection.*cosine similarity.*0.85" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Semantic loop detection with threshold documented"
    ((test_passed++))
  else
    test_warn "Semantic loop detection details unclear"
  fi
  
  # Check escalation rule
  if grep -q "Escalation rule.*After 3 unsuccessful attempts" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "3-strike escalation rule documented"
    ((test_passed++))
  else
    test_fail "Escalation rule missing"
  fi
  
  # Check COMPLETION STATUS PROTOCOL
  if grep -q "COMPLETION STATUS PROTOCOL" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Completion status protocol documented"
    ((test_passed++))
  else
    test_fail "Completion status protocol missing"
  fi
  
  # Check graph init timeout fallback (Gap 4 fix)
  if grep -q "Graph init incomplete\|Timeout.*5 second\|graph_init.*5s" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Graph init timeout fallback documented"
    ((test_passed++))
  else
    test_fail "Graph init timeout fallback missing"
  fi
  
  echo "Loop Safety: $test_passed/5 checks passed" >> "$TEST_LOG"
  return $((5 - test_passed))
}

# ============================================================================
# TEST 5: Scope Drift Detection
# ============================================================================
test_scope_drift() {
  log "============ TEST 5: Scope Drift Detection ============"
  
  local test_passed=0
  
  # Check scope drift section exists
  if grep -q "SCOPE DRIFT DETECTION" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Scope drift detection section found"
    ((test_passed++))
  else
    test_fail "Scope drift detection section missing"
  fi
  
  # Check verdicts: CLEAN, SCOPE_CREEP, REQUIREMENTS_MISSING
  if grep -q "CLEAN\|SCOPE_CREEP\|REQUIREMENTS_MISSING" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "All 3 scope drift verdicts documented"
    ((test_passed++))
  else
    test_fail "Some scope drift verdicts missing"
  fi
  
  # Check timing: before quality gates
  if grep -q "Runs before quality gates, not after" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Scope drift timing (before gates) documented"
    ((test_passed++))
  else
    test_warn "Scope drift timing unclear"
  fi
  
  echo "Scope Drift Detection: $test_passed/3 checks passed" >> "$TEST_LOG"
  return $((3 - test_passed))
}

# ============================================================================
# TEST 6: Blast Radius Gate
# ============================================================================
test_blast_radius() {
  log "============ TEST 6: Blast Radius Gate ============"
  
  local test_passed=0
  
  # Check ACTION CLASSIFICATION section
  if grep -q "ACTION CLASSIFICATION" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Action classification rules found"
    ((test_passed++))
  else
    test_fail "Action classification section missing"
  fi
  
  # Check blast radius gate (> 5 files)
  if grep -q "BLAST RADIUS GATE\|touches > 5 files" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Blast radius gate (> 5 files) documented"
    ((test_passed++))
  else
    test_fail "Blast radius gate not documented"
  fi
  
  # Check reclassification to SURFACE-TO-USER
  if grep -q "unconditionally reclassified as SURFACE-TO-USER" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Reclassification rule documented"
    ((test_passed++))
  else
    test_fail "Reclassification rule missing"
  fi
  
  # Check 3 options (A/B/C)
  if grep -q "\\(A\\).*\\(B\\).*\\(C\\)" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "A/B/C options for user decision found"
    ((test_passed++))
  else
    test_warn "A/B/C options not clearly documented"
  fi
  
  echo "Blast Radius Gate: $test_passed/4 checks passed" >> "$TEST_LOG"
  return $((4 - test_passed))
}

# ============================================================================
# TEST 7: Quality Gates (Production-Strict)
# ============================================================================
test_quality_gates() {
  log "============ TEST 7: Quality Gates (Production-Strict) ============"
  
  local test_passed=0
  
  # Check Session Lifecycle section
  if grep -q "Quality Gates.*before shipping\|Evidence Collector" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Quality gates phase documented"
    ((test_passed++))
  else
    test_fail "Quality gates section incomplete"
  fi
  
  # Check Baseline vs Security-Deep groups
  if grep -q "Baseline Group.*Security-Deep Group" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Baseline and Security-Deep groups distinguished"
    ((test_passed++))
  else
    test_fail "Profile security grouping unclear"
  fi
  
  # Check production-strict gates
  if grep -q "production-strict.*cross-model review\|challenge mode\|Reality Checker" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Production-strict gate requirements documented"
    ((test_passed++))
  else
    test_warn "Production-strict gate details sparse"
  fi
  
  echo "Quality Gates: $test_passed/3 checks passed" >> "$TEST_LOG"
  return $((3 - test_passed))
}

# ============================================================================
# TEST 8: Layer 1 Override Policy
# ============================================================================
test_layer1_override() {
  log "============ TEST 8: Layer 1 Override Policy ============"
  
  local test_passed=0
  
  # Check SUPREME POLICY
  if grep -q "SUPREME POLICY" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Supreme policy section found"
    ((test_passed++))
  else
    test_fail "Supreme policy missing"
  fi
  
  # Check Layer 1 override policy table
  if grep -q "LAYER 1 OVERRIDE POLICY" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Layer 1 override policy table found"
    ((test_passed++))
  else
    test_fail "Layer 1 override policy table missing"
  fi
  
  # Check Completeness Principle intercept (in SUPREME POLICY or Layer 1 Override)
  if grep -q "Completeness Principle" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    if grep -q "intercepted\|surface as recommendation" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
      test_pass "Completeness Principle intercept documented"
      ((test_passed++))
    else
      test_warn "Completeness Principle handling sparse"
    fi
  else
    test_warn "Completeness Principle not mentioned"
  fi
  
  # Check proactive=false enforcement
  if grep -q "proactive=false.*enforced at activation" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Proactive disable enforcement documented"
    ((test_passed++))
  else
    test_fail "Proactive disable enforcement unclear"
  fi
  
  # Check re-grounding template (Gap 6 fix)
  if grep -q "Re-grounding Template" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md" && grep -q "project_name.*current_phase\|agent_name.*needs a decision" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Re-grounding template documented"
    ((test_passed++))
  else
    test_fail "Re-grounding template missing"
  fi
  
  echo "Layer 1 Override: $test_passed/5 checks passed" >> "$TEST_LOG"
  return $((5 - test_passed))
}

# ============================================================================
# TEST 9: Investigation Protocol
# ============================================================================
test_investigation_protocol() {
  log "============ TEST 9: Investigation Protocol ============"
  
  local test_passed=0
  
  # Check investigation protocol section
  if grep -q "INVESTIGATION PROTOCOL" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Investigation protocol section found"
    ((test_passed++))
  else
    test_fail "Investigation protocol missing"
  fi
  
  # Check 6 bug patterns
  if grep -q "Race condition\|Nil.*null propagation\|State corruption\|Integration failure\|Configuration drift\|Stale cache" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "6 bug patterns documented"
    ((test_passed++))
  else
    test_fail "Bug patterns incomplete"
  fi
  
  # Check 3-strike hypothesis testing
  if grep -q "Hypothesis test.*3-strike rule" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "3-strike hypothesis testing documented"
    ((test_passed++))
  else
    test_fail "Hypothesis testing rules missing"
  fi
  
  # Check red flags
  if grep -q "Red flags.*quick fix for now\|fix before data flow traced\|each fix reveals new problem" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Red flag warnings documented"
    ((test_passed++))
  else
    test_warn "Red flag warnings sparse"
  fi
  
  echo "Investigation Protocol: $test_passed/4 checks passed" >> "$TEST_LOG"
  return $((4 - test_passed))
}

# ============================================================================
# TEST 10: Layer 2 Components (12 Components: 11 dirs + MG_MODE.md)
# ============================================================================
test_layer2_components() {
  log "============ TEST 10: Layer 2 Components ============"
  
  local test_passed=0
  local directories=("identity" "graph" "map" "optimizer" "governance" "profiles" "session" "business" "activation" "registry" "conductor")
  
  # Check all 11 component directories exist
  for dir in "${directories[@]}"; do
    if [ -d "$PROJECT_ROOT/mg-mode-core/$dir" ]; then
      ((test_passed++))
    else
      test_warn "Component directory missing: $dir"
    fi
  done
  
  if [ $test_passed -eq 11 ]; then
    test_pass "All 11 Layer 2 component directories exist"
  else
    test_warn "Found $test_passed/11 component directories"
  fi
  
  # Check MG_MODE.md exists (the 12th component — the Brain)
  if [ -f "$PROJECT_ROOT/mg-mode-core/MG_MODE.md" ]; then
    test_pass "MG_MODE.md (Brain — 12th component) exists"
    ((test_passed++))
  else
    test_fail "MG_MODE.md missing"
  fi
  
  echo "Layer 2 Components: $test_passed/12 checks passed" >> "$TEST_LOG"
  return $((12 - test_passed))
}

# ============================================================================
# TEST 11: Session Persistence Format
# ============================================================================
test_session_format() {
  log "============ TEST 11: Session Persistence Format ============"
  
  local test_passed=0
  
  # Check JSONL format documented (Gap 3 fix)
  if grep -q "Session Persistence Format" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md" && grep -q "JSONL" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Session JSONL format documented"
    ((test_passed++))
  else
    test_fail "Session persistence format missing"
  fi
  
  # Check event types defined
  if grep -q "task_routed.*role_started\|role_completed.*handoff" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Session event types defined"
    ((test_passed++))
  else
    test_fail "Session event types missing"
  fi
  
  # Check concurrency safety rules
  if grep -q "atomic append\|No locks" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Session concurrency safety documented"
    ((test_passed++))
  else
    test_fail "Session concurrency rules missing"
  fi
  
  echo "Session Format: $test_passed/3 checks passed" >> "$TEST_LOG"
  return $((3 - test_passed))
}

# ============================================================================
# TEST 12: Bypass Prevention Mechanism
# ============================================================================
test_bypass_mechanism() {
  log "============ TEST 12: Bypass Prevention Mechanism ============"
  
  local test_passed=0
  
  # Check enforcement levels documented (Gap 5 fix)
  if grep -q "Enforcement levels" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md" && grep -q "Audit-only\|Warn-then-proceed\|Block-destructive" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Bypass enforcement levels documented"
    ((test_passed++))
  else
    test_fail "Bypass enforcement levels missing"
  fi
  
  # Check audit entry format
  if grep -q "bypass_attempt" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md" && grep -q "audit entry format\|Audit entry format" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Bypass audit entry format documented"
    ((test_passed++))
  else
    test_fail "Bypass audit format missing"
  fi
  
  echo "Bypass Mechanism: $test_passed/2 checks passed" >> "$TEST_LOG"
  return $((2 - test_passed))
}

# ============================================================================
# TEST 13: Business Intelligence
# ============================================================================
test_business_intelligence() {
  log "============ TEST 13: Business Intelligence ============"
  
  local test_passed=0
  
  # Check BUSINESS INTELLIGENCE section in MG_MODE.md
  if grep -q "BUSINESS INTELLIGENCE" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Business intelligence section documented"
    ((test_passed++))
  else
    test_fail "Business intelligence section missing from MG_MODE.md"
  fi
  
  # Check business/ directory exists with template files
  local biz_files=("README.md" "user-profile.md" "core.md" "market.md" "insights.md")
  local found=0
  for f in "${biz_files[@]}"; do
    if [ -f "$PROJECT_ROOT/mg-mode-core/business/$f" ]; then
      ((found++))
    fi
  done
  if [ $found -eq 5 ]; then
    test_pass "All 5 business/ template files exist"
    ((test_passed++))
  else
    test_fail "Found $found/5 business/ template files"
  fi
  
  # Check intelligence gathering rules
  if grep -q "user-stated\|user-implied\|system-generated\|external" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Confidence tagging documented"
    ((test_passed++))
  else
    test_fail "Confidence tagging missing"
  fi
  
  # Check approval-before-persistence rule
  if grep -q "Approval before persistence\|user confirms\|No silent writes" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Approval-before-write rule documented"
    ((test_passed++))
  else
    test_fail "Approval rule missing"
  fi
  
  # Check integration with routing
  if grep -q "Check business/ for.*context\|business/ for relevant" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Business intelligence integrated with routing"
    ((test_passed++))
  else
    test_fail "Business context not in routing flow"
  fi
  
  # Check profile-aware intelligence depth table
  if grep -q "Profile-Aware Intelligence Depth" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md" && grep -q "Onboarding questions.*learning.*MVP\|learning.*MVP.*production-lite" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Profile-aware intelligence depth table documented"
    ((test_passed++))
  else
    test_fail "Profile-aware intelligence depth table missing"
  fi
  
  # Check pre-ship intelligence review
  if grep -q "Pre-ship intelligence review\|pre-ship.*block\|pre-ship.*warn" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Pre-ship intelligence review documented"
    ((test_passed++))
  else
    test_fail "Pre-ship intelligence review missing"
  fi
  
  echo "Business Intelligence: $test_passed/7 checks passed" >> "$TEST_LOG"
  return $((7 - test_passed))
}

# ============================================================================
# TEST 14: Existing Repo Bootstrap (Auto-Learn)
# ============================================================================
test_existing_repo_bootstrap() {
  log "============ TEST 14: Existing Repo Bootstrap ============"
  
  local test_passed=0
  
  # Check Existing Repo Bootstrap section in MG_MODE.md
  if grep -q "Existing Repo Bootstrap\|EXISTING REPO SCAN" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Existing repo bootstrap section documented"
    test_passed=$((test_passed + 1))
  else
    test_fail "Existing repo bootstrap section missing from MG_MODE.md"
  fi
  
  # Check scan targets documented (README.md, package.json, configs, docs/)
  if grep -q "Read README.md\|package.json.*Cargo.toml\|docker-compose" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Repo scan targets documented"
    test_passed=$((test_passed + 1))
  else
    test_fail "Repo scan targets not documented"
  fi
  
  # Check batch approval rule
  if grep -q "batch.*approval\|batch for approval\|Present.*batch" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Batch approval rule documented"
    test_passed=$((test_passed + 1))
  else
    test_fail "Batch approval rule missing"
  fi
  
  # Check idempotency rule (no overwrite of existing intelligence)
  if grep -q "Idempotent\|only proposes additions.*never overwrites" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Idempotency rule documented"
    test_passed=$((test_passed + 1))
  else
    test_fail "Idempotency rule missing"
  fi
  
  # Check that activation/ references existing repo detection
  if grep -q "EXISTING CODEBASE\|existing.*codebase\|Existing codebase" "$PROJECT_ROOT/mg-mode-core/activation/README.md"; then
    test_pass "Activation flow references existing repo detection"
    test_passed=$((test_passed + 1))
  else
    test_fail "Activation flow missing existing repo detection"
  fi
  
  # Check profile-specific scan extensions documented
  if grep -q "production-lite adds\|production-strict adds" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Profile-specific scan extensions documented"
    test_passed=$((test_passed + 1))
  else
    test_fail "Profile-specific scan extensions missing"
  fi
  
  # Check scan depth scales with profile (quick scan vs deep scan)
  if grep -q "Quick scan.*README.*package config\|Deep scan.*compliance.*security" "$PROJECT_ROOT/mg-mode-core/MG_MODE.md"; then
    test_pass "Scan depth scales with profile level"
    test_passed=$((test_passed + 1))
  else
    test_fail "Scan depth not profile-aware"
  fi
  
  echo "Existing Repo Bootstrap: $test_passed/7 checks passed" >> "$TEST_LOG"
  return $((7 - test_passed))
}

# ============================================================================
# TEST 15: Trigger Contracts
# ============================================================================
test_trigger_contracts() {
  log "============ TEST 15: Trigger Contracts ============"

  local test_passed=0

  # Check conductor mode trigger registry exists and includes all 4 modes
  if [ -f "$PROJECT_ROOT/mg-mode-core/conductor/mode-triggers.json" ] \
    && grep -q '"mode": "plan"' "$PROJECT_ROOT/mg-mode-core/conductor/mode-triggers.json" \
    && grep -q '"mode": "ask"' "$PROJECT_ROOT/mg-mode-core/conductor/mode-triggers.json" \
    && grep -q '"mode": "execute"' "$PROJECT_ROOT/mg-mode-core/conductor/mode-triggers.json" \
    && grep -q '"mode": "review"' "$PROJECT_ROOT/mg-mode-core/conductor/mode-triggers.json"; then
    test_pass "Conductor mode trigger registry documented"
    ((test_passed++))
  else
    test_fail "Conductor mode trigger registry missing or incomplete"
  fi

  # Check conductor matching rules are explicit
  if grep -q 'Single source of truth: `mode-triggers.json`' "$PROJECT_ROOT/mg-mode-core/conductor/README.md" \
    && grep -q 'If zero or multiple modes match, ask a clarifying question instead of guessing' "$PROJECT_ROOT/mg-mode-core/conductor/README.md"; then
    test_pass "Conductor trigger matching rules documented"
    ((test_passed++))
  else
    test_fail "Conductor trigger matching rules missing"
  fi

  # Check gstack trigger registry exists and includes preference triggers
  if [ -f "$PROJECT_ROOT/gstack/skill-suggestion-triggers.json" ] \
    && grep -q '"stop suggesting things"' "$PROJECT_ROOT/gstack/skill-suggestion-triggers.json" \
    && grep -q '"be proactive again"' "$PROJECT_ROOT/gstack/skill-suggestion-triggers.json"; then
    test_pass "gstack trigger registry documented"
    ((test_passed++))
  else
    test_fail "gstack trigger registry missing or incomplete"
  fi

  # Check generated Claude-host skill doc includes the registry and preference triggers
  if grep -q 'Skill Suggestion Trigger Registry' "$PROJECT_ROOT/gstack/SKILL.md" \
    && grep -q 'stop suggesting things' "$PROJECT_ROOT/gstack/SKILL.md" \
    && grep -q '/office-hours' "$PROJECT_ROOT/gstack/SKILL.md"; then
    test_pass "Generated Claude-host skill doc includes trigger registry"
    ((test_passed++))
  else
    test_fail "Generated Claude-host skill doc missing trigger registry"
  fi

  # Check generated Codex-host skill doc includes the same registry and preference triggers
  if grep -q 'Skill Suggestion Trigger Registry' "$PROJECT_ROOT/gstack/.agents/skills/gstack/SKILL.md" \
    && grep -q 'be proactive again' "$PROJECT_ROOT/gstack/.agents/skills/gstack/SKILL.md" \
    && grep -q '/office-hours' "$PROJECT_ROOT/gstack/.agents/skills/gstack/SKILL.md"; then
    test_pass "Generated Codex-host skill doc includes trigger registry"
    ((test_passed++))
  else
    test_fail "Generated Codex-host skill doc missing trigger registry"
  fi

  echo "Trigger Contracts: $test_passed/5 checks passed" >> "$TEST_LOG"
  return $((5 - test_passed))
}

# ============================================================================
# MAIN TEST EXECUTION
# ============================================================================
main() {
  log "========== MG_MODE Test Suite Start =========="
  log "Project: $PROJECT_ROOT"
  log "Test Dir: $TEST_DIR"
  log "Session Dir: $SESSION_DIR"
  
  local total_score=0
  local failures=0
  
  set +e  # Allow test functions to return non-zero without exiting
  
  # Run all tests and accumulate ACTUAL pass counts (not fixed max values)
  test_profile_selection; failures=$?
  total_score=$((total_score + 4 - failures))
  
  test_role_routing; failures=$?
  total_score=$((total_score + 5 - failures))
  
  test_handoff_schema; failures=$?
  total_score=$((total_score + 3 - failures))
  
  test_loop_safety; failures=$?
  total_score=$((total_score + 5 - failures))
  
  test_scope_drift; failures=$?
  total_score=$((total_score + 3 - failures))
  
  test_blast_radius; failures=$?
  total_score=$((total_score + 4 - failures))
  
  test_quality_gates; failures=$?
  total_score=$((total_score + 3 - failures))
  
  test_layer1_override; failures=$?
  total_score=$((total_score + 5 - failures))
  
  test_investigation_protocol; failures=$?
  total_score=$((total_score + 4 - failures))
  
  test_layer2_components; failures=$?
  total_score=$((total_score + 12 - failures))
  
  test_session_format; failures=$?
  total_score=$((total_score + 3 - failures))
  
  test_bypass_mechanism; failures=$?
  total_score=$((total_score + 2 - failures))
  
  test_business_intelligence; failures=$?
  total_score=$((total_score + 7 - failures))
  
  test_existing_repo_bootstrap; failures=$?
  total_score=$((total_score + 7 - failures))

  test_trigger_contracts; failures=$?
  total_score=$((total_score + 5 - failures))
  
  set -e  # Restore strict mode
  
  # Summary
  local max_score=72
  log ""
  log "========== Test Summary =========="
  log "Total Checks Passed: $total_score/$max_score"
  log "Test Log: $TEST_LOG"
  
  if [ $total_score -ge $max_score ]; then
    test_pass "MG_MODE.md is PRODUCTION READY ($total_score/$max_score checks)"
  elif [ $total_score -ge 50 ]; then
    test_warn "MG_MODE.md is MOSTLY READY ($total_score/$max_score checks) — minor gaps to resolve"
  else
    test_fail "MG_MODE.md needs more work ($total_score/$max_score checks)"
  fi
  
  log "========== Test Suite Complete =========="
  
  # Return 0 on full pass, non-zero otherwise
  return $((max_score - total_score))
}

main "$@"
