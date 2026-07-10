#!/usr/bin/env bash
set -euo pipefail

mode=${1:-worktree}
log_file=${HERDR_HUNK_OVERLAY_LOG:-$HOME/.config/herdr/hunk-overlay.log}

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*" >> "$log_file"
}

if ! command -v hunk >/dev/null 2>&1; then
  log "missing hunk; PATH=$PATH"
  printf 'hunk-overlay: hunk is not installed\n' >&2
  exit 127
fi
hunk_cmd=(hunk)

log "start mode=$mode cwd=$PWD command=${hunk_cmd[*]}"

print_command() {
  printf '%q ' "$@"
}

run_hunk() {
  local -a args
  args=("$@")
  if [[ -n "${HUNK_THEME:-}" ]]; then
    args=(--theme "$HUNK_THEME" "${args[@]}")
  fi

  log "exec: $(print_command "${hunk_cmd[@]}" "${args[@]}")"
  exec "${hunk_cmd[@]}" "${args[@]}"
}

git_output() {
  git "$@" 2>/dev/null | tr -d '\n'
}

default_base_ref() {
  local candidate origin_head

  origin_head=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
  if [[ -n "$origin_head" ]] && git rev-parse --verify "$origin_head" >/dev/null 2>&1; then
    printf '%s\n' "$origin_head"
    return
  fi

  for candidate in origin/main origin/master origin/develop origin/trunk main master develop trunk; do
    if git rev-parse --verify "$candidate" >/dev/null 2>&1; then
      printf '%s\n' "$candidate"
      return
    fi
  done

  printf 'hunk-overlay: branch has no discoverable default base ref\n' >&2
  return 1
}

case "$mode" in
  staged)
    run_hunk diff --staged
    ;;
  branch)
    branch=$(git_output branch --show-current)
    [[ -n "$branch" ]] || branch=HEAD
    base_ref=$(default_base_ref)
    run_hunk diff "$base_ref...$branch"
    ;;
  worktree)
    run_hunk diff --exclude-untracked
    ;;
  *)
    log "invalid mode=$mode"
    printf 'hunk-overlay: usage: hunk-overlay.sh worktree|staged|branch\n' >&2
    exit 2
    ;;
esac
