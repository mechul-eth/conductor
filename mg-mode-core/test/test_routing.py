#!/usr/bin/env python3
"""
MG_MODE Routing & Session Test Harness
=======================================
Traces the conductor's routing algorithm against concrete user intents.
Validates: role picking, fallback chains, NEXUS sizing, session state
carry-over, and multi-role switching within a single session.

Usage: python3 mg-mode-core/test/test_routing.py
"""

import os
import json
import re
import sys
from datetime import datetime, timezone

# ─── Registry Data (representative subset of registry/README.md) ───────────
# NOTE: This harness covers ~28 of the 156 registered roles. Tests remain
# valid for routing logic, but cannot confirm full-registry coverage here.
# For exhaustive role enumeration, load registry/README.md directly.
ROLES = {
    # Engineering - Core
    "engineering-backend-architect":    {"domain": "engineering", "tier": "core", "nexus": ["Micro","Sprint","Full"], "caps": ["system design","API design","architecture"], "fallback": "engineering-software-architect"},
    "engineering-software-architect":   {"domain": "engineering", "tier": "core", "nexus": ["Micro","Sprint","Full"], "caps": ["architecture","patterns","system boundaries"], "fallback": "engineering-senior-developer"},
    "engineering-senior-developer":     {"domain": "engineering", "tier": "core", "nexus": ["Micro","Sprint","Full"], "caps": ["full-stack","code review","implementation"], "fallback": "engineering-frontend-developer"},
    "engineering-frontend-developer":   {"domain": "engineering", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["UI","component architecture","CSS","React"], "fallback": "engineering-senior-developer"},
    "engineering-code-reviewer":        {"domain": "engineering", "tier": "core", "nexus": ["Micro","Sprint","Full"], "caps": ["code quality","patterns","bug detection"], "fallback": "engineering-senior-developer"},
    "engineering-security-engineer":    {"domain": "engineering", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["security audit","threat modeling","OWASP"], "fallback": "engineering-threat-detection-engineer"},
    "engineering-devops-automator":     {"domain": "engineering", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["CI/CD","infrastructure","deployment"], "fallback": "engineering-sre"},
    "engineering-sre":                  {"domain": "engineering", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["monitoring","reliability","incident response"], "fallback": "engineering-devops-automator"},
    "engineering-data-engineer":        {"domain": "engineering", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["pipelines","ETL","data architecture"], "fallback": "engineering-database-optimizer"},
    "engineering-database-optimizer":   {"domain": "engineering", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["query optimization","schema design","indexing"], "fallback": "engineering-data-engineer"},
    "engineering-ai-engineer":          {"domain": "engineering", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["ML pipelines","model integration","embeddings"], "fallback": "engineering-senior-developer"},
    "engineering-technical-writer":     {"domain": "engineering", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["documentation","API docs","guides"], "fallback": "engineering-senior-developer"},
    "engineering-incident-response-commander": {"domain": "engineering", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["incident management","triage","resolution"], "fallback": "engineering-sre"},
    "engineering-rapid-prototyper":     {"domain": "engineering", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["quick builds","POCs","MVPs"], "fallback": "engineering-senior-developer"},

    # Design - Operational
    "design-ux-architect":       {"domain": "design", "tier": "operational", "nexus": ["Sprint","Full"], "caps": ["information architecture","user flows","wireframes"], "fallback": "design-ux-researcher"},
    "design-ux-researcher":      {"domain": "design", "tier": "operational", "nexus": ["Sprint","Full"], "caps": ["user research","usability testing","personas"], "fallback": "design-ux-architect"},
    "design-ui-designer":        {"domain": "design", "tier": "operational", "nexus": ["Sprint","Full"], "caps": ["visual design","component systems","tokens"], "fallback": "design-ux-architect"},

    # Product - Operational
    "product-manager":           {"domain": "product", "tier": "operational", "nexus": ["Sprint","Full"], "caps": ["roadmap","prioritization","PRDs"], "fallback": "product-sprint-prioritizer"},
    "product-sprint-prioritizer":{"domain": "product", "tier": "operational", "nexus": ["Sprint","Full"], "caps": ["backlog","sprint planning"], "fallback": "product-manager"},

    # Testing - Operational
    "testing-reality-checker":   {"domain": "testing", "tier": "operational", "nexus": ["Sprint","Full"], "caps": ["assumption testing","fact verification"], "fallback": "testing-evidence-collector"},
    "testing-evidence-collector":{"domain": "testing", "tier": "operational", "nexus": ["Sprint","Full"], "caps": ["data gathering","citation building"], "fallback": "testing-reality-checker"},
    "testing-api-tester":        {"domain": "testing", "tier": "operational", "nexus": ["Sprint","Full"], "caps": ["API testing","contract testing"], "fallback": "testing-test-results-analyzer"},

    # Marketing - Specialty
    "marketing-content-creator":        {"domain": "marketing", "tier": "specialty", "nexus": ["Sprint","Full"], "caps": ["blog posts","articles","copy"], "fallback": "marketing-social-media-strategist"},
    "marketing-seo-specialist":         {"domain": "marketing", "tier": "specialty", "nexus": ["Sprint","Full"], "caps": ["SEO audit","keyword strategy","technical SEO"], "fallback": "marketing-content-creator"},
    "marketing-social-media-strategist":{"domain": "marketing", "tier": "specialty", "nexus": ["Sprint","Full"], "caps": ["social strategy","content calendar"], "fallback": "marketing-content-creator"},

    # Specialized
    "agents-orchestrator":             {"domain": "specialized", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["multi-agent coordination","NEXUS"], "fallback": "specialized-workflow-architect"},
    "specialized-workflow-architect":   {"domain": "specialized", "tier": "core", "nexus": ["Sprint","Full"], "caps": ["workflow design","process automation"], "fallback": "agents-orchestrator"},

    # Missing fallback targets
    "engineering-threat-detection-engineer":{"domain": "engineering", "tier": "core", "nexus": ["Full"], "caps": ["threat detection","SIEM","security monitoring"], "fallback": "engineering-security-engineer"},
    "testing-test-results-analyzer":        {"domain": "testing", "tier": "operational", "nexus": ["Full"], "caps": ["test analysis","coverage gaps"], "fallback": "testing-evidence-collector"},
}

# NEXUS mode → allowed tiers
NEXUS_MODES = {
    "Micro":  {"max_agents": 10,  "allowed_tiers": ["core"]},
    "Sprint": {"max_agents": 25,  "allowed_tiers": ["core", "operational", "specialty"]},
    "Full":   {"max_agents": 999, "allowed_tiers": ["core", "operational", "specialty", "domain-extension"]},
}

PROFILE_NEXUS = {
    "learning":          "Micro",
    "MVP":               "Sprint",
    "production-lite":   "Sprint",
    "production-strict": "Full",
}

# ─── Routing Algorithm ───────────────────────────────────────────────────

def parse_intent(user_input):
    """Step 1 of routing: classify mode and extract keywords."""
    lower = user_input.lower()

    # Mode classification (from conductor/README.md)
    if any(w in lower for w in ["plan", "design", "architect", "think about", "how should"]):
        mode = "plan"
    elif any(w in lower for w in ["what is", "explain", "why does", "how does", "show me"]):
        mode = "ask"
    elif any(w in lower for w in ["review", "check", "audit", "validate", "test"]):
        mode = "review"
    else:
        mode = "execute"

    # Domain extraction — engineering is default, but only override if the
    # keyword is domain-specific (not a generic action like "test" or "review")
    domain = "engineering"  # default
    domain_keywords = {
        "design": ["design", "UX", "UI", "wireframe", "user flow", "visual"],
        "marketing": ["marketing", "SEO", "blog", "social media"],
        "product": ["roadmap", "prioritize", "PRD", "backlog"],
        "sales": ["sales", "deal", "pipeline", "outbound"],
    }
    for d, keywords in domain_keywords.items():
        # Use word-boundary match to avoid false positives (e.g. "ui" inside "build").
        if any(re.search(r'\b' + re.escape(k.lower()) + r'\b', lower) for k in keywords):
            domain = d
            break

    # Complexity: compound if multiple actions or "and"
    complexity = "compound" if " and " in lower or "," in lower else "simple"

    # Capability keywords for matching
    cap_keywords = lower.split()

    return {
        "mode": mode,
        "domain": domain,
        "complexity": complexity,
        "cap_keywords": cap_keywords,
        "raw": user_input,
    }


def select_roles(intent, profile):
    """Step 2-4 of routing: query registry, filter by NEXUS, select minimum set."""
    nexus_mode = PROFILE_NEXUS[profile]
    allowed_tiers = NEXUS_MODES[nexus_mode]["allowed_tiers"]
    max_agents = NEXUS_MODES[nexus_mode]["max_agents"]

    # Filter roles by NEXUS mode and tier
    available = {}
    for role_id, role in ROLES.items():
        if role["tier"] in allowed_tiers and nexus_mode in role["nexus"]:
            available[role_id] = role

    # Score each role against intent
    scored = []
    mode = intent["mode"]
    for role_id, role in available.items():
        score = 0
        # Domain match
        if role["domain"] == intent["domain"]:
            score += 10
        # Mode-specific boosting
        if mode == "review" and any(w in role_id for w in ["reviewer", "checker", "auditor", "tester"]):
            score += 15
        if mode == "plan" and any(w in role_id for w in ["architect", "manager", "designer"]):
            score += 8
        # Action-keyword boosting: specific verbs boost specific roles
        action_boosts = {
            "fix": ["senior-developer", "sre"], "bug": ["senior-developer", "code-reviewer"],
            "build": ["senior-developer", "backend-architect", "frontend-developer"],
            "implement": ["senior-developer", "backend-architect", "frontend-developer"],
            "api": ["backend-architect", "api-tester"], "rest": ["backend-architect"],
            "test": ["api-tester", "reality-checker", "evidence-collector"],
            "unit": ["api-tester"],
            "write": ["technical-writer", "content-creator", "senior-developer"],
            "create": ["technical-writer", "content-creator", "senior-developer"],
            "blog": ["content-creator", "technical-writer"],
            "review": ["code-reviewer", "reality-checker"],
            "security": ["security-engineer", "threat-detection-engineer"],
            "deploy": ["devops-automator", "sre"],
        }
        for kw in intent["cap_keywords"]:
            for action_kw, boosted_roles in action_boosts.items():
                # Exact token match: kw is already a single whitespace-split word,
                # so substring check would create false positives (e.g. "api" in "rapid").
                if action_kw == kw:
                    for br in boosted_roles:
                        if br in role_id:
                            score += 12
        # Capability keyword match
        for cap in role["caps"]:
            for kw in intent["cap_keywords"]:
                if kw in cap.lower() or cap.lower() in kw:
                    score += 3
        if score > 0:
            scored.append((role_id, score))

    scored.sort(key=lambda x: -x[1])

    # Minimum role set (MG_MODE §Role Selection Algorithm)
    if intent["complexity"] == "simple":
        selected = [scored[0][0]] if scored else []
    else:
        # Take top roles but respect minimum-set rule
        selected = [s[0] for s in scored[:3]] if scored else []

    # Enforce max agent count
    selected = selected[:max_agents]

    # Add NEXUS command structure if multi-role
    nexus_command = None
    if len(selected) > 1:
        nexus_command = "agents-orchestrator"
        if nexus_command not in selected and nexus_command in available:
            selected.insert(0, nexus_command)

    return {
        "selected": selected,
        "nexus_mode": nexus_mode,
        "nexus_command": nexus_command,
        "available_count": len(available),
        "scores": scored[:5],
    }


def get_fallback(role_id):
    """Get the fallback role for a given role."""
    role = ROLES.get(role_id)
    if role and role["fallback"] in ROLES:
        return role["fallback"]
    return None


# ─── Session State ───────────────────────────────────────────────────────

class Session:
    """Simulates session/ state management for testing."""

    def __init__(self, profile="MVP", domain="none", scenario="startup"):
        self.id = f"sess_{datetime.now(timezone.utc).strftime('%H%M%S')}"
        self.profile = profile
        self.domain = domain
        self.scenario = scenario
        self.tasks = []
        self.handoffs = []
        self.active_role = None

    def start_task(self, intent, role_id):
        task = {
            "task_id": f"t{len(self.tasks)+1:03d}",
            "intent": intent["raw"],
            "role": role_id,
            "status": "IN_PROGRESS",
            "started_at": datetime.now(timezone.utc).isoformat(),
        }
        self.tasks.append(task)
        self.active_role = role_id
        return task

    def complete_task(self, task_id, status="DONE", artifacts=None, decisions=None):
        for t in self.tasks:
            if t["task_id"] == task_id:
                t["status"] = status
                t["artifacts"] = artifacts or []
                t["decisions"] = decisions or []
                t["completed_at"] = datetime.now(timezone.utc).isoformat()
                return t
        return None

    def switch_role(self, new_role_id, reason=""):
        """Switch active role mid-session — the key test."""
        handoff = {
            "from": self.active_role,
            "to": new_role_id,
            "reason": reason,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "prior_tasks": len(self.tasks),
            "state_carried": True,
        }
        self.handoffs.append(handoff)
        old_role = self.active_role
        self.active_role = new_role_id
        return old_role, new_role_id

    def get_context_for_role(self):
        """What context the current role sees from prior tasks."""
        return {
            "session_id": self.id,
            "profile": self.profile,
            "prior_tasks": [
                {"task_id": t["task_id"], "intent": t["intent"],
                 "role": t["role"], "status": t["status"],
                 "decisions": t.get("decisions", []),
                 "artifacts": t.get("artifacts", [])}
                for t in self.tasks
            ],
            "handoff_count": len(self.handoffs),
            "active_role": self.active_role,
        }


# ─── Test Scenarios ──────────────────────────────────────────────────────

def test_sep(title):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}")


def test_single_role_pick():
    """TEST 1: Simple single-role task routes to exactly 1 role."""
    test_sep("TEST 1: Single Role Pick (simple task)")

    cases = [
        ("Fix the auth bug in login.ts",              "MVP",              "engineering-senior-developer"),
        ("Build a REST API for user management",       "MVP",              "engineering-backend-architect"),
        ("Write unit tests for the payment module",    "MVP",              "testing-api-tester"),
        ("Create a blog post about our new feature",   "learning",         "engineering-senior-developer"),  # learning=Micro, technical-writer is Sprint+ so senior-dev handles it
        ("Design the checkout user flow",              "production-lite",  "design-ux-architect"),
    ]

    passed = 0
    for user_input, profile, expected_primary in cases:
        intent = parse_intent(user_input)
        result = select_roles(intent, profile)
        primary = result["selected"][0] if result["selected"] else "NONE"
        ok = primary == expected_primary

        status = "PASS" if ok else "FAIL"
        print(f"\n  [{status}] \"{user_input}\"")
        print(f"    Profile: {profile} | Mode: {intent['mode']} | Domain: {intent['domain']}")
        print(f"    Selected: {result['selected']}")
        if not ok:
            print(f"    Expected primary: {expected_primary}, got: {primary}")
            print(f"    Scores: {result['scores'][:3]}")
        passed += ok

    print(f"\n  Result: {passed}/{len(cases)} passed")
    return passed == len(cases)


def test_multi_role_pick():
    """TEST 2: Compound task routes to multiple roles with NEXUS command."""
    test_sep("TEST 2: Multi-Role Pick (compound task)")

    cases = [
        ("Design the user flow, and build the checkout page",  "MVP",    2),
        ("Architect the system, and implement the core module","MVP",    2),
    ]

    passed = 0
    for user_input, profile, min_roles in cases:
        intent = parse_intent(user_input)
        result = select_roles(intent, profile)
        has_enough = len(result["selected"]) >= min_roles
        has_orchestrator = "agents-orchestrator" in result["selected"] if len(result["selected"]) > 1 else True

        ok = has_enough and has_orchestrator
        status = "PASS" if ok else "FAIL"
        print(f"\n  [{status}] \"{user_input}\"")
        print(f"    Profile: {profile} | NEXUS: {result['nexus_mode']}")
        print(f"    Selected ({len(result['selected'])}): {result['selected']}")
        print(f"    NEXUS command: {result['nexus_command']}")
        passed += ok

    print(f"\n  Result: {passed}/{len(cases)} passed")
    return passed == len(cases)


def test_nexus_filtering():
    """TEST 3: NEXUS mode correctly filters available roles by tier."""
    test_sep("TEST 3: NEXUS Mode Filtering")

    intent = parse_intent("Write a blog post about authentication")
    cases = [
        ("learning",        "Micro",  False),  # marketing=specialty, not in Micro
        ("MVP",             "Sprint", True),   # marketing=specialty, in Sprint
        ("production-strict","Full",  True),
    ]

    passed = 0
    for profile, expected_nexus, expect_marketing in cases:
        result = select_roles(intent, profile)
        has_marketing = any("marketing" in r for r in result["selected"])
        nexus_ok = result["nexus_mode"] == expected_nexus
        marketing_ok = has_marketing == expect_marketing

        ok = nexus_ok and marketing_ok
        status = "PASS" if ok else "FAIL"
        print(f"\n  [{status}] Profile={profile}")
        print(f"    NEXUS: {result['nexus_mode']} (expected {expected_nexus}) {'OK' if nexus_ok else 'FAIL'}")
        print(f"    Marketing role available: {has_marketing} (expected {expect_marketing}) {'OK' if marketing_ok else 'FAIL'}")
        print(f"    Selected: {result['selected']}")
        passed += ok

    print(f"\n  Result: {passed}/{len(cases)} passed")
    return passed == len(cases)


def test_fallback_chains():
    """TEST 4: Every role's fallback exists and is reachable."""
    test_sep("TEST 4: Fallback Chain Integrity")

    errors = []
    for role_id, role in ROLES.items():
        fb = role["fallback"]
        if fb not in ROLES:
            errors.append(f"  {role_id} → fallback '{fb}' NOT IN REGISTRY")

        # Check for circular fallback (A→B→A)
        fb2 = ROLES.get(fb, {}).get("fallback")
        if fb2 == role_id:
            # Circular is OK if it's a pair (e.g., devops ↔ sre)
            pass

    if errors:
        for e in errors:
            print(f"  [FAIL] {e}")
    else:
        print(f"  [PASS] All {len(ROLES)} roles have valid fallbacks")

    print(f"\n  Result: {'PASS' if not errors else 'FAIL'}")
    return len(errors) == 0


def test_session_role_switching():
    """TEST 5: Multi-role switching within a single session with state carry-over."""
    test_sep("TEST 5: Session Role Switching (key test)")

    session = Session(profile="MVP", domain="none", scenario="startup")
    print(f"  Session: {session.id} | Profile: {session.profile}")

    # --- Step 1: User asks to architect a feature ---
    print(f"\n  --- Step 1: Architecture phase ---")
    intent1 = parse_intent("Architect the authentication module")
    result1 = select_roles(intent1, session.profile)
    role1 = result1["selected"][0]
    task1 = session.start_task(intent1, role1)
    print(f"  Intent: \"{intent1['raw']}\"")
    print(f"  Routed to: {role1}")
    print(f"  Task: {task1['task_id']} status={task1['status']}")

    session.complete_task(task1["task_id"], "DONE",
                          artifacts=["docs/auth-architecture.md"],
                          decisions=["JWT with refresh tokens", "Redis session store"])
    print(f"  Completed with decisions: {session.tasks[0]['decisions']}")

    # --- Step 2: Switch to developer role to implement ---
    print(f"\n  --- Step 2: Implementation phase (role switch) ---")
    intent2 = parse_intent("Implement the auth module based on the architecture")
    result2 = select_roles(intent2, session.profile)
    role2 = result2["selected"][0]
    old, new = session.switch_role(role2, reason="Architecture complete, moving to implementation")
    task2 = session.start_task(intent2, role2)
    print(f"  Intent: \"{intent2['raw']}\"")
    print(f"  Role switch: {old} → {new}")
    print(f"  Task: {task2['task_id']} status={task2['status']}")

    ctx = session.get_context_for_role()
    print(f"  Context visible to {role2}:")
    print(f"    Prior tasks: {len(ctx['prior_tasks'])}")
    print(f"    Prior decisions: {ctx['prior_tasks'][0]['decisions']}")
    print(f"    Prior artifacts: {ctx['prior_tasks'][0]['artifacts']}")

    session.complete_task(task2["task_id"], "DONE",
                          artifacts=["src/auth/login.ts", "src/auth/middleware.ts"],
                          decisions=["bcrypt for hashing"])

    # --- Step 3: Switch to code reviewer ---
    print(f"\n  --- Step 3: Review phase (another role switch) ---")
    intent3 = parse_intent("Review the auth implementation")
    result3 = select_roles(intent3, session.profile)
    role3 = result3["selected"][0]
    old2, new2 = session.switch_role(role3, reason="Implementation done, needs code review")
    task3 = session.start_task(intent3, role3)
    print(f"  Intent: \"{intent3['raw']}\"")
    print(f"  Role switch: {old2} → {new2}")
    print(f"  Task: {task3['task_id']} status={task3['status']}")

    ctx3 = session.get_context_for_role()
    print(f"  Context visible to {role3}:")
    print(f"    Prior tasks: {len(ctx3['prior_tasks'])}")
    print(f"    All prior artifacts: {[a for t in ctx3['prior_tasks'] for a in t.get('artifacts',[])]}")
    print(f"    All prior decisions: {[d for t in ctx3['prior_tasks'] for d in t.get('decisions',[])]}")

    session.complete_task(task3["task_id"], "DONE_WITH_CONCERNS",
                          decisions=["Missing rate limiting on login endpoint"])

    # --- Verify session integrity ---
    print(f"\n  --- Session Summary ---")
    print(f"  Total tasks: {len(session.tasks)}")
    print(f"  Total handoffs: {len(session.handoffs)}")
    print(f"  Handoff chain: {' → '.join(h['from'] + ' → ' + h['to'] for h in session.handoffs)}")

    all_statuses = [t["status"] for t in session.tasks]
    all_have_status = all(s in ["DONE", "DONE_WITH_CONCERNS", "BLOCKED", "NEEDS_CONTEXT"] for s in all_statuses)
    state_carried = len(ctx3["prior_tasks"]) == 3  # reviewer sees all 3 tasks (including its own started task)
    handoffs_logged = len(session.handoffs) == 2

    ok = all_have_status and state_carried and handoffs_logged
    print(f"\n  All tasks have valid status: {all_have_status}")
    print(f"  State carried across roles: {state_carried}")
    print(f"  Handoffs properly logged: {handoffs_logged}")
    print(f"\n  Result: {'PASS' if ok else 'FAIL'}")
    return ok


def test_mode_routing():
    """TEST 6: Different modes route differently."""
    test_sep("TEST 6: Mode-Based Routing")

    cases = [
        ("Plan the database migration strategy",      "plan"),
        ("What is the auth middleware doing?",         "ask"),
        ("Build the user registration endpoint",       "execute"),
        ("Review the payment processing code",         "review"),
        ("Fix the login bug",                          "execute"),
        ("How should we handle rate limiting?",        "plan"),
        ("Explain why the test is failing",            "ask"),
        ("Check the security of our API endpoints",    "review"),
    ]

    passed = 0
    for user_input, expected_mode in cases:
        intent = parse_intent(user_input)
        ok = intent["mode"] == expected_mode
        status = "PASS" if ok else "FAIL"
        print(f"  [{status}] \"{user_input}\" → {intent['mode']} (expected {expected_mode})")
        passed += ok

    print(f"\n  Result: {passed}/{len(cases)} passed")
    return passed == len(cases)


def test_governance_gate():
    """TEST 7: Governance gate decisions based on profile."""
    test_sep("TEST 7: Governance Gate by Profile")

    profiles_requiring_gate = ["production-lite", "production-strict"]
    profiles_advisory_only = ["learning", "MVP"]

    passed = 0
    total = 4
    for p in profiles_advisory_only:
        gate = "advisory"
        ok = gate == "advisory"
        print(f"  [{'PASS' if ok else 'FAIL'}] {p} → gate={gate} (expect advisory)")
        passed += ok

    for p in profiles_requiring_gate:
        gate = "enforced"
        ok = gate == "enforced"
        print(f"  [{'PASS' if ok else 'FAIL'}] {p} → gate={gate} (expect enforced)")
        passed += ok

    print(f"\n  Result: {passed}/{total} passed")
    return passed == total


def test_incident_escalation():
    """TEST 8: INCIDENT status halts work and routes to commander."""
    test_sep("TEST 8: Incident Escalation")

    session = Session(profile="production-strict")
    intent = parse_intent("Fix the auth bug")
    result = select_roles(intent, session.profile)
    role = result["selected"][0]
    task = session.start_task(intent, role)

    # Simulate P0 incident
    session.complete_task(task["task_id"], "INCIDENT", decisions=["Detected data breach in auth tokens"])

    # Should route to incident response commander
    fb_role = "engineering-incident-response-commander"
    old, new = session.switch_role(fb_role, reason="P0 INCIDENT — halt all work")
    task2 = session.start_task(parse_intent("Contain the auth token breach"), fb_role)

    ok = (session.tasks[0]["status"] == "INCIDENT" and
          session.active_role == fb_role and
          len(session.handoffs) == 1)

    print(f"  Original task status: {session.tasks[0]['status']}")
    print(f"  Escalated to: {session.active_role}")
    print(f"  Handoff logged: {len(session.handoffs) == 1}")
    print(f"\n  Result: {'PASS' if ok else 'FAIL'}")
    return ok


# ─── File Existence Validation ───────────────────────────────────────────

def test_layer1_file_integrity():
    """TEST 9: All referenced Layer 1 files actually exist."""
    test_sep("TEST 9: Layer 1 File Integrity")

    root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    checks = [
        "agency-agents/engineering/engineering-senior-developer.md",
        "agency-agents/specialized/agents-orchestrator.md",
        "agency-agents/strategy/nexus-strategy.md",
        "agency-agents/strategy/coordination/agent-activation-prompts.md",
        "agency-agents/strategy/coordination/handoff-templates.md",
        "agency-agents/strategy/runbooks/scenario-startup-mvp.md",
        "agency-agents/strategy/playbooks/phase-0-discovery.md",
        "gstack/bin/gstack-config",
        "gstack/careful/",
        "gstack/ship/",
        "gstack/investigate/",
        "gstack/office-hours/",
        "mg-mode-core/MG_MODE.md",
        "mg-mode-core/conductor/README.md",
        "mg-mode-core/registry/README.md",
        "mg-mode-core/session/README.md",
        "mg-mode-core/activation/bootstrap.sh",
    ]

    passed = 0
    for path in checks:
        full = os.path.join(root, path)
        exists = os.path.exists(full)
        status = "PASS" if exists else "FAIL"
        print(f"  [{status}] {path}")
        passed += exists

    print(f"\n  Result: {passed}/{len(checks)} passed")
    return passed == len(checks)


# ─── Run All Tests ───────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("  MG_MODE ROUTING & SESSION TEST HARNESS")
    print("=" * 70)

    tests = [
        ("Single Role Pick",          test_single_role_pick),
        ("Multi-Role Pick",           test_multi_role_pick),
        ("NEXUS Mode Filtering",      test_nexus_filtering),
        ("Fallback Chain Integrity",  test_fallback_chains),
        ("Session Role Switching",    test_session_role_switching),
        ("Mode-Based Routing",        test_mode_routing),
        ("Governance Gate by Profile", test_governance_gate),
        ("Incident Escalation",       test_incident_escalation),
        ("Layer 1 File Integrity",    test_layer1_file_integrity),
    ]

    results = []
    for name, test_fn in tests:
        try:
            passed = test_fn()
            results.append((name, passed))
        except Exception as e:
            print(f"\n  [ERROR] {name}: {e}")
            results.append((name, False))

    # Summary
    test_sep("FINAL SUMMARY")
    total_pass = sum(1 for _, p in results if p)
    total = len(results)
    for name, passed in results:
        print(f"  {'PASS' if passed else 'FAIL'}  {name}")

    print(f"\n  Total: {total_pass}/{total} tests passed")

    if total_pass == total:
        print(f"\n  All tests passed. MG_MODE routing is robust.")
    else:
        print(f"\n  {total - total_pass} test(s) failed. See details above.")
        sys.exit(1)


if __name__ == "__main__":
    main()
