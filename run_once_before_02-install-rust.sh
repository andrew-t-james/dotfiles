#!/usr/bin/env bash
# run_once_before_02-install-rust.sh
# Installs rustup if rustc is not found. Platform-agnostic.
set -euo pipefail

if command -v rustc &>/dev/null; then
  echo "==> Rust already installed ($(rustc --version))."
  exit 0
fi

echo "==> Installing rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
echo "==> rustup installed. Restart your shell or run: source \"\$HOME/.cargo/env\""
