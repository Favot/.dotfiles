{ pkgs, config, lib, ... }:

let
  common = import ../lib/common.nix;
  firaMonoNerdFont = pkgs.nerd-fonts.fira-mono;
  
  commonPackages = map (name: pkgs.${name}) common.commonPackages;
in
{
  # macOS-specific packages
  environment.systemPackages = commonPackages ++ [
    # React Native specific
    pkgs.watchman    # Essential for React Native
    pkgs.cocoapods   # iOS dependencies

    # macOS specific tools
    pkgs.capstone
    # Note: pkgs.xcodebuild removed - we use the real Xcode tools instead
    # Nix's xcodebuild wrapper reports version "0.1" which breaks React Native
    # The real Xcode tools are configured via environment.extraInit below

    # Fonts
    firaMonoNerdFont
  ];

  # Ensure Xcode tools take precedence over Nix wrappers
  # This fixes React Native and CocoaPods builds that require the real Xcode version
  environment.extraInit = ''
    # Prepend Xcode's developer tools to PATH if Xcode is installed
    if [ -d "/Applications/Xcode.app/Contents/Developer/usr/bin" ]; then
      export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH"
    fi
  '';

  # Homebrew for macOS package management
  homebrew = {
    enable = true;

    # Install cli packages from Homebrew.
    brews = [
      # "mas" - removed: mas signin not supported on newer macOS versions
      # See: https://github.com/mas-cli/mas#known-issues
      "qwen-code"
      "gdtoolkit"  # Essential! Provides 'gdformat' and 'gdlint' for GDScript
    ];

    # Install cask packages from Homebrew.
    casks = [
      "cursor"
      "antigravity"
      # Browsers
      "zen"
      "vivaldi"
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
      "ollama-app"
      "zulu@17"  # Java 17
      # Game development (not available via Nix on macOS, using Homebrew instead)
      "godot"     # The Game Engine (v4.x is best for current features)
      "inkscape"  # Best for creating vector UI assets (chat bubbles, icons)

      "steam"
      "Sikarugir-App/sikarugir/sikarugir"
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

  # macOS specific activation scripts
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

  # Hide Recents section from Finder sidebar
  system.activationScripts."01-hideFinderRecents" = {
    text = ''
      echo "Hiding Recents section from Finder sidebar..."
      sudo -u favot defaults write com.apple.finder ShowRecentTags -bool false 2>/dev/null || true
    '';
    deps = [];
  };

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

  # macOS specific defaults
  system.defaults = {
    dock.autohide  = true;
    dock.magnification = true;
    dock.mineffect = "genie";
    finder.FXPreferredViewStyle = "clmv";
    finder.NewWindowTarget = "Home";  # Open new Finder windows to home directory instead of Recent
    loginwindow.GuestEnabled  = false;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.KeyRepeat = 2;
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = null; # Will be set in flake.nix

  # Used for backwards compatibility
  system.stateVersion = 6;

  system.primaryUser = "favot";

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
