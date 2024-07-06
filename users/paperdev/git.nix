{ ... }:
{
  programs.git = {
    enable = true;

    userName = "paperdev-code";
    userEmail = "51487819+paperdev-code@users.noreply.github.com";

    difftastic.enable = true;

    extraConfig = {
      init.defaultBranch = "main";

      url = {
        "https://github.com/".insteadOf = [ "github:" ];
        "https://gitlab.com/".insteadOf = [ "gitlab:" ];
      };
    };
  };
}
