#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

APPLY=false
[[ ${1:-} == "--apply" ]] && APPLY=true

if [[ "$(uname -s)" == "Linux" ]]; then
  for script in "$DOTFILES_DIR"/setup-omarchy/*.sh; do
    [[ -f "$script" ]] || continue
    if $APPLY; then
      bash "$script" --apply
    else
      bash "$script"
    fi
  done
fi
