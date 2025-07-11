#!/usr/bin/env bash
set -euo pipefail

REPO_URL="git@github.com:andrew-t-james/dotfiles.git"
CLONE_DIR="$HOME/dotfiles"

echo "[INFO] Bootstrapping dotfiles from $REPO_URL"

# Install git if not present (macOS/Arch only)
if ! command -v git >/dev/null 2>&1; then
  echo "[INFO] git not found. Installing..."
  if [[ "$(uname -s)" == "Linux" ]]; then
    sudo pacman -Syu --noconfirm git
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    echo "[INFO] Please install Xcode Command Line Tools..."
    xcode-select --install
    exit 1
  else
    echo "[ERROR] Unsupported OS"
    exit 1
  fi
fi

# Clone if dotfiles folder is missing
if [[ -d "$CLONE_DIR/.git" ]]; then
  echo "[INFO] Dotfiles already cloned at $CLONE_DIR"
else
  echo "[INFO] Cloning dotfiles repo..."
  git clone "$REPO_URL" "$CLONE_DIR"
fi

# Run the install script in dry-run mode unless --apply is passed
cd "$CLONE_DIR"

if [[ ${1:-} == "--apply" ]]; then
  echo "[INFO] Running full install..."
  exec bash ./install.sh --apply
else
  echo "[INFO] Running dry-run install..."
  exec bash ./install.sh
fi
