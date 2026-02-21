# State Management Instructions

> **Version**: 1.0.0 | **Last Updated**: 2026-02-18
> Rules for tracking project state, checkpoints, and artifact lifecycle across all agents.
> State is the shared memory of the agent system. Corrupt it and everything breaks.

---

## 1. Project Phases

Every project moves through these phases IN ORDER. Skipping phases is a violation.

```
INITIALIZATION
  │  Project received, no work started
  │  Required: Project ID assigned
  ▼
CONTEXT_CLARIFICATION
  │  Agent 1 is resolving ambiguities
  │  Required: clarification_report artifact started
  │  Exit gate: CONTEXT_CLEAR checkpoint
  ▼
RESEARCH & SPECIFICATION (FORK)
  ├──► Agent 3 (Research) ──► research_summary
  └──► Agent 6 (Spec)     ──► refined_specification
  │
  ▼ (JOIN)
  │  Exit gate: RESEARCH_COMPLETE & SPEC_APPROVED checkpoints
PLANNING
  │  Agent 4/8 creating execution plan
  │  Required: execution_plan artifact started
  │  Exit gate: PLAN_APPROVED checkpoint
  ▼
IMPLEMENTATION
  │  Agent 2 building the solution
  │  Required: architecture_design artifact + code
  │  Exit gate: IMPLEMENTATION_COMPLETE checkpoint
  ▼
VALIDATION (FORK)
  ├──► Agent 5 (Efficiency) ──► performance_analysis
  └──► Agent 7 (Testing)    ──► test_strategy
  │
  ▼ (JOIN)
  │  Exit gate: VALIDATION_PASSED checkpoint
GOVERNANCE
  │  Agent 8 reviewing all artifacts for approval
  │  Required: governance_report artifact
  │  Exit gate: APPROVED checkpoint
  ▼
COMPLETE
     All work finished, all gates passed
```

### Phase Transition Rules
```
RULE: Phase can only advance forward (no skipping)
RULE: Phase can regress if a gate fails (back to relevant phase)
RULE: Every phase transition creates a rollback point
RULE: Phase transitions are logged with timestamp and triggering agent
```

### Allowed Phase Skips (Explicit User Override Only)
```
- CONTEXT_CLARIFICATION: Skip if user says "requirements are clear"
- RESEARCH: Skip if technology is well-known to the team
- SPECIFICATION: Skip for trivial tasks (bug fixes, typo corrections)
```

---

## 2. Checkpoint System

Checkpoints are the gates between phases. They represent verified milestones.

### Checkpoint Registry
```
CHECKPOINT: CONTEXT_CLEAR
  Description:  All requirements clarified, no ambiguity remains
  Verified by:  Agent 1 artifact (completeness_score >= 80, open_questions empty)
  Required for: Proceeding to RESEARCH or IMPLEMENTATION
  Evidence:     clarification_report artifact in VALIDATED state

CHECKPOINT: RESEARCH_COMPLETE
  Description:  All necessary research conducted and summarized
  Verified by:  Agent 3 artifact (>= 2 sources, >= 1 comparative analysis)
  Required for: Proceeding to IMPLEMENTATION
  Evidence:     research_summary artifact in VALIDATED state

CHECKPOINT: SPEC_APPROVED
  Description:  Formal specification reviewed and approved
  Verified by:  Agent 6 artifact (all requirements have priority, acceptance criteria present)
  Required for: Proceeding to PLANNING
  Evidence:     refined_specification artifact in APPROVED state

CHECKPOINT: PLAN_APPROVED
  Description:  Execution plan reviewed and approved
  Verified by:  Agent 4 artifact (no circular deps, all tasks assigned)
  Required for: Proceeding to IMPLEMENTATION
  Evidence:     execution_plan artifact in APPROVED state

CHECKPOINT: IMPLEMENTATION_COMPLETE
  Description:  All code implemented per specification
  Verified by:  Agent 2 artifact (architecture documented, code complete)
  Required for: Proceeding to VALIDATION
  Evidence:     architecture_design artifact in VALIDATED state + working code

CHECKPOINT: VALIDATION_PASSED
  Description:  Testing and efficiency analysis complete
  Verified by:  Agent 5 + Agent 7 artifacts (coverage >= 70%, no critical bugs)
  Required for: Proceeding to GOVERNANCE
  Evidence:     test_strategy + performance_analysis artifacts in VALIDATED state

CHECKPOINT: APPROVED
  Description:  All artifacts approved by Team Coordinator
  Verified by:  Agent 8 governance_report (approval_status = "approved")
  Required for: Marking project COMPLETE
  Evidence:     governance_report artifact with all quality gates passed
```

### Checkpoint Completion Protocol
When an agent believes a checkpoint is satisfied:
```
1. VERIFY: Check all evidence requirements are met
2. DOCUMENT: Record what evidence satisfies the checkpoint
3. SIGNAL: Emit CHECKPOINT_COMPLETE signal to Coordinator
4. LOG: Record checkpoint completion with timestamp
5. WAIT: Do not proceed until Coordinator acknowledges
```

---

## 3. Artifact State Tracking

Every artifact has a lifecycle that must be tracked.

### Artifact State Machine
```
         ┌──────────────────────────────────────┐
         │                                      │
         ▼                                      │
       DRAFT ──→ IN_REVIEW ──→ VALIDATED ──→ APPROVED ──→ COMPLETE
         ▲           │              │            │
         │           │              │            │
         └───────────┴──────────────┴────────────┘
                        REJECTED (returns to DRAFT)
```

### State Tracking Format
For each artifact, maintain this state record:
```
ARTIFACT STATE RECORD:
├── artifact_id      : Unique identifier
├── artifact_type    : Type (matches agent's declared type)
├── owner_agent      : Which agent produced it
├── current_state    : Current lifecycle state
├── state_history    : Chronological list of state changes
│   ├── {state, timestamp, changed_by, reason}
│   ├── {state, timestamp, changed_by, reason}
│   └── ...
├── version          : Current semver
├── version_history  : Previous versions
├── dependencies     : Other artifacts this depends on
├── dependents       : Other artifacts that depend on this
└── validation_results: Most recent validation outcome
```

### Version Increment Rules
```
PATCH (x.y.Z): Minor corrections, typo fixes, formatting
MINOR (x.Y.z): Added content, new sections, expanded analysis
MAJOR (X.y.z): Fundamental changes, restructured approach, scope change

RULE: Version must increment on every state transition
RULE: REJECTED artifacts increment PATCH when returning to DRAFT
RULE: MAJOR version changes require re-validation of all dependents
```

---

## 4. Rollback System

When things go wrong, rollback to a known good state.

### Rollback Points Created Automatically
```
- Every phase transition
- Every checkpoint completion
- Every artifact state transition to APPROVED
- Before every agent handoff
- When any error triggers escalation
```

### Rollback Protocol
```
STEP 1 — Identify Failure Point
  What failed and when? Which artifact/checkpoint/gate?

STEP 2 — Find Nearest Rollback Point
  Search rollback points backwards from failure:
  └── Use the most recent rollback point BEFORE the failure

STEP 3 — Restore State
  ├── Revert project phase to rollback point's phase
  ├── Revert artifact states to rollback point's versions
  ├── Mark invalidated checkpoints as incomplete
  └── Notify all active agents of state rollback

STEP 4 — Resume from Rollback Point
  ├── Re-execute from the restored phase
  ├── Address the root cause of the failure
  └── Document what caused the rollback and what was changed

STEP 5 — Verify Recovery
  ├── Confirm state is consistent
  ├── Verify no orphaned artifacts
  └── Confirm all agents are aware of current state
```

### Rollback Triggers
```
AUTOMATIC ROLLBACK:
  - Quality gate FAILS during governance review
  - Circular dependency detected in execution plan
  - Checksum mismatch on any artifact (tampering/corruption)
  - Critical bug found that invalidates architecture

MANUAL ROLLBACK (requires Coordinator approval):
  - User changes requirements significantly
  - Better approach discovered during implementation
  - External dependency becomes unavailable
```

### Corrupted Rollback Point

If the rollback point itself is corrupted or missing (e.g., checksum mismatch on rollback state, file unreadable):

```
1. DO NOT attempt to restore from the corrupted point
2. Classify as CRITICAL — escalate immediately to Default Copilot
3. Include: which rollback point is corrupted, when it was created, what triggered the rollback attempt
4. Search for the next-oldest valid rollback point:
   - Work backwards through rollback history
   - Use the most recent point whose checksum is intact
5. Restore from that older point; document the gap (work done between old point and corrupted point may be lost)
6. Notify all active agents of the state regression
7. Re-execute the lost work from the restored point
```

---

## 5. State Consistency Rules

### Single Source of Truth
```
RULE: The artifact chain IS the project state
RULE: If it isn't in an artifact, it didn't happen
RULE: No side-channel communication — everything goes through handoff protocols
RULE: Agent memory is NOT persistent — only artifacts and state records persist
```

### Consistency Checks (Run by Coordinator)
```
CHECK: All active artifacts reference the same project_id
CHECK: No two artifacts claim the same artifact_id
CHECK: Artifact dependency graph has no cycles
CHECK: All referenced artifacts actually exist
CHECK: State history timestamps are monotonically increasing
CHECK: Version numbers are monotonically increasing per artifact
CHECK: Current phase matches the most advanced completed checkpoint
```

### Conflict Detection
```
CONFLICT: Two agents modify same resource simultaneously
  → Resolution: Last-write-wins with mandatory Coordinator review

CONFLICT: Artifact depends on a REJECTED artifact
  → Resolution: Dependent artifact automatically returns to DRAFT

CONFLICT: Checkpoint satisfied but prerequisite artifact later REJECTED
  → Resolution: Checkpoint revoked, downstream work paused

CONFLICT: Phase regression requested but downstream work exists
  → Resolution: All downstream artifacts return to DRAFT
```

---

## 6. State Query Interface

Any agent can query project state by asking these questions:

```
Q: "What phase is the project in?"
A: Check the most recent phase transition in state history

Q: "Is checkpoint X complete?"
A: Check if X exists in completed_checkpoints list

Q: "What is artifact Y's current state?"
A: Read artifact Y's state record → current_state

Q: "Who is the active agent?"
A: Check active_agents list in project state

Q: "What work has been done?"
A: Read all artifacts and their state histories

Q: "Can I proceed with task Z?"
A: Run the "Should I Proceed?" decision tree from validation-rules
```
