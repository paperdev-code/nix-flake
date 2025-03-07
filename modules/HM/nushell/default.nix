{ config
, lib
, pkgs
, ...
}:
let
  inherit (builtins)
    attrValues
    concatStringsSep
    fromJSON
    mapAttrs
    readFile;

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    mkMerge
    types;

  opts = config.hm-modules.nushell;
in
{
  options.hm-modules.nushell = {
    enable = mkEnableOption "nushell integration";

    withDirenv = mkOption {
      type = types.bool;
      default = true;
    };

    withAutojump = mkOption {
      type = types.bool;
      default = true;
    };

    envVars = mkOption {
      type = with types; attrsOf str;
      default = { };
    };
  };

  config = mkIf opts.enable (mkMerge [
    {
      programs.nushell = {
        enable = true;
        package = pkgs.nushell;
        configFile.text = (readFile ./config.nu);
        envFile.text = (readFile ./env.nu) + ''
          ${concatStringsSep "\n" (attrValues (mapAttrs (k: v: "$env.${k} = \"${v}\"" ) opts.envVars))}
        '';
      };

      programs.oh-my-posh = {
        enable = true;
        settings = (fromJSON (readFile ./omp.json));
      };
    }

    (mkIf opts.withDirenv {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    })

    (mkIf opts.withAutojump {
      programs.zoxide.enable = true;
    })
  ]);
}
