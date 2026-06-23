---
name: skillopt-sleep
description: Use SkillOpt-Sleep concepts for local agent experience replay, consolidation, and gated skill improvement
---

# SkillOpt Sleep

Use this skill when the user asks about SkillOpt-Sleep, agent sleep cycles, nightly skill improvement, experience replay, validation-gated skill edits, or consolidating coding-agent sessions into long-term skills.

## Source

The reference README is vendored at:

```text
~/.agents/skills/skillopt-sleep/README.md
```

Original upstream:

```text
https://github.com/microsoft/SkillOpt/blob/main/docs/sleep/README.md
```

## Operating Model

SkillOpt-Sleep is a deployment-time companion pattern for local coding agents:

1. Harvest prior agent transcripts.
2. Mine recurring tasks.
3. Replay or evaluate tasks offline.
4. Reflect on recurring failures or improvements.
5. Propose bounded skill edits.
6. Gate proposed changes against held-out tasks.
7. Stage the proposal for human review before adoption.

## Use This Way

- Treat all harvested transcripts as private local data.
- Keep experience replay opt-in and explicit.
- Do not auto-adopt generated skill changes without a review step.
- Prefer small, bounded edits to existing skills over broad rewrites.
- Keep a validation gate on by default when a checkable correctness signal exists.
- Record proposed changes, rejected alternatives, and verification evidence.

## Do Not Use When

- The task is a one-off with no recurring workflow signal.
- There is no safe way to inspect the relevant transcripts.
- The proposed change cannot be validated or reviewed.
- The user only needs a normal implementation, review, or debugging pass.

## Procedure

1. Read the vendored README for the current details.
2. Identify the target harness and the local transcript source.
3. Define the recurring task family to mine.
4. Define the validation or held-out gate.
5. Generate a staged proposal rather than directly editing production skills.
6. Apply only reviewed, bounded, validated changes.
