---
name: crew
description: Coordinate native Codex agent crews across Desktop or Herdr. Use for explicit $crew requests or tasks where multiple agents materially improve the outcome. Editing this skill does not invoke it.
---

# Crew

Coordinate the smallest useful agent graph that delivers the requested outcome. Optimize
for correct, reviewable work rather than agent activity, review count, or code volume.

## Invocation and routing

Explicit user choices override these defaults. Preserve authorization, acceptance gates,
models, reasoning efforts, and the designated workspace through every handoff and resume.

For an explicit `$crew` invocation:

| Setting | Default |
| --- | --- |
| Surface | `auto`: Herdr when `HERDR_ENV=1`, otherwise a native Desktop child thread |
| Primary | `gpt-5.6-luna` with `reasoning_effort: "max"` |
| Advisor | read-only `gpt-6-astra` with `reasoning_effort: "medium"` |

The resolved primary route applies to the coordinator and all non-advisor descendants.
The resolved advisor route applies to advisor/reviewer threads.
Explicit model routing requires `fork_turns: "none"`; put the complete bounded brief in
the spawn prompt instead of attempting a full-history fork with model overrides.

Accept the same compact overrides:

- `--surface auto|desktop|herdr`
- `--primary <model>:<effort>`
- `--advisor <model>:<effort>` or `--no-advisor`

Map `luna`, `sol`, and `astra` to `gpt-5.6-luna`, `gpt-5.6-sol`, and `gpt-6-astra`.
Natural-language overrides are equivalent to flags. Ask only when an override is
incomplete or unavailable; do not silently substitute a requested model. If `$crew` has
no goal, ask only: “What should the crew accomplish?”

The invoking thread is the outer monitor. On Desktop, launch exactly one native child as
the implementation coordinator. On Herdr, designate exactly one Herdr-managed Codex agent
as that coordinator. It owns the DAG, implementation, integration, verification, and its
native worker children. The outer monitor remains responsive and may own read-only advisor
threads, but must not become a competing implementer. Preserve native parent/child
relationships on retry and resume. Read [surface routing](references/surfaces.md) before
starting Herdr or when surface selection or recovery is relevant.

A coordinator is active only after its start call returns a non-empty agent or pane ID.
Until then, do not describe it as assigned, active, running, or working, and do not wait.
Record the returned ID in the graph and pass it to every operation whose current schema
accepts an agent target. A host-wide wait is valid only after that live ID exists; reconcile
its result against the recorded coordinator before treating the coordinator as settled.
Correct a rejected start call once using the current API. If that retry fails, report the
Crew run blocked instead of simulating coordination or silently doing the coordinator's work.
On Desktop, `spawn_agent` must be the first collaboration action. Do not call `wait`, send
messages, inspect the task as a substitute coordinator, or announce progress before that
spawn succeeds. A one-node graph still runs in the separate implementation coordinator;
it never collapses that role into the outer monitor. If native spawning is unavailable,
report the explicit Crew run blocked.
Prefix each root child prompt with exactly one machine-readable role line:

- `Crew role: implementation-coordinator`
- `Crew role: advisor`

Do not use either marker for worker descendants owned by the implementation coordinator.

## Set scope before work

Record a compact scope contract before implementation:

- required user-visible behavior and proof;
- excluded adjacent work;
- expected production and test change shape, including cumulative stack size when known;
- any required new subsystem, migration, compatibility layer, or shared contract.

Every new subsystem, migration, persistent contract, compatibility path, or broad surface
rollout must map to an explicit requirement. Delete compatibility for unshipped
intermediate designs by default. A valid review finding does not itself authorize new
product scope.

At integration points, compare the whole cumulative diff—not only the current slice—to
the scope contract. Separate production, tests, generated files, migrations, and support
tools when that changes the judgment. Stop and replan when work introduces an unplanned
boundary or materially exceeds the expected change shape. Split independent improvements
instead of absorbing them into the active deliverable.

Within the scope contract, continue through implementation, relevant verification, and
repairs without pausing for routine approval. Stop only for a new authority, scope,
safety, or materially branching decision.

## Build the smallest DAG

Use a DAG only where ownership or dependencies benefit from it. A sequential or single-
worker task may have a one-node graph; do not invent parallel work.

Each delegated node records:

- `id`, outcome, dependencies, and successor handoff;
- read/write/review mode and exclusive file, system, or runtime ownership;
- model, reasoning effort, native agent type, and `fork_turns` choice;
- proof tied to the relevant revision or diff, environment, result, and known gaps.

The coordinator retains integration and final verification unless explicitly delegated.
Start only ready nodes, run genuinely independent nodes in parallel, and serialize shared
resources. Changed inputs invalidate dependent reviews and proof. A completed child is not
evidence that the whole objective is complete.

### Optional Beads

Use Beads when the user requests durable tracking or the graph is likely to span context
windows, resumptions, or multiple worktrees. If selected and `bd` is available, first read
[external Beads tracking](references/beads.md); keep its store outside every repository,
never use `--global`, and keep one authoritative graph. Otherwise the implementation
coordinator keeps that graph in native parent/child thread state or the existing continuity
checkpoint. Missing or failed Beads must not block the crew or cause a repo-local fallback.

## Delegate with hard boundaries

Use `fork_turns: "none"` for explicitly routed coordinators and workers, and use native
`agent_type: "default"` with explicit model and reasoning fields. A full-history fork may
be used only when it inherits the parent route without overrides. Give each child its exact scope, inputs, ownership, proof,
dependencies, successor, model, effort, and write constraints. Include this boundary in
every leaf assignment:

`Complete this scope directly. Do not spawn other agents or reviewers, and do not
interrupt, close, or reassign siblings. Return blockers and partial evidence to your
parent.`

Tell writing agents they share the workspace, must preserve user and sibling changes, and
must remain inside their ownership. Only a coordinator may own a child DAG, and only when
at least two independent children justify it. Check actual spawn arguments and runtime
metadata when exposed; prompt labels are not routing proof.

## Keep review convergent

Use the configured advisor—Astra Medium by default—only for a concrete read-only question
whose answer can change a decision. For complex work, prefer one early boundary/approach
review and one revision-bound final review. Reuse an existing advisor for corrective
deltas. Additional reviews require materially changed input or a named unresolved
question; do not create performative second opinions.

Before acting on a finding, classify it:

1. A defect introduced by this change: fix in scope.
2. A blocker to an explicit requirement: fix or rescope.
3. An independent improvement or broader behavior: separate work.
4. Compatibility for an unshipped intermediate design: remove by default.

After two review/fix rounds without convergence, stop broad review cycling. Batch the
remaining defect family, reduce or split scope, or replace the approach before requesting
another whole-diff review. User-requested reviews and changed-input verification still
apply.

## Execute, recover, and finish

Pass prerequisite artifacts in a successor's prompt, or message an existing owner when
evidence changes. Use `followup_task` to start new work on an idle child; `send_message`
alone is informational.

Wait only after recording a live coordinator ID. Use a targeted wait when the current API
supports one; otherwise use the host-wide wait and reconcile its result against that ID.
When a coordinator reports a completed join, inspect the result. If required proof passes,
deliver the final answer in the same turn. If proof is missing, return the exact gap to the
same coordinator. Close or cleanup results may be reported after an accepted answer, but
cleanup must not delay or suppress it.

For a stalled or superseded node, preserve its evidence and owned processes, stop the old
owner, then narrow or reassign the remainder. Do not create overlapping replacement work.
On resume, reconcile the graph, live parent/child threads, routing, revisions, dirty state,
and proof before spawning.

Treat agent reports and turn status as inputs, not acceptance. The implementation
coordinator integrates and runs task-level verification; the outer monitor inspects the
evidence. Final proof identifies the exact revision or dirty-diff fingerprint, required
checks, outstanding findings, relevant runtime identity, and owned-resource disposition.
Do not replace a missing required gate with an easier one or add unrelated live-provider
proof.

Before the first collaboration action in an explicit `$crew` run, hash the resolved Crew
`SKILL.md` and emit exactly one identity line:

`Crew skill: <absolute-path>#sha256:<64-lowercase-hex>`

Also record its Git revision when available. Report the outcome as implemented, verified,
published, paused, or blocked independently of whether the latest agent turn completed.

For a captured Codex JSONL run, verify the root coordinator and completion receipt with
`scripts/validate_receipt.py --skill-sha256 <hash> <receipt.jsonl>` before using that run
as promotion evidence.
