{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.cl-nix-lite.url = "github:r4v3n6101/cl-nix-lite/url-fix";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-services = {
      url = "github:homebrew/homebrew-services";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, homebrew-services, ... }:
  let
    configuration = { pkgs, ... }:
    let
      firaMonoNerdFont = pkgs.nerd-fonts.fira-mono;
    in {
      nixpkgs.config.allowUnfree = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.git
        pkgs.lazygit
        pkgs.bruno
        pkgs.vim
        pkgs.wget
        pkgs.gh
        pkgs.stow
        pkgs.oh-my-posh
        pkgs.tmux
        pkgs.zsh
        pkgs.tree

        # Language version managers
        pkgs.rbenv
        pkgs.pyenv

        # Programming languages
        pkgs.go
        pkgs.deno
        # Node.js managed via nvm (see system.activationScripts.nvm)
        pkgs.zulu17

        # React Native specific
        pkgs.watchman    # Essential for React Native
        pkgs.cocoapods   # iOS dependencies

        # Docker
        pkgs.docker
        pkgs.docker-compose

        pkgs.dbeaver-bin
        pkgs.llama-cpp

        # Terminal utilities
        pkgs.fzf         # Fuzzy finder
        pkgs.bat         # Better cat
        pkgs.ripgrep     # Better grep
        pkgs.fd          # Better find
        pkgs.zoxide      # Better cd
        pkgs.delta       # Better git diff
        pkgs.go-task     # Task runner
        pkgs.ngrok       # Secure tunneling tool

        # Libraries
        pkgs.capstone
        pkgs.xcodebuild
        pkgs.unzip
        pkgs.zip
        pkgs.gnupg

        # Fonts
        firaMonoNerdFont

        pkgs.google-chrome
        pkgs.firefox
      ];

      nixpkgs.config.allowBroken = true;
      
      homebrew = {
        enable = true;

        # Install cli packages from Homebrew.
        brews = [
          # "mas" - removed: mas signin not supported on newer macOS versions
          # See: https://github.com/mas-cli/mas#known-issues
        ];

        # Uncomment to install cask packages from Homebrew.
        casks = [
          "cursor"
          "antigravity"
          # Browsers
          "zen"
          # Window Management
          "rectangle"
          # Docker
          "docker-desktop"
          # Development Tools
          "visual-studio-code"  # Code editor
          "postman"  # API testing (alternative to Bruno)
          "insomnia"  # Another API client option
          # React/React Native Tools
          "android-studio"  # For React Native Android development
          # Communication
          "slack"  # Team communication
          # Utilities
          "raycast"  # Better Spotlight alternative
          "ghostty"  # Better terminal
          "nordvpn"
          "todoist-app"

          "ollama"
        ];

        # Mac App Store apps installation
        # Note: mas signin is not supported on newer macOS versions
        # Xcode must be installed manually from Mac App Store:
        # 1. Open Mac App Store and search for "Xcode"
        # 2. Install Xcode (App Store ID: 497799835)
        # 3. After installation, run:
        #    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
        #    sudo xcodebuild -license accept
        # masApps = {
        #   "Xcode" = 497799835;
        # };

        # Uncomment to remove any non-specified homebrew packages.
        # onActivation.cleanUp = "zap";

        # Uncomment to automatically update Homebrew and upgrade packages.
        # onActivation.autoUpdate = true;
        # onActivation.upgrade = true;
      };

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

      # Package installation and setup scripts
      # Accept Xcode license (required for Homebrew and other tools)
      # This must run early, before Homebrew operations
      system.activationScripts."00-xcodeLicense" = {
        text = ''
          # Set up Xcode and accept license if Xcode is installed
          if [ -d "/Applications/Xcode.app" ]; then
            # Ensure xcode-select points to Xcode
            sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer 2>/dev/null || true
            # Accept Xcode license (this will fail silently if already accepted)
            echo "Ensuring Xcode license is accepted..."
            sudo xcodebuild -license accept 2>&1 || true
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

      # Install TPM (Tmux Plugin Manager) if it doesn't exist
      system.activationScripts.tpm.text = ''
        # Install TPM if it doesn't exist
        TPM_HOME="/Users/favot/.tmux/plugins/tpm"
        if [ ! -d "$TPM_HOME" ]; then
          echo "Installing TPM (Tmux Plugin Manager)..."
          sudo -u favot mkdir -p "$(dirname "$TPM_HOME")"
          sudo -u favot git clone https://github.com/tmux-plugins/tpm "$TPM_HOME" || true
        else
          echo "TPM is already installed"
        fi
      '';

      # Disable macOS system shortcuts that conflict with Ctrl+Space for tmux
      system.activationScripts.keyboardShortcuts.text = ''
        echo "Configuring keyboard shortcuts to allow Ctrl+Space for tmux..."
        
        # Disable Ctrl+Space for switching input sources (Keyboard ID 60)
        # This is the most common conflict on macOS
        sudo -u favot /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:60:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || {
          # If the key doesn't exist, create it
          sudo -u favot /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:60:enabled bool false" ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || true
        }
        
        # Note: You may also need to configure your terminal emulator to pass Ctrl+Space through
        # For iTerm2: Preferences > Keys > Key Bindings > remove or change Ctrl+Space
        # For Terminal.app: This should work by default
        # For other terminals: Check their keyboard shortcut settings
        
        echo "Keyboard shortcut configuration complete."
        echo "Note: If Ctrl+Space still doesn't work, check your terminal emulator's keyboard shortcut settings."
      '';

      # Install FiraMono Nerd Font
      system.activationScripts.fonts.text = ''
        # Install FiraMono Nerd Font to system fonts directory
        FONT_DIR="/Library/Fonts"
        FONT_SOURCE="${firaMonoNerdFont}/share/fonts"
        
        # Create font directory if it doesn't exist
        mkdir -p "$FONT_DIR"
        
        # Find and copy FiraMono Nerd Font files
        if [ -d "$FONT_SOURCE" ]; then
          echo "Installing FiraMono Nerd Font..."
          find "$FONT_SOURCE" -name "*FiraMono*" -type f | while read -r font; do
            font_name=$(basename "$font")
            if [ ! -f "$FONT_DIR/$font_name" ]; then
              sudo cp "$font" "$FONT_DIR/$font_name"
              echo "  Installed: $font_name"
            else
              echo "  Already installed: $font_name"
            fi
          done
          # Refresh font cache
          /System/Library/Frameworks/CoreText.framework/Versions/A/Resources/fontCache -v 2>/dev/null || true
          echo "FiraMono Nerd Font installation complete!"
        else
          echo "Warning: Font source directory not found: $FONT_SOURCE"
        fi
      '';

      # Install displayplacer and set display resolution to 2048x1330
      system.activationScripts.displayResolution.text = ''
        # Install displayplacer if not already installed
        if ! command -v displayplacer >/dev/null 2>&1; then
          echo "Installing displayplacer for display resolution management..."
          if command -v brew >/dev/null 2>&1; then
            # Tap the repository first
            brew tap jakehilborn/jakehilborn 2>/dev/null || true
            # Install displayplacer
            brew install displayplacer 2>/dev/null || {
              echo "Warning: Could not install displayplacer automatically."
              echo "You can install it manually with: brew tap jakehilborn/jakehilborn && brew install displayplacer"
            }
          else
            echo "Warning: Homebrew not found. Cannot install displayplacer."
          fi
        fi
        
        # Set display resolution to 2048x1330
        echo "Configuring display resolution to 2048x1330..."
        
        # Wait a moment for displayplacer to be available
        sleep 1
        
        # Use displayplacer to set the resolution
        if command -v displayplacer >/dev/null 2>&1; then
          echo "Using displayplacer to set resolution to 2048x1330..."
          
          # Get the main display ID
          MAIN_DISPLAY=$(displayplacer list 2>/dev/null | grep -A 5 "Persistent screen id" | head -1 | awk '{print $4}' || echo "")
          
          if [ -n "$MAIN_DISPLAY" ]; then
            # Set resolution for the main display
            displayplacer "id:$MAIN_DISPLAY res:2048x1330" 2>/dev/null || {
              echo "Attempting alternative method to set resolution..."
              # Try without specifying display ID (will use main display)
              displayplacer "res:2048x1330" 2>/dev/null || echo "Could not set resolution. You may need to set it manually."
            }
          else
            # Try to set resolution without specifying display ID
            echo "Setting resolution for default display..."
            displayplacer "res:2048x1330" 2>/dev/null || echo "Could not set resolution. You may need to set it manually."
          fi
        else
          echo "Warning: displayplacer not available. Resolution will not be set automatically."
          echo "You can install it manually with:"
          echo "  brew tap jakehilborn/jakehilborn"
          echo "  brew install displayplacer"
          echo "  displayplacer 'res:2048x1330'"
        fi
        
        echo "Display resolution configuration complete!"
      '';

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      system.primaryUser = "favot";

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.defaults = {
        dock.autohide  = true;
        dock.magnification = true;
        dock.mineffect = "genie";
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled  = false;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.KeyRepeat = 2;
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."defaultMac" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            # enableRosetta = true;

            # User owning the Homebrew prefix
            user = "favot";

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
              "homebrew/homebrew-services" = homebrew-services;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;

            # Automatically migrate existing Homebrew installations
            # autoMigrate = true;
          };
        }
      ];
    };
  };
}
