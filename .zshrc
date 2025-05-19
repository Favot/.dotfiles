#=============================================================================
# TERMINAL CONFIGURATION
#=============================================================================

# Encoding for the terminal
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE="en_US:en"

# Add deno completions to search path
if [[ ":$FPATH:" != *":${HOME}/.zsh/completions:"* ]]; then
  export FPATH="${HOME}/.zsh/completions:$FPATH"
fi

#=============================================================================
# SHELL ENHANCEMENTS
#=============================================================================

# Oh My Zsh Configuration
ZSH=$HOME/.oh-my-zsh

# Set Oh My Zsh theme (using a simple theme since we're using Starship)
ZSH_THEME="robbyrussell"

# Starship prompt (this will override the Oh My Zsh theme)
eval "$(starship init zsh)"

# Oh My Zsh plugins
plugins=(git gitfast last-working-dir common-aliases history-substring-search npm zsh-autosuggestions web-search)

# Load Oh-My-Zsh
source "${ZSH}/oh-my-zsh.sh"

# Zinit plugin manager
source "${HOME}/.local/share/zinit/zinit.git/zinit.zsh"

# Load zinit annexes
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# Syntax highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#=============================================================================
# PATH CONFIGURATION
#=============================================================================

# Python user binaries
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# Java configuration
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH

# Go configuration
export GOPATH=$HOME/go
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

# Flutter
export PATH="$PATH:${HOME}/development/flutter/bin"

# Volta (Node.js version manager)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# LunarVim
export PATH="$HOME/.local/bin/lvim:$PATH"

# Deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

#=============================================================================
# LANGUAGE VERSION MANAGERS
#=============================================================================

# Ruby (rbenv)
export PATH="${HOME}/.rbenv/bin:${PATH}"
type -a rbenv >/dev/null && eval "$(rbenv init -)"

# Python (pyenv)
export PATH="$HOME/.pyenv/shims:$PATH"

# Node.js (nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# NVM auto-switching
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use --silent
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    nvm use default --silent
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

#=============================================================================
# ANDROID DEVELOPMENT
#=============================================================================

# Android SDK configuration
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

#=============================================================================
# SYSTEM CONFIGURATION
#=============================================================================

# Disable interactive rm by default
unalias rm

# Custom aliases
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Dynamic library path
export DYLD_LIBRARY_PATH=/usr/local/opt/capstone/lib/:$DYLD_LIBRARY_PATH

#=============================================================================
# SHELL HOOKS AND UTILITIES
#=============================================================================

# Reset trap function
function reset_trap {
  trap - INT
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec reset_trap

eval "$(starship init zsh)"

#=============================================================================
# EXTERNAL TOOLS INTEGRATION
#=============================================================================
