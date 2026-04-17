---
name: browse
preamble-tier: 1
version: 2026.04.13
user-invocable: true
description: |
  Fast headless browser (~100ms/cmd). Navigate, interact, screenshot, diff, assert. Use when you need to open a URL, test a page, verify a deploy, or capture visual evidence.
allowed-tools:
  - Bash
  - Read
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
"$_WSTACK_BIN/wstack-timeline-log" '{"skill":"browse","event":"started","branch":"'"$_BRANCH"'","session":"'"$_SESSION_ID"'"}' 2>/dev/null &
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

**Writing rules:** No em dashes (use commas, periods, "..."). No AI vocabulary (delve, crucial, robust, comprehensive, nuanced, etc.). Short paragraphs. End with what to do.

The user always has context you don't. Cross-model agreement is a recommendation, not a decision... the user decides.

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
echo '{"skill":"browse","type":"operational","key":"SHORT_KEY","insight":"DESCRIPTION","confidence":N,"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' >> "${WSTACK_HOME:-$HOME/.wstack}/projects/${SLUG:-unknown}/learnings.jsonl" 2>/dev/null || true
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
"$_WSTACK_BIN/wstack-timeline-log" '{"skill":"browse","event":"completed","branch":"'$(git branch --show-current 2>/dev/null || echo unknown)'","outcome":"OUTCOME","duration_s":"'"$_TEL_DUR"'","session":"'"$_SESSION_ID"'"}' 2>/dev/null || true
# Local analytics (gated on telemetry setting)
if [ "$_TEL" != "off" ]; then
mkdir -p "$_ANALYTICS_DIR"
echo '{"skill":"browse","duration_s":"'"$_TEL_DUR"'","outcome":"OUTCOME","browse":"USED_BROWSE","session":"'"$_SESSION_ID"'","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","source":"epilogue"}' >> "$_ANALYTICS_DIR/skill-usage.jsonl" 2>/dev/null || true
fi
# Remote telemetry (opt-in, requires binary)
if [ "$_TEL" != "off" ] && [ -n "$_WSTACK_BIN" ] && [ -x "$_WSTACK_BIN/wstack-telemetry-log" ]; then
"$_WSTACK_BIN/wstack-telemetry-log" \
  --skill "browse" --duration "$_TEL_DUR" --outcome "OUTCOME" \
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

# browse: QA Testing & Dogfooding

Persistent headless Chromium. First call auto-starts (~3s), then ~100ms per command.
State persists between calls (cookies, tabs, login sessions).

## SETUP (run this check BEFORE any browse command)

```bash
_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
B=""
[ -n "$_ROOT" ] && [ -x "$_ROOT/.claude/skills/wstack/browse/dist/browse" ] && B="$_ROOT/.claude/skills/wstack/browse/dist/browse"
[ -z "$B" ] && B=~/.claude/skills/wstack/browse/dist/browse
if [ -x "$B" ]; then
  echo "READY: $B"
else
  echo "NEEDS_SETUP"
fi
```

If `NEEDS_SETUP`:
1. Tell the user: "wstack browse needs a one-time build (~10 seconds). OK to proceed?" Then STOP and wait.
2. Run: `cd <SKILL_DIR> && ./setup`
3. If `bun` is not installed: `curl -fsSL https://bun.sh/install | bash`

## Core QA Patterns

### 1. Verify a page loads correctly
```bash
$B goto https://yourapp.com
$B text                          # content loads?
$B console                       # JS errors?
$B network                       # failed requests?
$B is visible ".main-content"    # key elements present?
```

### 2. Test a user flow
```bash
$B goto https://app.com/login
$B snapshot -i                   # see all interactive elements
$B fill @e3 "user@test.com"
$B fill @e4 "password"
$B click @e5                     # submit
$B snapshot -D                   # diff: what changed after submit?
$B is visible ".dashboard"       # success state present?
```

### 3. Verify an action worked
```bash
$B snapshot                      # baseline
$B click @e3                     # do something
$B snapshot -D                   # unified diff shows exactly what changed
```

### 4. Visual evidence for bug reports
```bash
$B snapshot -i -a -o /tmp/annotated.png   # labeled screenshot
$B screenshot /tmp/bug.png                # plain screenshot
$B console                                # error log
```

### 5. Find all clickable elements (including non-ARIA)
```bash
$B snapshot -C                   # finds divs with cursor:pointer, onclick, tabindex
$B click @c1                     # interact with them
```

### 6. Assert element states
```bash
$B is visible ".modal"
$B is enabled "#submit-btn"
$B is disabled "#submit-btn"
$B is checked "#agree-checkbox"
$B is editable "#name-field"
$B is focused "#search-input"
$B js "document.body.textContent.includes('Success')"
```

### 7. Test responsive layouts
```bash
$B responsive /tmp/layout        # mobile + tablet + desktop screenshots
$B viewport 375x812              # or set specific viewport
$B screenshot /tmp/mobile.png
```

### 8. Test file uploads
```bash
$B upload "#file-input" /path/to/file.pdf
$B is visible ".upload-success"
```

### 9. Test dialogs
```bash
$B dialog-accept "yes"           # set up handler
$B click "#delete-button"        # trigger dialog
$B dialog                        # see what appeared
$B snapshot -D                   # verify deletion happened
```

### 10. Compare environments
```bash
$B diff https://staging.app.com https://prod.app.com
```

### 11. Show screenshots to the user
After `$B screenshot`, `$B snapshot -a -o`, or `$B responsive`, always use the Read tool on the output PNG(s) so the user can see them. Without this, screenshots are invisible.

## User Handoff

When you hit something you can't handle in headless mode (CAPTCHA, complex auth, multi-factor
login), hand off to the user:

```bash
# 1. Open a visible Chrome at the current page
$B handoff "Stuck on CAPTCHA at login page"

# 2. Tell the user what happened (via AskUserQuestion)
#    "I've opened Chrome at the login page. Please solve the CAPTCHA
#     and let me know when you're done."

# 3. When user says "done", re-snapshot and continue
$B resume
```

**When to use handoff:**
- CAPTCHAs or bot detection
- Multi-factor authentication (SMS, authenticator app)
- OAuth flows that require user interaction
- Complex interactions the AI can't handle after 3 attempts

The browser preserves all state (cookies, localStorage, tabs) across the handoff.
After `resume`, you get a fresh snapshot of wherever the user left off.

## Snapshot Flags

The snapshot is your primary tool for understanding and interacting with pages.

```
-i        --interactive           Interactive elements only (buttons, links, inputs) with @e refs. Also auto-enables cursor-interactive scan (-C) to capture dropdowns and popovers.
-c        --compact               Compact (no empty structural nodes)
-d <N>    --depth                 Limit tree depth (0 = root only, default: unlimited)
-s <sel>  --selector              Scope to CSS selector
-D        --diff                  Unified diff against previous snapshot (first call stores baseline)
-a        --annotate              Annotated screenshot with red overlay boxes and ref labels
-o <path> --output                Output path for annotated screenshot (default: <temp>/browse-annotated.png)
-C        --cursor-interactive    Cursor-interactive elements (@c refs — divs with pointer, onclick). Auto-enabled when -i is used.
```

All flags can be combined freely. `-o` only applies when `-a` is also used.
Example: `$B snapshot -i -a -C -o /tmp/annotated.png`

**Ref numbering:** @e refs are assigned sequentially (@e1, @e2, ...) in tree order.
@c refs from `-C` are numbered separately (@c1, @c2, ...).

After snapshot, use @refs as selectors in any command:
```bash
$B click @e3       $B fill @e4 "value"     $B hover @e1
$B html @e2        $B css @e5 "color"      $B attrs @e6
$B click @c1       # cursor-interactive ref (from -C)
```

**Output format:** indented accessibility tree with @ref IDs, one element per line.
```
  @e1 [heading] "Welcome" [level=1]
  @e2 [textbox] "Email"
  @e3 [button] "Submit"
```

Refs are invalidated on navigation — run `snapshot` again after `goto`.

## Full Command List

### Navigation
| Command | Description |
|---------|-------------|
| `back` | History back |
| `forward` | History forward |
| `goto <url>` | Navigate to URL |
| `reload` | Reload page |
| `url` | Print current URL |

### Reading
| Command | Description |
|---------|-------------|
| `accessibility` | Full ARIA tree |
| `data [--jsonld|--og|--meta|--twitter]` | Structured data: JSON-LD, Open Graph, Twitter Cards, meta tags |
| `forms` | Form fields as JSON |
| `html [selector]` | innerHTML of selector (throws if not found), or full page HTML if no selector given |
| `links` | All links as "text → href" |
| `media [--images|--videos|--audio] [selector]` | All media elements (images, videos, audio) with URLs, dimensions, types |
| `text` | Cleaned page text |

### Interaction
| Command | Description |
|---------|-------------|
| `cleanup [--ads] [--cookies] [--sticky] [--social] [--all]` | Remove page clutter (ads, cookie banners, sticky elements, social widgets) |
| `click <sel>` | Click element |
| `cookie <name>=<value>` | Set cookie on current page domain |
| `cookie-import <json>` | Import cookies from JSON file |
| `cookie-import-browser [browser] [--domain d]` | Import cookies from installed Chromium browsers (opens picker, or use --domain for direct import) |
| `dialog-accept [text]` | Auto-accept next alert/confirm/prompt. Optional text is sent as the prompt response |
| `dialog-dismiss` | Auto-dismiss next dialog |
| `fill <sel> <val>` | Fill input |
| `header <name>:<value>` | Set custom request header (colon-separated, sensitive values auto-redacted) |
| `hover <sel>` | Hover element |
| `press <key>` | Press key — Enter, Tab, Escape, ArrowUp/Down/Left/Right, Backspace, Delete, Home, End, PageUp, PageDown, or modifiers like Shift+Enter |
| `scroll [sel]` | Scroll element into view, or scroll to page bottom if no selector |
| `select <sel> <val>` | Select dropdown option by value, label, or visible text |
| `style <sel> <prop> <value> | style --undo [N]` | Modify CSS property on element (with undo support) |
| `type <text>` | Type into focused element |
| `upload <sel> <file> [file2...]` | Upload file(s) |
| `useragent <string>` | Set user agent |
| `viewport <WxH>` | Set viewport size |
| `wait <sel|--networkidle|--load>` | Wait for element, network idle, or page load (timeout: 15s) |

### Inspection
| Command | Description |
|---------|-------------|
| `attrs <sel|@ref>` | Element attributes as JSON |
| `console [--clear|--errors]` | Console messages (--errors filters to error/warning) |
| `cookies` | All cookies as JSON |
| `css <sel> <prop>` | Computed CSS value |
| `dialog [--clear]` | Dialog messages |
| `eval <file>` | Run JavaScript from file and return result as string (path must be under /tmp or cwd) |
| `inspect [selector] [--all] [--history]` | Deep CSS inspection via CDP — full rule cascade, box model, computed styles |
| `is <prop> <sel>` | State check (visible/hidden/enabled/disabled/checked/editable/focused) |
| `js <expr>` | Run JavaScript expression and return result as string |
| `network [--clear]` | Network requests |
| `perf` | Page load timings |
| `storage [set k v]` | Read all localStorage + sessionStorage as JSON, or set <key> <value> to write localStorage |

### Extraction
| Command | Description |
|---------|-------------|
| `archive [path]` | Save complete page as MHTML via CDP |
| `download <url|@ref> [path] [--base64]` | Download URL or media element to disk using browser cookies |
| `scrape <images|videos|media> [--selector sel] [--dir path] [--limit N]` | Bulk download all media from page. Writes manifest.json |

### Visual
| Command | Description |
|---------|-------------|
| `diff <url1> <url2>` | Text diff between pages |
| `pdf [path]` | Save as PDF |
| `prettyscreenshot [--scroll-to sel|text] [--cleanup] [--hide sel...] [--width px] [path]` | Clean screenshot with optional cleanup, scroll positioning, and element hiding |
| `responsive [prefix]` | Screenshots at mobile (375x812), tablet (768x1024), desktop (1280x720). Saves as {prefix}-mobile.png etc. |
| `screenshot [--viewport] [--clip x,y,w,h] [selector|@ref] [path]` | Save screenshot (supports element crop via CSS/@ref, --clip region, --viewport) |

### Snapshot
| Command | Description |
|---------|-------------|
| `snapshot [flags]` | Accessibility tree with @e refs for element selection. Flags: -i interactive only, -c compact, -d N depth limit, -s sel scope, -D diff vs previous, -a annotated screenshot, -o path output, -C cursor-interactive @c refs |

### Meta
| Command | Description |
|---------|-------------|
| `chain` | Run commands from JSON stdin. Format: [["cmd","arg1",...],...] |
| `frame <sel|@ref|--name n|--url pattern|main>` | Switch to iframe context (or main to return) |
| `inbox [--clear]` | List messages from sidebar scout inbox |
| `watch [stop]` | Passive observation — periodic snapshots while user browses |

### Tabs
| Command | Description |
|---------|-------------|
| `closetab [id]` | Close tab |
| `newtab [url]` | Open new tab |
| `tab <id>` | Switch to tab |
| `tabs` | List open tabs |

### Server
| Command | Description |
|---------|-------------|
| `connect` | Launch headed Chromium with Chrome extension |
| `disconnect` | Disconnect headed browser, return to headless mode |
| `focus [@ref]` | Bring headed browser window to foreground (macOS) |
| `handoff [message]` | Open visible Chrome at current page for user takeover |
| `restart` | Restart server |
| `resume` | Re-snapshot after user takeover, return control to AI |
| `state save|load <name>` | Save/load browser state (cookies + URLs) |
| `status` | Health check |
| `stop` | Shutdown server |
