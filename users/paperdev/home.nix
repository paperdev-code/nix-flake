{ stateVersion
, paths
, pkgs
, ...
}:
{
  imports = [
    ./git.nix
    (paths.module "HM/nushell")
    (paths.module "HM/neovim")
  ];

  home.username = "paperdev";
  home.homeDirectory = "/home/paperdev";

  hm-modules = {
    nushell.enable = true;
    neovim.enable = true;
  };

  programs = {
    home-manager.enable = true;
    lazygit.enable = true;
  };

  home.packages = with pkgs; [
    fastfetch
    trash-cli
    lazydocker
  ];

  home.stateVersion = stateVersion;
}

