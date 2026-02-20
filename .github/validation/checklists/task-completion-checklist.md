# Task Completion Checklist

> Use this checklist BEFORE declaring any task complete.
> A task with unchecked mandatory items is NOT complete.
>
> **When a check fails**: Do not skip it and declare completion anyway. See the Remediation Guide at the bottom of this document.

---

## Requirements Validation

- [ ] Original task/request fully re-read before declaring completion
- [ ] Every explicit requirement addressed in the output
- [ ] Every success criterion from handoff/clarification is met
- [ ] Edge cases from clarification_report are handled
- [ ] Constraints from requirements are respected
- [ ] Non-goals are confirmed NOT included (no scope creep)

---

## Artifact Validation

- [ ] Artifact type matches my declared type in capability matrix
- [ ] ALL required fields are populated with meaningful values
- [ ] No placeholder or stub values remain
- [ ] Type-specific transition rules ALL pass:

### Per Artifact Type Quick-Check:
```
clarification_report:
  □ open_questions is EMPTY
  □ completeness_score >= 80

architecture_design:
  □ Every key_decision has at least 1 tradeoff
  □ risk_assessment has at least 1 entry
  □ high_level_components is non-empty

research_summary:
  □ sources has at least 2 entries
  □ comparative_analysis has at least 1 entry

execution_plan:
  □ No circular dependencies
  □ Every task has assigned_agent

refined_specification:
  □ All formal_requirements have priority
  □ acceptance_criteria covers every functional_requirement

test_strategy:
  □ coverage_target_percentage >= 70
  □ edge_cases is non-empty

performance_analysis:
  □ At least 1 optimization_recommendation
  □ expected_load_profile is fully specified

governance_report:
  □ approval_status set
  □ All quality_gate_results populated
```

---

## Metadata Envelope

- [ ] `agent_id` is my correct agent ID
- [ ] `artifact_type` matches my declared artifact type
- [ ] `project_id` matches the current project
- [ ] `version` is valid semver AND incremented from last version
- [ ] `timestamp` is current ISO-8601
- [ ] `state_before` reflects actual prior state
- [ ] `state_after` is the correct target state

---

## Quality Standards

- [ ] Output is clear, coherent, and professionally formatted
- [ ] No internal contradictions within the artifact
- [ ] Cross-references to other artifacts are valid
- [ ] Technical content is accurate
- [ ] Examples (if any) are correct and tested
- [ ] No information was fabricated or assumed without basis

---

## Consistency with Other Artifacts

- [ ] My output doesn't contradict the clarification_report
- [ ] My output aligns with the execution_plan (if exists)
- [ ] My output is compatible with existing architecture decisions
- [ ] Dependencies I reference actually exist and are accessible

> **If an upstream artifact doesn't exist yet** (e.g., you are the first agent and there is no `clarification_report`):
> - Skip the check for that specific artifact — mark it N/A with a note
> - Do NOT block completion solely because an optional upstream artifact is absent
> - If the absent artifact is a **required gate** for your work (e.g., CONTEXT_CLARIFICATION must pass before Code Architect starts), stop and invoke or request that artifact before proceeding

---

## Handoff Readiness

- [ ] Handoff package can be assembled with my deliverables
- [ ] Next agent in sequence can proceed with my output
- [ ] State updates are ready to be committed
- [ ] Rollback point exists if my output needs revision

---

## Final Sign-Off

- [ ] I would be confident if a Coordinator reviewed this right now
- [ ] This output represents my best work within my capabilities
- [ ] All validation workflow checkpoints (25%, 50%, 75%) were executed

---

## Remediation Guide

When a check fails, use the following actions before re-attempting completion:

### "Requirement not addressed"
```
→ Re-read the original task and handoff package
→ Identify which requirement was missed
→ Add the missing output before re-running this checklist
→ Do NOT declare completion with a known gap
```

### "Required artifact field is empty or stub"
```
→ Populate the field with real content — remove all placeholder values
→ Re-run the type-specific transition rules for this artifact
→ If you cannot determine the correct value: flag it as an open question and escalate to the user or Coordinator
```

### "Output contradicts clarification_report or execution_plan"
```
→ Identify the specific contradiction
→ Determine which is correct: your output or the upstream artifact
→ If your output is wrong: revise it
→ If the upstream artifact is wrong: return it to its producing agent for correction before completing your task
```

### "Quality check fails (internal contradiction, fabricated content, broken cross-reference)"
```
→ Correct the specific issue before declaring completion
→ For fabricated content: remove it entirely; replace with verified information or explicitly flag as assumption
→ For broken cross-reference: locate the correct artifact or note the reference as unresolvable
```

### "Handoff readiness check fails"
```
→ Identify what the next agent needs that you haven't produced
→ Produce the missing deliverable or document it as a known gap with justification
→ Do NOT hand off with a gap you know will block the next agent
```
