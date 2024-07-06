{ nixpkgs
, self
}:
let
  lib = {
    nixos = import ./nixos.nix { inherit self lib nixpkgs; };
    paths = import ./paths.nix { inherit lib; };
  };
in
lib

