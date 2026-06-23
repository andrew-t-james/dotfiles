---
name: deep-interview
description: Socratic requirements interview before planning or implementation
---

# Deep Interview

Use this skill when the user's request is broad, underspecified, or explicitly asks not to assume. The goal is to convert intent into a concrete, testable brief before planning or coding.

## When to Use

- The user says "interview me", "deep interview", "gather requirements", or "don't assume".
- The task lacks acceptance criteria, boundaries, examples, or success signals.
- The work could branch in materially different directions depending on user intent.
- A wrong assumption would cause significant rework.

Do not use this skill when the user provided concrete files, acceptance criteria, and verification targets, or when they explicitly asked to skip planning.

## Procedure

1. Ask one question at a time.
2. Start with intent and success before implementation details.
3. Prefer questions that expose boundaries, examples, constraints, and tradeoffs.
4. Inspect available project context before asking the user where obvious code or docs live.
5. Summarize what is now known after each meaningful answer.
6. Stop when the task can be expressed as a brief with acceptance criteria and non-goals.

## Clarity Dimensions

- Goal: what outcome should exist when the work is done?
- User or audience: who benefits and what changes for them?
- Scope: what is in and out?
- Constraints: deadlines, compatibility, dependencies, style, safety, or process rules.
- Examples: concrete before/after cases or comparable behavior.
- Verification: how will we know it works?
- Decision rights: what may the agent decide without asking?

## Output Brief

```text
Goal:

Context:

In Scope:

Out of Scope:

Acceptance Criteria:

Verification:

Open Questions:
```

## Interview Rules

- Never batch multiple unrelated questions.
- Do not ask preference questions when local evidence can answer them.
- Do not start implementation from an ambiguous brief.
- If the user says to proceed, carry forward all non-conflicting answers as constraints.
