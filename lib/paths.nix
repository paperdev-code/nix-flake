{
  lib,
}:
let
  inherit (builtins) mapAttrs pathExists;
  validatePath = path: if pathExists path then path else abort "error: path '${path}' not found.";
  flake_root = "${(./..)}";
in
(mapAttrs
  (
    func_name: dir: sub_path:
    validatePath ("${flake_root}/${dir}/${sub_path}")
  )
  {
    root = ".";
    host = "hosts";
    user = "users";
    module = "modules";
  }
)
// {
  users = dirs: (map (dir: (lib.paths.user dir)) dirs);
  modules = dirs: (map (dir: (lib.paths.module dir)) dirs);
}
