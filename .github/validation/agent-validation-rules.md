# Agent Validation Rules Framework

> **Version**: 1.0.0 | **Last Updated**: 2026-02-18
> This is the single source of truth for all agent invocation and artifact validation rules.
> Every agent MUST reference this file before executing any task.

---

## 1. Global Artifact Schema

Every artifact produced by any agent MUST include this metadata envelope. If any field is missing, the artifact is **INVALID** and cannot transition states.

```
ARTIFACT ENVELOPE (MANDATORY):
├── agent_id          : Which agent produced this (e.g., "agent_1")
├── artifact_type     : What was produced (must match agent's allowed types)
├── project_id        : Which project this belongs to
├── version           : Semantic version (MAJOR.MINOR.PATCH)
├── timestamp         : ISO-8601 when produced
├── state_before      : State at time of creation
├── state_after       : State after production
├── checksum          : SHA-256 of content (for integrity)
└── content           : The actual artifact payload (type-specific)
```

### State Lifecycle
```
DRAFT → IN_REVIEW → VALIDATED → APPROVED → COMPLETE
  │         │           │          │
  └─────────┴───────────┴──────────┴──→ REJECTED (can return to DRAFT)
```

### State Transition Rules
- `DRAFT → IN_REVIEW`: All required fields populated, type-specific rules pass
- `IN_REVIEW → VALIDATED`: Peer agent review passes, no blocking violations
- `VALIDATED → APPROVED`: Coordinator (Agent 8) or Orchestrator (Agent 4) signs off
- `APPROVED → COMPLETE`: All downstream dependencies satisfied
- `ANY → REJECTED`: Blocking violation detected, must return to DRAFT with fixes

---

## 2. Agent Capability Matrix

Each agent has STRICT boundaries. An agent MUST NOT perform operations outside its declared capabilities.

### Agent 1 — Context Clarifier
```
ALLOWED:
  - Ask clarifying questions
  - Analyze requirements for ambiguity
  - Document clarification results
  - Read files and search codebase for context

FORBIDDEN:
  - Execute terminal commands
  - Create or edit files
  - Implement solutions
  - Make architectural decisions

ARTIFACT TYPE: "clarification_report"
REQUIRED FIELDS:
  - scope                    : string (what is being clarified)
  - objectives               : string[] (identified goals)
  - non_goals                : string[] (explicitly excluded)
  - constraints              : string[] (limitations identified)
  - assumptions              : string[] (documented assumptions)
  - dependencies             : string[] (identified dependencies)
  - success_criteria         : string[] (how to measure completion)
  - edge_cases_identified    : string[] (boundary scenarios found)
  - open_questions           : string[] (remaining unknowns)
  - risk_flags               : {type, description, severity}[]
  - completeness_score       : number (0-100)

TRANSITION RULES:
  ✅ Can transition to IN_REVIEW when:
     - open_questions is EMPTY (all questions resolved)
     - completeness_score >= 80
  ❌ BLOCKED if:
     - open_questions has any entries
     - completeness_score < 80
```

### Agent 2 — Code Architect
```
ALLOWED:
  - Write and edit code
  - Create files and directories
  - Apply design patterns
  - Refactor existing code
  - Run terminal commands for building/testing

FORBIDDEN:
  - Proceed without clear requirements (CONTEXT_CLEAR gate)
  - Skip architecture planning for complex tasks
  - Ignore test considerations

ARTIFACT TYPE: "architecture_design"
REQUIRED FIELDS:
  - architecture_style       : enum (monolith|modular|microservices|event-driven|hybrid)
  - high_level_components    : {name, responsibility, interfaces}[]
  - data_flow_description    : string
  - design_patterns_used     : string[]
  - key_decisions            : {decision, alternatives_considered, tradeoffs, justification}[]
  - risk_assessment          : {risk, impact, mitigation}[]
  - scalability_strategy     : string

TRANSITION RULES:
  ✅ Can transition to IN_REVIEW when:
     - Every key_decision includes at least 1 tradeoff
     - risk_assessment has at least 1 entry
     - high_level_components is non-empty
  ❌ BLOCKED if:
     - Any key_decision has empty tradeoffs
     - risk_assessment is empty
     - CONTEXT_CLEAR checkpoint not satisfied
```

### Agent 3 — Documentation Researcher
```
ALLOWED:
  - Search web and documentation
  - Read files and codebases
  - Compile research summaries
  - Verify source credibility

FORBIDDEN:
  - Create or edit project files
  - Execute terminal commands
  - Make implementation decisions

ARTIFACT TYPE: "research_summary"
REQUIRED FIELDS:
  - sources                  : {name, url, version, credibility_score}[]
  - best_practices           : string[]
  - anti_patterns            : string[]
  - recommended_patterns     : string[]
  - comparative_analysis     : {option, pros, cons, fit_score}[]
  - gaps_or_uncertainties    : string[]

TRANSITION RULES:
  ✅ Can transition to IN_REVIEW when:
     - sources has at least 2 entries
     - comparative_analysis has at least 1 entry
     - All sources have credibility_score > 0
  ❌ BLOCKED if:
     - Fewer than 2 sources
     - No comparative analysis provided
```

### Agent 4 — Orchestrator
```
ALLOWED:
  - Plan and delegate tasks
  - Coordinate agent workflows
  - Track progress via todo lists
  - Read files and search codebase

FORBIDDEN:
  - Implement code directly
  - Edit files (delegate to Agent 2/6/7)
  - Conduct research (delegate to Agent 3)

ARTIFACT TYPE: "execution_plan"
REQUIRED FIELDS:
  - execution_mode           : enum (small|medium|large)
  - task_breakdown           : {task_id, description, depends_on, assigned_agent}[]
  - parallelizable_tasks     : string[] (task IDs)
  - milestones               : string[]
  - rollback_strategy        : string

TRANSITION RULES:
  ✅ Can transition to IN_REVIEW when:
     - No circular dependencies in task_breakdown
     - Every task has an assigned_agent
     - At least 1 milestone defined
  ❌ BLOCKED if:
     - Circular dependency detected
     - Any task missing assigned_agent
```

### Agent 5 — Efficiency Analyzer
```
ALLOWED:
  - Analyze algorithm complexity
  - Profile performance characteristics
  - Compare alternative approaches
  - Read files and search codebase

FORBIDDEN:
  - Implement optimizations (recommend only)
  - Create or edit files
  - Execute production code

ARTIFACT TYPE: "performance_analysis"
REQUIRED FIELDS:
  - time_complexity_analysis    : string[]
  - space_complexity_analysis   : string[]
  - expected_load_profile       : {concurrent_users, peak_requests_per_second}
  - bottleneck_predictions      : string[]
  - optimization_recommendations: {type, description, expected_gain}[]
  - cost_impact_estimate        : string

TRANSITION RULES:
  ✅ Can transition to IN_REVIEW when:
     - At least 1 optimization_recommendation provided
     - expected_load_profile is fully specified
     - time_complexity_analysis is non-empty
  ❌ BLOCKED if:
     - No optimization recommendations
     - Load profile is missing
```

### Agent 6 — Instruction Upgrader
```
ALLOWED:
  - Analyze and refine instructions
  - Create and edit instruction/documentation files
  - Adapt requirements to context
  - Create specification documents

FORBIDDEN:
  - Write application code
  - Execute terminal commands
  - Make architectural decisions

ARTIFACT TYPE: "refined_specification"
REQUIRED FIELDS:
  - refined_scope              : string
  - formal_requirements        : {id, description, priority}[]
  - functional_requirements    : string[]
  - non_functional_requirements: string[]
  - acceptance_criteria        : string[]
  - requirement_traceability   : {original_reference, mapped_requirement_id}[]
  - spec_version               : semver

TRANSITION RULES:
  ✅ Can transition to IN_REVIEW when:
     - All formal_requirements have a priority assigned
     - At least 1 acceptance_criteria per functional_requirement
     - spec_version follows semver format
  ❌ BLOCKED if:
     - Any formal_requirement missing priority
     - Functional requirements lack acceptance criteria
```

### Agent 7 — Test Strategist
```
ALLOWED:
  - Design test strategies and plans
  - Create and edit test files
  - Execute tests
  - Analyze test results

FORBIDDEN:
  - Implement production code
  - Make architectural decisions
  - Skip strategy clarification phase

ARTIFACT TYPE: "test_strategy"
REQUIRED FIELDS:
  - test_levels              : {unit, integration, e2e, performance} (each string[])
  - edge_cases               : string[]
  - mocking_strategy         : string
  - coverage_target_percentage: number (0-100)
  - test_data_strategy       : string
  - regression_plan          : string

TRANSITION RULES:
  ✅ Can transition to IN_REVIEW when:
     - coverage_target_percentage >= 70
     - edge_cases is non-empty
     - At least 1 test level has entries
  ❌ BLOCKED if:
     - coverage_target_percentage < 70
     - edge_cases is empty
```

### Agent 8 — Team Coordinator
```
ALLOWED:
  - Coordinate multi-agent workflows
  - Manage project governance
  - Approve/reject artifacts
  - Track progress and quality gates

FORBIDDEN:
  - Implement code directly
  - Conduct research
  - Edit production files

ARTIFACT TYPE: "governance_report"
REQUIRED FIELDS:
  - state_history            : string[]
  - artifact_chain_integrity : enum (valid|invalid)
  - quality_gate_results     : {gate_name, status, notes}[]
  - policy_violations        : string[]
  - approval_status          : enum (approved|rejected|needs_revision)

TRANSITION RULES:
  ✅ Can reach COMPLETE when:
     - approval_status is "approved"
     - artifact_chain_integrity is "valid"
     - All quality_gate_results have status "pass"
  ❌ BLOCKED if:
     - approval_status is not "approved"
     - Any quality gate has status "fail"
```

### Agent 9 — Terminal Logger
```
ALLOWED:
  - Log terminal commands and outputs
  - Create and edit log files
  - Execute monitoring commands
  - Track system health metrics

FORBIDDEN:
  - Make decisions about implementation
  - Modify production code
  - Override other agents' decisions
```

---

## 3. Mandatory Precondition Gates

These gates BLOCK agent invocation until prerequisites are met. No exceptions.

### GATE: CONTEXT_CLARIFICATION
```
DESCRIPTION: All ambiguous requirements must be clarified before implementation
TRIGGER:     Before invoking Agent 2, Agent 4, Agent 5, Agent 7
REQUIRED:    CONTEXT_CLEAR checkpoint must be satisfied
ENFORCEMENT: STRICT — invocation is BLOCKED if gate fails

CHECK:
  □ Agent 1 has produced a clarification_report
  □ clarification_report.open_questions is empty
  □ clarification_report.completeness_score >= 80
  □ User has confirmed understanding

BYPASS CONDITIONS (exceptional only):
  - User explicitly states "requirements are clear, skip clarification"
  - Task is a trivial/obvious operation (single file edit, typo fix)
```

### GATE: RESEARCH_COMPLETE
```
DESCRIPTION: Research must complete before implementation begins
TRIGGER:     Before invoking Agent 2 for implementation tasks
REQUIRED:    Agent 3 has produced a research_summary
ENFORCEMENT: STRICT for new technologies, ADVISORY for familiar patterns

CHECK:
  □ research_summary has at least 2 verified sources
  □ comparative_analysis has at least 1 entry
  □ gaps_or_uncertainties documented and acknowledged
```

### GATE: CAPABILITY_CHECK
```
DESCRIPTION: Agent can only perform operations within declared capabilities
TRIGGER:     Every agent invocation
REQUIRED:    Task matches agent's ALLOWED operations
ENFORCEMENT: STRICT — always enforced

CHECK:
  □ Requested task falls within agent's ALLOWED list
  □ Task does NOT match any FORBIDDEN operation
  □ Required tools are available to the agent
```

---

## 4. Sequential Dependency Rules

These define the ORDER in which agents must be invoked for different workflow types.

### For New Feature Implementation
```
MANDATORY SEQUENCE:
  1. Agent 1 (Context Clarifier)    → Produces: clarification_report
  2. Agent 3 (Documentation Researcher) → Produces: research_summary
  3. Agent 6 (Instruction Upgrader) → Produces: refined_specification
  4. Agent 4 (Orchestrator)         → Produces: execution_plan
  5. Agent 2 (Code Architect)       → Produces: architecture_design + code
  6. Agent 5 (Efficiency Analyzer)  → Produces: performance_analysis
  7. Agent 7 (Test Strategist)      → Produces: test_strategy + tests
  8. Agent 8 (Team Coordinator)     → Produces: governance_report

PARALLEL OPPORTUNITIES:
  - Steps 2 + 3 can run in parallel (research + spec refinement)
  - Steps 5 + 7 can run in parallel (analysis + testing)
```

### For Bug Fix
```
MANDATORY SEQUENCE:
  1. Agent 1 (Context Clarifier)    → Clarify bug report
  2. Agent 2 (Code Architect)       → Implement fix
  3. Agent 7 (Test Strategist)      → Verify fix + regression tests

CONTEXT_CLARIFICATION gate: Can be bypassed if bug report is clear
```

### For Refactoring
```
MANDATORY SEQUENCE:
  1. Agent 5 (Efficiency Analyzer)  → Analyze current code
  2. Agent 2 (Code Architect)       → Implement refactoring
  3. Agent 7 (Test Strategist)      → Verify no regressions
  4. Agent 5 (Efficiency Analyzer)  → Verify improvement
```

---

## 5. Validation Decision Trees

### Should I Proceed? (Every Agent, Every Task)
```
START: Task Received
│
├─ Q: Is this task within my ALLOWED capabilities?
│  ├─ NO → STOP. Return: "Task outside my capabilities. 
│  │        Recommend delegating to [appropriate agent]."
│  └─ YES → Continue
│
├─ Q: Does this task match any FORBIDDEN operation?
│  ├─ YES → STOP. Return: "This operation is restricted for my role.
│  │         Delegate to [appropriate agent]."
│  └─ NO → Continue
│
├─ Q: Are all prerequisite gates satisfied?
│  ├─ NO → STOP. Return: "Prerequisite gate [X] not satisfied.
│  │        Required: [specific checkpoint]. 
│  │        Action: Invoke [agent] to satisfy prerequisite."
│  └─ YES → Continue
│
├─ Q: Is required context available?
│  ├─ NO → Gather context via search/read tools
│  │  └─ Still insufficient? → Invoke Agent 1 for clarification
│  └─ YES → Continue
│
└─ PROCEED with task execution
```

### Is My Artifact Ready for Transition?
```
START: Artifact Produced
│
├─ Q: Are all REQUIRED FIELDS populated?
│  ├─ NO → Fill missing fields before proceeding
│  └─ YES → Continue
│
├─ Q: Do type-specific TRANSITION RULES pass?
│  ├─ NO → Address blocking conditions:
│  │  ├─ List specific failures
│  │  ├─ Recommend corrective actions
│  │  └─ Return to DRAFT state
│  └─ YES → Continue
│
├─ Q: Is the artifact internally consistent?
│  ├─ NO → Resolve inconsistencies
│  └─ YES → Continue
│
└─ TRANSITION artifact to next state
```

---

## 6. Error Handling Rules

### Escalation Matrix
```
LEVEL 1 — Self-Recovery:
  TRIGGER: Temporary failures, missing context
  ACTION:  Retry with broader search, gather more context
  LIMIT:   2 retry attempts

LEVEL 2 — Peer Agent:
  TRIGGER: Task partially outside capabilities
  ACTION:  Delegate specific subtask to appropriate agent
  LIMIT:   1 delegation attempt

LEVEL 3 — Coordinator:
  TRIGGER: Validation failures, agent conflicts, blocked gates
  ACTION:  Escalate to Agent 8 (Team Coordinator) or Agent 4 (Orchestrator)
  INCLUDE: Full context dump, attempted actions, specific blocker

LEVEL 4 — Default Copilot:
  TRIGGER: System failures, unresolvable conflicts, all agents exhausted
  ACTION:  Escalate to default Copilot agent
  INCLUDE: Complete state history, all agent outputs, failure analysis
```

### Error Communication Format
When reporting errors, ALWAYS include:
```
ERROR REPORT:
├── error_type          : What category of error
├── error_description   : What went wrong
├── attempted_resolution: What was tried to fix it
├── escalation_required : boolean
├── affected_components : Which agents/artifacts impacted
└── recommended_action  : What should happen next
```

---

## 7. Quality Gates

These gates are checked by Agent 8 (Team Coordinator) before final approval.

### Gate: COMPLETENESS
```
CHECK: All required artifacts produced for the workflow type
PASS:  Every mandatory agent in the sequence has produced its artifact
FAIL:  Any mandatory artifact is missing
```

### Gate: CONSISTENCY
```
CHECK: All artifacts reference consistent requirements and decisions
PASS:  No contradictions between artifacts
FAIL:  Conflicting information detected between agent outputs
```

### Gate: TRACEABILITY
```
CHECK: Every requirement can be traced to implementation and tests
PASS:  Full trace from requirement → design → code → test
FAIL:  Any requirement without complete trace
```

### Gate: TRANSITION_INTEGRITY
```
CHECK: All state transitions followed legal paths
PASS:  Every artifact's state history shows valid transitions
FAIL:  Any illegal state transition detected
```
