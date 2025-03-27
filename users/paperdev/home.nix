{
  stateVersion,
  paths,
  pkgs,
  ...
}:
{
  imports = [
    ./git.nix
    (paths.module "HM/nushell")
    (paths.module "HM/neovim")
    (paths.module "registry")
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
    systemctl-tui
    lazydocker
  ];

  modules.registry = {
    "zls" = "github:zigtools/zls";
    "zig" = "github:mitchellh/zig-overlay";
  };

  home.stateVersion = stateVersion;
}
