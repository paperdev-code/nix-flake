{ pkgs
, ...
}:
let
  inherit (builtins) readFile;
in
{
  programs.direnv =
    {
      enable = true;
      nix-direnv.enable = true;
    };

  programs.nushell =
    {
      enable = true;

      package = pkgs.nushell;

      configFile.text = (readFile ./config.nu);

      envFile.text = (readFile ./env.nu);
    };

  programs.zoxide.enable = true;

  programs.oh-my-posh = {
    enable = true;
    useTheme = "pure";
  };
}
