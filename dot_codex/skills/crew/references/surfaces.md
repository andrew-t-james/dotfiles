# Crew surface routing

Read this reference when selecting, starting, or recovering the explicit `$crew` surface.

## Auto selection

- `auto` selects Herdr when the invoking thread has `HERDR_ENV=1`.
- Otherwise `auto` selects a native Desktop child thread.
- An explicit unavailable surface is a blocker; do not silently switch surfaces.

## Desktop

Start one native child as the implementation coordinator with the resolved primary model
and reasoning effort. Explicitly authorize it to own the bounded worker DAG, integration,
and verification. Its workers remain native descendants of that coordinator. The invoking
thread stays the outer monitor and may own read-only advisor children.

## Herdr

When Herdr is selected, follow the Herdr skill and use one designated Herdr-managed Codex
agent as the implementation coordinator. Start it with the resolved primary model and
reasoning arguments passed as native agent arguments after `--`; use the installed Herdr
and Codex help to resolve their current spelling. The Herdr agent is not represented as a
native child of the outer monitor, but its worker agents are its native children. Keep the
invoking thread as the outer monitor; do not substitute an AGNC or provider session. If
Herdr was explicitly requested but `HERDR_ENV=1` is absent, report it as unavailable.

## Continuity

Preserve the selected surface, resolved model and reasoning overrides, native parent/child
relationships where used, ownership, and proof requirements through follow-ups, retries,
compaction, and resume. Stop or reconcile an old owner before assigning overlapping work.
Surface recovery must not create a second implementation coordinator.
