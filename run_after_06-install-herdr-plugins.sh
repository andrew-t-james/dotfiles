#!/usr/bin/env bash
# Reconcile Herdr extensions that support the local workspace workflow.
set -euo pipefail

if ! command -v herdr >/dev/null 2>&1; then
  echo "==> herdr not found, skipping Herdr plugins."
  exit 0
fi

if [[ -f "$HOME/.cargo/env" ]]; then
  # Some Herdr plugins compile native helpers during install.
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
fi

plugin_installed() {
  herdr plugin list --json |
    jq -e --arg plugin_id "$1" '.result.plugins[]? | select(.plugin_id == $plugin_id)' >/dev/null
}

plugin_enabled() {
  herdr plugin list --json |
    jq -e --arg plugin_id "$1" '.result.plugins[]? | select(.plugin_id == $plugin_id and .enabled == true)' >/dev/null
}

plugin_matches_github_revision() {
  local plugin_id=$1
  local repository=$2
  local revision=$3

  herdr plugin list --json |
    jq -e \
      --arg plugin_id "$plugin_id" \
      --arg repository "$repository" \
      --arg revision "$revision" '
        .result.plugins[]?
        | select(
            .plugin_id == $plugin_id
            and .source.kind == "github"
            and ((.source.owner + "/" + .source.repo) == $repository)
            and .source.resolved_commit == $revision
          )
      ' >/dev/null
}

ensure_github_plugin() {
  local plugin_id=$1
  local repository=$2
  local revision=$3

  if plugin_matches_github_revision "$plugin_id" "$repository" "$revision"; then
    if plugin_enabled "$plugin_id"; then
      echo "  $plugin_id already installed."
    else
      herdr plugin enable "$plugin_id"
    fi
  else
    if plugin_installed "$plugin_id"; then
      herdr plugin uninstall "$plugin_id"
    fi
    herdr plugin install "$repository" --ref "$revision" --yes
  fi
}

ensure_local_plugin() {
  local plugin_id=$1
  local path=$2

  if plugin_enabled "$plugin_id"; then
    echo "  $plugin_id already linked."
  elif plugin_installed "$plugin_id"; then
    herdr plugin enable "$plugin_id"
  else
    herdr plugin link "$path"
  fi
}

echo "==> Installing Herdr plugins..."

# Codex must report its native session id for Herdr to resume conversations
# after a server restart. The hook source is managed by Herdr itself.
herdr integration install codex

ensure_github_plugin vim-herdr-navigation paulbkim-dev/vim-herdr-navigation 53e318c772c4d3b7fbd904ac43bcf3e5b5d8b244
ensure_github_plugin branch-cleanup dutifuldev/herdr-branch-cleanup d83cb4b557ae539babd454067ce83459d321b875
ensure_github_plugin hunk.diff edmundmiller/herdr-plugin-hunk 11ba5dcca4358203ca68f160becf6870cf016c18
ensure_local_plugin hunk.overlay "$HOME/.config/herdr/plugins/local/hunk-overlay"

echo "==> Herdr plugins installed."
