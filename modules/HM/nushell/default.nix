{ config
, lib
, pkgs
, ...
}:
let
  inherit (builtins) readFile;
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
  };

  config = mkIf opts.enable (mkMerge [
    {
      programs.nushell = {
        enable = true;
        package = pkgs.nushell;
        configFile.text = (readFile ./config.nu);
        envFile.text = (readFile ./env.nu);
      };

      programs.oh-my-posh = {
        enable = true;
        useTheme = "pure";
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
