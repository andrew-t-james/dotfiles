#!/usr/bin/env bash
# run_once_after_05-mise-npm-globals.sh
# Installs npm global packages on all managed node versions
set -euo pipefail

# Ensure brew bins are in PATH
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null || true)"

if ! command -v mise &>/dev/null; then
  echo "==> mise not found, skipping npm globals."
  exit 0
fi

echo "==> Installing mise tools..."
mise install

echo "==> Installing npm globals across all node versions..."
for version in 22.22.0 24.13.1; do
  echo "  node@$version: installing @antfu/ni..."
  mise exec node@"$version" -- npm install -g @antfu/ni || echo "  skipped node@$version"
done

echo "==> npm globals installed."
