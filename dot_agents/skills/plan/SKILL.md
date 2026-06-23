---
name: plan
description: Create a grounded implementation plan before coding
---

# Plan

Use this skill when the user wants to plan a change, compare approaches, review an existing plan, or turn a broad request into concrete implementation steps.

## When to Use

- The request is broad, risky, or cross-cutting.
- The user says "plan this", "let's plan", or asks for tradeoffs.
- The user wants requirements, acceptance criteria, or a test strategy before execution.
- The task touches security, data migration, public APIs, production behavior, or multiple modules.

Do not use this skill for a small obvious fix or a direct factual question.

## Procedure

1. Restate the goal in one or two sentences.
2. Inspect the relevant repo context before asking questions that the code can answer.
3. Ask at most one focused question at a time when scope or tradeoffs are unclear.
4. Identify constraints, non-goals, risks, and reversible vs irreversible choices.
5. Propose a right-sized plan with concrete files or modules where possible.
6. Include verification steps that would prove the work is complete.
7. Stop at the plan unless the user has clearly asked for implementation.

## Plan Shape

```text
Goal:

Known Context:

Assumptions:

Non-goals:

Approach:
1. ...
2. ...

Verification:

Risks / Open Questions:
```

## Quality Bar

- Acceptance criteria are observable and testable.
- Implementation steps are sized to the real task, not a fixed template.
- Alternatives are recorded when a decision is not obvious.
- Verification includes the narrowest useful tests or checks.
- The plan does not delegate unresolved ambiguity to the implementation step.
