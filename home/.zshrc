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

# Starship prompt (check if available)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Oh My Zsh Configuration (check if available)
if [ -d "$HOME/.oh-my-zsh" ] || [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
  ZSH="${ZSH:-$HOME/.oh-my-zsh}"
  ZSH_THEME="${ZSH_THEME:-robbyrussell}"
  
  # Oh My Zsh plugins
  plugins=(git gitfast last-working-dir common-aliases history-substring-search npm zsh-autosuggestions web-search)
  
  # Load Oh-My-Zsh
  if [ -f "${ZSH}/oh-my-zsh.sh" ]; then
    source "${ZSH}/oh-my-zsh.sh"
  fi
fi

# Zinit plugin manager (check if available)
if [ -f "${HOME}/.local/share/zinit/zinit.git/zinit.zsh" ]; then
  source "${HOME}/.local/share/zinit/zinit.git/zinit.zsh"
  
  # Load zinit annexes
  zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
fi

# Syntax highlighting (check multiple possible locations)
if [ -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

#=============================================================================
# PATH CONFIGURATION
#=============================================================================

# Python user binaries
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# Java configuration (managed by Nix - zulu)
# JAVA_HOME will be set by Nix if zulu is installed
if command -v java >/dev/null 2>&1; then
  # Try to detect JAVA_HOME from java command if not set
  if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null || echo "")
  fi
  [ -n "$JAVA_HOME" ] && export PATH="$JAVA_HOME/bin:$PATH"
fi

# Go configuration
export GOPATH=$HOME/go
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

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

# Node.js (nvm) - only load if nvm is installed
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  
  # NVM auto-switching (only if nvm is available)
  autoload -U add-zsh-hook
  load-nvmrc() {
    if command -v nvm >/dev/null 2>&1; then
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
    fi
  }
  add-zsh-hook chpwd load-nvmrc
  load-nvmrc
fi

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

# Disable interactive rm by default (only if alias exists)
if alias rm >/dev/null 2>&1; then
  unalias rm
fi

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

# Starship prompt (re-initialize if available - in case oh-my-zsh overrides it)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

#=============================================================================
# EXTERNAL TOOLS INTEGRATION
#=============================================================================
