---
name: investigate
preamble-tier: 2
version: 2026.04.13
user-invocable: true
description: |
  Systematic debugging: investigate, analyze, hypothesize, implement. No fixes without root cause. Use when: "debug this", "fix this bug", "why is this broken", "investigate".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
  - WebSearch
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
"$_WSTACK_BIN/wstack-timeline-log" '{"skill":"investigate","event":"started","branch":"'"$_BRANCH"'","session":"'"$_SESSION_ID"'"}' 2>/dev/null &
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
echo '{"skill":"investigate","type":"operational","key":"SHORT_KEY","insight":"DESCRIPTION","confidence":N,"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> "${WSTACK_HOME:-$HOME/.wstack}/projects/${SLUG:-unknown}/learnings.jsonl" 2>/dev/null || true
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
"$_WSTACK_BIN/wstack-timeline-log" '{"skill":"investigate","event":"completed","branch":"'$(git branch --show-current 2>/dev/null || echo unknown)'","outcome":"OUTCOME","duration_s":"'"$_TEL_DUR"'","session":"'"$_SESSION_ID"'"}' 2>/dev/null || true
# Local analytics (gated on telemetry setting)
if [ "$_TEL" != "off" ]; then
mkdir -p "$_ANALYTICS_DIR"
echo '{"skill":"investigate","duration_s":"'"$_TEL_DUR"'","outcome":"OUTCOME","browse":"USED_BROWSE","session":"'"$_SESSION_ID"'","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","source":"epilogue"}' >> "$_ANALYTICS_DIR/skill-usage.jsonl" 2>/dev/null || true
fi
# Remote telemetry (opt-in, requires binary)
if [ "$_TEL" != "off" ] && [ -n "$_WSTACK_BIN" ] && [ -x "$_WSTACK_BIN/wstack-telemetry-log" ]; then
"$_WSTACK_BIN/wstack-telemetry-log" \
  --skill "investigate" --duration "$_TEL_DUR" --outcome "OUTCOME" \
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

# Systematic Debugging

## Iron Law

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

Fixing symptoms creates whack-a-mole debugging. Every fix that doesn't address root cause makes the next bug harder to find. Find the root cause, then fix it.

---

## Phase 1: Root Cause Investigation

Gather context before forming any hypothesis.

1. **Collect symptoms:** Read the error messages, stack traces, and reproduction steps. If the user hasn't provided enough context, ask ONE question at a time via AskUserQuestion.

2. **Read the code:** Trace the code path from the symptom back to potential causes. Use Grep to find all references, Read to understand the logic.

3. **Check recent changes:**
   ```bash
   git log --oneline -20 -- <affected-files>
   ```
   Was this working before? What changed? A regression means the root cause is in the diff.

4. **Reproduce:** Can you trigger the bug deterministically? If not, gather more evidence before proceeding.

Output: **"Root cause hypothesis: ..."** — a specific, testable claim about what is wrong and why.

---

## Scope Lock

After forming your root cause hypothesis, identify the narrowest directory containing the affected files. Restrict your edits to that directory to prevent scope creep.

If the bug spans the entire repo or the scope is genuinely unclear, skip the lock and note why.

---

## Phase 2: Pattern Analysis

Check if this bug matches a known pattern:

| Pattern | Signature | Where to look |
|---------|-----------|---------------|
| Race condition | Intermittent, timing-dependent | Concurrent access to shared state |
| Nil/null propagation | NoMethodError, TypeError | Missing guards on optional values |
| State corruption | Inconsistent data, partial updates | Transactions, callbacks, hooks |
| Integration failure | Timeout, unexpected response | External API calls, service boundaries |
| Configuration drift | Works locally, fails in staging/prod | Env vars, feature flags, DB state |
| Stale cache | Shows old data, fixes on cache clear | Redis, CDN, browser cache, Turbo |

Also check:
- `TODOS.md` for related known issues
- `git log` for prior fixes in the same area — **recurring bugs in the same files are an architectural smell**, not a coincidence

**External pattern search:** If the bug doesn't match a known pattern above, WebSearch for:
- "{framework} {generic error type}" — **sanitize first:** strip hostnames, IPs, file paths, SQL, customer data. Search the error category, not the raw message.
- "{library} {component} known issues"

If WebSearch is unavailable, skip this search and proceed with hypothesis testing. If a documented solution or known dependency bug surfaces, present it as a candidate hypothesis in Phase 3.

---

## Phase 3: Hypothesis Testing

Before writing ANY fix, verify your hypothesis.

1. **Confirm the hypothesis:** Add a temporary log statement, assertion, or debug output at the suspected root cause. Run the reproduction. Does the evidence match?

2. **If the hypothesis is wrong:** Before forming the next hypothesis, consider searching for the error. **Sanitize first** — strip hostnames, IPs, file paths, SQL fragments, customer identifiers, and any internal/proprietary data from the error message. Search only the generic error type and framework context: "{component} {sanitized error type} {framework version}". If the error message is too specific to sanitize safely, skip the search. If WebSearch is unavailable, skip and proceed. Then return to Phase 1. Gather more evidence. Do not guess.

3. **3-strike rule:** If 3 hypotheses fail, **STOP**. Use AskUserQuestion:
   ```
   3 hypotheses tested, none match. This may be an architectural issue
   rather than a simple bug.

   A) Continue investigating — I have a new hypothesis: [describe]
   B) Escalate for human review — this needs someone who knows the system
   C) Add logging and wait — instrument the area and catch it next time
   ```

**Red flags** — if you see any of these, slow down:
- "Quick fix for now" — there is no "for now." Fix it right or escalate.
- Proposing a fix before tracing data flow — you're guessing.
- Each fix reveals a new problem elsewhere — wrong layer, not wrong code.

---

## Phase 4: Implementation

Once root cause is confirmed:

1. **Fix the root cause, not the symptom.** The smallest change that eliminates the actual problem.

2. **Minimal diff:** Fewest files touched, fewest lines changed. Resist the urge to refactor adjacent code.

3. **Write a regression test** that:
   - **Fails** without the fix (proves the test is meaningful)
   - **Passes** with the fix (proves the fix works)

4. **Run the full test suite.** Paste the output. No regressions allowed.

5. **If the fix touches >5 files:** Use AskUserQuestion to flag the blast radius:
   ```
   This fix touches N files. That's a large blast radius for a bug fix.
   A) Proceed — the root cause genuinely spans these files
   B) Split — fix the critical path now, defer the rest
   C) Rethink — maybe there's a more targeted approach
   ```

---

## Phase 5: Verification & Report

**Fresh verification:** Reproduce the original bug scenario and confirm it's fixed. This is not optional.

Run the test suite and paste the output.

Output a structured debug report:
```
DEBUG REPORT
════════════════════════════════════════
Symptom:         [what the user observed]
Root cause:      [what was actually wrong]
Fix:             [what was changed, with file:line references]
Evidence:        [test output, reproduction attempt showing fix works]
Regression test: [file:line of the new test]
Related:         [TODOS.md items, prior bugs in same area, architectural notes]
Status:          DONE | DONE_WITH_CONCERNS | BLOCKED
════════════════════════════════════════
```

---

## Important Rules

- **3+ failed fix attempts → STOP and question the architecture.** Wrong architecture, not failed hypothesis.
- **Never apply a fix you cannot verify.** If you can't reproduce and confirm, don't ship it.
- **Never say "this should fix it."** Verify and prove it. Run the tests.
- **If fix touches >5 files → AskUserQuestion** about blast radius before proceeding.
- **Completion status:**
  - DONE — root cause found, fix applied, regression test written, all tests pass
  - DONE_WITH_CONCERNS — fixed but cannot fully verify (e.g., intermittent bug, requires staging)
  - BLOCKED — root cause unclear after investigation, escalated
