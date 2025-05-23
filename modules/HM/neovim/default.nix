{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (builtins)
    mapAttrs
    readFile
    fromJSON
    attrValues
    ;

  inherit (lib)
    mkIf
    mkEnableOption
    ;

  plugins =
    (mapAttrs (
      name: meta:
      (pkgs.vimUtils.buildVimPlugin {
        inherit name;
        src = pkgs.fetchzip {
          inherit (meta) url hash;
        };
      }).overrideAttrs
        { doCheck = false; }
    ) (fromJSON (readFile ./plugins.json)))
    // {
      nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
        p: with p; [
          c
          cpp
          lua
          nix
          python
          zig
          vimdoc
          nu
        ]
      );
    };

  opts = config.hm-modules.neovim;
in
{
  options.hm-modules.neovim = {
    enable = mkEnableOption "neovim with dotfiles and plugins";
  };

  config = mkIf opts.enable {
    home.packages = with pkgs; [
      nil
      lua-language-server
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true; # 4559

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins = attrValues plugins;
    };

    home.file.".config/nvim/init.lua" = {
      source = ./init.lua;
    };

    #4559
    hm-modules.nushell.envVars = {
      EDITOR = "nvim";
    };
  };
}
