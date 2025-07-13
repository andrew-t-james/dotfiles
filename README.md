# 🌿 Andrew’s Dotfiles

This repository contains my personal dotfiles for a minimal, performant, and developer-friendly setup on **Arch Linux** and **macOS**.

---

## ⚙️ Features

- Zsh with:
  - Oh My Zsh
  - Antigen plugin manager
  - Plugins: autosuggestions, syntax highlighting, vi-mode, git-open
- Starship prompt (Catppuccin theme)
- Tmux with TPM and vi-mode
- Hyprland tiling window manager (Wayland)
- Neovim (optional, minimal setup)
- Dotfile management using GNU Stow
- Tools: mise, zoxide, direnv, fzf

---

## 🚀 Quickstart

### Dry Run (Preview)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/andrew-t-james/dotfiles/main/bootstrap.sh)
```

### Full Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/andrew-t-james/dotfiles/main/bootstrap.sh) --apply
```

---

## 🗂️ Stowed Packages

These directories are managed by [GNU Stow](https://www.gnu.org/software/stow/):

- `zsh/`
- `tmux/`
- `nvim/`
- `starship/`
- `bat/`
- `hypr/`

---

## 🔧 Requirements

Automatically handled by the bootstrap script:

- **Linux (Arch)**: installs `yay` if missing
- **macOS**: installs Homebrew if missing

Requires `sudo` privileges for some installations.

---

## ❌ Uninstall

To remove all symlinks created by Stow:

```bash
cd ~/dotfiles
stow -D bat tmux hypr zsh starship nvim
```

---

## 📸 Screenshots

_To be added._

---

## 📄 License

MIT © [Andrew James](https://github.com/andrew-t-james)
