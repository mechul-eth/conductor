# Registry — Role Catalog

> The routing engine asks: "Who can do this?" Registry answers in <100ms. No guessing, no hallucinating roles.

> **Format note:** This catalog is markdown-based (tables + schema templates). An LLM agent can parse and query it directly. There is no separate YAML/JSON data file — this README is the single source of truth.

## Design Advisors (Layer 1 — do not rebuild)
- `agency-agents/` — 156 agent role definitions across 13 domains
- `agency-agents/strategy/nexus-strategy.md` — NEXUS multi-agent composition
- `agency-agents/strategy/coordination/agent-activation-prompts.md` — activation patterns
- `agency-agents/strategy/coordination/handoff-templates.md` — handoff patterns
- `gstack/` — 21 workflow skills with SKILL.md definitions

## Core Guarantees

1. **Single source of truth.** Every role Conductor can invoke is listed here with its capability fingerprint.
2. **LLM-parseable.** Structured markdown tables that any LLM-based routing algorithm (map/) can read and select roles from without additional tooling.
3. **Fallback chains.** Every role has a fallback — if unavailable, the next best option is declared.
4. **NEXUS-aware.** Roles are tagged by tier for Micro/Sprint/Full composition sizing.
5. **Manual sync required.** Registry reflects what exists in Layer 1 at time of last edit. If a role file is added or removed in agency-agents/, this README must be updated manually. No automated sync exists.

---

## Role Entry Schema

```yaml
role:
  id: <filename without .md>
  name: <human-readable name>
  domain: <primary domain category>
  path: <relative path from Conductor root>
  
  # Capability fingerprint (what map/ uses for routing)
  capabilities:
    primary: [<core capabilities>]
    secondary: [<supporting capabilities>]
    input_formats: [<what this role expects>]
    output_formats: [<what this role produces>]
  
  # NEXUS tier assignment
  tier: <core|operational|specialty|domain-extension>
  nexus_modes: [<Micro|Sprint|Full>]
  
  # Fallback chain (if this role is unavailable)
  fallback: <role_id of next best option>
  
  # Authority scope (from identity/)
  max_authority: <read-only|suggest|write-self|write-cross|approve|admin>
  
  # Regulated domain flags
  regulated_domains: [<domains where this role has special rules>]
```

---

## Agent Roles (156 roles across 13 domains)

### Engineering (23 roles) — Tier: Core

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `engineering-backend-architect` | Backend Architect | system design, API design, architecture decisions | engineering-software-architect | Micro+ |
| `engineering-software-architect` | Software Architect | architecture, patterns, system boundaries | engineering-senior-developer | Micro+ |
| `engineering-senior-developer` | Senior Developer | full-stack implementation, code review | engineering-frontend-developer | Micro+ |
| `engineering-frontend-developer` | Frontend Developer | UI implementation, component architecture, CSS | engineering-senior-developer | Sprint+ |
| `engineering-code-reviewer` | Code Reviewer | code quality, patterns, bug detection | engineering-senior-developer | Micro+ |
| `engineering-security-engineer` | Security Engineer | security audit, threat modeling, OWASP | engineering-threat-detection-engineer | Sprint+ |
| `engineering-devops-automator` | DevOps Automator | CI/CD, infrastructure, deployment | engineering-sre | Sprint+ |
| `engineering-sre` | Site Reliability Engineer | monitoring, reliability, incident response | engineering-devops-automator | Sprint+ |
| `engineering-data-engineer` | Data Engineer | pipelines, ETL, data architecture | engineering-database-optimizer | Sprint+ |
| `engineering-database-optimizer` | Database Optimizer | query optimization, schema design, indexing | engineering-data-engineer | Sprint+ |
| `engineering-ai-engineer` | AI Engineer | ML pipelines, model integration, embeddings | engineering-senior-developer | Sprint+ |
| `engineering-ai-data-remediation-engineer` | AI Data Remediation Engineer | data quality, anomaly routing, Ollama local | engineering-data-engineer | Full |
| `engineering-autonomous-optimization-architect` | Autonomous Optimization Architect | self-healing systems, adaptive optimization | engineering-software-architect | Full |
| `engineering-technical-writer` | Technical Writer | documentation, API docs, guides | engineering-senior-developer | Sprint+ |
| `engineering-git-workflow-master` | Git Workflow Master | branching, merge strategy, git operations | engineering-devops-automator | Full |
| `engineering-rapid-prototyper` | Rapid Prototyper | quick builds, POCs, MVPs | engineering-senior-developer | Sprint+ |
| `engineering-mobile-app-builder` | Mobile App Builder | iOS, Android, React Native, Flutter | engineering-frontend-developer | Full |
| `engineering-incident-response-commander` | Incident Response Commander | incident management, triage, resolution | engineering-sre | Sprint+ |
| `engineering-embedded-firmware-engineer` | Embedded Firmware Engineer | firmware, embedded systems, IoT | engineering-senior-developer | Full |
| `engineering-threat-detection-engineer` | Threat Detection Engineer | threat detection, SIEM, security monitoring | engineering-security-engineer | Full |
| `engineering-solidity-smart-contract-engineer` | Solidity Smart Contract Engineer | Solidity, EVM, smart contracts | engineering-senior-developer | Full |
| `engineering-feishu-integration-developer` | Feishu Integration Developer | Feishu/Lark APIs, bot development | engineering-backend-architect | Full |
| `engineering-wechat-mini-program-developer` | WeChat Mini Program Developer | WeChat mini programs, WXML/WXSS | engineering-frontend-developer | Full |

### Design (8 roles) — Tier: Operational

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `design-ux-architect` | UX Architect | information architecture, user flows, wireframes | design-ux-researcher | Sprint+ |
| `design-ux-researcher` | UX Researcher | user research, usability testing, personas | design-ux-architect | Sprint+ |
| `design-ui-designer` | UI Designer | visual design, component systems, tokens | design-ux-architect | Sprint+ |
| `design-brand-guardian` | Brand Guardian | brand consistency, style guides, voice | design-ui-designer | Full |
| `design-visual-storyteller` | Visual Storyteller | narrative visuals, illustration direction | design-image-prompt-engineer | Full |
| `design-image-prompt-engineer` | Image Prompt Engineer | AI image generation, prompt crafting | design-visual-storyteller | Full |
| `design-inclusive-visuals-specialist` | Inclusive Visuals Specialist | accessibility, inclusive design | design-ux-researcher | Full |
| `design-whimsy-injector` | Whimsy Injector | delight moments, micro-interactions, Easter eggs | design-ui-designer | Full |

### Marketing (27 roles) — Tier: Specialty

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `marketing-content-creator` | Content Creator | blog posts, articles, copy | marketing-social-media-strategist | Sprint+ |
| `marketing-seo-specialist` | SEO Specialist | SEO audit, keyword strategy, technical SEO | marketing-content-creator | Sprint+ |
| `marketing-growth-hacker` | Growth Hacker | growth loops, viral mechanics, A/B testing | marketing-social-media-strategist | Sprint+ |
| `marketing-social-media-strategist` | Social Media Strategist | social strategy, content calendar | marketing-content-creator | Sprint+ |
| `marketing-ai-citation-strategist` | AI Citation Strategist | AI visibility, LLM citations | marketing-seo-specialist | Full |
| `marketing-app-store-optimizer` | App Store Optimizer | ASO, app metadata, screenshots | marketing-seo-specialist | Full |
| `marketing-book-co-author` | Book Co-Author | book writing, chapter structure | marketing-content-creator | Full |
| `marketing-podcast-strategist` | Podcast Strategist | podcast planning, show notes, guest strategy | marketing-content-creator | Full |
| `marketing-linkedin-content-creator` | LinkedIn Content Creator | LinkedIn posts, thought leadership | marketing-social-media-strategist | Full |
| `marketing-twitter-engager` | Twitter Engager | Twitter/X strategy, threads, engagement | marketing-social-media-strategist | Full |
| `marketing-instagram-curator` | Instagram Curator | Instagram visual strategy, reels | marketing-social-media-strategist | Full |
| `marketing-reddit-community-builder` | Reddit Community Builder | Reddit strategy, community engagement | marketing-social-media-strategist | Full |
| `marketing-tiktok-strategist` | TikTok Strategist | TikTok content, trends, hooks | marketing-social-media-strategist | Full |
| `marketing-carousel-growth-engine` | Carousel Growth Engine | carousel content, slide design | marketing-content-creator | Full |
| `marketing-short-video-editing-coach` | Short Video Editing Coach | video editing guidance, reels/shorts | marketing-tiktok-strategist | Full |
| `marketing-livestream-commerce-coach` | Livestream Commerce Coach | live selling, stream strategy | marketing-social-media-strategist | Full |
| `marketing-baidu-seo-specialist` | Baidu SEO Specialist | Baidu search, Chinese SEO | marketing-seo-specialist | Full |
| `marketing-bilibili-content-strategist` | Bilibili Content Strategist | Bilibili platform, video strategy | marketing-social-media-strategist | Full |
| `marketing-china-ecommerce-operator` | China E-commerce Operator | Tmall, JD, Chinese e-commerce | marketing-cross-border-ecommerce | Full |
| `marketing-cross-border-ecommerce` | Cross-Border E-commerce | international e-commerce, logistics | marketing-growth-hacker | Full |
| `marketing-douyin-strategist` | Douyin Strategist | Douyin (Chinese TikTok) strategy | marketing-tiktok-strategist | Full |
| `marketing-kuaishou-strategist` | Kuaishou Strategist | Kuaishou platform strategy | marketing-social-media-strategist | Full |
| `marketing-private-domain-operator` | Private Domain Operator | WeChat groups, private traffic | marketing-social-media-strategist | Full |
| `marketing-wechat-official-account` | WeChat Official Account | WeChat content, mini-program links | marketing-social-media-strategist | Full |
| `marketing-weibo-strategist` | Weibo Strategist | Weibo platform strategy | marketing-social-media-strategist | Full |
| `marketing-xiaohongshu-specialist` | Xiaohongshu Specialist | RED/Xiaohongshu content strategy | marketing-social-media-strategist | Full |
| `marketing-zhihu-strategist` | Zhihu Strategist | Zhihu Q&A, long-form knowledge | marketing-content-creator | Full |

### Product (5 roles) — Tier: Operational

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `product-manager` | Product Manager | roadmap, prioritization, PRDs | product-sprint-prioritizer | Sprint+ |
| `product-sprint-prioritizer` | Sprint Prioritizer | backlog grooming, sprint planning | product-manager | Sprint+ |
| `product-feedback-synthesizer` | Feedback Synthesizer | user feedback analysis, themes | product-manager | Full |
| `product-trend-researcher` | Trend Researcher | market trends, competitive intel | product-manager | Full |
| `product-behavioral-nudge-engine` | Behavioral Nudge Engine | behavioral design, nudge strategy | product-manager | Full |

### Testing (8 roles) — Tier: Operational

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `testing-reality-checker` | Reality Checker | assumption testing, fact verification | testing-evidence-collector | Sprint+ |
| `testing-evidence-collector` | Evidence Collector | data gathering, citation building | testing-reality-checker | Sprint+ |
| `testing-api-tester` | API Tester | API testing, contract testing | testing-test-results-analyzer | Sprint+ |
| `testing-accessibility-auditor` | Accessibility Auditor | WCAG audit, a11y testing | testing-reality-checker | Full |
| `testing-performance-benchmarker` | Performance Benchmarker | load testing, performance profiling | testing-api-tester | Full |
| `testing-test-results-analyzer` | Test Results Analyzer | test analysis, coverage gaps | testing-evidence-collector | Full |
| `testing-tool-evaluator` | Tool Evaluator | tool assessment, comparison | testing-reality-checker | Full |
| `testing-workflow-optimizer` | Workflow Optimizer | process optimization, bottleneck analysis | testing-reality-checker | Full |

### Sales (8 roles) — Tier: Specialty

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `sales-deal-strategist` | Deal Strategist | deal planning, objection handling | sales-coach | Sprint+ |
| `sales-coach` | Sales Coach | sales skills, call review | sales-deal-strategist | Sprint+ |
| `sales-engineer` | Sales Engineer | technical demos, POC support | sales-deal-strategist | Full |
| `sales-outbound-strategist` | Outbound Strategist | outbound sequences, cold outreach | sales-deal-strategist | Full |
| `sales-account-strategist` | Account Strategist | account planning, expansion | sales-deal-strategist | Full |
| `sales-discovery-coach` | Discovery Coach | discovery calls, qualification | sales-coach | Full |
| `sales-pipeline-analyst` | Pipeline Analyst | pipeline metrics, forecasting | sales-deal-strategist | Full |
| `sales-proposal-strategist` | Proposal Strategist | proposal writing, RFP responses | sales-deal-strategist | Full |

### Project Management (6 roles) — Tier: Operational

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `project-manager-senior` | Senior Project Manager | project planning, risk management | project-management-project-shepherd | Sprint+ |
| `project-management-project-shepherd` | Project Shepherd | project tracking, status updates | project-manager-senior | Sprint+ |
| `project-management-jira-workflow-steward` | Jira Workflow Steward | Jira configuration, workflow design | project-manager-senior | Full |
| `project-management-experiment-tracker` | Experiment Tracker | A/B test tracking, experiment log | project-manager-senior | Full |
| `project-management-studio-operations` | Studio Operations | studio scheduling, resource allocation | project-management-studio-producer | Full |
| `project-management-studio-producer` | Studio Producer | production management, delivery | project-management-studio-operations | Full |

### Support (6 roles) — Tier: Operational

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `support-support-responder` | Support Responder | customer support, ticket handling | support-analytics-reporter | Sprint+ |
| `support-analytics-reporter` | Analytics Reporter | reporting, dashboards, metrics | support-support-responder | Sprint+ |
| `support-finance-tracker` | Finance Tracker | budget tracking, cost analysis | support-analytics-reporter | Full |
| `support-infrastructure-maintainer` | Infrastructure Maintainer | infra maintenance, updates | support-support-responder | Full |
| `support-legal-compliance-checker` | Legal Compliance Checker | compliance audit, regulation check | support-support-responder | Full |
| `support-executive-summary-generator` | Executive Summary Generator | executive reports, summaries | support-analytics-reporter | Full |

### Paid Media (7 roles) — Tier: Specialty

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `paid-media-ppc-strategist` | PPC Strategist | Google Ads, search campaigns | paid-media-auditor | Sprint+ |
| `paid-media-auditor` | Paid Media Auditor | account audit, waste identification | paid-media-ppc-strategist | Sprint+ |
| `paid-media-paid-social-strategist` | Paid Social Strategist | Meta, LinkedIn, TikTok ads | paid-media-ppc-strategist | Full |
| `paid-media-creative-strategist` | Creative Strategist | ad creative, copy, visual direction | paid-media-paid-social-strategist | Full |
| `paid-media-programmatic-buyer` | Programmatic Buyer | DSP, programmatic strategy | paid-media-ppc-strategist | Full |
| `paid-media-search-query-analyst` | Search Query Analyst | search term analysis, negatives | paid-media-ppc-strategist | Full |
| `paid-media-tracking-specialist` | Tracking Specialist | conversion tracking, attribution | paid-media-auditor | Full |

### Spatial Computing (6 roles) — Tier: Domain Extension

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `visionos-spatial-engineer` | VisionOS Spatial Engineer | visionOS, RealityKit, SwiftUI 3D | xr-immersive-developer | Full |
| `xr-immersive-developer` | XR Immersive Developer | WebXR, Three.js, immersive dev | visionos-spatial-engineer | Full |
| `xr-interface-architect` | XR Interface Architect | spatial UI, 3D interaction patterns | xr-immersive-developer | Full |
| `xr-cockpit-interaction-specialist` | XR Cockpit Specialist | cockpit UI, automotive XR | xr-interface-architect | Full |
| `macos-spatial-metal-engineer` | macOS Spatial Metal Engineer | Metal, GPU compute, spatial macOS | visionos-spatial-engineer | Full |
| `terminal-integration-specialist` | Terminal Integration Specialist | terminal UX in spatial contexts | xr-interface-architect | Full |

### Game Development (20 roles) — Tier: Domain Extension

> **Path note**: Game-dev roles are split across subdirectories under `agency-agents/game-development/`.
> Top-level (5): `game-designer`, `narrative-designer`, `level-designer`, `technical-artist`, `game-audio-engineer`
> `unity/` (4): unity-architect, unity-editor-tool-developer, unity-multiplayer-engineer, unity-shader-graph-artist
> `unreal-engine/` (4): unreal-systems-engineer, unreal-world-builder, unreal-multiplayer-architect, unreal-technical-artist
> `godot/` (3): godot-gameplay-scripter, godot-multiplayer-engineer, godot-shader-developer
> `roblox-studio/` (3): roblox-experience-designer, roblox-systems-scripter, roblox-avatar-creator
> `blender/` (1): blender-addon-engineer

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `game-designer` | Game Designer | game mechanics, systems design | narrative-designer | Full |
| `narrative-designer` | Narrative Designer | story, dialogue, world-building | game-designer | Full |
| `level-designer` | Level Designer | level layout, pacing, encounter design | game-designer | Full |
| `technical-artist` | Technical Artist | shaders, VFX, art pipeline | game-designer | Full |
| `game-audio-engineer` | Game Audio Engineer | game audio, sound design, music | game-designer | Full |
| `unity-architect` | Unity Architect | Unity architecture, C#, ECS | unity-editor-tool-developer | Full |
| `unity-editor-tool-developer` | Unity Editor Tool Developer | Unity editor extensions, custom tools | unity-architect | Full |
| `unity-multiplayer-engineer` | Unity Multiplayer Engineer | Netcode, Mirror, multiplayer | unity-architect | Full |
| `unity-shader-graph-artist` | Unity Shader Graph Artist | Unity shaders, visual effects | technical-artist | Full |
| `unreal-systems-engineer` | Unreal Systems Engineer | UE5, C++, Blueprints | unreal-world-builder | Full |
| `unreal-world-builder` | Unreal World Builder | level design, world composition | unreal-systems-engineer | Full |
| `unreal-multiplayer-architect` | Unreal Multiplayer Architect | UE5 replication, Lyra framework | unreal-systems-engineer | Full |
| `unreal-technical-artist` | Unreal Technical Artist | UE5 materials, Niagara VFX | technical-artist | Full |
| `godot-gameplay-scripter` | Godot Gameplay Scripter | GDScript, Godot architecture | godot-multiplayer-engineer | Full |
| `godot-multiplayer-engineer` | Godot Multiplayer Engineer | Godot multiplayer, ENet | godot-gameplay-scripter | Full |
| `godot-shader-developer` | Godot Shader Developer | Godot shaders, visual effects | technical-artist | Full |
| `roblox-experience-designer` | Roblox Experience Designer | Roblox Studio, Luau, experience design | roblox-systems-scripter | Full |
| `roblox-systems-scripter` | Roblox Systems Scripter | Luau scripting, game systems | roblox-experience-designer | Full |
| `roblox-avatar-creator` | Roblox Avatar Creator | Roblox avatars, UGC | roblox-experience-designer | Full |
| `blender-addon-engineer` | Blender Addon Engineer | Blender Python API, addon dev | technical-artist | Full |

### Academic (5 roles) — Tier: Domain Extension

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `academic-historian` | Historian | historical research, periodization | academic-narratologist | Full |
| `academic-psychologist` | Psychologist | behavioral analysis, cognitive patterns | academic-anthropologist | Full |
| `academic-anthropologist` | Anthropologist | cultural analysis, ethnography | academic-psychologist | Full |
| `academic-narratologist` | Narratologist | narrative structure, story analysis | academic-historian | Full |
| `academic-geographer` | Geographer | spatial analysis, GIS, mapping | academic-historian | Full |

### Specialized (27 roles) — Tier: Mixed

| Role ID | Name | Primary Capabilities | Fallback | NEXUS |
|---------|------|---------------------|----------|-------|
| `agents-orchestrator` | Agents Orchestrator | multi-agent coordination, NEXUS | specialized-workflow-architect | Sprint+ |
| `specialized-workflow-architect` | Workflow Architect | workflow design, process automation | agents-orchestrator | Sprint+ |
| `specialized-mcp-builder` | MCP Builder | MCP server development, tool creation | engineering-backend-architect | Sprint+ |
| `specialized-model-qa` | Model QA | LLM evaluation, prompt testing | testing-reality-checker | Sprint+ |
| `agentic-identity-trust` | Agentic Identity & Trust | identity management, RBAC, trust | engineering-security-engineer | Full |
| `automation-governance-architect` | Automation Governance Architect | automation assessment, value gates | specialized-workflow-architect | Full |
| `identity-graph-operator` | Identity Graph Operator | entity resolution, graph operations | agentic-identity-trust | Full |
| `lsp-index-engineer` | LSP Index Engineer | language server, code intelligence | engineering-software-architect | Full |
| `zk-steward` | Zettelkasten Steward | knowledge management, Luhmann method | specialized-workflow-architect | Full |
| `blockchain-security-auditor` | Blockchain Security Auditor | smart contract audit, DeFi security | engineering-security-engineer | Full |
| `compliance-auditor` | Compliance Auditor | regulatory compliance, audit | support-legal-compliance-checker | Full |
| `healthcare-marketing-compliance` | Healthcare Marketing Compliance | HIPAA, FDA marketing rules | compliance-auditor | Full |
| `specialized-salesforce-architect` | Salesforce Architect | Salesforce platform, Apex, LWC | engineering-backend-architect | Full |
| `specialized-developer-advocate` | Developer Advocate | developer relations, docs, demos | engineering-technical-writer | Full |
| `specialized-document-generator` | Document Generator | document automation, templates | engineering-technical-writer | Full |
| `specialized-cultural-intelligence-strategist` | Cultural Intelligence Strategist | cross-cultural strategy | academic-anthropologist | Full |
| `specialized-french-consulting-market` | French Consulting Market | French market consulting | specialized-cultural-intelligence-strategist | Full |
| `specialized-korean-business-navigator` | Korean Business Navigator | Korean market guidance | specialized-cultural-intelligence-strategist | Full |
| `corporate-training-designer` | Corporate Training Designer | L&D, training programs | specialized-document-generator | Full |
| `recruitment-specialist` | Recruitment Specialist | hiring, interview design | project-manager-senior | Full |
| `study-abroad-advisor` | Study Abroad Advisor | education consulting, admissions | specialized-document-generator | Full |
| `government-digital-presales-consultant` | Government Digital Presales | government tech presales | sales-engineer | Full |
| `supply-chain-strategist` | Supply Chain Strategist | supply chain optimization | support-finance-tracker | Full |
| `accounts-payable-agent` | Accounts Payable Agent | AP processing, invoice handling | support-finance-tracker | Full |
| `data-consolidation-agent` | Data Consolidation Agent | data merging, deduplication | engineering-data-engineer | Full |
| `report-distribution-agent` | Report Distribution Agent | report routing, scheduling | support-analytics-reporter | Full |
| `sales-data-extraction-agent` | Sales Data Extraction Agent | sales data mining, CRM extraction | sales-pipeline-analyst | Full |

---

## Workflow Skills (21 gstack skills)

| Skill ID | Name | Phase | When to Invoke |
|----------|------|-------|---------------|
| `office-hours` | YC Office Hours | 0 — Discovery | New project or feature ideation |
| `plan-ceo-review` | CEO Review | 1 — Strategy | Rethink scope, find 10-star product |
| `plan-design-review` | Design Review | 1 — Strategy | UX/UI review, design rating |
| `plan-eng-review` | Eng Review | 1 — Strategy | Architecture, data flow, edge cases |
| `design-consultation` | Design Consultation | 2 — Foundation | Interactive design decisions |
| `design-review` | Design Review | 2 — Foundation | Rate and improve design |
| `careful` | Careful Build | 3 — Build | Methodical, multi-step builds |
| `codex` | Codex Build | 3 — Build | Parallel task execution via Codex CLI |
| `review` | Code Review | 4 — Hardening | Automated code review + fix |
| `guard` | Guard | 4 — Hardening | Security + quality enforcement |
| `qa` | QA | 4 — Hardening | Browser-based testing + validation |
| `qa-only` | QA Only | 4 — Hardening | QA without code changes |
| `investigate` | Investigate | 4 — Hardening | Deep code investigation |
| `ship` | Ship | 5 — Launch | Test + PR + deploy |
| `document-release` | Document Release | 5 — Launch | Release notes, changelog |
| `freeze` | Freeze | 6 — Operate | Lock deployments |
| `unfreeze` | Unfreeze | 6 — Operate | Unlock deployments |
| `retro` | Retrospective | 6 — Operate | Sprint retrospective |
| `browse` | Browse | Utility | Headless browser automation |
| `setup-browser-cookies` | Setup Browser Cookies | Utility | Browser auth for QA |
| `gstack-upgrade` | Upgrade | Utility | Self-update gstack |

---

## NEXUS Mode Composition

### Micro Mode (5–10 agents)
Core engineering roles + code reviewer + one testing role. For focused, single-feature work.

**Default composition:**
- engineering-backend-architect OR engineering-frontend-developer (based on task)
- engineering-senior-developer
- engineering-code-reviewer
- testing-reality-checker
- product-manager (if product decisions needed)

### Sprint Mode (15–25 agents)
Core + operational roles. For full sprint cycles with planning, building, and shipping.

**Adds to Micro:**
- design-ux-architect, design-ui-designer
- engineering-devops-automator, engineering-security-engineer
- testing-api-tester, testing-evidence-collector
- project-manager-senior
- support-analytics-reporter
- marketing-content-creator (if content sprint)
- All gstack workflow skills

### Full Mode (all available agents)
All 156 agent roles + all 21 workflow skills. For enterprise-scale, multi-domain initiatives.

---

## Routing Lookup Interface

map/ queries registry/ with this contract:

```
Input:  { intent: string, domain: string, nexus_mode: string }
Output: { 
  recommended_roles: [role_id],
  fallback_roles: [role_id],  
  workflow_skills: [skill_id],
  confidence: float 
}
```

**Selection algorithm:**
1. Parse intent → extract capability keywords
2. Filter by nexus_mode (Micro / Sprint / Full)
3. Match capabilities against role fingerprints
4. Return minimum set (don't over-assign)
5. Attach fallback chain for each selected role

---

## Integration Points

| Component | How registry/ interacts |
|-----------|------------------------|
| `map/` | map/ queries registry/ for role selection during pre-execution |
| `identity/` | identity/ validates that invoked roles exist in registry/ |
| `profiles/` | Profile's NEXUS mode filters which roles are available |
| `session/` | Session records which roles were invoked per task |
| `activation/` | Activation loads registry/ on bootstrap |
| `conductor/` | conductor/ uses registry/ to validate routing decisions |
