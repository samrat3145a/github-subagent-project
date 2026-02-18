# Validation Workflows

> **Version**: 1.0.0 | **Last Updated**: 2026-02-18
> Step-by-step workflows that every agent executes at each stage of task processing.
> These are not optional. They are the operating procedure.

---

## 1. Pre-Task Validation Workflow

**When**: Before starting ANY task.
**Who**: Every agent, every time.

```
┌─────────────────────────────────────────────────┐
│           PRE-TASK VALIDATION                    │
│                                                  │
│  STEP 1: INTAKE                                  │
│  □ Read the task/handoff package completely       │
│  □ Identify: What am I being asked to do?         │
│  □ Identify: What artifacts should I produce?     │
│                                                   │
│  STEP 2: CAPABILITY CHECK                         │
│  □ Is this task in my ALLOWED list?               │
│    → NO: Stop. Return task with redirect.         │
│  □ Does it match any FORBIDDEN operation?         │
│    → YES: Stop. Return task with redirect.        │
│  □ Do I have the tools I need?                    │
│    → NO: Report missing tools in error format.    │
│                                                   │
│  STEP 3: GATE CHECK                               │
│  □ What gates apply to me? (See validation-rules) │
│  □ Are all applicable gates satisfied?             │
│    → NO: Stop. Report which gate failed and       │
│           what is needed to satisfy it.            │
│    → YES: Continue.                                │
│                                                   │
│  STEP 4: CONTEXT CHECK                            │
│  □ Do I have sufficient context to proceed?        │
│  □ Are all dependencies available?                 │
│  □ Is the handoff package complete?                │
│    → NO for any: Gather what's missing.            │
│      Still missing? Request from source agent.     │
│                                                   │
│  STEP 5: PLAN                                     │
│  □ Break task into concrete steps                  │
│  □ Identify which artifact fields I'll fill        │
│  □ Estimate completion scope (small/medium/large)  │
│                                                   │
│  ✅ ALL PASSED → Begin task execution              │
└─────────────────────────────────────────────────┘
```

---

## 2. In-Progress Validation Workflow

**When**: During task execution, at each milestone.
**Who**: Every agent executing a task.

### 25% Checkpoint — Direction Validation
```
TRIGGER: After initial exploration and approach decision

CHECK:
  □ Approach aligns with requirements from handoff/clarification
  □ No unexpected blockers discovered
  □ All assumptions from intake still hold
  □ Scope has not expanded beyond original task

IF ANY CHECK FAILS:
  → Minor issue: Adjust approach, document deviation
  → Major issue: PAUSE. Signal BLOCKING_ISSUE to Coordinator.
     Include: what changed, what was expected, recommendation
```

### 50% Checkpoint — Quality Validation
```
TRIGGER: At approximate halfway point of work

CHECK:
  □ Output quality meets the standard for my artifact type
  □ Artifact required fields are being populated correctly
  □ No conflicting information with other artifacts
  □ Timeline is realistic for remaining work
  □ No scope creep has occurred

IF ANY CHECK FAILS:
  → Quality issue: Fix immediately before proceeding
  → Scope creep: Document additional scope, request approval
  → Timeline risk: Signal STATE_UPDATE to Coordinator
```

### 75% Checkpoint — Pre-Completion Validation
```
TRIGGER: Near completion, before final assembly

CHECK:
  □ All required artifact fields will be populated
  □ Type-specific transition rules can be satisfied
  □ Edge cases from requirements have been addressed
  □ Handoff preparation can begin
  □ No critical gaps in deliverable

IF ANY CHECK FAILS:
  → Gap found: Address before completing
  → Transition rule risk: Focus remaining effort on blocking criteria
  → Cannot complete: Escalate at Level 2 (peer agent) or Level 3 (coordinator)
```

---

## 3. Artifact Completion Validation Workflow

**When**: After producing an artifact, BEFORE transitioning state.
**Who**: The producing agent.

```
┌─────────────────────────────────────────────────┐
│        ARTIFACT COMPLETION VALIDATION             │
│                                                   │
│  STEP 1: FIELD COMPLETENESS                       │
│  For each REQUIRED FIELD in my artifact type:     │
│  □ Is the field populated?                         │
│  □ Is the value meaningful (not placeholder)?      │
│  □ Does the value meet format/type requirements?   │
│                                                   │
│  → If any field is missing or invalid:             │
│    STOP. Fill the field before proceeding.         │
│                                                   │
│  STEP 2: TRANSITION RULE CHECK                    │
│  For each transition rule for my artifact type:    │
│  □ Does my artifact satisfy the rule?              │
│                                                   │
│  → If any rule fails:                              │
│    STOP. Address the specific failure.             │
│    Document what failed and why.                   │
│                                                   │
│  STEP 3: INTERNAL CONSISTENCY                      │
│  □ No contradictions within the artifact            │
│  □ All cross-references are valid                   │
│  □ Numbers/scores are within valid ranges           │
│  □ Lists that should be empty ARE empty             │
│  □ Lists that should be non-empty ARE non-empty     │
│                                                   │
│  STEP 4: CROSS-ARTIFACT CONSISTENCY                │
│  □ My artifact doesn't contradict earlier artifacts │
│  □ Dependencies I reference actually exist           │
│  □ Requirements I address match the specification    │
│                                                   │
│  STEP 5: METADATA ENVELOPE                         │
│  □ agent_id is set to my agent ID                   │
│  □ artifact_type matches my declared type            │
│  □ project_id matches current project                │
│  □ version follows semver and is incremented         │
│  □ timestamp is current ISO-8601                     │
│  □ state_before reflects actual prior state          │
│  □ state_after is the target transition state        │
│                                                   │
│  ✅ ALL PASSED → Transition artifact to IN_REVIEW   │
│  ❌ ANY FAILED → Fix before transitioning            │
└─────────────────────────────────────────────────┘
```

---

## 4. Handoff Validation Workflow

**When**: Before transferring work to another agent.
**Who**: The agent completing their portion.

```
┌─────────────────────────────────────────────────┐
│           HANDOFF VALIDATION                      │
│                                                   │
│  STEP 1: DELIVERABLE CHECK                        │
│  □ All artifacts I was supposed to produce exist    │
│  □ All artifacts are in at least IN_REVIEW state    │
│  □ Artifact content matches what was requested      │
│                                                   │
│  STEP 2: HANDOFF PACKAGE ASSEMBLY                  │
│  □ All 12 required handoff fields populated         │
│    (See coordination-protocol-templates.md §1)      │
│  □ completed_work is specific, not vague             │
│  □ remaining_work is actionable for target agent     │
│  □ success_criteria are measurable                   │
│                                                   │
│  STEP 3: TARGET AGENT VALIDATION                   │
│  □ Target agent's capabilities match remaining work  │
│  □ Remaining work doesn't include target's FORBIDDEN │
│  □ Target agent has access to required dependencies  │
│                                                   │
│  STEP 4: STATE UPDATE                              │
│  □ Project phase updated if transitioning phases     │
│  □ Checkpoint marked complete if applicable          │
│  □ Active agent list updated                         │
│  □ Rollback point created before handoff             │
│                                                   │
│  STEP 5: SIGNAL                                    │
│  □ Emit ARTIFACT_READY signal                        │
│  □ Emit CHECKPOINT_COMPLETE if applicable            │
│  □ Wait for Coordinator acknowledgment               │
│                                                   │
│  ✅ ALL PASSED → Execute handoff                     │
│  ❌ ANY FAILED → Fix before handing off              │
└─────────────────────────────────────────────────┘
```

---

## 5. Governance Validation Workflow

**When**: During final review phase.
**Who**: Agent 8 (Team Coordinator).

```
┌─────────────────────────────────────────────────┐
│        GOVERNANCE VALIDATION                      │
│                                                   │
│  GATE 1: COMPLETENESS                             │
│  For each mandatory agent in the workflow:         │
│  □ Agent produced its required artifact?            │
│  □ Artifact is in VALIDATED or APPROVED state?      │
│  → FAIL if any mandatory artifact is missing        │
│                                                   │
│  GATE 2: CONSISTENCY                               │
│  □ All artifacts reference same project_id          │
│  □ No contradictions between agent outputs          │
│  □ Requirements in spec match implementation         │
│  □ Tests cover specified requirements                │
│  → FAIL if any contradiction found                  │
│                                                   │
│  GATE 3: TRACEABILITY                              │
│  For each formal requirement:                       │
│  □ Can trace to design decision in architecture?     │
│  □ Can trace to implementation in code?              │
│  □ Can trace to test case in test strategy?          │
│  → FAIL if any requirement lacks full trace          │
│                                                   │
│  GATE 4: TRANSITION INTEGRITY                       │
│  For each artifact:                                  │
│  □ State history shows only legal transitions        │
│  □ Version numbers are monotonically increasing      │
│  □ Timestamps are chronologically consistent         │
│  □ No artifacts stuck in intermediate states         │
│  → FAIL if any illegal transition detected           │
│                                                   │
│  FINAL DECISION:                                    │
│  ALL GATES PASS → approval_status = "approved"       │
│  ANY GATE FAILS → approval_status = "needs_revision" │
│                    Produce: list of specific failures │
│                    Action: rollback to relevant phase │
│                                                   │
└─────────────────────────────────────────────────┘
```

---

## 6. Error Recovery Workflow

**When**: Any validation step fails during execution.
**Who**: The agent that encountered the failure.

```
FAILURE DETECTED
│
├─ SEVERITY: LOW (missing optional field, formatting issue)
│  └─ Fix immediately. No escalation needed.
│     Log the fix in artifact's state history.
│
├─ SEVERITY: MEDIUM (transition rule not met, incomplete context)
│  ├─ Can I fix this myself?
│  │  ├─ YES → Fix it. Re-run validation. Document fix.
│  │  └─ NO → Escalate to Level 2 (peer agent)
│  │         Use error communication format.
│  └─ Time limit: 2 self-fix attempts, then escalate.
│
├─ SEVERITY: HIGH (gate violation, capability mismatch, dependency missing)
│  └─ IMMEDIATELY escalate to Level 3 (Coordinator).
│     Include: full error report, attempted resolutions, state snapshot.
│     PAUSE all work until resolution received.
│
└─ SEVERITY: CRITICAL (state corruption, checksum mismatch, system failure)
   └─ IMMEDIATELY escalate to Level 4 (Default Copilot).
      Include: complete context dump, all artifacts, full state history.
      TRIGGER automatic rollback to last known good state.
```

---

## 7. Continuous Improvement Workflow

**When**: After every project completion.
**Who**: Agent 8 (Team Coordinator).

```
POST-PROJECT REVIEW:

1. COLLECT METRICS
   □ Total agent invocations
   □ Number of validation failures (by type)
   □ Number of rollbacks triggered
   □ Number of escalations (by level)
   □ Time spent in each phase

2. IDENTIFY PATTERNS
   □ Which validation steps fail most often?
   □ Which agents trigger most escalations?
   □ Where do handoff failures cluster?
   □ Which gates are bypassed most often?

3. RECOMMEND IMPROVEMENTS
   □ Adjust validation thresholds if too strict/loose
   □ Add new validation rules for recurring failures
   □ Refine handoff templates based on actual usage
   □ Update capability matrix if agents evolved

4. UPDATE FRAMEWORK
   □ Version-bump affected validation documents
   □ Document changes in change log
   □ Notify all agents of updated rules
```
