{
  lib,
  self,
  nixpkgs,
}:
let
  inherit (builtins) mapAttrs elemAt;
  inherit (lib) paths;
in
{
  mkSystems =
    configs:
    mapAttrs (
      hostname: conf:
      nixpkgs.lib.nixosSystem rec {
        inherit (conf) system;

        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        specialArgs = {
          inherit (conf) stateVersion;
          inherit (self) inputs outputs;
          inherit paths;
          primaryUser = (elemAt conf.users 0);
        };

        modules = [
          self.inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
            };

            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];

            networking.hostName = hostname;
            system.stateVersion = conf.stateVersion;
          }
          (paths.host hostname)
        ] ++ (paths.users conf.users);
      }
    ) configs;
}
