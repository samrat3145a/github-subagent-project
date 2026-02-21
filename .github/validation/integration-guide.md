# Integration Guide

> **Version**: 1.0.0 | **Last Updated**: 2026-02-18
> How the validation framework connects to existing agents.
> Read this ONCE to understand the system. Then follow the workflows.

---

## System Architecture

```
USER REQUEST
     │
     ▼
┌──────────────────────────────────────────────────────────┐
│                   VALIDATION LAYER                        │
│  .github/validation/                                      │
│  ┌──────────────┐ ┌─────────────────┐ ┌───────────────┐  │
│  │ Validation   │ │ Coordination    │ │ State         │  │
│  │ Rules        │ │ Protocols       │ │ Management    │  │
│  │              │ │                 │ │               │  │
│  │ • Capability │ │ • Handoff       │ │ • Phases      │  │
│  │   matrix     │ │   templates     │ │ • Checkpoints │  │
│  │ • Gate rules │ │ • Signal types  │ │ • Rollbacks   │  │
│  │ • Artifact   │ │ • Conflict      │ │ • Artifact    │  │
│  │   schemas    │ │   resolution    │ │   lifecycle   │  │
│  └──────────────┘ └─────────────────┘ └───────────────┘  │
│  ┌──────────────┐ ┌─────────────────────────────────────┐│
│  │ Workflows    │ │ Checklists                          ││
│  │              │ │                                     ││
│  │ • Pre-task   │ │ • Agent handoff    • Task completion││
│  │ • In-progress│ │ • Error handling   • State verify   ││
│  │ • Completion │ │                                     ││
│  │ • Governance │ │                                     ││
│  └──────────────┘ └─────────────────────────────────────┘│
└──────────────────────────────────────────────────────────┘
     │
     ▼
┌──────────────────────────────────────────────────────────┐
│                    AGENT LAYER                            │
│  .github/agents/                                          │
│                                                           │
│  Agent 1    Agent 2    Agent 3    Agent 4    Agent 5      │
│  Clarifier  Architect  Researcher Orchestr.  Efficiency   │
│                                                           │
│  Agent 6    Agent 7    Agent 8    Agent 9                  │
│  Upgrader   Tester     Coordinator Logger                  │
└──────────────────────────────────────────────────────────┘
```

---

## How Agents Use the Validation Framework

### Every Agent instruction file now includes a Validation Integration section that:

1. **References** the validation rules that apply to that agent
2. **Declares** which artifact type the agent produces
3. **Lists** which gates must be satisfied before the agent can proceed
4. **Points to** the workflows the agent must follow during execution
5. **Defines** the handoff templates the agent must use

### The integration works through INSTRUCTION EMBEDDING, not code execution:
- Agents READ the validation rules as part of their operating instructions
- Agents FOLLOW the workflows as step-by-step checklists
- Agents PRODUCE artifacts that conform to the declared schemas
- Agents USE handoff templates when transferring work
- Agents SIGNAL state changes through their outputs

---

## File Reference Map

When you need to know which file to consult:

```
"What can this agent do?"
  → agent-validation-rules.md § Agent Capability Matrix

"What artifact must this agent produce?"
  → agent-validation-rules.md § Agent Capability Matrix → ARTIFACT TYPE

"What fields are required in this artifact?"
  → agent-validation-rules.md § Agent Capability Matrix → REQUIRED FIELDS

"Can this artifact transition to the next state?"
  → agent-validation-rules.md § Agent Capability Matrix → TRANSITION RULES

"What gates block this agent?"
  → agent-validation-rules.md § Mandatory Precondition Gates

"What order should agents execute?"
  → agent-validation-rules.md § Sequential Dependency Rules

"How do I hand off work?"
  → coordination-protocol-templates.md § Handoff Templates

"How do I report a problem?"
  → agent-validation-rules.md § Error Handling Rules
  → coordination-protocol-templates.md § Signal Protocol

"What phase is the project in?"
  → state-management-instructions.md § Project Phases

"Is a checkpoint complete?"
  → state-management-instructions.md § Checkpoint System

"What do I do before starting a task?"
  → validation-workflows.md § Pre-Task Validation

"What do I check while working?"
  → validation-workflows.md § In-Progress Validation

"What do I check before handing off?"
  → validation-workflows.md § Handoff Validation

"How does final review work?"
  → validation-workflows.md § Governance Validation
```

---

## Quick-Start: Adding Validation to an Agent

The validation integration section added to each agent follows this template:

```markdown
## Validation Framework Integration
> Reference: `.github/validation/agent-validation-rules.md`

### My Artifact Contract
- **Artifact Type**: [type from capability matrix]
- **Required Fields**: [list from capability matrix]
- **Transition Rules**: [rules from capability matrix]

### Gates That Apply to Me
- [Gate name]: [what must be true before I can start]

### My Operating Workflow
0. **Todo List Setup**: Create a todo list tracking each step of your task
1. **Input Validation**: Confirm the request is actionable before starting
2. **Pre-Task**: Follow `.github/validation/validation-workflows.md` § Pre-Task Validation
3. **Execution checkpoints** (name these per your task — generic examples):
   - After initial analysis / approach confirmed (25%): confirm direction before proceeding
   - After core work complete (50%): confirm quality and scope before finishing
   - Before final assembly (75%): confirm all artifact fields populated, no gaps
4. **Completion**: Run artifact completion validation — verify all required fields populated
5. **Handoff**: Use appropriate template from `.github/validation/coordination-protocol-templates.md`

### My Handoff Responsibilities
- **Receiving handoffs**: Validate package has all required handoff fields (see `coordination-protocol-templates.md` § Required Handoff Fields); confirm the field count matches your artifact contract in `agent-validation-rules.md`
- **Sending handoffs**: Use appropriate template for my workflow type
- **Signals**: Emit ARTIFACT_READY when my artifact reaches IN_REVIEW
```

### If a Validation Framework File is Inaccessible

If an agent cannot read a validation file (e.g., `.github/validation/agent-validation-rules.md` is missing or unreadable):

```
1. DO NOT proceed with the task as if the rules don't apply
2. Report the missing file immediately: "Cannot access [file path] — validation rules unavailable"
3. Escalate to the Default Copilot agent with:
   - Which file is missing
   - What task was being attempted
   - What validation step was blocked
4. Do NOT self-interpret or improvise the validation rules from memory
5. Resume only after the file is confirmed accessible
```

---

## Enforcement Model

This is an **instruction-driven** enforcement system. It works because:

1. **Agents are instruction-followers** — they execute what their `.agent.md` file says
2. **Validation rules are embedded** in agent instructions as mandatory operating procedures
3. **Artifact schemas are contracts** — agents know exactly what they must produce
4. **Workflows are checklists** — agents follow them step by step
5. **Coordinators enforce** — Agent 4 and Agent 8 check compliance as part of their role
6. **State is documented** — everything is traceable through artifacts and state records

### What Happens When an Agent Violates Rules?

```
VIOLATION DETECTED (by agent self-check or coordinator review):
│
├─ Agent catches own violation during workflow execution
│  └─ Fix before proceeding. Log the violation and correction.
│
├─ Coordinator catches violation during governance review
│  └─ REJECT artifact. Return to producing agent with specific failures.
│     Agent must address each failure and re-submit.
│
├─ Downstream agent catches violation in received handoff
│  └─ REJECT handoff. Return to source agent with missing/invalid fields.
│     Source agent must complete the handoff package.
│
└─ User reports violation or incorrect output
   └─ Coordinator initiates rollback to last valid state.
      Root cause analysis. Update validation rules if gap found.
```
