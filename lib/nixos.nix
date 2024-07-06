{ lib
, self
, nixpkgs
}:
let
  inherit (builtins) mapAttrs map elemAt;
  inherit (lib) paths;
  inherit (nixpkgs.lib) mkIf;
in
{
  mkSystems = configs:
    mapAttrs
      (hostname: conf: nixpkgs.lib.nixosSystem rec {
        inherit (conf) system pkgs;

        specialArgs = {
          inherit (conf) stateVersion;
          inherit (self) inputs outputs;
          inherit paths;
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
        ] ++ (if (conf.wsl or false) then [
          # preferably this is not here,
          # WSL as module,
          # but i'll have to figure out the `wsl.defaultUser` thing.
          self.inputs.nixos-wsl.nixosModules.wsl
          {
            wsl.enable = true;
            wsl.defaultUser = "${(elemAt conf.users 0)}";
          }
        ] else [ ]) ++ (paths.users conf.users);
      })
      configs;
}
