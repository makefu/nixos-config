{ config, lib, pkgs, ... }:

# stuff for the main laptop
# this is pretty much nice-to-have and does
# not fit into base-gui
# TODO split generic desktop stuff and laptop-specifics like lidswitching

with import <stockholm/lib>;
let
  window-manager = "awesome";
  user = config.krebs.build.user.name;
in {
  imports = [
    ./gui/base.nix
    # ./gui/look-up.nix
    ./fetchWallpaper.nix
    ./zsh-user.nix
    ./tools/core.nix
    ./tools/core-gui.nix
    ./gui/automatic-diskmount.nix
  ];

  users.users.${config.krebs.build.user.name}.extraGroups = [ "dialout" ];

  krebs.power-action = let
    #speak = "XDG_RUNTIME_DIR=/run/user/$(id -u) ${pkgs.espeak}/bin/espeak"; # when run as user
    speak = "${pkgs.espeak}/bin/espeak"; # systemwide pulse
    whisper = text: ''${speak} -v +whisper -s 110 "${text}"'';

    note = pkgs.writeDash "note-as-user" ''
      eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(${pkgs.procps}/bin/pgrep -u ${user} ${window-manager})/environ)"
      ${pkgs.libnotify}/bin/notify-send "$@";
    '';
  in {
    enable = true;
    inherit user;
    plans.low-battery = {
      upperLimit = 25;
      lowerLimit = 15;
      charging = false;
      action = pkgs.writeDash "low-speak" ''
        ${whisper "power level low, please plug me in"}
      '';
    };
    plans.nag-harder = {
      upperLimit = 15;
      lowerLimit = 5;
      charging = false;
      action = pkgs.writeDash "crit-speak" ''
        ${note} Battery -u critical -t 60000 "Power level critical, do something!"
        ${whisper "Power level critical, do something"}
      '';
    };
    plans.last-chance = {
      upperLimit = 5;
      lowerLimit = 3;
      charging = false;
      action = pkgs.writeDash "suspend-wrapper" ''
        ${note} Battery -u crit "You've had your chance, suspend in 5 seconds"
        ${concatMapStringsSep "\n" (i: ''
            ${note} -u critical -t 1000 ${toString i}
            ${speak} ${toString i} &
            sleep 1
          '')
          [ 5 4 3 2 1 ]}
        /var/run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl suspend
      '';
    };
  };
  security.sudo.extraConfig = "${config.krebs.power-action.user} ALL= (root) NOPASSWD: ${pkgs.systemd}/bin/systemctl suspend";

  location.latitude = 48.7;
  location.longitude = 9.1;

}
