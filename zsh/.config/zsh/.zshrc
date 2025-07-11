# ---------------- PATH SETUP ----------------
unset DYLD_LIBRARY_PATH

typeset -U path
path=(
    /opt/homebrew/bin             # macOS Homebrew (Apple Silicon)
    /opt/homebrew/sbin
    "$HOME/.local/bin"            # Linux user bin
    "$HOME/go/bin"                # Go binaries
    "$path"
)
export PATH

[[ -f "$HOME/.config/zsh/alias.sh" ]] && source "$HOME/.config/zsh/alias.sh"

# ---------------- ZSH & OH-MY-ZSH ----------------
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"  # Defaults to ~/.oh-my-zsh
ZSH_THEME="robbyrussell"

# ---------------- Antigen Plugin Manager ----------------
# Load Antigen from XDG_CONFIG_HOME or fallback to ~/.config
ANTIGEN_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/antigen.zsh"
[[ -f "$ANTIGEN_PATH" ]] && source "$ANTIGEN_PATH"

# Use oh-my-zsh as plugin source
antigen use oh-my-zsh

# Core plugins
antigen bundles <<EOBUNDLES
    git
    zsh-users/zsh-autosuggestions
    zdharma-continuum/fast-syntax-highlighting
    jeffreytse/zsh-vi-mode
EOBUNDLES

antigen apply

# ---------------- Oh-My-Zsh ----------------
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ---------------- Terminal Settings ----------------
[[ -n "$TMUX" ]] && export TERM="xterm-256color"
export GPG_TTY=$(tty)

# ---------------- Prompt ----------------
eval "$(starship init zsh)"
export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"

# ---------------- Navigation & Tools ----------------
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# ---------------- Development Environments ----------------
[[ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]] && . /opt/homebrew/opt/asdf/libexec/asdf.sh

# ---------------- Local Environment ----------------
[[ -f "$HOME/bin/env" ]] && . "$HOME/bin/env"
