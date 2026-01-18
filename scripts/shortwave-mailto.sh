#!/usr/bin/env bash
#
# shortwave-mailto.sh - Handle mailto: links by opening compose in Shortwave
#
# This script is invoked by the desktop environment when clicking mailto: links.
# It focuses an existing Shortwave window and triggers the compose action.
#
# How it works:
#   1. Parses the mailto: URI to extract the recipient email address
#   2. Finds the Shortwave window using hyprctl (Hyprland IPC)
#   3. Focuses the Shortwave window
#   4. Sends 'c' keypress to open compose (Shortwave keyboard shortcut)
#   5. Types the recipient address if one was provided
#
# Requirements:
#   - Shortwave must already be running (script exits silently if not)
#   - Hyprland window manager (uses hyprctl for window management)
#   - jq for parsing JSON from hyprctl
#   - wtype for sending keypresses on Wayland
#
# Installation:
#   1. Ensure this script is executable: chmod +x shortwave-mailto.sh
#   2. Run setup-web-apps.sh to install the .desktop file and set as mailto handler
#
# Usage (typically called by xdg-open, not directly):
#   ./shortwave-mailto.sh "mailto:someone@example.com"
#   ./shortwave-mailto.sh "mailto:someone@example.com?subject=Hello"
#
set -euo pipefail

URI="${1:-}"

# Verify required commands are available
need() { command -v "$1" >/dev/null 2>&1 || { echo "missing: $1" >&2; exit 1; }; }
need hyprctl
need jq
need wtype

# Decode URL-encoded strings (e.g., %40 -> @)
urldecode() {
  local s="${1//+/ }"
  printf '%b' "${s//%/\\x}"
}

# Extract the "to" address from a mailto: URI
# Sets the global TO variable with the decoded recipient
# Example: "mailto:foo%40bar.com?subject=Hi" -> TO="foo@bar.com"
parse_mailto_to() {
  local uri="$1" rest to_part
  TO=""
  [[ "$uri" == mailto:* ]] || return 0
  rest="${uri#mailto:}"        # Remove "mailto:" prefix
  to_part="${rest%%\?*}"       # Remove query string (?subject=... etc)
  TO="$(urldecode "$to_part")"
}

# Query Hyprland for the Shortwave window address
# Returns the hex address (e.g., 0x55828c672df0) or empty if not found
get_shortwave_address() {
  hyprctl clients -j | jq -r '.[] | select(.class == "shortwave") | .address' | head -1
}

# Focus Shortwave window or exit silently if not running
# We exit silently because there's nothing useful to do without Shortwave open
focus_shortwave_or_exit() {
  local addr
  addr="$(get_shortwave_address || true)"
  [[ -n "${addr:-}" ]] || exit 0
  hyprctl dispatch focuswindow "address:${addr}" >/dev/null 2>&1 || exit 0
}

main() {
  parse_mailto_to "$URI"
  focus_shortwave_or_exit

  # Press 'c' to open compose window (Shortwave keyboard shortcut)
  wtype -k c
  sleep 0.1

  # Type the recipient address if one was provided in the mailto: link
  [[ -n "${TO:-}" ]] && wtype -- "$TO"
}

main "$@"
