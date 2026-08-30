---
name: omp-crew
description: Coordinate Oh My Pi (OMP) task agents across the configured Cursor and other provider models with explicit task ownership, parallel analysis, and joined verification. Use when a task benefits from multiple model perspectives, cross-checking, or parallel implementation and review through omp.
---

# Model Council

Use this shared, harness-neutral workflow when the task benefits from multiple
independent model perspectives. Keep the coordinator user-facing, freeze the
task context before dispatch, and reconcile all reports before claiming success.

This skill is for the shared `.agents` environment and the Oh My Pi (`omp`)
runtime. It is not Codex's native `$crew` workflow.

## Optional Ponytail pass

If the `ponytail` skill is available in the current OMP skill set, load it before
planning or implementing nodes and use it to minimize the DAG, agent count, and
diff. Treat it as an optimization pass only: it must not override user intent,
safety constraints, required tests, or final verification. If Ponytail is not
available, continue normally without adding a replacement layer.

## Available OMP models

Use OMP's live catalog rather than maintaining a stale model list:

```bash
omp models --json
omp models cursor
omp models openai-codex
```

Your current OMP config defaults to `cursor/gpt-5.6-luna-high`. Cursor is a
first-class provider here; use its qualified model IDs, including Cursor's
Claude, GPT, Gemini, Grok, Composer, and other catalog entries. The catalog is
runtime- and account-dependent, so probe it before dispatching and report any
fallback explicitly. Prefer different model families for independent review
when the task warrants it; use the user's configured default for ordinary work.

## Council protocol

1. Freeze the request, repository state, constraints, and acceptance criteria.
2. Build a small DAG. Each node has an owner, model, mode (`read`, `write`,
   `review`, or `verify`), files or system boundary, dependencies, handoff, and
   proof requirement.
3. Dispatch independent nodes concurrently through OMP's `task` facility, using
   distinct qualified `--model` selections when useful. Use fresh context for
   focused work and include all required inputs.
4. Tell every writing agent to preserve unrelated user changes, stay within its
   ownership, and not spawn another council.
5. Send completed findings directly to dependent owners when the runtime supports
   messaging; otherwise retain the complete structured report in the coordinator.
6. Join only after all required predecessors finish. Resolve disagreements by
   checking the source, running the relevant verification, and preserving the
   narrowest safe conclusion.
7. Run an explicit final verification node. A model report is evidence, not proof.

## Dispatch examples

Use OMP's native task facility when running inside OMP. For isolated CLI-backed
dispatch, keep prompts independent and pass the same frozen context:

```bash
omp -p --model cursor/gpt-5.6-luna-high --thinking high "<scoped assignment>"
omp -p --model cursor/claude-4.6-opus-max --thinking high "<scoped assignment>"
omp -p --model openai-codex/gpt-5.6-terra --thinking high "<scoped assignment>"
```

Run these independently, capture exit status and output per model, and never
merge their edits automatically. For implementation work, designate one owner;
use the other models for read-only design, review, or verification unless the
task explicitly calls for independent implementations. OMP's `--models` flag
can constrain model cycling for an interactive session.

## Handoff format

Require each agent to return:

```text
Node: <id>
Status: complete | blocked
Findings: <facts and decisions>
Changed: <files, or none>
Proof: <tests, commands, or evidence>
Risks: <remaining uncertainty>
Handoff: <next owner or coordinator>
```

Do not call the council complete until every required node is complete, changes
are reconciled, verification has run, and remaining risks are stated.
