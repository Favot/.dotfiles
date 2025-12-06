{ pkgs, config, lib, ... }:

let
  common = import ../lib/common.nix;
  commonPackages = map (name: pkgs.${name}) common.commonPackages;
in
{
  # Linux-specific packages
  environment.systemPackages = commonPackages ++ [
    # Add Linux-specific packages here
    # Example:
    # pkgs.steam
    # pkgs.obs-studio
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
