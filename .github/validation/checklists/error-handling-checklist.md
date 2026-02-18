# Error Handling Checklist

> Use this when ANY validation step fails or ANY unexpected issue occurs.
> Follow in order. Do not skip levels.

---

## Step 1: Classify the Error

- [ ] **What happened?** (One-sentence description)
- [ ] **What was I trying to do?** (Task/workflow step)
- [ ] **What was expected?** (Expected outcome)
- [ ] **What actually happened?** (Actual outcome)

### Determine Severity:
```
LOW:     Missing optional field, formatting issue, minor inconsistency
         → Self-fix. No escalation needed.

MEDIUM:  Transition rule not met, incomplete context, capability edge case
         → Attempt self-fix (max 2 attempts). Then escalate to peer agent.

HIGH:    Gate violation, capability mismatch, missing dependency, blocked
         → Immediately escalate to Coordinator (Agent 8 or Agent 4).

CRITICAL: State corruption, checksum mismatch, system failure, data loss
         → Immediately escalate to Default Copilot. Trigger rollback.
```

- [ ] Severity classified: __________ (LOW / MEDIUM / HIGH / CRITICAL)

---

## Step 2: Attempt Self-Resolution (LOW and MEDIUM only)

### Attempt 1:
- [ ] Root cause identified: __________
- [ ] Fix applied: __________
- [ ] Re-validation run
- [ ] **Result**: FIXED / STILL FAILING

### Attempt 2 (if Attempt 1 failed):
- [ ] Alternative approach tried: __________
- [ ] Re-validation run
- [ ] **Result**: FIXED / STILL FAILING

### If still failing after 2 attempts:
- [ ] Escalate to next level (see Step 3)

---

## Step 3: Escalate

### Compose Error Report (ALL escalations must include):
```
ERROR REPORT:
  error_type:           [classification from Step 1]
  error_description:    [what went wrong — specific]
  context:              [what I was doing when it happened]
  attempted_resolution: [what I tried in Step 2]
  artifacts_affected:   [which artifacts are impacted]
  state_impact:         [how project state is affected]
  escalation_required:  true
  recommended_action:   [what I think should happen next]
```

### Escalation Routing:
- [ ] **MEDIUM → Level 2 (Peer Agent)**
  - Identify which peer agent can help
  - Use handoff template from coordination-protocol-templates.md
  - Include error report in handoff
  
- [ ] **HIGH → Level 3 (Coordinator)**
  - Escalate to Agent 8 (Team Coordinator) or Agent 4 (Orchestrator)
  - Include: error report + full state snapshot + all artifacts
  - PAUSE all work until resolution received
  
- [ ] **CRITICAL → Level 4 (Default Copilot)**
  - Use Escalation Handoff template from coordination-protocol-templates.md
  - Include: COMPLETE context dump — everything — hide nothing
  - Trigger automatic rollback to last known good state
  - HALT all agent operations

---

## Step 4: Post-Resolution

After error is resolved (at any level):

- [ ] Root cause documented
- [ ] Fix verified through re-validation
- [ ] State consistency confirmed
- [ ] Affected artifacts updated
- [ ] State history updated with error and resolution
- [ ] Rollback point created at new clean state
- [ ] Normal workflow resumed

---

## Common Error Patterns & Quick Fixes

### "Transition rule not met"
```
→ Check which specific rule failed
→ Fill the missing/invalid field
→ Re-run artifact completion validation
```

### "Gate not satisfied"
```
→ Check which gate and which checkpoint is missing
→ Identify which agent needs to produce the prerequisite
→ Escalate to Coordinator to invoke prerequisite agent
```

### "Capability violation"
```
→ You're being asked to do something outside your ALLOWED list
→ Identify the correct agent for this work
→ Return the task with a redirect to the appropriate agent
```

### "Handoff package incomplete"
```
→ Identify which fields are missing
→ Return to source agent with list of missing fields
→ Do NOT begin work until handoff is valid
```

### "Conflicting artifacts"
```
→ Identify which artifacts conflict and on what
→ Document both positions
→ Escalate to Coordinator for conflict resolution
→ Follow Conflict Resolution Protocol
```
