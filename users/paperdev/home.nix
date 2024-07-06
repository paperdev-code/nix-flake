{ stateVersion
, paths
, pkgs
, ...
}:
{
  imports =
    [
      ./git.nix
      (paths.module "HM/nushell")
    ];

  home.username = "paperdev";
  home.homeDirectory = "/home/paperdev";

  programs =
    {
      home-manager.enable = true;
      lazygit.enable = true;
    };

  home.packages = with pkgs;
    [
      fastfetch
      trash-cli
    ];

  home.stateVersion = stateVersion;
}

