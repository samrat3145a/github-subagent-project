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
├── trace_id          : Correlation ID (required for both multi-agent and single-agent runs)
├── version           : Semantic version (MAJOR.MINOR.PATCH)
├── timestamp         : ISO-8601 when produced
├── state_before      : State at time of creation
├── state_after       : State after production
├── retry_count       : Number of attempts (0 for first try, max 3)
├── checksum          : SHA-256 of content (for integrity)
└── content           : The actual artifact payload (type-specific)
```

### Trace ID Policy
- `trace_id` remains mandatory to keep artifact lineage consistent.
- For **multi-agent** workflows: use a shared correlation ID across all related artifacts and handoffs.
- For **single-agent** workflows: generate a local trace ID at start and reuse it for all artifacts in that run.
- Recommended single-agent format: `trace_{agent_id}_{timestamp}` (example: `trace_agent_2_2026-02-21T12:30:00Z`).

### State Lifecycle
```
DRAFT → IN_REVIEW → VALIDATED → APPROVED → COMPLETE
  │         │           │          │
  └─────────┴───────────┴──────────┴──→ REJECTED (can return to DRAFT if retry_count < 3)
                                          │
                                          └──→ ESCALATED_TO_HUMAN (if retry_count >= 3)
```

### State Transition Rules
- `DRAFT → IN_REVIEW`: All required fields populated, type-specific rules pass
- `IN_REVIEW → VALIDATED`: Peer agent review passes, no blocking violations
- `VALIDATED → APPROVED`: Coordinator (Agent 8) or Orchestrator (Agent 4) signs off
- `APPROVED → COMPLETE`: All downstream dependencies satisfied
- `ANY → REJECTED`: Blocking violation detected, must return to DRAFT with fixes (increment retry_count)
- `REJECTED → ESCALATED_TO_HUMAN`: Circuit breaker tripped (retry_count >= 3), halt automated execution

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
  - solution_plan            : structured step-by-step plan derived from clarified requirements

TRANSITION RULES:
  ✅ Can transition to IN_REVIEW when:
     - open_questions is EMPTY (all questions resolved)
     - completeness_score >= 80
     - solution_plan is present with at least 1 numbered, actionable step
  ❌ BLOCKED if:
     - open_questions has any entries
     - completeness_score < 80
     - solution_plan is missing or empty
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

ARCHITECTURE QUALITY SCORE (0-100):
  This rubric is used for architecture quality checks and retakes.
  - Artifact contract completeness (all 7 required fields meaningful): 30 pts
  - Transition-rule readiness (tradeoffs, risks, components): 20 pts
  - Workflow + gate compliance (CONTEXT_CLEAR, RESEARCH_COMPLETE when applicable, checkpoints): 20 pts
  - Handoff readiness (Implementation→Testing/Efficiency package quality): 15 pts
  - Metadata envelope completeness (agent_id, artifact_type, project_id, trace_id, version,
    timestamp, state_before, state_after, retry_count, checksum): 15 pts

  Scoring guidance:
  - 100: All five areas fully satisfied with no inconsistencies
  - 90-99: Minor documentation/consistency gaps only
  - 70-89: One major area partially satisfied
  - <70: Multiple required areas missing or blocked
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
  - expected_load_profile       : {input_size_n, dataset_scale, operation_frequency}
  - bottleneck_predictions      : string[]
  - optimization_recommendations: {type, description, expected_gain}[]
      - description must name: (1) current approach, (2) proposed approach, (3) why it's better
      - expected_gain must be quantified (e.g., "O(n²) → O(n log n)", "saves ~200ms at n=10k") — vague terms like "faster" or "better" are not acceptable
  - cost_impact_estimate        : string (must include a concrete metric: time, memory, cost, or throughput)

TRANSITION RULES:
  ✅ Can transition to IN_REVIEW when: all 6 required fields populated — time_complexity_analysis,
     space_complexity_analysis, expected_load_profile, bottleneck_predictions,
     optimization_recommendations (at least 1), and cost_impact_estimate;
     all optimization_recommendations[].expected_gain are quantified; cost_impact_estimate includes a concrete metric
  ❌ BLOCKED if: any of the 6 required fields is empty or missing, or any expected_gain is vague, or cost_impact_estimate lacks a concrete metric
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
  ✅ Can transition to IN_REVIEW when: all 7 required fields populated — refined_scope,
     formal_requirements (all with priority), functional_requirements, non_functional_requirements,
     acceptance_criteria (≥1 per functional requirement), requirement_traceability, spec_version (semver format)
  ❌ BLOCKED if: any of the 7 required fields is empty or missing
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

ARTIFACT TYPE: "terminal_log"
REQUIRED FIELDS:
  - session_id         : string (unique per invocation)
  - command_executed   : string
  - output             : string
  - exit_code          : number
  - timestamp          : ISO-8601

NOTE: terminal_log entries are written directly — no IN_REVIEW gate required.
BLOCKED if: command_executed or output is missing.
```

### Standalone Agent — DSA Interview Coach
```
ALLOWED:
  - Ask MCQ questions via ask_questions tool (non-code) or chat (code-related)
  - Search web for DSA references and answer verification
  - Produce session assessment reports
  - Use todo list for session tracking
  - Read files for context

FORBIDDEN:
  - Create or edit project files
  - Execute terminal commands
  - Implement solutions
  - Set recommended options on quiz questions

ARTIFACT TYPE: "dsa_assessment"
REQUIRED FIELDS:
  - overall_score        : {correct: number, total: number, percentage: number}
  - difficulty_range     : {start: enum, end: enum, adaptations: number}
  - topic_scores         : {topic, questions_asked, correct, percentage}[]
  - weak_areas           : {topic, description, recommended_problems}[]
  - strong_areas         : string[]
  - recommendations      : {leetcode_problems: string[], concepts_to_review: string[], next_session_focus: string}
  - questions_asked      : number
  - hints_used           : number
  - early_stop           : boolean

TRANSITION RULES:
  ✅ Can transition to IN_REVIEW when:
     - At least 5 questions were asked and answered
     - overall_score is calculated
     - weak_areas is populated (empty list acceptable if no weak areas)
  ❌ BLOCKED if:
     - Fewer than 5 questions answered
     - Scores not calculated

NOTE: Standalone agent — not part of a fixed invocation sequence.
Invoked on-demand for interview preparation sessions.
```

### Standalone Agent — Workspace Quizmaster
```
ALLOWED:
  - Read files and search codebase (silent scan)
  - Ask MCQ questions via ask_questions tool
  - Produce knowledge assessment reports
  - Use todo list for tracking

FORBIDDEN:
  - Create or edit project files
  - Execute terminal commands
  - Implement solutions
  - Reveal answers during the quiz
  - Set recommended options on quiz questions

ARTIFACT TYPE: "knowledge_assessment"
REQUIRED FIELDS:
  - overall_score        : number (0-100)
  - rating               : enum (expert|proficient|developing|needs-review)
  - area_scores          : {area, score, max_score, questions_asked, correct, gaps}[]
  - knowledge_gaps       : {title, description, review_file}[]
  - strengths            : string[]
  - recommendations      : string[]
  - questions_asked      : number
  - questions_correct    : number
  - early_stop           : boolean

TRANSITION RULES:
  ✅ Can transition to IN_REVIEW when:
     - Workspace scan was performed before any questions were asked
     - At least 5 questions were asked and answered
     - overall_score is calculated
     - knowledge_gaps is populated (empty list acceptable if no gaps found)
  ❌ BLOCKED if:
     - Fewer than 5 questions answered
     - Workspace scan was skipped
     - Score not calculated

NOTE: Standalone agent — not part of a fixed invocation sequence.
Invoked on-demand to assess a user's understanding of their workspace.
```

---

## 3. Mandatory Precondition Gates

These gates BLOCK agent invocation until prerequisites are met. No exceptions.

### GATE: CONTEXT_CLARIFICATION
```
DESCRIPTION: All ambiguous requirements must be clarified before implementation
TRIGGER:
  STRICT  — Before invoking Agent 2 (Code Architect), Agent 4 (Orchestrator),
             Agent 5 (Efficiency Analyzer, pipeline mode), Agent 7 (Test Strategist),
             Agent 8 (Team Coordinator, before governance review)
  ADVISORY — Before invoking Agent 3 (Documentation Researcher),
              Agent 6 (Instruction Upgrader), Mule-to-Python Reviewer,
              Workspace Quizmaster, DSA Interview Coach
              (redirect to Context Clarifier only if request is vague/ambiguous;
               if clarification_report already exists in the handoff, use it directly)

REQUIRED:    CONTEXT_CLEAR checkpoint must be satisfied
ENFORCEMENT:
  STRICT agents   — invocation is BLOCKED if gate fails
  ADVISORY agents — agent self-assesses the request; redirects to Agent 1 if vague

CHECK:
  □ Agent 1 has produced a clarification_report
  □ clarification_report.open_questions is empty
  □ clarification_report.completeness_score >= 80
  □ User has confirmed understanding

BYPASS CONDITIONS (exceptional only):
  - User explicitly states "requirements are clear, skip clarification"
  - Task is a trivial/obvious operation (single file edit, typo fix)
  - ADVISORY agents with a clearly scoped standalone request (no clarification_report needed)
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

BYPASS CONDITIONS (none — this gate has no bypass):
  CAPABILITY_CHECK is enforced on every invocation without exception.
  If the task falls outside ALLOWED operations, redirect to the appropriate agent.
  Do NOT attempt the task and do NOT ask the user to override this gate.
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

### For Migration Review (MuleSoft → Python)
```
MANDATORY SEQUENCE:
  1. Mule-to-Python Reviewer        → Produces: migration_checklist + report file
  2. Agent 2 (Code Architect)       → Implement all ❌ Missing and ⚠️ Partial items
  3. Agent 7 (Test Strategist)      → Verify migrated Lambda code
  4. Agent 8 (Team Coordinator)     → Governance review

Note: Agent 1 (Context Clarifier) should be invoked first if MuleSoft and Python
paths are not yet known or the migration scope is ambiguous.
```

### Agent 9 — Terminal Logger: Invocation Notes
```
Agent 9 is invoked ON-DEMAND (not in a fixed sequence position).
TRIGGER: Any agent that needs to log terminal command execution.

INVOKED BY:
  - Agent 2 (Code Architect): when running build/test commands
  - Agent 7 (Test Strategist): when executing test suites
  - Agent 4 (Orchestrator): when tracking system health

Agent 9 does NOT block any dependency gate and has no exit checkpoint.
It operates in parallel with any agent that executes terminal commands.
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
