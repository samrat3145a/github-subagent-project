# Agent Coordination Protocol Templates

> **Version**: 1.0.0 | **Last Updated**: 2026-02-18
> Standardized templates for agent-to-agent communication, handoffs, and coordination.
> Every handoff between agents MUST follow these protocols.

---

## 1. Agent Handoff Protocol

When transferring work from one agent to another, the handing-off agent MUST produce a handoff package that includes ALL of the following fields. A handoff with missing fields is **INVALID** and the receiving agent MUST reject it.

### Required Handoff Fields
```
HANDOFF PACKAGE:
├── handoff_id           : Unique identifier (format: "handoff_{from}_{to}_{timestamp}")
├── from_agent           : Agent ID producing the handoff
├── to_agent             : Agent ID receiving the handoff
├── timestamp            : ISO-8601 when handoff was created
├── task_summary         : What was the original task
├── completed_work       : What has been done (list of deliverables)
├── remaining_work       : What still needs to be done (specific items)
├── deliverables         : Artifacts produced (with references)
├── context_state        : Current project state snapshot
├── next_agent_requirements: What the receiving agent specifically needs to do
├── success_criteria     : How the receiving agent knows they're done
├── dependencies         : What the receiving agent needs access to
└── escalation_notes     : Any issues or risks to be aware of
```

### Handoff Validation Checklist
Before completing a handoff, the source agent MUST verify:
```
□ task_summary accurately reflects the original request
□ completed_work lists every action taken with outcomes
□ remaining_work is specific and actionable (not vague)
□ deliverables are referenced and accessible
□ context_state reflects the TRUE current state
□ next_agent_requirements match the target agent's capabilities
□ success_criteria are measurable and unambiguous
□ dependencies are available and accessible to receiving agent
```

---

## 2. Handoff Templates by Workflow Type

### Template A: Clarification → Implementation Handoff
```
HANDOFF: Agent 1 (Context Clarifier) → Agent 2 (Code Architect)

TASK SUMMARY:
  [Original user request in full]

COMPLETED WORK:
  - Clarification report produced (artifact_id: [X])
  - All ambiguities resolved
  - Requirements documented with success criteria
  - Edge cases identified: [list]
  - Constraints confirmed: [list]

REMAINING WORK:
  - Implement solution per clarified requirements
  - Follow architectural constraints identified
  - Handle edge cases: [specific list]
  - Ensure success criteria are met in implementation

DELIVERABLES:
  - clarification_report: [reference/location]
  - Completeness score: [X]/100

CONTEXT STATE:
  - Phase: CONTEXT_CLARIFICATION → IMPLEMENTATION
  - Gate: CONTEXT_CLEAR ✅ satisfied
  - Open questions: NONE
  - User confirmations: [list what user confirmed]

NEXT AGENT REQUIREMENTS:
  - Read clarification_report in full before starting
  - Implement per documented requirements
  - Address all identified edge cases
  - Follow constraints: [list]

SUCCESS CRITERIA:
  [Copied from clarification_report.success_criteria]

DEPENDENCIES:
  - clarification_report artifact
  - [Any files or resources identified during clarification]
```

### Template B: Research → Implementation Handoff
```
HANDOFF: Agent 3 (Doc Researcher) → Agent 2 (Code Architect)

TASK SUMMARY:
  [Research objective and how it feeds implementation]

COMPLETED WORK:
  - Research summary produced (artifact_id: [X])
  - [N] sources verified with credibility scores
  - Best practices documented
  - Anti-patterns identified
  - Comparative analysis of [N] options completed

REMAINING WORK:
  - Implement using recommended approach: [specific recommendation]
  - Follow best practices: [list from research]
  - Avoid anti-patterns: [list from research]
  - Apply patterns: [recommended patterns]

DELIVERABLES:
  - research_summary: [reference/location]
  - Recommended approach: [name] (fit_score: [X]/100)
  - Source documentation: [list of key URLs]

CONTEXT STATE:
  - Phase: RESEARCH → IMPLEMENTATION
  - Gate: RESEARCH_COMPLETE ✅ satisfied
  - Confidence level: [high/medium/low]
  - Gaps: [any remaining uncertainties]

NEXT AGENT REQUIREMENTS:
  - Review research_summary before implementation
  - Use recommended approach unless technical constraints prevent it
  - Document any deviations from research recommendations
  - Reference sources for complex decisions

SUCCESS CRITERIA:
  - Implementation follows recommended patterns
  - No identified anti-patterns in code
  - All best practices applied where applicable
```

### Template C: Implementation → Testing Handoff
```
HANDOFF: Agent 2 (Code Architect) → Agent 7 (Test Strategist)

TASK SUMMARY:
  [What was implemented and needs testing]

COMPLETED WORK:
  - Architecture designed and implemented
  - Files created/modified: [list with descriptions]
  - Design patterns applied: [list]
  - Known edge cases handled: [list]

REMAINING WORK:
  - Design test strategy for implemented solution
  - Create and execute test suite
  - Verify all success criteria
  - Check edge case handling
  - Validate error handling paths

DELIVERABLES:
  - architecture_design artifact: [reference]
  - Source files: [list of files created/modified]
  - API/interface contracts: [specification]

CONTEXT STATE:
  - Phase: IMPLEMENTATION → VALIDATION
  - Implemented components: [list]
  - Known risks: [from architecture risk_assessment]
  - Test priority areas: [list]

NEXT AGENT REQUIREMENTS:
  - Read architecture_design artifact
  - Understand component interfaces and data flow
  - Design test strategy covering all test levels
  - Focus edge cases on: [high-risk areas]
  - Coverage target: >= 70%

SUCCESS CRITERIA:
  - All test levels covered (unit, integration, e2e as applicable)
  - Coverage >= 70%
  - All edge cases from clarification_report tested
  - No critical bugs found, or if found, documented with reproduction steps
```

### Template D: Implementation → Efficiency Analysis Handoff
```
HANDOFF: Agent 2 (Code Architect) → Agent 5 (Efficiency Analyzer)

TASK SUMMARY:
  [What was implemented and needs performance analysis]

COMPLETED WORK:
  - Solution implemented with design patterns: [list]
  - Data structures used: [list]
  - Algorithms applied: [list]

REMAINING WORK:
  - Analyze time and space complexity
  - Identify performance bottlenecks
  - Compare with alternative approaches
  - Recommend optimizations if needed

DELIVERABLES:
  - Source files: [list]
  - Architecture description: [brief or artifact reference]

CONTEXT STATE:
  - Expected scale: [user count, data volume, request rate]
  - Performance requirements: [SLAs, response times]
  - Constraints: [memory limits, cost budgets]

NEXT AGENT REQUIREMENTS:
  - Analyze algorithm complexity for core operations
  - Profile expected load characteristics
  - Identify top 3 bottleneck risks
  - Provide actionable optimization recommendations
```

### Template E: Escalation Handoff
```
HANDOFF: [Any Agent] → Default Copilot (Escalation)

ESCALATION REASON:
  [Specific reason for escalation — MUST be one of:]
  - Unable to complete task within capabilities
  - Prerequisite gate cannot be satisfied
  - Agent conflict or coordination deadlock
  - System failure or tool unavailability
  - User requirements exceed agent framework scope

TASK SUMMARY:
  [Complete original request]

COMPLETED WORK:
  - [Everything accomplished before escalation]

ATTEMPTED RESOLUTIONS:
  - Attempt 1: [what was tried, why it failed]
  - Attempt 2: [what was tried, why it failed]

CURRENT STATE:
  - [Full state snapshot]
  - Active artifacts: [list with states]
  - Completed checkpoints: [list]
  - Blocked gates: [list with reasons]

FULL CONTEXT DUMP:
  - All artifacts produced: [list with references]
  - All agent interactions: [chronological list]
  - User confirmations received: [list]
  - Open questions: [if any]

RECOMMENDED NEXT STEPS:
  1. [Most likely resolution path]
  2. [Alternative approach]
  3. [Fallback option]
```

---

## 3. Signal Protocol

For lightweight coordination that doesn't require a full handoff.

### Signal Types
```
CHECKPOINT_COMPLETE:
  Source: Any agent completing a checkpoint
  Target: Coordinator (Agent 8) + waiting agents
  Payload: {checkpoint_id, metadata, completion_timestamp}
  Priority: HIGH

BLOCKING_ISSUE:
  Source: Any agent encountering a blocker
  Target: Coordinator (Agent 8)
  Payload: {issue_description, affected_tasks, severity}
  Priority: CRITICAL

ARTIFACT_READY:
  Source: Any agent producing an artifact
  Target: Next agent in sequence
  Payload: {artifact_id, artifact_type, state}
  Priority: NORMAL

STATE_UPDATE:
  Source: Any agent changing project state
  Target: ALL agents (broadcast)
  Payload: {field_changed, old_value, new_value}
  Priority: NORMAL

VALIDATION_RESULT:
  Source: Agent performing validation
  Target: Artifact owner + Coordinator
  Payload: {artifact_id, is_valid, errors[], warnings[]}
  Priority: HIGH
```

### Signal Format
```
SIGNAL:
├── signal_id    : Unique identifier
├── type         : One of the defined signal types above
├── source       : Agent ID sending the signal
├── target       : Agent ID or "ALL" for broadcast
├── payload      : Type-specific data
├── priority     : CRITICAL | HIGH | NORMAL | LOW
├── timestamp    : ISO-8601
└── acknowledged : boolean (set by receiver)
```

---

## 4. Conflict Resolution Protocol

When two agents produce conflicting outputs or disagree on approach:

### Resolution Steps
```
STEP 1 — Identify Conflict
  Both agents document their position:
  ├── Agent A position: [description + rationale]
  └── Agent B position: [description + rationale]

STEP 2 — Evidence Comparison
  Compare supporting evidence:
  ├── Agent A evidence: [sources, analysis, data]
  └── Agent B evidence: [sources, analysis, data]

STEP 3 — Coordinator Decision
  Agent 8 (Team Coordinator) evaluates:
  ├── Which position better satisfies user requirements?
  ├── Which has stronger evidence?
  ├── What are the risks of each approach?
  └── DECISION: [chosen approach with justification]

STEP 4 — Update & Continue
  ├── Losing position documented as "alternative considered"
  └── Winning position integrated into project artifacts
  └── All agents updated on decision
```

### Deadlock Resolution
If Agent 8 cannot resolve:
```
1. Escalate to user with both positions clearly presented
2. Present trade-offs objectively
3. Request user decision
4. Document user's choice and rationale
5. Proceed with chosen approach
```
