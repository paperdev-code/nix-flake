{ config
, pkgs
, lib
, ...
}:
let
  inherit (builtins)
    mapAttrs
    readFile
    fromJSON;

  inherit (lib)
    mkIf
    mkEnableOption;

  plugins =
    (mapAttrs
      (name: meta: (pkgs.vimUtils.buildVimPlugin {
        inherit name;
        src = pkgs.fetchzip {
          inherit (meta) url hash;
        };
      }))
      (fromJSON (readFile ./plugins.json)))
    // {
      nvim-treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
        c
        cpp
        lua
        nix
        python
        zig
        vimdoc
        nu
      ]);
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
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins = with plugins; [
        catppuccin
        gitsigns-nvim
        indent-blankline-nvim
        mini-nvim
        nvim-lspconfig
        nvim-web-devicons
        persistence-nvim
        toggleterm-nvim
        which-key-nvim
        nvim-treesitter
        luasnip
        nvim-cmp
        cmp-nvim-lsp
        lspkind-nvim
      ];
    };

    home.file.".config/nvim/init.lua" = {
      source = ./init.lua;
    };
  };
}
