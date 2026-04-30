{ pkgs, config, inputs, ... }:
let
  mainUser = config.krebs.build.user.name;
  #noctalia-shell = inputs.noctalia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  pkg = pkgs.noctalia-shell;
in {
  home-manager.users.${mainUser} = {
    imports = [ inputs.noctalia-shell.homeModules.default ];

    programs.noctalia-shell = {
      enable = true;
      package = pkg;
      settings = {};
    };

    systemd.user.services.noctalia-shell = {
      Unit = {
        Description = "Noctalia Shell - Wayland desktop shell";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkg}/bin/noctalia-shell";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
