{ inputs
, pkgs
, paths
, primaryUser
, ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    (paths.module "locale")
  ];

  wsl.enable = true;
  wsl.defaultUser = primaryUser;

  modules.locale = {
    enable = true;
    timeZone = "Europe/Amsterdam";
    lcPrefix = "nl_NL";
  };

  # usbip support through WSL
  services.udev.enable = true;

  # start ssh-agent as a systemd service
  # FIXME: (Microsoft broke this)
  # programs.ssh.startAgent = true;

  # run foreign binaries on Nix
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  # docker
  virtualisation.docker.enable = true;

  environment.systemPackages = [
    pkgs.wget
  ];
}
