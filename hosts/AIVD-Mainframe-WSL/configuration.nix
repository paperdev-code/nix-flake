{ paths
, ...
}:
{
  imports = [
    (paths.module "locale")
  ];

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
