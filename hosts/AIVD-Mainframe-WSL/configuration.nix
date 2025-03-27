{
  pkgs,
  paths,
  ...
}:
{
  imports = [
    (paths.host "WSL")
    (paths.module "cftunnel")
  ];

  # start ssh-agent as a systemd service
  # FIXME: (Microsoft broke this)
  # programs.ssh.startAgent = true;

  modules.locale = {
    enable = true;
    timeZone = "Europe/Amsterdam";
    lcPrefix = "nl_NL";
  };

  modules.cftunnel = {
    enable = true;
    tunnels = {
      "AIVD_Mainframe_WSL" = {
        active = false;
        ingress = { };
      };
    };
  };

  # run foreign binaries on Nix
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  # docker
  virtualisation.docker = {
    enable = true;
    # setSocketVariable = true;
  };
}
