{ pkgs
, ...
}:
{
  config = {
    users.users.paperdev = {
      isNormalUser = true;
      description = "Jorn Veken";
      extraGroups = [
        "wheel"
        "plugdev"
      ];

      shell = pkgs.nushell;
    };

    home-manager.users.paperdev = import ./home.nix;
  };
}
