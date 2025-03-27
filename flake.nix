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

    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems = {
      url = "github:nix-systems/x86_64-linux";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt,
      ...
    }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      lib = import ./lib {
        inherit nixpkgs self;
      };

      treefmtEval = eachSystem (pkgs: treefmt.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      inherit lib;

      nixosModules = nixpkgs.lib.genAttrs [
        "cftunnel"
        "locale"
        "registry"
      ] (name: lib.paths.module name);

      hmModules = nixpkgs.lib.genAttrs [
        "neovim"
        "nushell"
      ] (name: lib.paths.module "HM/${name}");

      nixosConfigurations = lib.nixos.mkSystems {
        AIVD-Mainframe-WSL = {
          system = "x86_64-linux";
          users = [ "paperdev" ];
          stateVersion = "24.11";
        };
      };

      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
    };
}
