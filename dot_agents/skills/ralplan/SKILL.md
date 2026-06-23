---
name: ralplan
description: Consensus planning with planner, architect, and critic perspectives
---

# Ralplan

Use this skill when a plan needs deliberate review before implementation. It is a harness-neutral consensus-planning pattern: planner proposes, architect challenges structure and tradeoffs, critic checks risks and testability.

## When to Use

- The change is high-risk, ambiguous, or architecture-shaping.
- The user asks for "ralplan", "consensus plan", or multi-perspective planning.
- A normal plan exists but needs stronger challenge before execution.

## Procedure

1. Planner creates an initial plan with goal, constraints, options, risks, and verification.
2. Architect reviews for module boundaries, coupling, migration path, reversibility, and tradeoffs.
3. Critic reviews for weak assumptions, missing tests, vague acceptance criteria, and hidden risks.
4. Planner revises the plan from both reviews.
5. Repeat until the critic would approve or until five review loops are reached.
6. Output the final plan and stop unless the user separately asked for implementation.

Run architect review before critic review so the critic can evaluate the revised architectural framing.

## Required Output

```text
Decision:

Drivers:

Alternatives Considered:

Chosen Approach:

Implementation Plan:

Verification Plan:

Risks:

Follow-ups:
```

## Quality Bar

- At least two viable options are considered unless there is a documented reason only one option is realistic.
- The chosen approach states what it optimizes for and what it gives up.
- Acceptance criteria are testable.
- Verification covers the riskiest behavior first.
- Execution is a separate step from consensus planning.
