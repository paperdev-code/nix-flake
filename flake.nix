{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
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

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };

      lib = import ./lib {
        inherit nixpkgs self;
      };
    in
    {
      nixosConfigurations = lib.nixos.mkSystems {
        "AIVD-Mainframe-WSL" = {
          system = "x86_64-linux";
          derivedFromHost = "WSL";
          users = [ "paperdev" ];
          stateVersion = "24.11";
        };
      };

      formatter."${system}" = pkgs.nixpkgs-fmt;
    };
}
