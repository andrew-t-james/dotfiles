#!/usr/bin/env bash
# Installs web apps through Omarchy's default-browser launcher.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../web-apps"
SRC_ICON_DIR="$SRC_DIR/icons"

APPLY=false
[[ ${1:-} == "--apply" ]] && APPLY=true

[[ -d "$SRC_DIR" ]] || { echo "[INFO] No web-apps directory, skipping"; exit 0; }

if $APPLY; then
  # Keep Omarchy and XDG URL handlers on the stock Chromium default.
  omarchy default browser chromium

  omarchy webapp install shortwave https://app.shortwave.com "$SRC_ICON_DIR/shortwave.png"

  echo "[INFO] Installed Shortwave using Omarchy's default browser"
else
  echo "[DRY RUN] Would set Chromium as the Omarchy default browser"
  echo "[DRY RUN] Would install Shortwave using Omarchy's default browser"
fi
