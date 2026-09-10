# External, project-scoped Beads

Use this reference when substantive Crew work benefits from durable tracking and
`bd` is available. Each project owns a separate external store. Task data must never
enter source repositories or worktrees, including this dotfiles checkout. This
reference itself is managed skill code, not Beads task data.

## Select the store

1. Check `command -v bd`, `bd version`, and installed command help. Do not install or
   upgrade Beads as a side effect of a Crew task.
2. Reuse the project's designated external store after verifying its identity. Leave
   any existing repo-local `.beads` intact; do not write to, move, delete, or copy it.
   Link existing issue references when needed instead of silently migrating history.
3. Otherwise choose a stable directory outside repos, for example
   `${XDG_STATE_HOME:-$HOME/.local/state}/codex/crew/beads/<project-key>`. Derive the key
   from the canonical Git common directory so linked worktrees use the same store;
   use the canonical project root for non-Git work. A readable project name plus a
   short hash of that identity distinguishes same-named projects. Related initiatives
   can use separate epics; unrelated projects must not share a database.
4. Resolve paths and verify the store is outside every involved source checkout and
   worktree, even if `XDG_STATE_HOME` points into one. Record the project identity
   beside the external store and verify it on resume. Do not reuse a path associated
   with another project or create a new store merely because work moved to a worktree.

Never configure a global active project or permanent shell targeting variables, use
`--global`, or create repo-local redirects, exclusions, hooks, or agent instructions.
Do not stage, commit, export, sync, or push Beads data into project Git history or
hidden remote refs. An ignored `.beads` inside a checkout does not satisfy this rule.
Do not run `bd setup`, install hooks, or add a shared server as part of Crew setup.

## Git-free bootstrap and command scope

Use an explicit external working directory and a per-command `BEADS_DIR`. For new
local stores, build each child-process environment without inherited `BEADS_*`,
`BD_*`, or `GIT_*` variables, then set the exact `BEADS_DIR`. Do not alter the parent
shell or print credentials. Existing external stores with custom backend settings
need their own verified project-specific configuration; do not blindly redirect them.

Beads 1.2.2 was verified with two isolated stores. Its fresh-store bootstrap has
three important differences from ordinary repository setup:

- Pre-create local `.beads/config.yaml` containing `no-git-ops: true`. Without it,
  `init --stealth` attempts to write global `~/.config/bd/config.yaml`.
- Initialize with the external directory as the process working directory, **without
  `-C`**. `-C` rejects a directory that is not yet a Beads project.
- After initialization use `-C` and `where --json` to verify identity. In this version,
  `context --json` rejects this git-free layout; do not respond by moving it into a repo.

For a **new** store only, after verifying the absolute external path and project key:

```sh
python3 - "$crew_store" "$crew_prefix" <<'PY'
import os
from pathlib import Path
import subprocess
import sys

store = Path(sys.argv[1])
if not store.is_absolute():
    raise SystemExit("Use a verified absolute external store path")
store = store.resolve()
os.umask(0o077)
store.mkdir(parents=True, exist_ok=True)
beads = store / ".beads"
beads.mkdir()  # Refuse to overwrite or reinitialize an existing store.
(beads / "config.yaml").write_text("no-git-ops: true\n")
env = {k: v for k, v in os.environ.items()
       if not k.startswith(("BEADS_", "BD_", "GIT_"))}
env["BEADS_DIR"] = str(beads)
subprocess.run([
    "bd", "--sandbox", "init", "--stealth", "--skip-hooks", "--skip-agents",
    "--non-interactive", "--prefix", sys.argv[2],
], cwd=store, env=env, check=True)
subprocess.run(["bd", "--sandbox", "-C", str(store), "where", "--json"],
               cwd=store, env=env, check=True)
PY
```

For subsequent operations keep that sanitized process environment and external
working directory, and use `bd --sandbox -C <absolute-store> <command>`. Verify the
reported location/database and project association before mutations. Check
`config get no-git-ops` is true and no source-repo files/hooks were created. New
stores must have no remote sync configured. Ignore git identity/exclude suggestions
from this git-free bootstrap; do not configure Git to silence those warnings.

Check installed help on other versions. If initialization fails, preserve the partial
external store and report the tracking gap; continue with an external/native checkpoint.
Do not force reinitialization, install services, or retry inside a source repository.
The embedded backend permits a single writer: the coordinator serializes Beads CLI
access, and workers return status/proof through native messages. No new service is needed.

## Keep one authoritative Crew graph

- Reuse or create an epic for the objective and beads for substantive DAG nodes. Store
  routing, ownership, exact inputs, handoff targets, and proof requirements in their
  descriptions/metadata. Maintain bead ID to native-agent ID mapping, including the
  designated coordinator and its role. Do not maintain a second authoritative task list.
- Wire dependencies explicitly: `dep add <successor> <prerequisite>` means the
  successor depends on the prerequisite. Epic membership alone is not a blocking edge.
- Use `ready --json` as a candidate set, then check authorization, resource ownership,
  and prerequisite proof before dispatch. Always supply explicit IDs to update commands;
  never rely on implicit last-touched issue selection.
- Assign/claim the bead and dispatch through native tools. Record blockers, interim
  findings, and preserved partial work on the same bead. Stop an old owner before
  assigning overlapping work; duplicate beads are not a recovery strategy.
- Workers propose completion; the coordinator records accepted proof and closes the
  node. Proof includes tested revision/diff, relevant environment, command/behavior,
  result, and artifact. Close the epic only after required verification and cleanup.
- Reopen affected nodes when inputs change and explicitly invalidate/reopen dependent
  review and acceptance nodes. Reopening a prerequisite does not automatically reopen
  already-closed descendants. Recalculate readiness before dispatch.

Use installed help for `create`, `dep add`, `update`, `close`, and `reopen`. Keep large
evidence artifacts outside repos and reference their paths. Missing Beads does not
block the coding task; a failed existing store is a disclosed tracking gap, not a
reason to silently fork its history into a new store.

Reference: [Beads](https://github.com/gastownhall/beads), especially Git-Free Usage.
Installed help and the verified local behavior determine command compatibility;
upstream setup defaults do not override this external-only storage boundary.
