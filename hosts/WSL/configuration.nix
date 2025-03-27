{
  inputs,
  pkgs,
  paths,
  primaryUser,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    (paths.module "locale")
  ];

  wsl.enable = true;
  wsl.defaultUser = primaryUser;

  # usbip support through WSL
  services.udev.enable = true;

  environment.systemPackages = [
    pkgs.wget
  ];
}
