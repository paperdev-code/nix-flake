{ config
, lib
, ...
}:
let
  inherit (builtins)
    split
    head
    elemAt
    mapAttrs;

  parseFlake = alias: flake:
    let
      type_src = split ":" flake;
      type = head type_src;
      src = elemAt type_src 2;
      owner_repo = split "/" src;
      owner = head owner_repo;
      repo = elemAt owner_repo 2;
    in
    {
      from = {
        id = alias;
        type = "indirect";
      };
      to = {
        inherit type owner repo;
      };
    };

  inherit (lib)
    mkOption
    types;

  opts = config.modules.registry;
in
{
  options.modules.registry = mkOption {
    type = with types; attrsOf str;
    default = { };
  };

  config = {
    nix.registry = mapAttrs (alias: flake: parseFlake alias flake) opts;
  };
}
