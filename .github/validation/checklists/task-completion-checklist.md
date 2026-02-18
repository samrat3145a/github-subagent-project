# Task Completion Checklist

> Use this checklist BEFORE declaring any task complete.
> A task with unchecked mandatory items is NOT complete.

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
