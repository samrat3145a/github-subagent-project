# Agent Handoff Checklist

> Use this checklist EVERY TIME work transfers between agents.
> A handoff with any unchecked item is INVALID.

---

## Source Agent (Sending Work)

### Before Initiating Handoff:
- [ ] All artifacts I was responsible for have been produced
- [ ] My artifacts are in at least IN_REVIEW state
- [ ] I've run the Artifact Completion Validation workflow
- [ ] All type-specific transition rules pass for my artifacts

### Handoff Package Assembly:
- [ ] `handoff_id` — Unique ID assigned (format: handoff_{from}_{to}_{timestamp})
- [ ] `from_agent` — My agent ID specified
- [ ] `to_agent` — Target agent ID specified and verified capable
- [ ] `timestamp` — Current ISO-8601 timestamp
- [ ] `task_summary` — Complete, accurate summary of original task
- [ ] `completed_work` — Specific list of everything I did (not vague)
- [ ] `remaining_work` — Specific, actionable items for target agent
- [ ] `deliverables` — All artifacts listed with references/locations
- [ ] `context_state` — Current project phase, checkpoints, active state
- [ ] `next_agent_requirements` — What specifically the target must do
- [ ] `success_criteria` — Measurable criteria for target's completion
- [ ] `dependencies` — All resources target agent needs access to
- [ ] `escalation_notes` — Any risks, issues, or gotchas to be aware of

### Target Agent Validation:
- [ ] Target agent's ALLOWED capabilities include the remaining work
- [ ] Remaining work doesn't include target's FORBIDDEN operations
- [ ] Target agent has required tools for the work
- [ ] All dependencies are accessible to target agent

### State Updates:
- [ ] Rollback point created before handoff
- [ ] Active agent list updated
- [ ] Phase transition recorded if changing phases
- [ ] Checkpoint marked complete if applicable

### Signal:
- [ ] ARTIFACT_READY signal emitted
- [ ] CHECKPOINT_COMPLETE signal emitted (if applicable)

---

## Target Agent (Receiving Work)

### On Receiving Handoff:
- [ ] All 12+ handoff fields are present and populated
- [ ] `task_summary` is clear and understandable
- [ ] `remaining_work` matches my capabilities (ALLOWED list)
- [ ] `remaining_work` doesn't include my FORBIDDEN operations
- [ ] `success_criteria` are measurable and achievable
- [ ] `dependencies` are accessible — I can reach all referenced resources
- [ ] `deliverables` from source agent are readable and complete

### Before Starting Work:
- [ ] I've read ALL referenced artifacts from the handoff
- [ ] I understand the context and can proceed
- [ ] All prerequisite gates for me are satisfied
- [ ] I've run Pre-Task Validation workflow

### If Handoff is INVALID:
- [ ] Identify specific missing or invalid fields
- [ ] Return handoff to source agent with specific list of issues
- [ ] Do NOT begin work on an invalid handoff
