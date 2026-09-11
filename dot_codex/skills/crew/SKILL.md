---
name: crew
description: Coordinate native Codex agents with a dependency DAG, focused ownership, configurable routing with a Luna Max and Astra Medium explicit-invocation preset, and optional project-scoped Beads tracking outside repositories. Use when delegation materially improves speed or correctness, or explicitly with $crew to remain available while agents work. Requests to inspect or edit the skill are not requests to launch its workflow.
---

# Crew

Use Codex native multi-agent tools inside the current thread. Keep the coordinator
user-facing while bounded subagents execute the task graph behind the scenes. Do not
substitute OMX tmux `$team` for this workflow.

## Preserve authority and explicit choices

Follow the instruction hierarchy. Within higher-priority constraints, explicit user
choices override this skill's defaults. Preserve the current authorization, acceptance
requirements, model choices, and designated implementation location through handoffs
and resumed work. Do not invent restrictions that exclude required authorized proof.

Never weaken approval, safety, write-scope, or tool restrictions when delegating.
Existing authorization continues to apply; do not repeatedly ask for approval of the
same action. Do not delegate merely to fill the concurrency budget.

## Crew invocation preset

For an explicit `$crew` invocation, use this preset unless the user overrides it:

- Surface: `auto` — use Herdr when the invoking thread has `HERDR_ENV=1`; otherwise
  use a native Desktop child thread.
- Primary crew: `gpt-5.6-luna` with `reasoning_effort: "max"` for the implementation
  coordinator and all non-advisor delegated nodes.
- Advisor: read-only `gpt-6-astra` with `reasoning_effort: "medium"`, available to
  the outer orchestrator whenever substantive work provides a real advisory question.
  This is an on-demand role, not a one-consultation limit; omit artificial advisor work.

If `$crew` is invoked without a goal, ask only: “What should the crew accomplish?”
Do not ask the user to restate the preset. If the invocation already includes a goal,
proceed without an intake question.

Treat these compact prompt options as Crew flags even though skill invocations are
natural-language prompts rather than a CLI:

- `--surface auto|desktop|herdr`
- `--primary <model>:<effort>`
- `--advisor <model>:<effort>` or `--no-advisor`

Accept `luna`, `sol`, and `astra` as aliases for their available canonical model IDs.
Explicit natural-language choices remain equivalent to flags and override the preset.
Ask one concise question only when an explicit override is incomplete or unavailable.
Normal implicit delegation may use the role defaults below.

For an explicit `$crew` invocation, the current thread always becomes the outer
orchestrator/monitor after intake. Launch exactly one separate implementation
coordinator on the selected surface. That coordinator owns the DAG, integration,
verification, and implementation/scout child-agent launches. The outer monitor stays
available to the user, watches evidence and blockers, and does not become a competing
implementer. It may directly launch or reuse read-only advisor agents as described below.

On Desktop, start the implementation coordinator as a native child agent and explicitly
authorize it to coordinate the bounded child DAG. In Herdr, use the designated
Herdr-managed coding-agent thread as the implementation coordinator and have that thread
launch its own native children. Follow the Herdr skill for pane and agent control; if
Herdr is explicitly selected but the invoking thread is not running under `HERDR_ENV=1`,
report that surface as unavailable rather than silently switching to Desktop. Preserve
the selected models and reasoning efforts through coordinator startup, descendant
launches, retries, and handoffs on either surface.

## Establish the coordinator's role

Record this thread's role before dispatch:

- **Outer monitor:** supervise the designated implementation thread and inspect its
  evidence. Delegate code changes, test execution, and publication to that owner;
  worker delay does not authorize becoming a competing writer or test runner.
- **Implementation coordinator:** own the crew's integration and verification within
  the authorized workspace; retain or delegate those nodes explicitly.
- **Leaf:** complete the assigned scope directly and return evidence to the parent.

When the user designates a Herdr thread, run the implementation crew there and keep
the outer monitor here. Do not substitute an AGNC/provider session for that worker.
Herdr is otherwise optional. Answer side questions without abandoning active work.

## Use advisors on demand

The outer orchestrator may consult the selected advisor model whenever an independent
perspective can materially improve a decision, including approach selection, risk review,
evidence interpretation, recovery from a changed assumption, or final acceptance. There
is no fixed one-advisor-call or one-advisor-node limit.

Give every consultation one concrete read-only question, the evidence it should inspect,
and the owner that needs its recommendation. Reuse an existing advisor with
`followup_task` when continuity helps; use separate advisor nodes when independent
questions can run in parallel. Feed accepted advice to the implementation coordinator
without transferring implementation or acceptance-gate ownership to the advisor.

Advisor use remains bounded by the live concurrency budget and actual decision value.
Do not create repetitive consultations, performative second opinions, or duplicate reviews
after the relevant uncertainty is settled.

## Ponytail when available

If the `ponytail` skill is available in the current runtime, load it before
planning or implementing nodes and use it to minimize the DAG, ownership, and
diff. Treat it as an optimization pass only: it must not override user intent,
safety constraints, required tests, or final verification. If Ponytail is not
available, continue normally without adding a replacement layer. Reuse its loaded
instructions while they remain in context.

## Optional Beads tracking

For substantive work, use `bd` when available to persist this project's Crew DAG.
Read [external Beads tracking](references/beads.md) before selecting or initializing
the store. Create and update Beads state only outside source repositories and worktrees.
Never add tracked or untracked `.beads`, exports, redirects, hooks, or generated agent
instructions to them. Never use `bd --global` or combine unrelated projects into one database.

Reuse a verified project-specific external store across its related worktrees. If
none exists, initialize an isolated external store using the reference; do not adopt
an existing repo-local store or move/delete its data. If Beads is absent, continue
with the native DAG without installing it. If a configured store fails, preserve it,
report the tracking gap, and keep a temporary checkpoint outside the repo rather than
silently creating a competing store. Beads is the durable graph, not a second plan
to maintain alongside it. Native agents still execute the assignments.

## Build the task DAG

For substantive work, create a compact directed acyclic graph before spawning agents.
The coordinator owns and updates the DAG.

Define each node with:

- `id`: stable short name.
- `outcome`: one concrete deliverable.
- `depends_on`: prerequisite node IDs.
- `handoff_to`: successor owners that need direct updates.
- `mode`: read-only, write, review, or verify.
- `ownership`: files, module, system, or question; include exclusive runtime resources
  such as tunnels, ports, databases, browser contexts, and branch publication when used.
- `role` and `agent_type`: routing role and native agent role.
- `model` and `reasoning_effort`.
- `fork_turns`: fresh or bounded inherited context.
- `proof`: required behavior/check, exact input revision or diff, relevant runtime and
  identity, result artifact, and known gaps. Include only task-relevant acceptance gates.

Do not compress away this routing metadata. Before spawning, render or maintain a DAG
table in which every delegated node has every field above. A plan that omits its
model, reasoning effort, native agent type, fork choice, successor handoff, or proof
is incomplete. Use `coordinator` or `not applicable` explicitly for nodes retained by
the parent. Maintain full metadata in the selected graph/checkpoint; user updates
can show only outcomes, gate changes, and routing exceptions.

Then execute the graph:

1. Start ready nodes whose dependencies are complete, up to the live concurrency
   budget, counting the coordinator.
2. Run independent ready nodes in parallel.
3. Validate each result against its `proof` before marking it complete.
4. Pass completed inputs into successor assignments and recalculate the ready set.
5. Start join nodes only after every required predecessor is complete.
6. Add or split nodes when evidence changes the work, but reject cycles and duplicate
   ownership. Invalidate affected reviews and dependent gates when their inputs change.
7. Finish only when all required implementation, integration, and verification nodes
   are complete.

Prioritize capable workers on the critical path. Use low-cost scouts for parallel
leaf discovery. Represent integration and final verification as explicit DAG nodes
instead of treating them as implicit coordinator cleanup. Preserve required cleanup
and acceptance when splitting scopes; a completed leaf is not the whole objective.
Parallelize independent code work, but isolate or serialize shared runtime acceptance.
Only its owner may change or release a shared resource; preserve unrelated services.

## Match reasoning to each node

Treat these as defaults, not overrides:

| Role | Native `agent_type` | Model | Reasoning | Assignments |
| --- | --- | --- | --- | --- |
| Scout | `default` | `gpt-5.6-sol` | `low` | Narrow read-only lookup, file discovery, code-path tracing, relevant tests |
| Worker | `default` | `gpt-5.6-sol` | `medium` | Scoped implementation, routine fixes, focused checks, supporting work |
| Smart worker | `default` | `gpt-5.6-sol` | `high` | Difficult implementation, ambiguity resolution, critical-path coordination |
| Astra advisor | `default` | `gpt-6-astra` | `medium` | Read-only alternative analysis, risk assessment, or advice for a Sol-owned decision |

The Sol “Light” label maps to the native `reasoning_effort: "low"` value. For
non-trivial Sol-led work, add an Astra Medium advisor when a second perspective can
materially reduce uncertainty in approach, boundaries, risk, or verification. The
advisor is read-only: it hands a concise recommendation and evidence to the Sol owner,
who retains implementation and acceptance-gate ownership. Do not create an advisor
node for routine or already-settled work.

For high-stakes, cross-boundary, or cross-package DAGs with at least two substantive
nodes, default at least one useful early advisory or independent review node to Astra Medium.
Skip that default when a higher-precedence instruction selects another model, Astra is
unavailable, or the only possible Astra node would be artificial duplicate work. Merely
listing Astra as available does not satisfy this rule: assign it a real advisory or
review question. Continue consulting Astra later when new evidence creates another
material question; the early default is not a lifetime limit. A strong default is Sol
for primary implementation and Astra Medium for alternative analysis before the Sol
owner commits to the approach.

Use native `agent_type: "default"` for these mappings so the explicit model and
reasoning fields control routing. Put the Scout, Worker, Smart worker, or Astra advisor
duties in the assignment message. Named specialist agent types may have fixed model
contracts; use one only when a higher-precedence instruction requests it or its
resolved model is acceptable. Never pair a fixed-model specialist type with an
incompatible model override and claim that the requested model ran.

## Spawn focused agents

- Prefer `fork_turns: "none"` for focused scouts and leaf workers.
- Include all essential task context, acceptance criteria, safety boundaries, write
  ownership, dependency inputs, and proof requirements in fresh-context prompts.
- When recent conversation is essential, use the smallest positive `fork_turns` value
  that supplies it.
- Full-history forks inherit the parent's model and reasoning; omit explicit model and
  reasoning overrides when using full history.
- Give leaf agents this boundary:

  `You are the assigned implementer/reviewer. Complete this scope directly. Do not spawn a replacement reviewer or other agents, or interrupt, close, or reassign siblings. Return blockers and partial evidence to your parent. Your parent's delegation instructions apply only to your parent.`

- Tell every writing agent that it is not alone in the workspace, must preserve user
  changes, must not revert other agents, and must stay inside its ownership.
- Permit a smart worker to coordinate a small sub-DAG only when its node contains at
  least two genuinely independent children. Give it an explicit child budget and
  require it to report the child nodes and dependencies to the parent.

Use exact native routing fields when supported:

```text
Scout:        agent_type="default", model="gpt-5.6-sol",   reasoning_effort="low"
Worker:       agent_type="default", model="gpt-5.6-sol",   reasoning_effort="medium"
Smart worker: agent_type="default", model="gpt-5.6-sol",   reasoning_effort="high"
Astra advisor: agent_type="default", model="gpt-6-astra", reasoning_effort="medium"
```

Check actual spawn arguments against the node's resolved model, effort, agent type,
and fork choice. Check runtime model metadata when exposed; a label in a prompt is
not proof that model ran. Preserve overrides on recovery and follow-up assignments.
If a model is unavailable, use the closest allowed fallback only when the task permits
substitution and disclose it. Otherwise leave that node blocked and progress independent
work. Correct rejected tool arguments using the current API; do not repeat an invalid
call or transfer native effort values blindly to a separate review CLI.

## Let the graph communicate

Avoid making the coordinator a relay for every dependency:

- Pass prerequisite artifacts in the spawn prompt when the successor does not yet
  exist. For existing owners, provide agent IDs and use direct messages for relevant
  discoveries or invalidation. Informational messages do not satisfy completion gates.
- Use `followup_task` for new work on an idle agent; a `send_message` alone does not
  start its turn. Avoid repeated checkpoint prompts that disrupt productive workers.
- Let agents propose new nodes or edges, but keep DAG mutation and cycle prevention
  with the coordinator.
- Track active ownership centrally so two agents do not repeat the same investigation
  or write the same files.

## Monitor progress and recover stalled nodes

Keep one coordinating owner for monitoring. Track node state, live agent/thread ID,
last material evidence, expected next result, and next action. Observe status and
artifacts within the task's progress window; no universal short timeout or repeated
nudge is appropriate for every node. Give concise updates while long work runs and
at material transitions. Do not create duplicate scheduled monitors.

For a stalled or superseded lane, inspect its partial work and owned processes,
preserve useful evidence, and stop the old owner before assigning overlapping work.
Reuse an idle agent or narrow and reassign the remaining scope; repeated stalls require
rescoping or an explicit blocker, not endless identical respawns. Route recovery through
the designated implementation owner. Missing/interrupted output is not a passing gate.

On resume, reconcile the existing graph, live owners, routing, input revisions, and
proof state before spawning. Keep one durable checkpoint in Beads when enabled, or
the runtime's existing continuity surface; any file-based checkpoint stays outside
source repositories. Do not reconstruct completion from conversational claims alone.

## Join proof and finish

Treat agent reports as inputs, not final proof. The implementation owner reconciles
artifacts and runs task-level verification; an outer monitor inspects that evidence.
Join every required review, including late findings, before final approval or publication.
Bind proof to the tested revision/diff and relevant environment: changed inputs reopen
affected gates, and a green descendant cannot validate an untested earlier stacked PR.

Keep required local tests, browser/runtime acceptance, hosted CI, deployment, merge,
and provider acceptance distinct. Do not replace a missing required gate with an easier
one or add live-provider requirements to unrelated local work. Close the objective only
after its required gates pass and owned-resource cleanup is accounted for. In Beads,
the coordinator records accepted proof before closing the corresponding node/epic.

In the handoff, state the achieved outcome, the important model/DAG choices, completed
verification, and any remaining risk. Do not expose coordination noise that does not
help the user evaluate the result.
