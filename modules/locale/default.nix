{ config
, lib
, ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types;

  opts = config.modules.locale;
in
{
  options.modules.locale = {
    enable = mkEnableOption "locale management";

    timeZone = mkOption {
      type = types.str;
    };

    lcPrefix = mkOption {
      type = types.str;
    };
  };

  config = mkIf opts.enable {
    time.timeZone = opts.timeZone;

    i18n = {
      defaultLocale = "en_US.UTF-8";

      extraLocaleSettings = {
        LC_ADDRESS = "${opts.lcPrefix}.UTF-8";
        LC_IDENTIFICATION = "${opts.lcPrefix}.UTF-8";
        LC_MEASUREMENT = "${opts.lcPrefix}.UTF-8";
        LC_MONETARY = "${opts.lcPrefix}.UTF-8";
        LC_NAME = "${opts.lcPrefix}.UTF-8";
        LC_NUMERIC = "${opts.lcPrefix}.UTF-8";
        LC_TELEPHONE = "${opts.lcPrefix}.UTF-8";
        LC_TIME = "${opts.lcPrefix}.UTF-8";
      };
    };
  };
}
