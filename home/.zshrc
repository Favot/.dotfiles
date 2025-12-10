# Zinit configuration
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Source zinit if it exists
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "${dirname ${ZINIT_HOME}}"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# Load plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# plugin snippets
zinit snippet OMZP::git
zinit snippet OMZP::1password
zinit snippet OMZP::sudo


# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q


# keybindings
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# History
HISTSIZE=10000
HISTFILE="$HOME/.zsh_history"
SAVEHIST="${HISTSIZE}"
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# completions styles
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'


# shell integration
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias tree="eza --tree --git-ignore"

# Added by Antigravity
export PATH="/Users/favot/.antigravity/antigravity/bin:$PATH"

# Add Nix system profile to PATH (for packages installed via nix-darwin)
export PATH="/run/current-system/sw/bin:$PATH"

# Load nvm (Node Version Manager) - must be loaded after PATH setup
# nvm will prepend its paths, ensuring nvm-managed Node.js takes precedence
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"  # This loads nvm and prepends to PATH
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi



export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
