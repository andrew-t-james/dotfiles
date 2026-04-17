#!/usr/bin/env bash
# bootstrap.sh — one-shot Mac setup
# Usage: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/andrew-t-james/dotfiles/main/bootstrap.sh)"
set -euo pipefail

# ─── Xcode CLT ───────────────────────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
  echo "ERROR: Xcode Command Line Tools not installed."
  echo ""
  echo "  Run: xcode-select --install"
  echo "  Wait for it to finish, then re-run this script."
  exit 1
fi

# ─── Homebrew ────────────────────────────────────────────────────────────────
if [[ ! -x /opt/homebrew/bin/brew ]] && [[ ! -x /usr/local/bin/brew ]]; then
  echo "==> Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi
echo "==> Homebrew ready."

# ─── chezmoi ─────────────────────────────────────────────────────────────────
echo "==> Installing chezmoi..."
brew install chezmoi

# ─── dotfiles ────────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/dotfiles" ]]; then
  echo "==> Cloning dotfiles..."
  git clone https://github.com/andrew-t-james/dotfiles.git "$HOME/dotfiles"
else
  echo "==> Updating dotfiles..."
  git -C "$HOME/dotfiles" pull
fi

# ─── apply ───────────────────────────────────────────────────────────────────
echo "==> Applying dotfiles..."
chezmoi init --source "$HOME/dotfiles" --apply --force

echo ""
echo "==> Bootstrap complete. Open a new terminal."
