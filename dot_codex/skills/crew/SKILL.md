---
name: crew
description: Coordinate a native Codex agent crew with a dependency DAG, focused ownership, direct agent messaging, and task-matched GPT-5.6 Sol or Terra reasoning. Use for broad, high-stakes, ambiguous, context-scattered, or parallelizable work where delegation materially improves speed or correctness; use explicitly with $crew when the coordinator should stay available to the user while agents investigate, implement, review, or verify.
---

# Crew

Use Codex native multi-agent tools inside the current thread. Keep the coordinator
user-facing while bounded subagents execute the task graph behind the scenes. Do not
substitute OMX tmux `$team` for this workflow.

## Preserve authority and explicit choices

Apply model and reasoning choices in this order:

1. The user's explicit instructions.
2. System, developer, repository `AGENTS.md`, and task-specific constraints.
3. This skill's role defaults.
4. The closest currently available model only when a requested default is unavailable.

Never weaken approval, safety, write-scope, or tool restrictions when delegating.
Keep irreversible or materially branching decisions with the user. Do not delegate
merely to fill the concurrency budget.

## Optional Ponytail pass

If the `ponytail` skill is available in the current runtime, load it before
planning or implementing nodes and use it to minimize the DAG, ownership, and
diff. Treat it as an optimization pass only: it must not override user intent,
safety constraints, required tests, or final verification. If Ponytail is not
available, continue normally without adding a replacement layer.

## Build the task DAG

For substantive work, create a compact directed acyclic graph before spawning agents.
The coordinator owns and updates the DAG.

Define each node with:

- `id`: stable short name.
- `outcome`: one concrete deliverable.
- `depends_on`: prerequisite node IDs.
- `handoff_to`: successor owners that need direct updates.
- `mode`: read-only, write, review, or verify.
- `ownership`: files, module, system, or question owned by the node.
- `role` and `agent_type`: routing role and native agent role.
- `model` and `reasoning_effort`.
- `fork_turns`: fresh or bounded inherited context.
- `proof`: evidence required to mark the node complete.

Do not compress away this routing metadata. Before spawning, render or maintain a DAG
table in which every delegated node has every field above. A plan that omits its
model, reasoning effort, native agent type, fork choice, successor handoff, or proof
is incomplete. Use `coordinator` or `not applicable` explicitly for nodes retained by
the parent.

Then execute the graph:

1. Start ready nodes whose dependencies are complete, up to the live concurrency
   budget, counting the coordinator.
2. Run independent ready nodes in parallel.
3. Validate each result against its `proof` before marking it complete.
4. Pass discoveries directly to successor owners and recalculate the ready set.
5. Start join nodes only after every required predecessor is complete.
6. Add or split nodes when evidence changes the work, but reject cycles and duplicate
   ownership.
7. Finish only when all required implementation, integration, and verification nodes
   are complete.

Prioritize capable workers on the critical path. Use low-cost scouts for parallel
leaf discovery. Represent integration and final verification as explicit DAG nodes
instead of treating them as implicit coordinator cleanup.

## Match reasoning to each node

Treat these as defaults, not overrides:

| Role | Native `agent_type` | Model | Reasoning | Assignments |
| --- | --- | --- | --- | --- |
| Scout | `default` | `gpt-5.6-sol` | `low` | Narrow read-only lookup, file discovery, code-path tracing, relevant tests |
| Worker | `default` | `gpt-5.6-sol` | `medium` | Scoped implementation, routine fixes, focused checks, supporting work |
| Smart worker | `default` | `gpt-5.6-sol` | `high` | Difficult implementation, ambiguity resolution, critical-path coordination |
| Terra worker | `default` | `gpt-5.6-terra` | `high` | Independent implementation, alternate approach, hard review, or cross-check |

The Sol “Light” label maps to the native `reasoning_effort: "low"` value. Use Terra
High alongside Sol when model diversity materially improves a high-stakes decision,
implementation, or verification node. Do not force a Terra node when the DAG has no
useful independent work for it.

For high-stakes, cross-boundary, or cross-package DAGs with at least two substantive
nodes, route at least one independent hard review, alternative analysis, or
verification node to Terra High by default. Skip that default when a higher-precedence
instruction selects another model, Terra is unavailable, or the only possible Terra
node would be artificial duplicate work. Merely listing Terra as available does not
satisfy this rule: assign it a real DAG node. A strong default is Sol for primary
implementation and Terra High for independent verification or hard review.

Use native `agent_type: "default"` for these mappings so the explicit GPT-5.6 model
and reasoning fields control routing. Put the Scout, Worker, reviewer, or verifier
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

  `Complete this assignment directly. Do not spawn other agents; your parent's delegation instructions apply only to your parent.`

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
Terra worker: agent_type="default", model="gpt-5.6-terra", reasoning_effort="high"
```

If a model is unavailable, preserve the intended reasoning level with the closest
allowed model and tell the user about the fallback.

## Let the graph communicate

Avoid making the coordinator a relay for every dependency:

- After agents are spawned, tell each owner which successor agents consume its output.
- Ask agents to message those successors directly when findings unblock or invalidate
  their nodes.
- Use direct messages for live dependency updates and follow-up tasks for new work.
- Let agents propose new nodes or edges, but keep DAG mutation and cycle prevention
  with the coordinator.
- Track active ownership centrally so two agents do not repeat the same investigation
  or write the same files.

## Stay available and integrate

Give the user concise updates at material DAG transitions and remain responsive while
agents run. Monitor status rather than waiting blindly. Treat agent reports as inputs,
not final proof: inspect the relevant artifacts, reconcile conflicts, run task-level
verification, and own the final answer.

In the handoff, state the achieved outcome, the important model/DAG choices, completed
verification, and any remaining risk. Do not expose coordination noise that does not
help the user evaluate the result.
