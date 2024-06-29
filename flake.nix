{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, ... }:
    let
      inherit (self) inputs outputs;

      system = "x86_64-linux";

      overlays = [
        (final: prev: { })
      ];

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };

      lib = import ./lib {
        inherit nixpkgs self;
      };
    in
    {
      nixosConfigurations = lib.nixos.mkSystems {
        "AIVD-Mainframe-WSL" = {
          inherit system pkgs;

          wsl = true;

          users = [ "paperdev" ];

          stateVersion = "24.11";
        };
      };

      formatter."${system}" = pkgs.nixpkgs-fmt;
    };
}
