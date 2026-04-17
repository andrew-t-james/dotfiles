#!/usr/bin/env bash
# run_once_after_02-bat-theme.sh
# Rebuilds bat's theme cache so custom syntaxes and themes are available.
set -euo pipefail

if command -v bat &>/dev/null; then
  echo "==> Building bat theme cache..."
  bat cache --build
  echo "==> bat cache built."
else
  echo "==> bat not found, skipping cache build."
fi
