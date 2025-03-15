{ fetchFromGitHub
, linuxManualConfig
}:
let
  tag = "6.6.75.1";
in
linuxManualConfig rec {
  version = "${tag}-wsl";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "WSL2-Linux-Kernel";
    rev = "linux-msft-wsl-${tag}";
    hash = "sha256-5uIs+bwIwV0KIvDclLL14sw4Xu50v6vI+U78uhChijI=";
  };

  allowImportFromDerivation = true;
  configfile = "${src}/Microsoft/config-wsl";
  modDirVersion = "${tag}-microsoft-standard-WSL2";
}
