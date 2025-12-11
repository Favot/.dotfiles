{
  # Common packages for both macOS and Linux
  commonPackages = [
    # Version managers
    "rbenv"
    "pyenv"

    # Programming languages
    "go"
    "deno"
    "bun"

    # Version control
    "git"
    "lazygit"
    "gh"

    # Shell and terminal
    "zsh"
    "tmux"
    "oh-my-posh"
    "starship"

    # Editors
    "vim"
    "neovim"

    # Terminal utilities
    "tree"
    "fzf"
    "bat"
    "ripgrep"
    "fd"
    "zoxide"
    "delta"
    "eza"
    "bottom"
    "tmux-mem-cpu-load"
    "procs"
    "lsd"

    # File management
    "wget"
    "unzip"
    "zip"
    "stow"

    # Utilities
    "go-task"
    "ngrok"
    "gnupg"
    "act"

    # API and database
    "bruno"
    "dbeaver-bin"

    # Docker
    "docker"
    "docker-compose"
    "lazydocker"

    # AI and ML
    "llama-cpp"

    # Browsers
    "google-chrome"
    "firefox"

    "frp"
  ];

  # Common system configuration
  commonConfig = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowBroken = true;

    # Necessary for using flakes on this system.
    nix.settings.experimental-features = "nix-command flakes";

    # Enable zsh and set as default shell
    programs.zsh.enable = true;

    # Add zsh to the list of allowed shells
    environment.shells = [ pkgs.zsh ];

    # Set zsh as the default shell for the primary user
    users.users.favot = {
      shell = pkgs.zsh;
    };

    # Install TPM (Tmux Plugin Manager) if it doesn't exist
    system.activationScripts.tpm = {
      text = ''
        # Install TPM if it doesn't exist
        TPM_HOME="/Users/favot/.tmux/plugins/tpm"
        if [ ! -d "$TPM_HOME" ]; then
          echo "Installing TPM (Tmux Plugin Manager)..."
          sudo -u favot mkdir -p "$(dirname "$TPM_HOME")"
          sudo -u favot git clone https://github.com/tmux-plugins/tpm "$TPM_HOME" 2>&1 || {
            echo "Warning: Failed to clone TPM. You may need to install it manually:"
            echo "  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
          }
        else
          echo "TPM is already installed at $TPM_HOME"
        fi
      '';
      deps = [];
    };

    # Install nvm if it doesn't exist (for Node.js version management)
    system.activationScripts.nvm.text = ''
      # Install nvm if it doesn't exist
      if [ ! -d "/Users/favot/.nvm" ]; then
        echo "Installing nvm (Node Version Manager)..."
        sudo -u favot bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash' || true
      else
        echo "nvm is already installed"
      fi
    '';
  };
}
