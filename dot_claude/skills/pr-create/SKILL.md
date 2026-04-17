---
name: pr-create
description: "Stage, semantic commit, push (force-with-lease), and open a PR via gh CLI. No co-author tags."
user-invocable: true
---

# PR Create

Stage changes, create semantic commits, push with force-with-lease, and open a pull request. No co-author tags.

## usage

```
/pr-create [base] [title] [draft] [scope]
```

All args are positional and optional. Order: `base`, `title`, `draft`, `scope`.

| Position | Arg     | Description                                  | Default                  | Examples                              |
| -------- | ------- | -------------------------------------------- | ------------------------ | ------------------------------------- |
| 1        | `base`  | Target branch for the PR                     | repo default branch      | `main`, `develop`, `release/v2`       |
| 2        | `title` | PR title (conventional commit format)        | derived from commits     | `"fix(api): handle timeout"`          |
| 3        | `draft` | Create as draft PR                           | `false`                  | `true`, `false`                       |
| 4        | `scope` | Override commit scope for all commits        | inferred from file paths | `api`, `web`, `shared`                |

Examples:

```
/pr-create                                          # all defaults
/pr-create main                                     # target main
/pr-create main "fix(api): handle timeout"          # target main with title
/pr-create main "feat(web): add dashboard" true     # draft PR to main
/pr-create main "fix(api): retry logic" false api   # all args
```

Parse the positional args from the skill invocation input. Any omitted trailing args use their defaults.

---

## step 1: gather context

Detect the base branch first, then gather context in parallel:

```bash
BASE="${base:-$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name')}"
```

```bash
git status --porcelain
git diff --stat
git diff --staged --stat
git log -15 --oneline
git branch --show-current
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "NO_UPSTREAM"
git merge-base HEAD "$BASE" 2>/dev/null
```

From this determine:

- the resolved base branch (`$BASE`)
- changed files (staged + unstaged)
- current branch name
- commits already on this branch vs base
- whether upstream tracking exists

---

## step 2: plan commits

Conventional commit format is mandatory. Types: feat, fix, refactor, chore, docs, test, ci, perf, build.

If `scope` arg is provided, use it for all commits. Otherwise infer scope from the package or module name.

Rules:

- group by logical unit, not file type
- test files go with their implementation
- different directories or concerns = different commits
- each commit must be independently revertable

Output the plan before executing:

```
COMMIT PLAN
  1. feat(api): add SSE reconnection to event proxy
     - src/routes/events.ts
  2. fix(web): pass model in prompt body
     - src/components/chat.tsx
     - src/lib/api.ts
```

---

## step 3: format

If a formatter is configured in the project (package.json scripts, Makefile, etc.), run it before committing. Do NOT fail the workflow if no formatter is found.

---

## step 4: execute commits

For each planned commit:

```bash
git add <files>
git commit -m "<type>(<scope>): <description>"
```

Commit message rules:

- lowercase first word after colon
- no period at end
- imperative mood ("add" not "added")
- scope is the package or module name (or the `scope` arg if provided)
- body is optional, only for non-obvious changes
- NO co-author trailers — never add Co-Authored-By for Claude or any AI
- NO emoji

---

## step 5: push

Always push with force-with-lease:

```bash
git push --force-with-lease -u origin $(git branch --show-current)
```

Never force push to main, master, or develop. If the current branch is one of these, STOP and warn the user.

---

## step 6: create PR

Use the title arg if provided, otherwise derive from the most significant commit.

PR title must be conventional commit format: `type(scope): description`

```bash
gh pr create --base "$BASE" --title "${title}" --body "$(cat <<'EOF'
## Summary

- bullet points describing each logical change

## Test plan

- how the changes were verified
EOF
)"
```

If the project has a PR template or required sections (check CLAUDE.md, AGENTS.md, or `.github/PULL_REQUEST_TEMPLATE.md`), use those sections instead of the default above.

If draft arg is "true":

```bash
gh pr create --draft --base "$BASE" --title "${title}" --body "..."
```

---

## step 7: report

Output:

- PR URL
- number of commits
- files changed summary
- any warnings (force push, large diff, etc.)

---

## constraints

- never commit files matching: .env, credentials.json, *.pem, *.key
- never push to main/master/develop directly
- never use --no-verify
- never amend commits that have been pushed
- always use --force-with-lease (never --force)
- if the project has lint/typecheck and they haven't been run, warn before pushing
