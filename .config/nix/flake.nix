{
  description = "Multi-platform NixOS/nix-darwin configuration";

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
    sikarugir-tap = {
      url = "github:Sikarugir-App/homebrew-sikarugir";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, homebrew-services, sikarugir-tap, ... }:
  let
    common = import ./lib/common.nix;
  in
  {
    # macOS configuration
    darwinConfigurations."defaultMac" = nix-darwin.lib.darwinSystem {
      modules = [
        ./modules/darwin.nix
        common.commonConfig
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
              "Sikarugir-App/sikarugir" = sikarugir-tap;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            # Temporarily set to true to allow initial tap setup, then can be set back to false
            mutableTaps = true;

            # Automatically migrate existing Homebrew installations
            # autoMigrate = true;
          };
        }
      ];
    };

    # Linux configuration (NixOS)
    # To build: sudo nixos-rebuild switch --flake .#defaultLinux
    # nixosConfigurations."defaultLinux" = nixpkgs.lib.nixosSystem {
    #   system = "x86_64-linux";
    #   modules = [
    #     ./modules/linux.nix
    #     common.commonConfig
    #   ];
    # };
  };
}
