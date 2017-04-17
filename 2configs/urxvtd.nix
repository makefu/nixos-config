{ config, pkgs, ... }:

let
	mainUser = config.krebs.build.user.name;
in {
  systemd.services.urxvtd = {
    wantedBy = [ "multi-user.target" ];
    before = [ "graphical.target" ];
    reloadIfChanged = true;
    serviceConfig = {
      SyslogIdentifier = "urxvtd";
      ExecReload = "${pkgs.coreutils}/bin/echo NOP";
      ExecStart = "${pkgs.rxvt_unicode_with-plugins}/bin/urxvtd";
      Restart = "always";
      RestartSec = "2s";
      StartLimitBurst = 0;
      User = mainUser;
    };
  };
	# TODO: sessionCommands from base-gui related to urxvt in this file
}
