{ paths
, ...
}:
{
  imports = (paths.modules
    [
      "locale"
    ]);

  # usbip support through WSL
  services.udev.enable = true;
}
