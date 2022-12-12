{pkgs, config, ... }:
let
  user = config.krebs.build.user.name;
  window-manager = "awesome";
in
  {
  systemd.services.look-up = {
    startAt = "*:30";
    serviceConfig = {
      ExecStart= pkgs.writeDash "look-up" ''
        set -x
        eval "export '$(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(${pkgs.procps}/bin/pgrep -u ${user} ${window-manager})/environ)'"
        ${pkgs.libnotify}/bin/notify-send -u critical -t 9999999 'look up once in a while'
      '';
      User = user;
    };
  };
}
