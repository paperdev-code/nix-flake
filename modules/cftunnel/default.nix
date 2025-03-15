{ config
, lib
, primaryUser
, ...
}:
let
  inherit (builtins)
    mapAttrs;

  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types;

  opts = config.modules.cftunnel;
in
{
  options.modules.cftunnel = {
    enable = mkEnableOption "cloudflare tunnel";

    tunnels = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf opts.enable {
    services.cloudflared =
      let
        homeDir = config.users.users."${primaryUser}".home;
      in
      {
        enable = true;
        tunnels = (mapAttrs
          (name: ingress: {
            credentialsFile = "${homeDir}/.cloudflared/${name}.json";
            default = "http_status:404";
            inherit ingress;
          })
          opts.tunnels);
      };
  };
}
