#!/usr/bin/env bash
# run_once_after_05-mise-npm-globals.sh
# Installs npm global packages on all managed node versions
set -euo pipefail

BREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
[[ -f "$BREW_PREFIX/bin/brew" ]] || BREW_PREFIX="/usr/local"
eval "$("$BREW_PREFIX/bin/brew" shellenv 2>/dev/null || true)"

MISE_BIN="$BREW_PREFIX/bin/mise"
if [[ ! -x "$MISE_BIN" ]]; then
  echo "==> mise not found, skipping npm globals."
  exit 0
fi

echo "==> Installing mise tools..."
"$MISE_BIN" install

echo "==> Installing npm globals across all node versions..."
for version in 22.22.0 24.13.1; do
  echo "  node@$version: installing @antfu/ni..."
  "$MISE_BIN" exec node@"$version" -- npm install -g @antfu/ni || echo "  skipped node@$version"
done

echo "==> npm globals installed."
