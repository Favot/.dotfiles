{ pkgs, config, lib, ... }:

let
  common = import ../lib/common.nix;
  commonPackages = map (name: pkgs.${name}) common.commonPackages;
in
{
  # Linux-specific packages
  environment.systemPackages = commonPackages ++ [
    # Game development (available via Nix on Linux)
    pkgs.godot_4       # The Game Engine (v4.x is best for current features)
    pkgs.gdtoolkit_4   # Essential! Provides 'gdformat' and 'gdlint' for GDScript
    pkgs.inkscape      # Best for creating vector UI assets (chat bubbles, icons)
  ];

  # Set zsh as the default shell for the primary user (Linux)
  users.users.favot = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];  # Add user to groups
  };

  # Linux-specific system settings
  # Add your Linux-specific configuration here

  # State version for NixOS
  system.stateVersion = "24.11";  # Adjust based on your NixOS version
}
