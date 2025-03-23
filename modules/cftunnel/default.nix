{ config
, lib
, primaryUser
, ...
}:
let
  inherit (builtins)
    mapAttrs;

  inherit (lib)
    mapAttrs'
    mkIf
    mkEnableOption
    mkOption
    mkForce
    nameValuePair
    types;

  opts = config.modules.cftunnel;
in
{
  options.modules.cftunnel = {
    enable = mkEnableOption "cloudflare tunnel";

    tunnels = mkOption {
      type = with types; attrsOf (submodule (
        { name, ... }: {
          options = {
            active = mkOption {
              type = bool;
              default = true;
              description = "whether to activate the systemd service automatically.";
            };

            ingress = mkOption {
              type = attrs;
              default = { };
              description = "see services.cloudflared.tunnels.<name>.ingress";
            };
          };
        }
      ));
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
          (name: tunnel: {
            credentialsFile = "${homeDir}/.cloudflared/${name}.json";
            default = "http_status:404";
            inherit (tunnel) ingress;
          })
          opts.tunnels);
      };

    systemd.services = (mapAttrs'
      (name: config: nameValuePair "cloudflared-tunnel-${name}" (mkIf (!config.active) {
        wantedBy = mkForce [ ];
      }))
      opts.tunnels);
  };
}
