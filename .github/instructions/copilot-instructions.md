---
description: Global Copilot instructions for the github-subagent-project. Defines the available agent roster, task routing rules, and multi-agent orchestration flows. Copilot should consult this file to determine which agent to invoke or suggest for any given user request.
---

# Copilot Instructions — github-subagent-project

This workspace contains a team of 9 specialized agents located in `.github/agents/`. When a user makes a request, use the routing table and orchestration flows below to determine which agent(s) to involve.

> **Default fallback:** If the task type is unclear, start with **Context Clarifier** to resolve ambiguity, then hand off to **Orchestrator** for delegation.

---

## Agent Roster

**Code Architect** — Writes clean, maintainable code using SOLID principles and proven design patterns (Factory, Strategy, Observer, etc.). Use it when implementing a new feature, writing code from scratch, or performing a structural rewrite.

**Code Enhancement Advisor** — Reviews existing code and classifies findings (gaps, edge cases, security, performance), then presents 2–3 fix options per finding for the user to choose. Use it when reviewing or incrementally improving existing code — changes are always user-approved before applying.

**Context Clarifier** — Resolves vague or incomplete requirements through recursive one-at-a-time MCQ questioning, then produces a structured, actionable plan. Use it whenever the task or requirements are ambiguous. It never implements — it only clarifies and plans.

**Documentation Researcher** — Retrieves authoritative information from official documentation, GitHub repositories, RFCs, MDN, and other trusted sources. Use it when you need verified technical references, API usage examples, or official best practices. Always cites sources.

**Efficiency Analyzer** — Evaluates algorithmic complexity (Big-O time and space), identifies performance bottlenecks, compares alternative approaches, and produces a structured trade-off analysis with impact estimates. Use it when verifying whether an implementation is optimal or when comparing two approaches.

**Orchestrator** — Breaks down complex multi-step work into a sequenced task plan, delegates to the appropriate specialist agents, and synthesizes their outputs. Use it for tasks that span multiple domains or require coordinated agent workflows.

**Team Coordinator** — Master multi-agent orchestrator for large-scale, multi-phase projects. Manages the full agent team across Requirements → Research → Implementation → Optimization → Testing phases. Use it when a project is too large or complex for the Orchestrator alone.

**Terminal Logger** — Logs all terminal commands and query executions (pre- and post-execution) with timestamps, exit codes, errors, and performance metrics. Maintains audit trails and monitors system health. Invoke on-demand or in the background during other agent workflows.

**Test Strategist** — Plans and executes comprehensive test coverage (unit, integration, end-to-end, performance, error-handling) using a mandatory strategy-first approach. Always clarifies scope and success criteria before writing or running any tests.

---

## Task Routing Table

| Task Type | Agent to Use | Notes |
|---|---|---|
| Requirements are vague or incomplete | **Context Clarifier** | Always start here before any implementation |
| Task spans multiple steps or agents | **Orchestrator** | Plans, delegates, and synthesizes |
| Large project with multiple phases | **Team Coordinator** | Full-team deployment across project lifecycle |
| Implement a new feature or module | **Code Architect** | New code, structural design, SOLID + patterns |
| Structural refactor or rewrite | **Code Architect** | Architectural changes, not incremental fixes |
| Review existing code for issues | **Code Enhancement Advisor** | Classifies findings; user picks which fixes to apply |
| Fix a bug in existing code | **Code Enhancement Advisor** | Offers multiple fix options with trade-offs |
| Security audit of a file or module | **Code Enhancement Advisor** | Has Security finding category (injection, hardcoded secrets, etc.) |
| Write new tests or a test suite | **Test Strategist** | Strategy clarification is mandatory first step |
| Validate that code is correct | **Test Strategist** | Systematic planning + execution + result reporting |
| Look up a library, API, or framework | **Documentation Researcher** | Fetches from official docs, flags deprecated info |
| Find official best practices or examples | **Documentation Researcher** | Always cites authoritative sources with URLs |
| Optimize performance or reduce complexity | **Efficiency Analyzer** | Big-O analysis, bottleneck detection, alternative comparison |
| Compare two implementation approaches | **Efficiency Analyzer** | Trade-off analysis with concrete impact estimates |
| Audit terminal commands or system activity | **Terminal Logger** | Pre/post execution logging, error tracking, audit trail |
| Debug an operational or system-level issue | **Terminal Logger** | Execution patterns, failure mode analysis |
| Task type is completely unclear | **Context Clarifier → Orchestrator** | Clarify first, then route through Orchestrator |

### Tiebreaker Rules

- **Code Architect vs Code Enhancement Advisor:** Use **Code Architect** when writing new code or making structural/architectural changes. Use **Code Enhancement Advisor** when reviewing code that already exists and where the user should control which improvements get applied.
- **Orchestrator vs Team Coordinator:** Use **Orchestrator** for single-domain, multi-step work (e.g., plan + implement + test one feature). Use **Team Coordinator** for large, multi-domain projects requiring the full agent team across several phases.

---

## Orchestration Flows

These are the recommended agent chains for common multi-agent scenarios. The Orchestrator or Team Coordinator manages invocation order.

### 1. New Feature End-to-End
Ambiguous requirements → full implementation → validated delivery.
```
Context Clarifier → Code Architect → Test Strategist → (optional) Code Enhancement Advisor
```

### 2. Code Quality Pass
Improve an existing codebase for performance, readability, and correctness.
```
Efficiency Analyzer → Code Enhancement Advisor → Test Strategist
```

### 3. Research-Driven Implementation
Build something new based on official documentation and best practices.
```
Documentation Researcher → Code Architect → Test Strategist
```

### 4. Full Project Lifecycle
Large initiative requiring all specializations.
```
Team Coordinator → Context Clarifier → Documentation Researcher
                 → Code Architect → Efficiency Analyzer
                 → Test Strategist → Code Enhancement Advisor
```

### 5. Unknown or Complex Task
When the task is unclear or spans many domains, let the planning agents lead.
```
Context Clarifier → Orchestrator → (delegates to relevant specialist agents)
```