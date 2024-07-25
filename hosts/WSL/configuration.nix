{ inputs
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
  programs.ssh.startAgent = true;
}
