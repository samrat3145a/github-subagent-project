# State Verification Checklist

> Use this to verify project state is consistent and correct.
> Run by **Coordinator (Agent 8 / Team Coordinator)** at every phase transition and before governance review.
> Any agent can run sections 1-3 for self-verification.
>
> **Pass/Fail threshold**: All checkboxes in sections 1–4 must be checked for state to be considered CONSISTENT. Section 5 must have all boxes checked for a phase transition to proceed. Any unchecked item = INCONSISTENT — do not advance the phase until resolved.
>
> **When a check fails**: See the Remediation Guide at the bottom of this document.

---

## 1. Phase Consistency

- [ ] Current phase matches the most advanced completed checkpoint
- [ ] Phase has not been skipped (unless explicit user override documented)
- [ ] Phase transition was logged with timestamp and triggering agent
- [ ] Rollback point exists for the current phase

### Phase-Checkpoint Alignment:
```
Current Phase              Required Completed Checkpoints
─────────────              ──────────────────────────────
CONTEXT_CLARIFICATION      (none — first phase)
RESEARCH                   CONTEXT_CLEAR
SPECIFICATION              CONTEXT_CLEAR
PLANNING                   CONTEXT_CLEAR, SPEC_APPROVED
IMPLEMENTATION             CONTEXT_CLEAR, PLAN_APPROVED
VALIDATION                 IMPLEMENTATION_COMPLETE
GOVERNANCE                 VALIDATION_PASSED
COMPLETE                   APPROVED
```

- [ ] All required checkpoints for current phase are in completed list

---

## 2. Artifact Integrity

For EACH artifact in the project:

- [ ] `artifact_id` is unique (no duplicates)
- [ ] `artifact_type` matches the producing agent's declared type
- [ ] `agent_id` matches an agent that is allowed to produce this type
- [ ] `project_id` matches the current project
- [ ] `version` follows semver format (X.Y.Z)
- [ ] `version` is greater than all previous versions of this artifact
- [ ] `timestamp` is a valid ISO-8601 date
- [ ] `state_before` and `state_after` represent a legal transition
- [ ] Content is present and non-empty

### State History Integrity:
- [ ] State transitions follow legal paths only:
  ```
  Legal: DRAFT → IN_REVIEW → VALIDATED → APPROVED → COMPLETE
  Legal: ANY → REJECTED → DRAFT (and restart)
  Illegal: DRAFT → APPROVED (skipped states)
  Illegal: COMPLETE → DRAFT (backward without REJECTED)
  ```
- [ ] Timestamps in state history are chronologically ordered
- [ ] Each state change has a recorded `changed_by` agent

---

## 3. Dependency Integrity

- [ ] No circular dependencies between artifacts
- [ ] Every referenced dependency artifact actually exists
- [ ] No artifact depends on a REJECTED artifact (without itself being DRAFT)
- [ ] No orphaned artifacts (artifacts with no connection to the workflow)

### Dependency Chain Check:
```
clarification_report
  └── referenced by: refined_specification, execution_plan, architecture_design
  
research_summary
  └── referenced by: architecture_design
  
refined_specification
  └── referenced by: execution_plan, architecture_design, test_strategy

execution_plan
  └── referenced by: architecture_design

architecture_design
  └── referenced by: performance_analysis, test_strategy

test_strategy
  └── referenced by: governance_report

performance_analysis
  └── referenced by: governance_report

governance_report
  └── referenced by: (terminal — final artifact)
```

- [ ] Actual dependency chain matches expected chain for workflow type

---

## 4. Checkpoint Verification

For EACH checkpoint marked as complete:

- [ ] Supporting evidence artifact exists
- [ ] Evidence artifact is in correct state (VALIDATED or higher)
- [ ] Evidence artifact satisfies all checkpoint requirements:

```
CONTEXT_CLEAR:
  □ clarification_report exists
  □ completeness_score >= 80
  □ open_questions is empty

RESEARCH_COMPLETE:
  □ research_summary exists
  □ sources >= 2
  □ comparative_analysis >= 1

SPEC_APPROVED:
  □ refined_specification exists
  □ All formal_requirements have priority
  □ Acceptance criteria present

PLAN_APPROVED:
  □ execution_plan exists
  □ No circular dependencies
  □ All tasks have assigned_agent

IMPLEMENTATION_COMPLETE:
  □ architecture_design exists
  □ Code files created per plan
  □ All key_decisions have tradeoffs

VALIDATION_PASSED:
  □ test_strategy exists with coverage >= 70%
  □ performance_analysis exists with recommendations
  □ No critical bugs unresolved

APPROVED:
  □ governance_report exists
  □ approval_status = "approved"
  □ All quality gates passed
```

---

## 5. Active Agent Consistency

- [ ] Only agents appropriate for the current phase are active
- [ ] No two agents claim to be working on the same artifact simultaneously
- [ ] All active agents have valid, complete handoff packages

---

## Remediation Guide

When any check fails, use the following actions before re-running verification:

### Section 1 (Phase Consistency) fails
```
→ Identify which checkpoint is missing evidence
→ Invoke the agent responsible for producing that checkpoint's artifact
→ Do NOT advance the phase until the checkpoint evidence artifact reaches VALIDATED state
→ If phase was skipped without user override: roll back to the last consistent phase
```

### Section 2 (Artifact Integrity) fails
```
→ For missing/empty fields: return artifact to producing agent with specific list of gaps
→ For illegal state transition: roll back artifact to last legal state; re-run transition rules
→ For duplicate artifact_id: retain the higher-version artifact; deprecate the lower one
→ For checksum mismatch: classify as CRITICAL — escalate to Default Copilot immediately
```

### Section 3 (Dependency Integrity) fails
```
→ For circular dependency: escalate to Coordinator to restructure the dependency chain
→ For missing dependency artifact: invoke the agent that produces it before resuming
→ For REJECTED dependency: return all dependent artifacts to DRAFT; re-run from that point
→ For orphaned artifact: flag to Coordinator — either connect it to the workflow or archive it
```

### Section 4 (Checkpoint Verification) fails
```
→ For missing evidence artifact: invoke the responsible agent to produce it
→ For evidence below threshold (e.g., completeness_score < 80): return to producing agent for revision
→ For evidence in wrong state: advance the artifact through the remaining state transitions first
```

### Section 5 (Active Agent Consistency) fails
```
→ For two agents on same artifact: pause both; Coordinator assigns ownership to one; other is reassigned
→ For agent in wrong phase: reassign to an appropriate task for the current phase
→ For agent with invalid handoff: return handoff and block work until corrected
```
- [ ] No agent is active without a corresponding task assignment

---

## 6. Rollback Point Health

- [ ] At least 1 rollback point exists
- [ ] Most recent rollback point is from the current or previous phase
- [ ] Rollback points contain complete state snapshots
- [ ] No rollback points reference deleted/corrupted artifacts

---

## Verification Result

After running all checks:

```
ALL PASSED:
  → State is consistent. Proceed with current phase.
  → Log: "State verification passed at [timestamp] by [agent]"

ANY FAILED:
  → Document specific failures
  → Determine severity (can we fix in place or need rollback?)
  → Fix in place if possible (LOW severity)
  → Rollback if state is inconsistent (HIGH/CRITICAL severity)
  → Log: "State verification FAILED at [timestamp]: [specific failures]"
```
