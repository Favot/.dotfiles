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
    configuration = { pkgs, ... }: {
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
        pkgs.starship
        pkgs.tmux
        pkgs.zsh

        # Language version managers
        pkgs.rbenv
        pkgs.pyenv

        # Programming languages
        pkgs.go
        pkgs.deno
        pkgs.zulu17

        # React Native specific
        pkgs.watchman    # Essential for React Native
        pkgs.cocoapods   # iOS dependencies

        # Docker
        pkgs.docker
        pkgs.docker-compose

        # Terminal utilities
        pkgs.fzf         # Fuzzy finder
        pkgs.bat         # Better cat
        pkgs.ripgrep     # Better grep
        pkgs.fd          # Better find
        pkgs.zoxide      # Better cd
        pkgs.delta       # Better git diff

        # Libraries
        pkgs.capstone
        pkgs.xcodebuild
        pkgs.unzip
        pkgs.zip
        pkgs.gnupg
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
          "zed"
          # Browsers
          "firefox"
          "zen"
          # Window Management
          "rectangle"
          # Docker
          "docker-desktop"
          # Development Tools
          "postman"  # API testing (alternative to Bruno)
          "insomnia"  # Another API client option
          # React/React Native Tools
          "android-studio"  # For React Native Android development
          # Utilities
          "raycast"  # Better Spotlight alternative
          "ghostty"  # Better terminal (if you want)
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

      # Install nvm if it doesn't exist
      system.activationScripts.nvm.text = ''
        # Install nvm if it doesn't exist
        if [ ! -d "/Users/favot/.nvm" ]; then
          sudo -u favot bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash' || true
        fi
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
