# Clear any potential system interference
unset DYLD_LIBRARY_PATH

# Path Management
typeset -U path
path=(
    /opt/homebrew/bin
    /opt/homebrew/sbin
    /usr/local/bin
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
    "$HOME/go/bin"
    "$XDG_DATA_HOME/pnpm"
    $path
)
export PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/${USER}/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="cobalt2"
# ZSH_THEME="powerlevel9k/powerlevel9k"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# Antigen Plugin Management
source $XDG_CONFIG_HOME/antigen.zsh
antigen use oh-my-zsh

# Bundles from the default repo
antigen bundles <<EOBUNDLES
    git
    zsh-users/zsh-autosuggestions
    zdharma-continuum/fast-syntax-highlighting
    paulirish/git-open
    jeffreytse/zsh-vi-mode
EOBUNDLES
# antigen bundle MichaelAquilina/you-should-use
# antigen bundle ajeetdsouza/zoxide
antigen apply

source $ZSH/oh-my-zsh.sh

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Load aliases
source $ZDOTDIR/alias.sh
source $ZDOTDIR/ssh.sh
source $ZDOTDIR/functions.sh

# Terminal and tmux configuration
[[ -n $TMUX ]] && export TERM=xterm-256color

# Plugin configurations
export YSU_HARDCORE=1

# Tool initializations
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export GPG_TTY=$(tty)

# Starship prompt
eval "$(starship init zsh)"
export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship.toml

# Navigation tools
eval "$(zoxide init zsh --cmd z)"

# # Install direnv
# brew install direnv
#
# # Add to your .zshrc
# eval "$(direnv hook zsh)"
#
# # Create a global environment file
# mkdir -p ~/.config/env
# cat > ~/.config/env/.envrc << 'EOF'
# # Global secrets
# export OPENAI_API_KEY="your_key_here"
# export GITHUB_TOKEN="your_token_here"
# # Add other global environment variables here
# EOF
#
# # Allow the global environment
# direnv allow ~/.config/env
#
# # Add to your .gitignore
# echo ".envrc" >> ~/.gitignore
# echo ".env" >> ~/.gitignore
eval "$(direnv hook zsh)"

# Development tools
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# Bun configuration
export BUN_INSTALL="$HOME/.bun"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# PNPM configuration
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Load local environment
. "$XDG_DATA_HOME/../bin/env"
