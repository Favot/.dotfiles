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
    # "zed-editor"  # Disabled - too slow to build from source
    "obsidian"
    "claude-code"


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
    "unrar"
    "stow"
    "localsend"

    # Utilities
    "go-task"
    "ngrok"
    "gnupg"
    "act"
    "tesseract"

    # Build tools and development
    "cmake"
    "ninja"
    "gperf"
    "ccache"
    "dfu-util"
    "qemu"
    "dtc"
    "python3"


    # Tauri development (for JS frontend)
    "rustc"       # Rust compiler
    "cargo"       # Rust package manager
    "cargo-tauri" # Tauri CLI tool (optional but helpful)
    "pkg-config"  # For building native dependencies

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
    # Chrome in nixpkgs is marked insecure (updater broken); permit to allow install
    nixpkgs.config.permittedInsecurePackages = [
      "google-chrome-144.0.7559.97"
    ];

    # Necessary for using flakes on this system.
    nix.settings.experimental-features = "nix-command flakes";
    # Avoid "download buffer is full" on fast links (value in bytes, 500 MiB)
    nix.settings.download-buffer-size = 524288000;

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
        TPM_HOME="$HOME/.tmux/plugins/tpm"
        if [ ! -d "$TPM_HOME" ]; then
          echo "Installing TPM (Tmux Plugin Manager)..."
          mkdir -p "$(dirname "$TPM_HOME")"
          git clone https://github.com/tmux-plugins/tpm "$TPM_HOME" 2>&1 || {
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
    system.activationScripts.nvm = {
      text = ''
        # Install nvm if it doesn't exist
        NVM_DIR="$HOME/.nvm"
        if [ ! -d "$NVM_DIR" ]; then
          echo "Installing nvm (Node Version Manager)..."
          # Download and install nvm without sudo
          curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | PROFILE=/dev/null bash
        else
          echo "nvm is already installed at $NVM_DIR"
        fi

        # Ensure nvm is loaded for current session
        if [ -s "$NVM_DIR/nvm.sh" ]; then
          . "$NVM_DIR/nvm.sh"
          echo "nvm version: $(nvm --version)"
        fi
      '';
      deps = [];
    };
  };
}
