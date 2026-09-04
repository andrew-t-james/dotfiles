#!/usr/bin/env bash
# Install the FFF MCP binary configured by dot_codex/modify_private_config.toml.
set -euo pipefail

version="0.10.6"
install_path="$HOME/.local/bin/fff-mcp"

case "$(uname -m)" in
  x86_64)
    target="x86_64-unknown-linux-musl"
    expected_sha="a44ef64015f1754aa63b690c24d9a748ed16298f05350da7b09554c4c98dfb0f"
    ;;
  aarch64 | arm64)
    target="aarch64-unknown-linux-musl"
    expected_sha="028b9e388716a8c0c39de3f153dd8e14e5ee998ffa70d4951f1cd2a3fc42f6ce"
    ;;
  *)
    echo "[ERROR] Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

if [[ -x "$install_path" ]] && "$install_path" --version 2>/dev/null | grep -q "fff-mcp $version"; then
  echo "[INFO] FFF MCP $version is already installed"
  exit 0
fi

if [[ ${1:-} != "--apply" ]]; then
  echo "[DRY RUN] Would install FFF MCP $version to $install_path"
  exit 0
fi

asset="fff-mcp-$target"
url="https://github.com/dmtrKovalenko/fff/releases/download/v$version/$asset"
temp_dir="$(mktemp -d)"
trap 'rm -rf -- "$temp_dir"' EXIT

curl -fsSL "$url" -o "$temp_dir/$asset"
printf '%s  %s\n' "$expected_sha" "$temp_dir/$asset" | sha256sum --check --status
install -Dm755 "$temp_dir/$asset" "$install_path"

echo "[INFO] Installed $($install_path --version)"
