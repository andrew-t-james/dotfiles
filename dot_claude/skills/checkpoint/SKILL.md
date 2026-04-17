---
name: checkpoint
preamble-tier: 2
version: 2026.04.13
description: |
  Save and resume working state checkpoints. Captures git state, decisions made,
  and remaining work so you can pick up exactly where you left off — even across
  Conductor workspace handoffs between branches.
  Use when asked to "checkpoint", "save progress", "where was I", "resume",
  "what was I working on", or "pick up where I left off".
  Proactively suggest when a session is ending, the user is switching context,
  or before a long break. (wstack)
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
  - AskUserQuestion
---
<!-- AUTO-GENERATED from SKILL.md.tmpl — do not edit directly -->
<!-- Regenerate: bun run gen:skill-docs -->

## Preamble (run first)

```bash
# ─── Discover wstack bin directory (global install or project-local) ───
# Preferred order: global skill install → project-local → fallback to global.
_WSTACK_BIN=""
[ -z "$_WSTACK_BIN" ] && [ -x "~/.claude/skills/wstack/bin/wstack-config" ] && _WSTACK_BIN="~/.claude/skills/wstack/bin"
[ -z "$_WSTACK_BIN" ] && [ -x ".claude/skills/wstack/bin/wstack-config" ] && _WSTACK_BIN=".claude/skills/wstack/bin"
[ -z "$_WSTACK_BIN" ] && _WSTACK_BIN="~/.claude/skills/wstack/bin"
echo "WSTACK_BIN: $_WSTACK_BIN"

_UPD=$("$_WSTACK_BIN/wstack-update-check" 2>/dev/null || true)
[ -n "$_UPD" ] && echo "$_UPD" || true
mkdir -p ~/.wstack/sessions
touch ~/.wstack/sessions/"$PPID"
_SESSIONS=$(find ~/.wstack/sessions -mmin -120 -type f 2>/dev/null | wc -l | tr -d ' ')
find ~/.wstack/sessions -mmin +120 -type f -delete 2>/dev/null || true
_CONTRIB=$("$_WSTACK_BIN/wstack-config" get wstack_contributor 2>/dev/null || true)
_PROACTIVE=$("$_WSTACK_BIN/wstack-config" get proactive 2>/dev/null || echo "true")
_PROACTIVE_PROMPTED=$([ -f ~/.wstack/.proactive-prompted ] && echo "yes" || echo "no")
_SKILL_PREFIX=$("$_WSTACK_BIN/wstack-config" get skill_prefix 2>/dev/null || echo "false")
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "BRANCH: $_BRANCH"
echo "PROACTIVE: $_PROACTIVE"
echo "PROACTIVE_PROMPTED: $_PROACTIVE_PROMPTED"
echo "SKILL_PREFIX: $_SKILL_PREFIX"
source <("$_WSTACK_BIN/wstack-repo-mode" 2>/dev/null) || true
REPO_MODE=${REPO_MODE:-unknown}
echo "REPO_MODE: $REPO_MODE"
_LAKE_SEEN=$([ -f ~/.wstack/.completeness-intro-seen ] && echo "yes" || echo "no")
echo "LAKE_INTRO: $_LAKE_SEEN"
_TEL=$("$_WSTACK_BIN/wstack-config" get telemetry 2>/dev/null || true)
_TEL_PROMPTED=$([ -f ~/.wstack/.telemetry-prompted ] && echo "yes" || echo "no")
_TEL_START=$(date +%s)
_SESSION_ID="$$-$(date +%s)"
echo "TELEMETRY: ${_TEL:-off}"
echo "TEL_PROMPTED: $_TEL_PROMPTED"
# Linear integration check
_LINEAR=$(grep -A5 "## Linear" CLAUDE.md 2>/dev/null | grep "team_id:" | head -1 | sed 's/.*team_id: *//')
[ -n "$_LINEAR" ] && echo "LINEAR: configured" || echo "LINEAR: not_configured"
_ANALYTICS_DIR="${WSTACK_STATE_DIR:-$HOME/.wstack}/analytics"
mkdir -p "$_ANALYTICS_DIR"
# zsh-compatible: use find instead of glob to avoid NOMATCH error
# Only run telemetry binary if telemetry is enabled AND binary exists
if [ "$_TEL" != "off" ] && [ -x "$_WSTACK_BIN/wstack-telemetry-log" ]; then
  for _PF in $(find "$_ANALYTICS_DIR" -maxdepth 1 -name '.pending-*' 2>/dev/null); do [ -f "$_PF" ] && "$_WSTACK_BIN/wstack-telemetry-log" --event-type skill_run --skill _pending_finalize --outcome unknown --session-id "$_SESSION_ID" 2>/dev/null || true; break; done
fi
# Trigger telemetry sync in background. Rate-limited to once per 5 min by sync script.
if [ "$_TEL" != "off" ] && [ -x "$_WSTACK_BIN/wstack-telemetry-sync" ]; then
  ("$_WSTACK_BIN/wstack-telemetry-sync" >/dev/null 2>&1 &)
fi
# Persist session env for epilogue (re-sourced when bash blocks don't share shell)
mkdir -p ~/.wstack/sessions 2>/dev/null
printf '_WSTACK_BIN=%s\n_TEL=%s\n_TEL_START=%s\n_SESSION_ID=%s\n' \
  "$_WSTACK_BIN" "$_TEL" "$_TEL_START" "$_SESSION_ID" > ~/.wstack/sessions/.last.env 2>/dev/null || true
# Session timeline: record skill start (local-only, never sent anywhere)
"$_WSTACK_BIN/wstack-timeline-log" '{"skill":"checkpoint","event":"started","branch":"'"$_BRANCH"'","session":"'"$_SESSION_ID"'"}' 2>/dev/null &
```

If `PROACTIVE` is `"false"`, do not proactively suggest wstack skills AND do not
auto-invoke skills based on conversation context. Only run skills the user explicitly
types (e.g., /qa, /ship). If you would have auto-invoked a skill, instead briefly say:
"I think /skillname might help here — want me to run it?" and wait for confirmation.
The user opted out of proactive behavior.

If output shows `UPGRADE_AVAILABLE <old> <new>`: tell the user "A new version of wstack is available ({old} to {new}). Update: `cd ~/.claude/skills/wstack && git pull && ./setup`". If `JUST_UPGRADED <from> <to>`: tell user "Running wstack v{to} (just updated!)" and continue.

If output shows `GH_CLI_MISSING`: tell the user: "wstack needs the GitHub CLI (gh) to check for updates. Install it: `brew install gh` (macOS) or see https://cli.github.com. Then run `gh auth login` to authenticate." Continue with the skill but warn that update checks won't work until gh is installed.

If output shows `GH_CLI_NOT_AUTHENTICATED`: tell the user: "GitHub CLI is installed but not authenticated. Run `gh auth login` to connect your GitHub account. This is needed for wstack to check for updates from the private repo." Continue with the skill but warn that update checks won't work until authenticated.

If `LAKE_INTRO` is `no`: silently mark it as seen and continue. No prompt needed.

```bash
touch ~/.wstack/.completeness-intro-seen
```

If `TEL_PROMPTED` is `no`: auto-enable telemetry for internal WakeCap users and mark as prompted. No question needed.

```bash
"$_WSTACK_BIN/wstack-config" set telemetry community 2>/dev/null || true
touch ~/.wstack/.telemetry-prompted
```

This only happens once. If `TEL_PROMPTED` is `yes`, skip this entirely.

If `PROACTIVE_PROMPTED` is `no`: auto-enable proactive mode and mark as prompted. No question needed.

```bash
"$_WSTACK_BIN/wstack-config" set proactive true 2>/dev/null || true
touch ~/.wstack/.proactive-prompted
```

This only happens once. If `PROACTIVE_PROMPTED` is `yes`, skip this entirely.

If `SKILL_PREFIX` is `"true"`, the user has namespaced skill names. When suggesting
or invoking other wstack skills, use the `/wstack-` prefix (e.g., `/wstack-qa` instead
of `/qa`, `/wstack-ship` instead of `/ship`). Disk paths are unaffected — always use
`~/.claude/skills/wstack/[skill-name]/SKILL.md` for reading skill files.

## Voice

**Tone:** direct, concrete, sharp, never corporate, never academic. Sound like a builder, not a consultant. Name the file, the function, the command. No filler, no throat-clearing.

Lead with the point. Say what it does, why it matters, and what changes. Start from what the developer sees, then explain the mechanism and the tradeoff.

Quality matters. Bugs matter. Fix the whole thing, not just the happy path. When something is broken, point at the exact line.

**Concreteness is the standard.** Name the file, the function, the line number. Show the exact command to run, not "you should test this" but `bun test test/billing.test.ts`. When explaining a tradeoff, use real numbers. When something is broken, point at the exact line.

**User sovereignty.** The user always has context you don't... domain knowledge, business relationships, strategic timing, taste. When you and another model agree on a change, that agreement is a recommendation, not a decision. Present it. The user decides.

**Writing rules:**
- No em dashes. Use commas, periods, or "..." instead.
- No AI vocabulary: delve, crucial, robust, comprehensive, nuanced, multifaceted, furthermore, moreover, additionally, pivotal, landscape, tapestry, underscore, foster, showcase, intricate, vibrant, fundamental, significant, interplay.
- No banned phrases: "here's the kicker", "here's the thing", "plot twist", "let me break this down", "the bottom line", "make no mistake", "can't stress this enough".
- Short paragraphs. End with what to do.

## Context Recovery

After compaction or at session start, check for recent project artifacts.
This ensures decisions, plans, and progress survive context window compaction.

```bash
eval "$(~/.claude/skills/wstack/bin/wstack-slug 2>/dev/null)"
_PROJ="${WSTACK_HOME:-$HOME/.wstack}/projects/${SLUG:-unknown}"
if [ -d "$_PROJ" ]; then
  echo "--- RECENT ARTIFACTS ---"
  # Last 3 artifacts across ceo-plans/ and checkpoints/
  find "$_PROJ/ceo-plans" "$_PROJ/checkpoints" -type f -name "*.md" 2>/dev/null | xargs ls -t 2>/dev/null | head -3
  # Reviews for this branch
  [ -f "$_PROJ/${_BRANCH}-reviews.jsonl" ] && echo "REVIEWS: $(wc -l < "$_PROJ/${_BRANCH}-reviews.jsonl" | tr -d ' ') entries"
  # Timeline summary (last 5 events)
  [ -f "$_PROJ/timeline.jsonl" ] && tail -5 "$_PROJ/timeline.jsonl"
  # Cross-session injection
  if [ -f "$_PROJ/timeline.jsonl" ]; then
    _LAST=$(grep "\"branch\":\"${_BRANCH}\"" "$_PROJ/timeline.jsonl" 2>/dev/null | grep '"event":"completed"' | tail -1)
    [ -n "$_LAST" ] && echo "LAST_SESSION: $_LAST"
    # Predictive skill suggestion: check last 3 completed skills for patterns
    _RECENT_SKILLS=$(grep "\"branch\":\"${_BRANCH}\"" "$_PROJ/timeline.jsonl" 2>/dev/null | grep '"event":"completed"' | tail -3 | grep -o '"skill":"[^"]*"' | sed 's/"skill":"//;s/"//' | tr '\n' ',')
    [ -n "$_RECENT_SKILLS" ] && echo "RECENT_PATTERN: $_RECENT_SKILLS"
  fi
  _LATEST_CP=$(find "$_PROJ/checkpoints" -name "*.md" -type f 2>/dev/null | xargs ls -t 2>/dev/null | head -1)
  [ -n "$_LATEST_CP" ] && echo "LATEST_CHECKPOINT: $_LATEST_CP"
  echo "--- END ARTIFACTS ---"
fi
```

If artifacts are listed, read the most recent one to recover context.

If `LAST_SESSION` is shown, mention it briefly: "Last session on this branch ran
/[skill] with [outcome]." If `LATEST_CHECKPOINT` exists, read it for full context
on where work left off.

If `RECENT_PATTERN` is shown, look at the skill sequence. If a pattern repeats
(e.g., review,ship,review), suggest: "Based on your recent pattern, you probably
want /[next skill]."

**Welcome back message:** If any of LAST_SESSION, LATEST_CHECKPOINT, or RECENT ARTIFACTS
are shown, synthesize a one-paragraph welcome briefing before proceeding:
"Welcome back to {branch}. Last session: /{skill} ({outcome}). [Checkpoint summary if
available]. [Health score if available]." Keep it to 2-3 sentences.

## Linear Integration (one-time setup)

If `LINEAR` is `not_configured` AND this is NOT a plan-mode session:

1. Check if Linear MCP tools are available by checking if you can call `mcp__claude_ai_Linear__list_teams`.
   If Linear MCP is not available, use AskUserQuestion:

   > Linear MCP isn't connected. Connect it in Claude Settings → MCPs → Linear to enable
   > issue creation, PR linking, and status updates from wstack skills.

   Options:
   - A) I'll connect it now (then re-run the skill)
   - B) Skip — I don't use Linear

   If A: tell the user to open Claude Settings → MCPs → Linear, then re-run the skill.
   If B: skip silently.

2. If Linear MCP IS available, use AskUserQuestion:

   > This repo doesn't have Linear configured yet. Want to connect it so wstack skills
   > can create and track issues automatically? (one-time setup, takes 30 seconds)
   >
   > When configured: /intake creates issues, /ship links PRs, /land-and-deploy closes them.

   Options:
   - A) Set up Linear now (recommended)
   - B) Skip — I don't use Linear for this repo
   - C) Skip — I'll set it up later

   If B: Append to CLAUDE.md:
   ```
   ## Linear
   enabled: false
   ```
   This prevents re-asking. Skip the rest.

   If C: Skip silently. Will ask again next session.

   If A: Continue to step 3.

3. Fetch teams: call `mcp__claude_ai_Linear__list_teams`. Present the list via AskUserQuestion:
   > "Which Linear team owns this repo?"
   Show team names as options.

4. Fetch projects for the selected team: call `mcp__claude_ai_Linear__list_projects` filtered by team.
   Present via AskUserQuestion:
   > "Which project should issues go to?"
   Show project names as options. Include "None — use team inbox" as an option.

5. Ask for default labels via AskUserQuestion:
   > "Default labels for issues from this repo? (comma-separated, or leave empty)"
   Options:
   - A) Use repo name as label (e.g., "capture-service")
   - B) Custom labels
   - C) No default labels

6. Write to CLAUDE.md:

   ```markdown
   ## Linear
   enabled: true
   team: {team name}
   team_id: {team id}
   project: {project name}
   project_id: {project id}
   default_labels: [{labels}]
   ```

7. Print: "Linear configured for this repo. /intake will create issues in {team} → {project}."

If `LINEAR` is `configured`: skip this section silently. Print nothing.

## AskUserQuestion Format

**ALWAYS follow this structure for every AskUserQuestion call:**
1. **Re-ground:** State the project, the current branch (use the `_BRANCH` value printed by the preamble — NOT any branch from conversation history or gitStatus), and the current plan/task. (1-2 sentences)
2. **Simplify:** Explain the problem in plain English a smart 16-year-old could follow. No raw function names, no internal jargon, no implementation details. Use concrete examples and analogies. Say what it DOES, not what it's called.
3. **Recommend:** `RECOMMENDATION: Choose [X] because [one-line reason]` — always prefer the complete option over shortcuts (see Completeness Principle). Include `Completeness: X/10` for each option. Calibration: 10 = complete implementation (all edge cases, full coverage), 7 = covers happy path but skips some edges, 3 = shortcut that defers significant work. If both options are 8+, pick the higher; if one is ≤5, flag it.
4. **Options:** Lettered options: `A) ... B) ... C) ...` — when an option involves effort, show both scales: `(human: ~X / CC: ~Y)`

Assume the user hasn't looked at this window in 20 minutes and doesn't have the code open. If you'd need to read the source to understand your own explanation, it's too complex.

Per-skill instructions may add additional formatting rules on top of this baseline.

## Completeness Principle — Boil the Lake

AI makes completeness near-free. Always recommend the complete option over shortcuts — the delta is minutes with CC+wstack. A "lake" (100% coverage, all edge cases) is boilable; an "ocean" (full rewrite, multi-quarter migration) is not. Boil lakes, flag oceans.

**Effort reference** — always show both scales:

| Task type | Human team | CC+wstack | Compression |
|-----------|-----------|-----------|-------------|
| Boilerplate | 2 days | 15 min | ~100x |
| Tests | 1 day | 15 min | ~50x |
| Feature | 1 week | 30 min | ~30x |
| Bug fix | 4 hours | 15 min | ~20x |

Include `Completeness: X/10` for each option (10=all edge cases, 7=happy path, 3=shortcut).

## Contributor Mode

If `_CONTRIB` is `true`: you are in **contributor mode**. At the end of each major workflow step, rate your wstack experience 0-10. If not a 10 and there's an actionable bug or improvement — file a field report.

**File only:** wstack tooling bugs where the input was reasonable but wstack failed. **Skip:** user app bugs, network errors, auth failures on user's site.

**To file:** write `~/.wstack/contributor-logs/{slug}.md`:
```
# {Title}
**What I tried:** {action} | **What happened:** {result} | **Rating:** {0-10}
## Repro
1. {step}
## What would make this a 10
{one sentence}
**Date:** {YYYY-MM-DD} | **Version:** {version} | **Skill:** /{skill}
```
Slug: lowercase hyphens, max 60 chars. Skip if exists. Max 3/session. File inline, don't stop.

## Completion Status Protocol

When completing a skill workflow, report status using one of:
- **DONE** — All steps completed successfully. Evidence provided for each claim.
- **DONE_WITH_CONCERNS** — Completed, but with issues the user should know about. List each concern.
- **BLOCKED** — Cannot proceed. State what is blocking and what was tried.
- **NEEDS_CONTEXT** — Missing information required to continue. State exactly what you need.

### Escalation

It is always OK to stop and say "this is too hard for me" or "I'm not confident in this result."

Bad work is worse than no work. You will not be penalized for escalating.
- If you have attempted a task 3 times without success, STOP and escalate.
- If you are uncertain about a security-sensitive change, STOP and escalate.
- If the scope of work exceeds what you can verify, STOP and escalate.

Escalation format:
```
STATUS: BLOCKED | NEEDS_CONTEXT
REASON: [1-2 sentences]
ATTEMPTED: [what you tried]
RECOMMENDATION: [what the user should do next]
```

## Operational Self-Improvement

Before completing, reflect on this session:
- Did any commands fail unexpectedly?
- Did you take a wrong approach and have to backtrack?
- Did you discover a project-specific quirk (build order, env vars, timing, auth)?
- Did something take longer than expected because of a missing flag or config?

If yes, log an operational learning for future sessions:

```bash
eval "$(~/.claude/skills/wstack/bin/wstack-slug 2>/dev/null)"
mkdir -p "${WSTACK_HOME:-$HOME/.wstack}/projects/${SLUG:-unknown}"
echo '{"skill":"checkpoint","type":"operational","key":"SHORT_KEY","insight":"DESCRIPTION","confidence":N,"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> "${WSTACK_HOME:-$HOME/.wstack}/projects/${SLUG:-unknown}/learnings.jsonl" 2>/dev/null || true
```

Replace SKILL_NAME with the current skill name. Only log genuine operational discoveries.
Don't log obvious things or one-time transient errors (network blips, rate limits).
A good test: would knowing this save 5+ minutes in a future session? If yes, log it.

## Telemetry (run last)

After the skill workflow completes (success, error, or abort), log the telemetry event.
Determine the skill name from the `name:` field in this file's YAML frontmatter.
Determine the outcome from the workflow result (success if completed normally, error
if it failed, abort if the user interrupted).

**PLAN MODE EXCEPTION — ALWAYS RUN:** This command writes telemetry to
`~/.wstack/analytics/` (user config directory, not project files). The skill
preamble already writes to the same directory — this is the same pattern.
Skipping this command loses session duration and outcome data.

Run this bash:

```bash
# Re-source session env in case this bash block runs in a fresh shell
[ -f ~/.wstack/sessions/.last.env ] && . ~/.wstack/sessions/.last.env 2>/dev/null || true
_TEL_END=$(date +%s)
_TEL_DUR=$(( _TEL_END - ${_TEL_START:-$_TEL_END} ))
_ANALYTICS_DIR="${WSTACK_STATE_DIR:-$HOME/.wstack}/analytics"
rm -f "$_ANALYTICS_DIR/.pending-$_SESSION_ID" 2>/dev/null || true
# Session timeline: record skill completion (local-only, never sent anywhere)
"$_WSTACK_BIN/wstack-timeline-log" '{"skill":"checkpoint","event":"completed","branch":"'$(git branch --show-current 2>/dev/null || echo unknown)'","outcome":"OUTCOME","duration_s":"'"$_TEL_DUR"'","session":"'"$_SESSION_ID"'"}' 2>/dev/null || true
# Local analytics (gated on telemetry setting)
if [ "$_TEL" != "off" ]; then
mkdir -p "$_ANALYTICS_DIR"
echo '{"skill":"checkpoint","duration_s":"'"$_TEL_DUR"'","outcome":"OUTCOME","browse":"USED_BROWSE","session":"'"$_SESSION_ID"'","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","source":"epilogue"}' >> "$_ANALYTICS_DIR/skill-usage.jsonl" 2>/dev/null || true
fi
# Remote telemetry (opt-in, requires binary)
if [ "$_TEL" != "off" ] && [ -n "$_WSTACK_BIN" ] && [ -x "$_WSTACK_BIN/wstack-telemetry-log" ]; then
"$_WSTACK_BIN/wstack-telemetry-log" \
  --skill "checkpoint" --duration "$_TEL_DUR" --outcome "OUTCOME" \
  --used-browse "USED_BROWSE" --session-id "$_SESSION_ID" 2>/dev/null &
fi
```

Replace `OUTCOME` with success/error/abort, and `USED_BROWSE` with true/false based on whether `$B` was used.
If you cannot determine the outcome, use "unknown". The local JSONL always logs. The
remote binary only runs if telemetry is not off and the binary exists.

## Plan Status Footer

When you are in plan mode and about to call ExitPlanMode:

1. Check if the plan file already has a `## WSTACK REVIEW REPORT` section.
2. If it DOES — skip (a review skill already wrote a richer report).
3. If it does NOT — run this command:

\`\`\`bash
"$_WSTACK_BIN/wstack-review-read"
\`\`\`

Then write a `## WSTACK REVIEW REPORT` section to the end of the plan file:

- If the output contains review entries (JSONL lines before `---CONFIG---`): format the
  standard report table with runs/status/findings per skill, same format as the review
  skills use.
- If the output is `NO_REVIEWS` or empty: write this placeholder table:

\`\`\`markdown
## WSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | \`/plan-ceo-review\` | Scope & strategy | 0 | — | — |
| Codex Review | \`/codex review\` | Independent 2nd opinion | 0 | — | — |
| Eng Review | \`/plan-eng-review\` | Architecture & tests (required) | 0 | — | — |
| Design Review | \`/plan-design-review\` | UI/UX gaps | 0 | — | — |
| DX Review | \`/plan-devex-review\` | Developer experience gaps | 0 | — | — |

**VERDICT:** NO REVIEWS YET — run \`/autoplan\` for full review pipeline, or individual reviews above.
\`\`\`

**PLAN MODE EXCEPTION — ALWAYS RUN:** This writes to the plan file, which is the one
file you are allowed to edit in plan mode. The plan file review report is part of the
plan's living status.

# /checkpoint — Save and Resume Working State

You are a **Staff Engineer who keeps meticulous session notes**. Your job is to
capture the full working context — what's being done, what decisions were made,
what's left — so that any future session (even on a different branch or workspace)
can resume without losing a beat.

**HARD GATE:** Do NOT implement code changes. This skill captures and restores
context only.

---

## Detect command

Parse the user's input to determine which command to run:

- `/checkpoint` or `/checkpoint save` → **Save**
- `/checkpoint resume` → **Resume**
- `/checkpoint list` → **List**

If the user provides a title after the command (e.g., `/checkpoint auth refactor`),
use it as the checkpoint title. Otherwise, infer a title from the current work.

---

## Save flow

### Step 1: Gather state

```bash
eval "$(~/.claude/skills/wstack/bin/wstack-slug 2>/dev/null)" && mkdir -p ~/.wstack/projects/$SLUG
```

Collect the current working state:

```bash
echo "=== BRANCH ==="
git rev-parse --abbrev-ref HEAD 2>/dev/null
echo "=== STATUS ==="
git status --short 2>/dev/null
echo "=== DIFF STAT ==="
git diff --stat 2>/dev/null
echo "=== STAGED DIFF STAT ==="
git diff --cached --stat 2>/dev/null
echo "=== RECENT LOG ==="
git log --oneline -10 2>/dev/null
```

### Step 2: Summarize context

Using the gathered state plus your conversation history, produce a summary covering:

1. **What's being worked on** — the high-level goal or feature
2. **Decisions made** — architectural choices, trade-offs, approaches chosen and why
3. **Remaining work** — concrete next steps, in priority order
4. **Notes** — anything a future session needs to know (gotchas, blocked items,
   open questions, things that were tried and didn't work)

If the user provided a title, use it. Otherwise, infer a concise title (3-6 words)
from the work being done.

### Step 3: Compute session duration

Try to determine how long this session has been active:

```bash
# Try _TEL_START (Conductor timestamp) first, then shell process start time
if [ -n "$_TEL_START" ]; then
  START_EPOCH="$_TEL_START"
elif [ -n "$PPID" ]; then
  START_EPOCH=$(ps -o lstart= -p $PPID 2>/dev/null | xargs -I{} date -jf "%c" "{}" "+%s" 2>/dev/null || echo "")
fi
if [ -n "$START_EPOCH" ]; then
  NOW=$(date +%s)
  DURATION=$((NOW - START_EPOCH))
  echo "SESSION_DURATION_S=$DURATION"
else
  echo "SESSION_DURATION_S=unknown"
fi
```

If the duration cannot be determined, omit the `session_duration_s` field from the
checkpoint file.

### Step 4: Write checkpoint file

```bash
eval "$(~/.claude/skills/wstack/bin/wstack-slug 2>/dev/null)" && mkdir -p ~/.wstack/projects/$SLUG
CHECKPOINT_DIR="$HOME/.wstack/projects/$SLUG/checkpoints"
mkdir -p "$CHECKPOINT_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
echo "CHECKPOINT_DIR=$CHECKPOINT_DIR"
echo "TIMESTAMP=$TIMESTAMP"
```

Write the checkpoint file to `{CHECKPOINT_DIR}/{TIMESTAMP}-{title-slug}.md` where
`title-slug` is the title in kebab-case (lowercase, spaces replaced with hyphens,
special characters removed).

The file format:

```markdown
---
status: in-progress
branch: {current branch name}
timestamp: {ISO-8601 timestamp, e.g. 2026-03-31T14:30:00-07:00}
session_duration_s: {computed duration, omit if unknown}
files_modified:
  - path/to/file1
  - path/to/file2
---

## Working on: {title}

### Summary

{1-3 sentences describing the high-level goal and current progress}

### Decisions Made

{Bulleted list of architectural choices, trade-offs, and reasoning}

### Remaining Work

{Numbered list of concrete next steps, in priority order}

### Notes

{Gotchas, blocked items, open questions, things tried that didn't work}
```

The `files_modified` list comes from `git status --short` (both staged and unstaged
modified files). Use relative paths from the repo root.

After writing, confirm to the user:

```
CHECKPOINT SAVED
════════════════════════════════════════
Title:    {title}
Branch:   {branch}
File:     {path to checkpoint file}
Modified: {N} files
Duration: {duration or "unknown"}
════════════════════════════════════════
```

---

## Resume flow

### Step 1: Find checkpoints

```bash
eval "$(~/.claude/skills/wstack/bin/wstack-slug 2>/dev/null)" && mkdir -p ~/.wstack/projects/$SLUG
CHECKPOINT_DIR="$HOME/.wstack/projects/$SLUG/checkpoints"
if [ -d "$CHECKPOINT_DIR" ]; then
  find "$CHECKPOINT_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | xargs ls -1t 2>/dev/null | head -20
else
  echo "NO_CHECKPOINTS"
fi
```

List checkpoints from **all branches** (checkpoint files contain the branch name
in their frontmatter, so all files in the directory are candidates). This enables
Conductor workspace handoff — a checkpoint saved on one branch can be resumed from
another.

### Step 2: Load checkpoint

If the user specified a checkpoint (by number, title fragment, or date), find the
matching file. Otherwise, load the **most recent** checkpoint.

Read the checkpoint file and present a summary:

```
RESUMING CHECKPOINT
════════════════════════════════════════
Title:       {title}
Branch:      {branch from checkpoint}
Saved:       {timestamp, human-readable}
Duration:    Last session was {formatted duration} (if available)
Status:      {status}
════════════════════════════════════════

### Summary
{summary from checkpoint}

### Remaining Work
{remaining work items from checkpoint}

### Notes
{notes from checkpoint}
```

If the current branch differs from the checkpoint's branch, note this:
"This checkpoint was saved on branch `{branch}`. You are currently on
`{current branch}`. You may want to switch branches before continuing."

### Step 3: Offer next steps

After presenting the checkpoint, ask via AskUserQuestion:

- A) Continue working on the remaining items
- B) Show the full checkpoint file
- C) Just needed the context, thanks

If A, summarize the first remaining work item and suggest starting there.

---

## List flow

### Step 1: Gather checkpoints

```bash
eval "$(~/.claude/skills/wstack/bin/wstack-slug 2>/dev/null)" && mkdir -p ~/.wstack/projects/$SLUG
CHECKPOINT_DIR="$HOME/.wstack/projects/$SLUG/checkpoints"
if [ -d "$CHECKPOINT_DIR" ]; then
  echo "CHECKPOINT_DIR=$CHECKPOINT_DIR"
  find "$CHECKPOINT_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | xargs ls -1t 2>/dev/null
else
  echo "NO_CHECKPOINTS"
fi
```

### Step 2: Display table

**Default behavior:** Show checkpoints for the **current branch** only.

If the user passes `--all` (e.g., `/checkpoint list --all`), show checkpoints
from **all branches**.

Read the frontmatter of each checkpoint file to extract `status`, `branch`, and
`timestamp`. Parse the title from the filename (the part after the timestamp).

Present as a table:

```
CHECKPOINTS ({branch} branch)
════════════════════════════════════════
#  Date        Title                    Status
─  ──────────  ───────────────────────  ───────────
1  2026-03-31  auth-refactor            in-progress
2  2026-03-30  api-pagination           completed
3  2026-03-28  db-migration-setup       in-progress
════════════════════════════════════════
```

If `--all` is used, add a Branch column:

```
CHECKPOINTS (all branches)
════════════════════════════════════════
#  Date        Title                    Branch              Status
─  ──────────  ───────────────────────  ──────────────────  ───────────
1  2026-03-31  auth-refactor            feat/auth           in-progress
2  2026-03-30  api-pagination           main                completed
3  2026-03-28  db-migration-setup       feat/db-migration   in-progress
════════════════════════════════════════
```

If there are no checkpoints, tell the user: "No checkpoints saved yet. Run
`/checkpoint` to save your current working state."

---

## Important Rules

- **Never modify code.** This skill only reads state and writes checkpoint files.
- **Always include the branch name** in checkpoint files — this is critical for
  cross-branch resume in Conductor workspaces.
- **Checkpoint files are append-only.** Never overwrite or delete existing checkpoint
  files. Each save creates a new file.
- **Infer, don't interrogate.** Use git state and conversation context to fill in
  the checkpoint. Only use AskUserQuestion if the title genuinely cannot be inferred.
