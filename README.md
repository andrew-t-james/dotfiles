# Andrew's Dotfiles

Managed with [chezmoi](https://chezmoi.io). One command gets you from a fresh Mac to a fully configured machine.

## Quickstart

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --source ~/dotfiles --apply andrew-t-james/dotfiles
```

This will:
1. Install chezmoi
2. Clone this repo to `~/dotfiles`
3. Prompt for your git email and whether this is a work machine
4. Install Xcode CLT + Homebrew + all packages from `Brewfile`
5. Install Rust via rustup
6. Apply all dotfiles to `~`
7. Set macOS defaults (dock, finder, keyboard repeat, trackpad)
8. Build the bat syntax/theme cache

## What gets installed

### GUI Apps (Homebrew Casks)
- **Terminals**: Ghostty (primary)
- **Editors**: Zed, Neovim (config included)
- **AI tools**: Claude, Claude Code, Codex, Copilot CLI
- **Productivity**: Raycast, Notion, Notion Calendar, Linear, Slack
- **Dev**: Beekeeper Studio, QMK Toolbox, Docker/OrbStack
- **Browsers**: Google Chrome, Zen Browser
- **Utilities**: CleanShot X, 1Password, AppCleaner, LocalSend

### CLI Tools (Homebrew Formulae)
- **Shell**: bat, btop, direnv, fzf, starship, tmux, zoxide
- **Git**: gh, git-delta, lazygit, lazydocker, git-lfs
- **Cloud**: awscli, aws-vault, cloudflared, stern
- **Languages**: mise (manages node/bun/python), go, zig, uv
- **Utilities**: jq, yq, ripgrep, fd, mkcert, pass, wget

### Dotfiles managed
| Config | Target |
|--------|--------|
| aerospace | `~/.config/aerospace/` |
| alacritty | `~/.config/alacritty/` |
| bat | `~/.config/bat/` |
| delta | `~/.config/delta/` |
| ghostty | `~/.config/ghostty/` |
| git | `~/.config/git/` |
| kitty | `~/.config/kitty/` |
| mise | `~/.config/mise/` |
| neofetch | `~/.config/neofetch/` |
| nvim | `~/.config/nvim/` |
| raycast-commands | `~/.config/raycast-commands/` |
| starship | `~/.config/starship.toml` |
| tmux | `~/.config/tmux/` |
| zsh | `~/.config/zsh/` |
| bin | `~/.local/bin/` |
| hypr | `~/.config/hypr/` (Linux only) |

## Post-install manual steps

1. **GPG keys** — restore from 1Password or USB backup, then set trust to ultimate
2. **SSH keys** — restore `id_ed25519` and `journey` from 1Password
3. **Password store** — `git clone git@github.com:andrew-t-james/pass-store.git ~/.password-store`
4. **Sign in** — 1Password, Claude, GitHub CLI (`gh auth login`)
5. **Rust tools** — `cargo install` any project-specific tools
6. **Go binaries** — `go install` goimports, gt, task, templ, etc.
7. **pipx tools** — `pipx install graphify vectorcode`
8. **Bun globals** — `bun install -g clawhub mcporter`

## Updating

```sh
chezmoi update
```

## Structure

```
dotfiles/
├── dot_config/          # chezmoi source → ~/.config/
├── dot_local/bin/       # chezmoi source → ~/.local/bin/
├── .chezmoi.toml.tmpl   # chezmoi config template (prompted on init)
├── .chezmoiignore       # excludes hypr on macOS, tmux plugins always
├── Brewfile             # all Homebrew packages
├── run_once_before_01-install-homebrew.sh.tmpl
├── run_once_before_02-install-rust.sh
├── run_once_after_01-macos-defaults.sh.tmpl
└── run_once_after_02-bat-theme.sh
```

The original stow directories (`aerospace/`, `nvim/`, etc.) are kept for reference.
