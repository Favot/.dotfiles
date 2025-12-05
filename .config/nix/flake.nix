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
        pkgs.oh-my-zsh
        # Language version managers (referenced in .zshrc)
        pkgs.rbenv
        pkgs.pyenv
        # Programming languages (referenced in .zshrc)
        pkgs.go
        pkgs.deno
        # Java (zulu JDK)
        pkgs.zulu17
        # Libraries (referenced in .zshrc)
        pkgs.capstone
      ];

      nixpkgs.config.allowBroken = true;
      
      homebrew = {
        enable = true;

        # Install cli packages from Homebrew.
        brews = [
          "zsh-syntax-highlighting"
          "zinit"
        ];

        # Uncomment to install cask packages from Homebrew.
        casks = [
        #  "balenaetcher"
        #  "calibre"
        #  "carbon-copy-cloner"
        #  "logitech-options"
          "cursor"
          "zed"
        ];

        # Uncomment to install app store apps using mas-cli.
        # masApps = {
        #   "Session" = 1521432881;
        # };

        # Uncomment to remove any non-specified homebrew packages.
        # onActivation.cleanUp = "zap";

        # Uncomment to automatically update Homebrew and upgrade packages.
        # onActivation.autoUpdate = true;
        # onActivation.upgrade = true;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
      programs.zsh.enable = true;
      programs.zsh.shellInit = ''
        # Cursor CLI
        export PATH="/Applications/Cursor.app/Contents/Resources/app/bin:$PATH"
        
        # Java (zulu) - set JAVA_HOME for zulu installed via Nix
        export JAVA_HOME="${pkgs.zulu17}/lib/openjdk"
        export PATH="$JAVA_HOME/bin:$PATH"
        
        # Environment variables for .zshrc to check (optional - .zshrc will work without these)
        # These help .zshrc locate tools, but .zshrc has fallbacks if these aren't set
        export ZSH_OH_MY_ZSH_PATH="$HOME/.oh-my-zsh"
        export ZSH_SYNTAX_HIGHLIGHTING_PATHS="/opt/homebrew/share/zsh-syntax-highlighting:/usr/local/share/zsh-syntax-highlighting"
      '';

      # Package installation and setup scripts
      # Note: .zshrc is designed to work independently - it checks for tool existence before using them
      # These activation scripts set up prerequisites, but .zshrc will work even if they haven't run yet
      
      # Set up oh-my-zsh symlink for compatibility with existing .zshrc
      system.activationScripts.ohMyZsh.text = ''
        # Create symlink for oh-my-zsh if it doesn't exist
        if [ ! -e "/Users/favot/.oh-my-zsh" ]; then
          sudo -u favot ln -sf ${pkgs.oh-my-zsh}/share/oh-my-zsh /Users/favot/.oh-my-zsh
        fi
      '';

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
