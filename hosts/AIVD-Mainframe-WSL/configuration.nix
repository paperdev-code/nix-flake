{ paths
, ...
}:
{
  imports = [
      (paths.module "locale")
  ];

  # usbip support through WSL
  services.udev.enable = true;

  # start ssh-agent as a systemd service
  programs.ssh.startAgent = true;
}
